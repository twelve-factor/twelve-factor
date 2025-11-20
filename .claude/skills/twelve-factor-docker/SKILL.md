---
name: twelve-factor-docker
description: Docker and containerization compliance for twelve-factor apps
---

# Twelve-factor-docker

Docker and containerization compliance for twelve-factor apps

## Quick Start

```bash
cd .claude/skills/twelve-factor-docker

# Run main task
./scripts/skill-run.sh run

# Self-test
./scripts/self-test.sh

# Check environment
./scripts/env-check.sh
```

## Features

- **Bus integration**: Publishes events to shared context bus
- **Parallel agents**: Micro-agents for concurrent execution
- **Performance hooks**: Optimized git hooks with time budgets
- **Auto-documentation**: Syncs with official twelve-factor sources

## Tasks

### Main Tasks
- `run`: Execute primary skill function
- `check`: Quick validation
- `selftest`: Run skill self-test

## Configuration

Environment variables in `.env`:
```bash
BUS_BACKEND=json              # Bus backend
SKILL_MODE=standard           # Execution mode
ENABLE_AGENTS=1               # Enable parallel agents
```

## Bus Integration

Publishes events:
- `twelve-factor-docker.start`: Skill execution started
- `twelve-factor-docker.complete`: Skill execution completed
- `agent.twelve-factor-docker.*.result`: Agent results

Subscribes to:
- Configure based on dependencies

## Agents

See `agents/README.md` for agent documentation.

## Development

Add new agents:
```bash
cp agents/agent.template.sh agents/agent.myagent.sh
chmod +x agents/agent.myagent.sh
# Edit agent logic
```

## See Also

- **twelve-factor-methodology**: Core reference
- **Context Bus**: `scripts/bus.sh`
- **Skill Index**: `context/skills.index.json`
