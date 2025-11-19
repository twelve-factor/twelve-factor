#!/usr/bin/env bash
# MODES: audit,check
# Factor-by-factor compliance checker agent
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"
source "$SKILL_DIR/scripts/bus.sh"

MODE="${1:-audit}"

# ============================================================================
# Check each factor
# ============================================================================
check_factor_i_codebase() {
  local status="unknown"
  local details=""

  if git rev-parse --git-dir >/dev/null 2>&1; then
    status="pass"
    details="Git repository detected"
  else
    status="fail"
    details="Not a Git repository"
  fi

  echo "{\"factor\":\"I. Codebase\",\"status\":\"$status\",\"details\":\"$details\"}"
}

check_factor_ii_dependencies() {
  local status="unknown"
  local details=""
  local manifest_files=0

  for f in package.json requirements.txt Pipfile Gemfile go.mod Cargo.toml pom.xml; do
    [[ -f "$ROOT/$f" ]] && ((manifest_files++))
  done

  if [[ $manifest_files -gt 0 ]]; then
    status="pass"
    details="Dependency manifest found"
  else
    status="fail"
    details="No dependency manifest detected"
  fi

  echo "{\"factor\":\"II. Dependencies\",\"status\":\"$status\",\"details\":\"$details\",\"manifest_count\":$manifest_files}"
}

check_factor_iii_config() {
  local status="unknown"
  local details=""
  local issues=()

  # Check for .env.example
  if [[ -f "$ROOT/.env.example" ]] || [[ -f "$ROOT/.env.template" ]]; then
    status="pass"
    details="Config template found"
  else
    issues+=("No .env.example template")
  fi

  # Check if .env is gitignored
  if [[ -f "$ROOT/.env" ]] && ! git check-ignore "$ROOT/.env" >/dev/null 2>&1; then
    issues+=(".env not in .gitignore")
    status="fail"
  fi

  # Check for hardcoded credentials
  if grep -r "password\s*=\s*['\"][^$]" --include="*.py" --include="*.js" "$ROOT" 2>/dev/null | head -1 >/dev/null; then
    issues+=("Potential hardcoded credentials")
    status="fail"
  fi

  details="${issues[*]}"
  [[ -z "$details" ]] && details="Config properly externalized"

  echo "{\"factor\":\"III. Config\",\"status\":\"$status\",\"details\":\"$details\"}"
}

check_factor_v_build_release_run() {
  local status="unknown"
  local details=""
  local has_build=0

  for f in Dockerfile Makefile build.sh; do
    [[ -f "$ROOT/$f" ]] && ((has_build++))
  done

  if [[ $has_build -gt 0 ]]; then
    status="pass"
    details="Build configuration found"
  else
    status="warn"
    details="No explicit build configuration"
  fi

  echo "{\"factor\":\"V. Build,Release,Run\",\"status\":\"$status\",\"details\":\"$details\"}"
}

check_factor_vii_port_binding() {
  local status="unknown"
  local details=""

  if grep -r "PORT.*env\|port.*process\.env\|os\.environ.*PORT" "$ROOT" --include="*.js" --include="*.py" --include="*.rb" 2>/dev/null | head -1 >/dev/null; then
    status="pass"
    details="PORT env var usage detected"
  else
    status="warn"
    details="No PORT env var pattern found"
  fi

  echo "{\"factor\":\"VII. Port Binding\",\"status\":\"$status\",\"details\":\"$details\"}"
}

check_factor_x_dev_prod_parity() {
  local status="unknown"
  local details=""

  if [[ -f "$ROOT/docker-compose.yml" ]]; then
    status="pass"
    details="Docker Compose for dev parity"
  else
    status="warn"
    details="No docker-compose.yml for dev environment"
  fi

  echo "{\"factor\":\"X. Dev/Prod Parity\",\"status\":\"$status\",\"details\":\"$details\"}"
}

# ============================================================================
# Main execution
# ============================================================================
RESULTS=()
RESULTS+=($(check_factor_i_codebase))
RESULTS+=($(check_factor_ii_dependencies))
RESULTS+=($(check_factor_iii_config))
RESULTS+=($(check_factor_v_build_release_run))
RESULTS+=($(check_factor_vii_port_binding))
RESULTS+=($(check_factor_x_dev_prod_parity))

# Aggregate results
COMPLIANCE=$(jq -s \
  '{"factors": ., "total": length, "passed": [.[] | select(.status=="pass")] | length, "failed": [.[] | select(.status=="fail")] | length}' \
  <(printf '%s\n' "${RESULTS[@]}"))

# Publish to bus
publish_event "agent.factor-check.result" "$COMPLIANCE"

# Output summary
echo "$COMPLIANCE" | jq -r '"Compliance: \(.passed)/\(.total) factors passed"'

exit 0
