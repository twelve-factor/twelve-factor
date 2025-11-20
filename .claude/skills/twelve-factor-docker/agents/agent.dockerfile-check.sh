#!/usr/bin/env bash
# MODES: audit,run
# Dockerfile compliance checker for twelve-factor principles
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-docker"
source "$SKILL_DIR/scripts/bus.sh"

MODE="${1:-run}"

echo "[dockerfile-check] Analyzing Dockerfiles for twelve-factor compliance..."

# ============================================================================
# Find Dockerfiles
# ============================================================================
DOCKERFILES=()
while IFS= read -r -d '' file; do
  DOCKERFILES+=("$file")
done < <(find "$ROOT" -name "Dockerfile*" -type f -print0 2>/dev/null || true)

if [[ ${#DOCKERFILES[@]} -eq 0 ]]; then
  echo "[dockerfile-check] No Dockerfiles found"
  publish_event "agent.twelve-factor-docker.dockerfile-check.result" '{"status":"skipped","reason":"no_dockerfiles"}'
  exit 0
fi

echo "[dockerfile-check] Found ${#DOCKERFILES[@]} Dockerfile(s)"

# ============================================================================
# Check twelve-factor compliance
# ============================================================================
VIOLATIONS=()
PASSED=()

for dockerfile in "${DOCKERFILES[@]}"; do
  echo "[dockerfile-check] Checking: $dockerfile"

  # Factor II: Dependencies - Check for package manager lock files
  if grep -q "COPY package.json" "$dockerfile" 2>/dev/null; then
    if ! grep -q "COPY package-lock.json\|COPY yarn.lock\|COPY pnpm-lock.yaml" "$dockerfile"; then
      VIOLATIONS+=($(jq -cn \
        --arg file "$dockerfile" \
        '{
          "file": $file,
          "factor": "II. Dependencies",
          "severity": "warning",
          "issue": "package.json copied but no lock file",
          "recommendation": "COPY package-lock.json (or yarn.lock) for reproducible builds"
        }'))
    else
      PASSED+=($(jq -cn '{"factor": "II. Dependencies", "check": "lock_files"}'))
    fi
  fi

  # Factor III: Config - Check for hardcoded values
  if grep -E "ENV\s+(PASSWORD|SECRET|API_KEY|TOKEN)" "$dockerfile" 2>/dev/null; then
    VIOLATIONS+=($(jq -cn \
      --arg file "$dockerfile" \
      '{
        "file": $file,
        "factor": "III. Config",
        "severity": "critical",
        "issue": "Hardcoded secrets in ENV",
        "recommendation": "Use ARG with --build-arg or runtime env vars"
      }'))
  else
    PASSED+=($(jq -cn '{"factor": "III. Config", "check": "no_hardcoded_secrets"}'))
  fi

  # Factor VII: Port Binding - Check for EXPOSE
  if grep -q "^EXPOSE" "$dockerfile" 2>/dev/null; then
    PASSED+=($(jq -cn '{"factor": "VII. Port Binding", "check": "port_exposed"}'))
  else
    VIOLATIONS+=($(jq -cn \
      --arg file "$dockerfile" \
      '{
        "file": $file,
        "factor": "VII. Port Binding",
        "severity": "info",
        "issue": "No EXPOSE directive",
        "recommendation": "Add EXPOSE directive to document port"
      }'))
  fi

  # Factor IX: Disposability - Check for proper signal handling
  if grep -q "STOPSIGNAL" "$dockerfile" 2>/dev/null; then
    PASSED+=($(jq -cn '{"factor": "IX. Disposability", "check": "custom_stop_signal"}'))
  fi

  # Factor XI: Logs - Check for stdout/stderr
  if ! grep -qE ">/dev/null|>>.*\.log|tee.*\.log" "$dockerfile" 2>/dev/null; then
    PASSED+=($(jq -cn '{"factor": "XI. Logs", "check": "no_file_logging"}'))
  else
    VIOLATIONS+=($(jq -cn \
      --arg file "$dockerfile" \
      '{
        "file": $file,
        "factor": "XI. Logs",
        "severity": "warning",
        "issue": "File-based logging detected",
        "recommendation": "Log to stdout/stderr, let container runtime handle logs"
      }'))
  fi

  # Best Practice: Multi-stage builds
  if grep -q "^FROM.*AS" "$dockerfile" 2>/dev/null; then
    PASSED+=($(jq -cn '{"factor": "V. Build/Release/Run", "check": "multi_stage_build"}'))
  fi

  # Best Practice: Non-root user
  if grep -q "^USER" "$dockerfile" 2>/dev/null && ! grep -q "USER root" "$dockerfile"; then
    PASSED+=($(jq -cn '{"factor": "Security", "check": "non_root_user"}'))
  else
    VIOLATIONS+=($(jq -cn \
      --arg file "$dockerfile" \
      '{
        "file": $file,
        "factor": "Security",
        "severity": "warning",
        "issue": "Running as root",
        "recommendation": "Use USER directive to run as non-root"
      }'))
  fi
done

# ============================================================================
# Aggregate results
# ============================================================================
RESULT=$(jq -n \
  --argjson violations "$(printf '%s\n' "${VIOLATIONS[@]}" 2>/dev/null | jq -s '.' || echo '[]')" \
  --argjson passed "$(printf '%s\n' "${PASSED[@]}" 2>/dev/null | jq -s '.' || echo '[]')" \
  --argjson count "${#DOCKERFILES[@]}" \
  '{
    "dockerfiles_checked": $count,
    "violations": $violations,
    "passed_checks": $passed,
    "violation_count": ($violations | length),
    "passed_count": ($passed | length),
    "compliance_score": (if ($passed | length) + ($violations | length) > 0 then
      ($passed | length) / (($passed | length) + ($violations | length))
    else 1.0 end)
  }')

# Publish result
publish_event "agent.twelve-factor-docker.dockerfile-check.result" "$RESULT"

# Display summary
echo ""
echo "[dockerfile-check] Results:"
echo "$RESULT" | jq -r '"  Dockerfiles: \(.dockerfiles_checked)\n  Passed: \(.passed_count)\n  Violations: \(.violation_count)\n  Score: \(.compliance_score * 100 | floor)%"'

if [[ ${#VIOLATIONS[@]} -gt 0 ]]; then
  echo ""
  echo "[dockerfile-check] Violations:"
  echo "$RESULT" | jq -r '.violations[] | "  [\(.severity | ascii_upcase)] \(.factor): \(.issue)\n    → \(.recommendation)"'
fi

exit 0
