#!/usr/bin/env bash
# Micro-agent: Compliance Checker
# Specialized task: Check code for twelve-factor compliance violations
# Reads jobs from: twelve-factor.jobs.compliance
# Writes results to: twelve-factor.agents.results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/bus.sh"

AGENT_NAME="compliance-checker"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

log() {
    echo "[$(date -u +"%H:%M:%S")] [$AGENT_NAME] $*" >&2
}

check_hardcoded_credentials() {
    log "Checking for hardcoded credentials (Factor III)..."

    local violations=()

    # Search for common patterns of hardcoded secrets
    if grep -rn --include="*.js" --include="*.py" --include="*.rb" --include="*.go" --include="*.java" \
        -E "(password|api_key|secret|token|credential)\s*=\s*['\"][^'\"]{8,}['\"]" \
        "$PROJECT_ROOT" 2>/dev/null | \
        grep -v "process\.env\|os\.environ\|ENV\[" | \
        head -5; then
        violations+=("hardcoded_credentials")
    fi

    echo "${violations[@]:-}"
}

check_dependency_manifest() {
    log "Checking dependency manifests (Factor II)..."

    local findings=()

    [ -f "$PROJECT_ROOT/package.json" ] && findings+=("node:package.json")
    [ -f "$PROJECT_ROOT/requirements.txt" ] && findings+=("python:requirements.txt")
    [ -f "$PROJECT_ROOT/Pipfile" ] && findings+=("python:Pipfile")
    [ -f "$PROJECT_ROOT/Gemfile" ] && findings+=("ruby:Gemfile")
    [ -f "$PROJECT_ROOT/go.mod" ] && findings+=("go:go.mod")
    [ -f "$PROJECT_ROOT/pom.xml" ] && findings+=("java:pom.xml")
    [ -f "$PROJECT_ROOT/build.gradle" ] && findings+=("java:build.gradle")

    if [ ${#findings[@]} -eq 0 ]; then
        echo "missing"
    else
        echo "${findings[@]}"
    fi
}

check_file_logging() {
    log "Checking for file logging (Factor XI)..."

    local violations=()

    if grep -rn --include="*.js" --include="*.py" --include="*.rb" \
        -E "FileHandler|createWriteStream.*log|open\(['\"].*\.log" \
        "$PROJECT_ROOT" 2>/dev/null | \
        grep -v test | head -5; then
        violations+=("file_logging_detected")
    fi

    echo "${violations[@]:-}"
}

check_process_state() {
    log "Checking for process state issues (Factor VI)..."

    local violations=()

    # Check for in-memory session storage patterns
    if grep -rn --include="*.js" --include="*.py" --include="*.rb" \
        -E "session\[|express-session.*MemoryStore|Flask.*session" \
        "$PROJECT_ROOT" 2>/dev/null | \
        grep -v "redis\|memcached\|database" | head -5; then
        violations+=("in_memory_sessions")
    fi

    echo "${violations[@]:-}"
}

# Main agent loop
main() {
    log "Starting compliance checker agent..."

    # Run all checks
    local creds_violations=$(check_hardcoded_credentials)
    local deps_status=$(check_dependency_manifest)
    local logging_violations=$(check_file_logging)
    local state_violations=$(check_process_state)

    # Calculate scores
    local total_checks=4
    local passed=0

    [ -z "$creds_violations" ] && ((passed++))
    [ "$deps_status" != "missing" ] && ((passed++))
    [ -z "$logging_violations" ] && ((passed++))
    [ -z "$state_violations" ] && ((passed++))

    local score=$((passed * 100 / total_checks))

    # Build result JSON
    local result=$(jq -n \
        --arg agent "$AGENT_NAME" \
        --arg status "completed" \
        --argjson score "$score" \
        --arg creds "$creds_violations" \
        --arg deps "$deps_status" \
        --arg logging "$logging_violations" \
        --arg state "$state_violations" \
        '{
            agent: $agent,
            status: $status,
            score: $score,
            violations: {
                hardcoded_credentials: ($creds != ""),
                missing_dependencies: ($deps == "missing"),
                file_logging: ($logging != ""),
                in_memory_state: ($state != "")
            },
            details: {
                credentials: $creds,
                dependencies: $deps,
                logging: $logging,
                state: $state
            }
        }')

    # Publish result to bus
    publish_event "twelve-factor.agents.results" "$result"

    log "Compliance check completed. Score: $score%"
    echo "$result"
}

# Execute
main "$@"
