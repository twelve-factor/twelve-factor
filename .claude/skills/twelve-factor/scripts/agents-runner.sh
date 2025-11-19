#!/usr/bin/env bash
# Twelve-Factor Skill - Agents Runner
# Runs micro-agents in parallel for specialized tasks
# Performance budget: agents run in background, results via bus

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$SCRIPT_DIR/../agents"
source "$SCRIPT_DIR/bus.sh"

MAX_AGENTS="${AGENTS_MAX:-4}"
AGENTS=(
    "compliance-checker.sh"
    "config-auditor.sh"
    "deployment-validator.sh"
)

log() {
    echo "[$(date -u +"%H:%M:%S")] [agents-runner] $*"
}

run_agent() {
    local agent="$1"
    local agent_path="$AGENTS_DIR/$agent"

    if [ ! -x "$agent_path" ]; then
        log "⚠️  Agent $agent not executable, skipping..."
        return 1
    fi

    log "▶️  Starting agent: $agent"

    # Run agent in background with timeout
    (
        timeout 30s bash "$agent_path" 2>&1 | while IFS= read -r line; do
            echo "  $line"
        done
    ) &

    return 0
}

wait_for_agents() {
    log "⏳ Waiting for all agents to complete..."

    # Wait for all background jobs
    local failed=0
    while [ $(jobs -r | wc -l) -gt 0 ]; do
        wait -n || ((failed++))
    done

    if [ $failed -gt 0 ]; then
        log "⚠️  $failed agent(s) failed or timed out"
    else
        log "✅ All agents completed successfully"
    fi

    return $failed
}

aggregate_results() {
    log "📊 Aggregating results from bus..."

    # Read recent agent results from bus
    local results=$(read_events "twelve-factor.agents.results" 10)

    if [ -z "$results" ]; then
        log "⚠️  No results found on bus"
        return 1
    fi

    # Parse and display summary
    echo "$results" | jq -s '
        {
            total_agents: length,
            completed: [.[] | select(.payload.status == "completed")] | length,
            needs_improvement: [.[] | select(.payload.status == "needs_improvement")] | length,
            agents: [.[] | {
                agent: .payload.agent,
                status: .payload.status,
                timestamp: .ts
            }]
        }
    '
}

# Main execution
main() {
    log "🚀 Starting agents runner (max parallel: $MAX_AGENTS)..."

    # Clear old results from bus (optional)
    publish_event "twelve-factor.agents.run" "$(jq -n --arg ts "$(ts_now)" '{started:$ts}')"

    # Run agents with parallelism control
    local active=0

    for agent in "${AGENTS[@]}"; do
        # Wait if we've hit max parallel agents
        while [ $active -ge $MAX_AGENTS ]; do
            wait -n || true
            active=$(($(jobs -r | wc -l)))
        done

        # Start agent
        run_agent "$agent" && ((active++)) || true
    done

    # Wait for all to complete
    wait_for_agents || true

    # Aggregate and display results
    log "📋 Final Results:"
    aggregate_results

    log "✅ Agents run completed"
}

# CLI interface
case "${1:-run}" in
    run)
        main
        ;;
    list)
        log "Available agents:"
        for agent in "${AGENTS[@]}"; do
            echo "  - $agent"
        done
        ;;
    test)
        log "Testing single agent: ${2:-compliance-checker.sh}"
        run_agent "${2:-compliance-checker.sh}"
        wait
        ;;
    *)
        cat <<HELP
Twelve-Factor Agents Runner

Usage:
  agents-runner.sh [command]

Commands:
  run    Run all agents in parallel (default)
  list   List available agents
  test <agent>  Test single agent

Environment:
  AGENTS_MAX  Maximum parallel agents (default: 4)

Examples:
  agents-runner.sh run
  agents-runner.sh test compliance-checker.sh
  AGENTS_MAX=2 agents-runner.sh run
HELP
        ;;
esac
