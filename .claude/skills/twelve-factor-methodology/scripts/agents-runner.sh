#!/usr/bin/env bash
# Parallel micro-agents runner for twelve-factor methodology
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"
AGENTS_DIR="$SKILL_DIR/agents"

source "$SKILL_DIR/scripts/bus.sh"

MODE="${1:-audit}"
MAX_AGENTS="${AGENTS_MAX:-4}"

echo "=== Running Micro-Agents (mode: $MODE, max: $MAX_AGENTS) ==="

# ============================================================================
# Discover agents
# ============================================================================
AGENTS=()
for agent in "$AGENTS_DIR"/agent.*.sh; do
  [[ -f "$agent" ]] || continue
  [[ -x "$agent" ]] || continue

  # Filter by mode if agent specifies it
  AGENT_MODES=$(grep "^# MODES:" "$agent" | cut -d: -f2 || echo "all")
  if [[ "$AGENT_MODES" == *"all"* ]] || [[ "$AGENT_MODES" == *"$MODE"* ]]; then
    AGENTS+=("$agent")
  fi
done

if [[ ${#AGENTS[@]} -eq 0 ]]; then
  echo "No agents found for mode: $MODE"
  exit 0
fi

echo "Found ${#AGENTS[@]} agents:"
for agent in "${AGENTS[@]}"; do
  echo "  - $(basename "$agent")"
done

# ============================================================================
# Run agents in parallel with concurrency control
# ============================================================================
run_agent() {
  local agent="$1"
  local agent_name=$(basename "$agent" .sh)

  echo "[$(date +%H:%M:%S)] Starting $agent_name..."

  # Publish start event
  publish_event "agent.$agent_name.start" "{\"agent\":\"$agent_name\",\"mode\":\"$MODE\"}"

  # Run agent with timeout
  if timeout 120s bash "$agent" "$MODE" 2>&1; then
    publish_event "agent.$agent_name.complete" "{\"agent\":\"$agent_name\",\"status\":\"success\"}"
    echo "[$(date +%H:%M:%S)] ✓ $agent_name complete"
  else
    publish_event "agent.$agent_name.complete" "{\"agent\":\"$agent_name\",\"status\":\"failed\"}"
    echo "[$(date +%H:%M:%S)] ✗ $agent_name failed"
  fi
}

# Track running agents
PIDS=()
ACTIVE=0

for agent in "${AGENTS[@]}"; do
  # Wait if at capacity
  while [[ $ACTIVE -ge $MAX_AGENTS ]]; do
    wait -n 2>/dev/null || true
    ACTIVE=$((ACTIVE - 1))
  done

  # Start agent in background
  run_agent "$agent" &
  PIDS+=($!)
  ACTIVE=$((ACTIVE + 1))

  # Small delay to avoid thundering herd
  sleep 0.1
done

# Wait for all agents
echo ""
echo "Waiting for all agents to complete..."
wait

echo ""
echo "=== All Agents Complete ==="

# Summary from bus
echo ""
echo "=== Results Summary ==="
read_events "agent\\..*\\.complete" "${#AGENTS[@]}"

exit 0
