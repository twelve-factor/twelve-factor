#!/usr/bin/env bash
# Twelve-Factor Methodology Skill - Main Entry Point
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"
source "$SKILL_DIR/scripts/bus.sh"

# Load environment
if [[ -f "$SKILL_DIR/templates/skill.env.example" ]]; then
  set -a
  source "$SKILL_DIR/templates/skill.env.example" 2>/dev/null || true
  set +a
fi

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
    analyze|assessment|audit)
      echo "=== Twelve-Factor Compliance Analysis ==="
      publish_event "skill.start" "{\"skill\":\"twelve-factor-methodology\",\"task\":\"$task\"}"

      # Run environment check
      bash "$SKILL_DIR/scripts/env-check.sh"

      # Trigger parallel agents for deep analysis
      if [[ "${ENABLE_AGENTS:-1}" == "1" ]]; then
        bash "$SKILL_DIR/scripts/agents-runner.sh" audit
      fi

      # Collect results from bus
      echo ""
      echo "=== Analysis Complete ==="
      read_events "agent\\..*\\.result" 10

      publish_event "skill.complete" "{\"skill\":\"twelve-factor-methodology\",\"task\":\"$task\",\"status\":\"success\"}"
      ;;

    check|validate)
      echo "=== Quick Compliance Check ==="
      publish_event "skill.start" "{\"skill\":\"twelve-factor-methodology\",\"task\":\"$task\"}"

      # Quick validation without agents
      bash "$SKILL_DIR/scripts/env-check.sh" --quick

      publish_event "skill.complete" "{\"skill\":\"twelve-factor-methodology\",\"task\":\"$task\",\"status\":\"success\"}"
      ;;

    remediate|fix)
      echo "=== Compliance Remediation ==="
      echo "⚠ This will modify your codebase. Continue? (y/N)"
      read -r confirm
      [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Cancelled"; exit 0; }

      publish_event "skill.start" "{\"skill\":\"twelve-factor-methodology\",\"task\":\"remediate\"}"

      # Would trigger remediation agents
      echo "Running remediation agents..."
      bash "$SKILL_DIR/scripts/agents-runner.sh" remediate

      publish_event "skill.complete" "{\"skill\":\"twelve-factor-methodology\",\"task\":\"remediate\",\"status\":\"success\"}"
      ;;

    monitor|watch)
      echo "=== Continuous Compliance Monitoring ==="
      publish_event "skill.start" "{\"skill\":\"twelve-factor-methodology\",\"task\":\"monitor\"}"

      # Monitor mode: periodic checks
      while true; do
        bash "$SKILL_DIR/scripts/env-check.sh" --quick
        sleep 60
      done
      ;;

    docs|documentation)
      echo "=== Generate Documentation ==="
      bash "$SKILL_DIR/hooks/post-skill-run.d/10-docs-update.sh"
      cat "$ROOT/context/docs/INDEX.md"
      ;;

    selftest|test)
      bash "$SKILL_DIR/scripts/self-test.sh" "$@"
      ;;

    help|*)
      cat <<HELP
Twelve-Factor Methodology Skill

Usage: skill-run.sh <task> [options]

Tasks:
  analyze, audit       Full compliance analysis with parallel agents
  check, validate      Quick compliance check
  remediate, fix       Auto-fix compliance violations
  monitor, watch       Continuous compliance monitoring
  docs                 Update and show documentation index
  selftest            Run skill self-test
  help                Show this help

Environment Variables:
  BUS_BACKEND         Backend: json|sqlite|redis|graph (default: json)
  SKIP_HOOKS          Skip hooks if set to 1
  FAST                Fast mode (minimal checks)
  AGENTS_MAX          Max parallel agents (default: 4)
  ENABLE_AUTO_DOCS    Auto-update docs (default: 1)
  ENABLE_METRICS      Emit metrics (default: 1)

Examples:
  # Full audit
  ./skill-run.sh analyze

  # Quick check
  ./skill-run.sh check

  # Fix violations
  ./skill-run.sh remediate

  # Self-test
  ./skill-run.sh selftest
HELP
      exit 0
      ;;
  esac
}

# ============================================================================
# Main execution with error handling
# ============================================================================
trap 'EXIT_CODE=$?; echo "Task failed with code $EXIT_CODE" >&2' ERR

run_task "$TASK" "$@"

# Post-execution hooks (non-blocking)
for hook in "$SKILL_DIR/hooks/post-skill-run.d/"*.sh; do
  [[ -x "$hook" ]] || continue
  ( timeout 15s bash "$hook" "$TASK" ) &
done

# Wait for hooks with timeout
sleep 1

DURATION=$((SECONDS - START_TIME))
echo ""
echo "✓ Task complete in ${DURATION}s"

exit 0
