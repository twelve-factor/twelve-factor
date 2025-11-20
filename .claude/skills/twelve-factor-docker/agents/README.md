# Agents for twelve-factor-docker

Micro-agents for parallel execution.

## Available Agents

- **agent.template.sh**: Template agent (customize this)

## Creating New Agents

```bash
cp agent.template.sh agent.myagent.sh
chmod +x agent.myagent.sh
# Edit agent logic
```

## Agent Contract

Each agent must:
1. Accept mode parameter
2. Publish events via bus
3. Complete within 120s
4. Declare modes in header comment

## Event Schema

```json
{
  "topic": "agent.twelve-factor-docker.{name}.result",
  "payload": {
    "status": "ok|failed",
    "data": {...}
  }
}
```
