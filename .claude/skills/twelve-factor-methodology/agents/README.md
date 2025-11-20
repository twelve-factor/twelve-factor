# Twelve-Factor Micro-Agents

This directory contains micro-agents for parallel execution of twelve-factor compliance tasks.

## Available Agents

### agent.factor-check.sh
- **Purpose**: Checks individual twelve-factor compliance
- **Modes**: audit, check
- **Output**: Compliance status per factor to bus

### agent.code-scan.sh
- **Purpose**: Scans codebase for twelve-factor patterns/anti-patterns
- **Modes**: audit, remediate
- **Output**: Violations and recommendations to bus

### agent.docs-sync.sh
- **Purpose**: Synchronizes documentation with official sources
- **Modes**: all
- **Output**: Documentation updates to bus

## Agent Contract

Each agent must:

1. **Accept mode parameter**: `./agent.name.sh <mode>`
2. **Publish events**: Start, progress, complete events via bus
3. **Timeout-safe**: Complete within 120 seconds
4. **Fail gracefully**: Return non-zero on error
5. **Declare modes**: Comment header `# MODES: audit,remediate` or `all`

## Event Schema

Agents publish events in this format:

```json
{
  "topic": "agent.<name>.<event>",
  "ts": "2025-11-19T12:00:00Z",
  "payload": {
    "agent": "agent-name",
    "status": "success|failed",
    "data": { ... }
  }
}
```

## Creating New Agents

Template:

```bash
#!/usr/bin/env bash
# MODES: audit,check
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"
source "$SKILL_DIR/scripts/bus.sh"

MODE="${1:-audit}"

# Your agent logic here
# ...

# Publish results
publish_event "agent.myagent.result" '{"status":"ok","findings":[...]}'

exit 0
```

## Running Agents

Agents are orchestrated by `agents-runner.sh`:

```bash
# Run all agents in audit mode
./scripts/agents-runner.sh audit

# Run with custom concurrency
AGENTS_MAX=8 ./scripts/agents-runner.sh audit
```

## Performance

- **Concurrency**: Controlled by `AGENTS_MAX` (default: 4)
- **Timeout**: 120 seconds per agent
- **Coordination**: Via shared context bus
- **Results**: Aggregated from bus events
