#!/usr/bin/env bash
# Agent runner for twelve-factor-docker
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-docker"
AGENTS_DIR="$SKILL_DIR/agents"

source "$SKILL_DIR/scripts/bus.sh"

MODE="${1:-run}"
MAX_AGENTS="${AGENTS_MAX:-4}"

echo "=== Running Agents (mode: $MODE) ==="

# Discover agents
AGENTS=()
for agent in "$AGENTS_DIR"/agent.*.sh; do
  [[ -f "$agent" ]] && [[ -x "$agent" ]] && AGENTS+=("$agent")
done

if [[ ${#AGENTS[@]} -eq 0 ]]; then
  echo "No agents found"
  exit 0
fi

echo "Found ${#AGENTS[@]} agents"

# Run agents
for agent in "${AGENTS[@]}"; do
  echo "Running: $(basename "$agent")"
  bash "$agent" "$MODE" &
done

wait
echo "✓ All agents complete"
