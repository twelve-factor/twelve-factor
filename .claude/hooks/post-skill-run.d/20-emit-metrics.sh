#!/usr/bin/env bash
# Hook: Emit metrics after skill run
# Publishes usage metrics to context bus

set -euo pipefail

SKILL_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")/.claude/skills/twelve-factor"
source "$SKILL_DIR/scripts/bus.sh"

echo "📊 Emitting skill metrics..."

# Collect metrics
TASK="${1:-unknown}"
DURATION="${2:-0}"
TIMESTAMP=$(ts_now)

# Publish metrics event
metrics=$(jq -n \
    --arg task "$TASK" \
    --arg duration "$DURATION" \
    --arg ts "$TIMESTAMP" \
    '{task:$task, duration_sec:$duration, timestamp:$ts}')

publish_event "twelve-factor.metrics" "$metrics" || {
    echo "⚠️  Failed to publish metrics, skipping..."
    exit 0
}

echo "✅ Metrics emitted"
