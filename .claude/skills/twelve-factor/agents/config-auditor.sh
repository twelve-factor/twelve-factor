#!/usr/bin/env bash
# Micro-agent: Config Auditor
# Specialized task: Audit configuration management (Factor III)
# Reads jobs from: twelve-factor.jobs.config
# Writes results to: twelve-factor.agents.results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/bus.sh"

AGENT_NAME="config-auditor"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

log() {
    echo "[$(date -u +"%H:%M:%S")] [$AGENT_NAME] $*" >&2
}

find_env_files() {
    log "Scanning for environment files..."

    local env_files=()

    # Find .env files
    while IFS= read -r file; do
        env_files+=("$file")
    done < <(find "$PROJECT_ROOT" -name ".env*" -type f 2>/dev/null | head -10)

    printf '%s\n' "${env_files[@]:-}"
}

check_env_example() {
    log "Checking for .env.example..."

    if [ -f "$PROJECT_ROOT/.env.example" ]; then
        echo "present"
    else
        echo "missing"
    fi
}

check_config_files() {
    log "Checking for config files that should use env vars..."

    local issues=()

    # Check for common config files with hardcoded values
    local config_patterns=("config/*.yml" "config/*.yaml" "config/*.json" "config.js" "config.py")

    for pattern in "${config_patterns[@]}"; do
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                # Check if file contains credentials without env var references
                if grep -q -E "(password|secret|key|token).*[:=].*['\"][^'\"]+['\"]" "$file" 2>/dev/null; then
                    if ! grep -q "process\.env\|os\.environ\|ENV\[" "$file" 2>/dev/null; then
                        issues+=("$file")
                    fi
                fi
            fi
        done < <(find "$PROJECT_ROOT" -path "*/$pattern" 2>/dev/null | head -5)
    done

    printf '%s\n' "${issues[@]:-}"
}

check_gitignore() {
    log "Checking if .env is in .gitignore..."

    if [ -f "$PROJECT_ROOT/.gitignore" ]; then
        if grep -q "^\.env" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
            echo "protected"
        else
            echo "unprotected"
        fi
    else
        echo "no_gitignore"
    fi
}

analyze_env_usage() {
    log "Analyzing environment variable usage..."

    local env_count=0

    # Count env var usage in code
    env_count=$(grep -r --include="*.js" --include="*.py" --include="*.rb" --include="*.go" \
        -E "process\.env\.|os\.environ\[|ENV\[" \
        "$PROJECT_ROOT" 2>/dev/null | wc -l || echo "0")

    echo "$env_count"
}

# Main agent loop
main() {
    log "Starting config auditor agent..."

    # Run all checks
    local env_files=$(find_env_files | jq -R . | jq -s .)
    local env_example=$(check_env_example)
    local config_issues=$(check_config_files | jq -R . | jq -s .)
    local gitignore_status=$(check_gitignore)
    local env_usage=$(analyze_env_usage)

    # Determine status
    local status="ok"
    local recommendations=()

    [ "$env_example" = "missing" ] && recommendations+=("Create .env.example template")
    [ "$gitignore_status" != "protected" ] && recommendations+=("Add .env to .gitignore")
    [ $(echo "$config_issues" | jq 'length') -gt 0 ] && recommendations+=("Move hardcoded config to environment variables")

    [ ${#recommendations[@]} -gt 0 ] && status="needs_improvement"

    # Build result JSON
    local result=$(jq -n \
        --arg agent "$AGENT_NAME" \
        --arg status "$status" \
        --argjson env_files "$env_files" \
        --arg env_example "$env_example" \
        --argjson config_issues "$config_issues" \
        --arg gitignore "$gitignore_status" \
        --argjson env_usage "$env_usage" \
        --argjson recs "$(printf '%s\n' "${recommendations[@]:-}" | jq -R . | jq -s .)" \
        '{
            agent: $agent,
            status: $status,
            findings: {
                env_files: $env_files,
                env_example: $env_example,
                config_issues: $config_issues,
                gitignore_status: $gitignore,
                env_usage_count: $env_usage
            },
            recommendations: $recs
        }')

    # Publish result to bus
    publish_event "twelve-factor.agents.results" "$result"

    log "Config audit completed. Status: $status"
    echo "$result"
}

# Execute
main "$@"
