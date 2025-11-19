#!/usr/bin/env bash
# Micro-agent: Deployment Validator
# Specialized task: Validate deployment configuration (Factors V, X)
# Reads jobs from: twelve-factor.jobs.deployment
# Writes results to: twelve-factor.agents.results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/bus.sh"

AGENT_NAME="deployment-validator"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

log() {
    echo "[$(date -u +"%H:%M:%S")] [$AGENT_NAME] $*" >&2
}

check_dockerfile() {
    log "Checking Dockerfile (Factor V: Build/Release/Run)..."

    local dockerfile="$PROJECT_ROOT/Dockerfile"
    local findings=()

    if [ ! -f "$dockerfile" ]; then
        echo "missing"
        return
    fi

    # Check for multi-stage build
    if grep -q "^FROM.*AS" "$dockerfile" 2>/dev/null; then
        findings+=("multi_stage:yes")
    else
        findings+=("multi_stage:no")
    fi

    # Check if builds at runtime (anti-pattern)
    if grep -E "npm install|pip install|bundle install" "$dockerfile" | \
       grep -v "^RUN" >/dev/null 2>&1; then
        findings+=("runtime_build:detected")
    fi

    printf '%s\n' "${findings[@]}"
}

check_docker_compose() {
    log "Checking docker-compose.yml (Factor X: Dev/Prod Parity)..."

    local compose_files=()

    [ -f "$PROJECT_ROOT/docker-compose.yml" ] && compose_files+=("docker-compose.yml")
    [ -f "$PROJECT_ROOT/docker-compose.yaml" ] && compose_files+=("docker-compose.yaml")
    [ -f "$PROJECT_ROOT/compose.yml" ] && compose_files+=("compose.yml")

    if [ ${#compose_files[@]} -eq 0 ]; then
        echo "missing"
        return
    fi

    # Check for different databases in different environments
    local dev_db=""
    local prod_db=""

    for file in "${compose_files[@]}"; do
        if grep -q "sqlite" "$PROJECT_ROOT/$file" 2>/dev/null; then
            dev_db="sqlite"
        fi
        if grep -q "postgres\|mysql\|mongodb" "$PROJECT_ROOT/$file" 2>/dev/null; then
            prod_db="production_db"
        fi
    done

    if [ -n "$dev_db" ] && [ -n "$prod_db" ]; then
        echo "parity_violation"
    else
        echo "ok"
    fi
}

check_ci_cd() {
    log "Checking CI/CD configuration..."

    local ci_files=()

    [ -f "$PROJECT_ROOT/.github/workflows"/*.yml ] && ci_files+=("github_actions")
    [ -f "$PROJECT_ROOT/.gitlab-ci.yml" ] && ci_files+=("gitlab_ci")
    [ -f "$PROJECT_ROOT/.circleci/config.yml" ] && ci_files+=("circle_ci")
    [ -f "$PROJECT_ROOT/Jenkinsfile" ] && ci_files+=("jenkins")

    if [ ${#ci_files[@]} -eq 0 ]; then
        echo "missing"
    else
        printf '%s\n' "${ci_files[@]}"
    fi
}

check_process_manager() {
    log "Checking for process manager (Factor IX: Disposability)..."

    local managers=()

    # Check package.json for process managers
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        if grep -q "pm2\|forever\|nodemon" "$PROJECT_ROOT/package.json" 2>/dev/null; then
            managers+=("node_pm")
        fi
    fi

    # Check for Procfile (Heroku/Foreman)
    [ -f "$PROJECT_ROOT/Procfile" ] && managers+=("procfile")

    # Check for systemd service
    if find "$PROJECT_ROOT" -name "*.service" -type f 2>/dev/null | grep -q .; then
        managers+=("systemd")
    fi

    if [ ${#managers[@]} -eq 0 ]; then
        echo "none_detected"
    else
        printf '%s\n' "${managers[@]}"
    fi
}

# Main agent loop
main() {
    log "Starting deployment validator agent..."

    # Run all checks
    local dockerfile_status=$(check_dockerfile | jq -R . | jq -s .)
    local compose_status=$(check_docker_compose)
    local ci_cd=$(check_ci_cd | jq -R . | jq -s .)
    local process_mgr=$(check_process_manager | jq -R . | jq -s .)

    # Determine overall status
    local status="ok"
    local recommendations=()

    [ "$dockerfile_status" = '["missing"]' ] && recommendations+=("Create Dockerfile with multi-stage build")
    [ "$compose_status" = "parity_violation" ] && recommendations+=("Use same database in dev and prod (Factor X)")
    [ "$compose_status" = "missing" ] && recommendations+=("Add docker-compose.yml for local development")
    [ "$ci_cd" = '[]' ] && recommendations+=("Set up CI/CD pipeline (Factor V)")
    [ "$process_mgr" = '["none_detected"]' ] && recommendations+=("Configure process manager (Factor IX)")

    [ ${#recommendations[@]} -gt 0 ] && status="needs_improvement"

    # Build result JSON
    local result=$(jq -n \
        --arg agent "$AGENT_NAME" \
        --arg status "$status" \
        --argjson dockerfile "$dockerfile_status" \
        --arg compose "$compose_status" \
        --argjson ci_cd "$ci_cd" \
        --argjson process_mgr "$process_mgr" \
        --argjson recs "$(printf '%s\n' "${recommendations[@]:-}" | jq -R . | jq -s .)" \
        '{
            agent: $agent,
            status: $status,
            findings: {
                dockerfile: $dockerfile,
                docker_compose: $compose,
                ci_cd: $ci_cd,
                process_manager: $process_mgr
            },
            recommendations: $recs
        }')

    # Publish result to bus
    publish_event "twelve-factor.agents.results" "$result"

    log "Deployment validation completed. Status: $status"
    echo "$result"
}

# Execute
main "$@"
