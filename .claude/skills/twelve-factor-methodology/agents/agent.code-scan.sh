#!/usr/bin/env bash
# MODES: audit,remediate
# Code scanner agent for twelve-factor anti-patterns
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"
source "$SKILL_DIR/scripts/bus.sh"

MODE="${1:-audit}"

# ============================================================================
# Anti-pattern detection
# ============================================================================
VIOLATIONS=()

# Check for hardcoded credentials
if grep -rn "password\s*=\s*['\"][^$]" --include="*.py" --include="*.js" --include="*.rb" "$ROOT" 2>/dev/null | head -5; then
  VIOLATIONS+=($(jq -cn '{
    "type": "hardcoded-credentials",
    "severity": "critical",
    "factor": "III. Config",
    "description": "Hardcoded credentials detected"
  }'))
fi

# Check for missing .env.example
if [[ ! -f "$ROOT/.env.example" ]] && [[ ! -f "$ROOT/.env.template" ]]; then
  VIOLATIONS+=($(jq -cn '{
    "type": "missing-env-template",
    "severity": "warning",
    "factor": "III. Config",
    "description": "No .env.example template found"
  }'))
fi

# Check for .env in git
if git ls-files "$ROOT/.env" 2>/dev/null | grep -q ".env"; then
  VIOLATIONS+=($(jq -cn '{
    "type": "env-in-git",
    "severity": "critical",
    "factor": "III. Config",
    "description": ".env file tracked in Git"
  }'))
fi

# Check for file-based session storage
if grep -rn "FileHandler\|RotatingFileHandler\|session.*filesystem" --include="*.py" --include="*.js" "$ROOT" 2>/dev/null | head -5; then
  VIOLATIONS+=($(jq -cn '{
    "type": "file-session-storage",
    "severity": "warning",
    "factor": "VI. Processes",
    "description": "File-based session storage detected"
  }'))
fi

# Check for file-based logging
if grep -rn "FileHandler\|createWriteStream.*log" --include="*.py" --include="*.js" "$ROOT" 2>/dev/null | head -5; then
  VIOLATIONS+=($(jq -cn '{
    "type": "file-logging",
    "severity": "warning",
    "factor": "XI. Logs",
    "description": "File-based logging detected"
  }'))
fi

# ============================================================================
# Aggregate and publish results
# ============================================================================
if [[ ${#VIOLATIONS[@]} -gt 0 ]]; then
  SCAN_RESULT=$(jq -s \
    '{"violations": ., "count": length, "critical": [.[] | select(.severity=="critical")] | length}' \
    <(printf '%s\n' "${VIOLATIONS[@]}"))
else
  SCAN_RESULT='{"violations": [], "count": 0, "critical": 0}'
fi

# Publish to bus
publish_event "agent.code-scan.result" "$SCAN_RESULT"

# Output summary
echo "$SCAN_RESULT" | jq -r '"Found \(.count) violations (\(.critical) critical)"'

exit 0
