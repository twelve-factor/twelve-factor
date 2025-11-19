#!/usr/bin/env bash
# Emit metrics after skill execution
set -euo pipefail

# Skip if disabled
[[ "${ENABLE_METRICS:-1}" == "0" ]] && exit 0

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"

# Timeout
TIMEOUT=5

timeout ${TIMEOUT}s bash -c '
  TASK="${1:-unknown}"

  # Gather metrics
  METRICS=$(jq -cn \
    --arg task "$TASK" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg skill "twelve-factor-methodology" \
    "{
      skill: \$skill,
      task: \$task,
      ts: \$ts,
      duration_sec: ${SECONDS:-0},
      exit_code: ${EXIT_CODE:-0}
    }")

  # Publish to bus
  if [[ -x "'"$SKILL_DIR"'/scripts/bus.sh" ]]; then
    source "'"$SKILL_DIR"'/scripts/bus.sh"
    publish_event "metrics.skill.run" "$METRICS"
  fi
' "$@" 2>&1 || true

exit 0
