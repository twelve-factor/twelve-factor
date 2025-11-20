#!/usr/bin/env bash
# Main entry point for twelve-factor-docker
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-docker"
source "$SKILL_DIR/scripts/bus.sh"

TASK="${1:-help}"
shift || true

START_TIME=$SECONDS

# ============================================================================
# Task execution
# ============================================================================
run_task() {
  local task="$1"
  shift

  case "$task" in
    run|execute)
      echo "=== twelve-factor-docker: Execute ==="
      publish_event "twelve-factor-docker.start" '{"task":"run"}'

      # TODO: Add your skill logic here
      echo "Running twelve-factor-docker..."

      # Run agents if enabled
      if [[ "${ENABLE_AGENTS:-1}" == "1" ]]; then
        bash "$SKILL_DIR/scripts/agents-runner.sh" run
      fi

      publish_event "twelve-factor-docker.complete" '{"task":"run","status":"success"}'
      ;;

    check|validate)
      echo "=== twelve-factor-docker: Check ==="
      bash "$SKILL_DIR/scripts/env-check.sh"
      ;;

    selftest|test)
      bash "$SKILL_DIR/scripts/self-test.sh" "$@"
      ;;

    help|*)
      cat <<HELP
twelve-factor-docker

Usage: skill-run.sh <task> [options]

Tasks:
  run, execute     Execute primary skill function
  check, validate  Environment validation
  selftest, test   Run self-test
  help             Show this help

Environment:
  BUS_BACKEND      Backend: json|sqlite|redis|graph
  ENABLE_AGENTS    Enable agents (default: 1)
  SKIP_HOOKS       Skip hooks (default: 0)

Examples:
  ./skill-run.sh run
  ./skill-run.sh check
  ./skill-run.sh selftest
HELP
      exit 0
      ;;
  esac
}

# ============================================================================
# Main execution
# ============================================================================
trap 'EXIT_CODE=$?; echo "Task failed with code $EXIT_CODE" >&2' ERR

run_task "$TASK" "$@"

# Post-execution hooks
for hook in "$SKILL_DIR/hooks/post-skill-run.d/"*.sh; do
  [[ -x "$hook" ]] || continue
  ( timeout 15s bash "$hook" "$TASK" ) &
done

DURATION=$((SECONDS - START_TIME))
echo ""
echo "✓ Task complete in ${DURATION}s"

exit 0
