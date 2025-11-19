# Twelve-Factor Micro-Agents

Specialized agents for parallel execution of twelve-factor compliance tasks.

## Overview

Micro-agents are autonomous scripts that:
- Execute specialized tasks in parallel
- Publish results to the context bus
- Don't block main Claude Code workflow
- Can be extended with new agents easily

## Available Agents

### 1. compliance-checker.sh

**Purpose**: Automated code scanning for twelve-factor violations

**Checks**:
- Factor III (Config): Hardcoded credentials/secrets
- Factor II (Dependencies): Dependency manifest presence
- Factor XI (Logs): File logging anti-patterns
- Factor VI (Processes): In-memory session storage

**Output**: Compliance score (0-100%) and detailed violations

**Example**:
```bash
.claude/skills/twelve-factor/agents/compliance-checker.sh
```

**Result format**:
```json
{
  "agent": "compliance-checker",
  "status": "completed",
  "score": 75,
  "violations": {
    "hardcoded_credentials": false,
    "missing_dependencies": false,
    "file_logging": true,
    "in_memory_state": false
  }
}
```

### 2. config-auditor.sh

**Purpose**: Audit configuration management practices

**Checks**:
- Environment file discovery (.env*)
- .env.example template presence
- .gitignore protection for secrets
- Config file security (hardcoded values)
- Environment variable usage analysis

**Output**: Security recommendations and findings

**Example**:
```bash
.claude/skills/twelve-factor/agents/config-auditor.sh
```

**Result format**:
```json
{
  "agent": "config-auditor",
  "status": "ok" | "needs_improvement",
  "findings": {
    "env_files": [".env", ".env.local"],
    "env_example": "present" | "missing",
    "gitignore_status": "protected" | "unprotected",
    "env_usage_count": 42
  },
  "recommendations": [
    "Create .env.example template",
    "Add .env to .gitignore"
  ]
}
```

### 3. deployment-validator.sh

**Purpose**: Validate deployment configuration

**Checks**:
- Factor V: Dockerfile multi-stage builds
- Factor X: Docker Compose dev/prod parity
- CI/CD pipeline detection
- Factor IX: Process manager configuration

**Output**: Deployment readiness and recommendations

**Example**:
```bash
.claude/skills/twelve-factor/agents/deployment-validator.sh
```

**Result format**:
```json
{
  "agent": "deployment-validator",
  "status": "ok" | "needs_improvement",
  "findings": {
    "dockerfile": ["multi_stage:yes"],
    "docker_compose": "ok" | "parity_violation",
    "ci_cd": ["github_actions"],
    "process_manager": ["procfile"]
  },
  "recommendations": [
    "Use same database in dev and prod (Factor X)"
  ]
}
```

## Running Agents

### Single Agent

```bash
# Run one agent directly
.claude/skills/twelve-factor/agents/compliance-checker.sh
```

### All Agents (Parallel)

```bash
# Run all agents in parallel (recommended)
.claude/skills/twelve-factor/scripts/agents-runner.sh run
```

**Performance**: Agents run with 30s timeout each, max 4 parallel by default

**Configuration**:
```bash
# Adjust max parallel agents
AGENTS_MAX=2 .claude/skills/twelve-factor/scripts/agents-runner.sh run
```

## Agent Results

All agent results are published to the context bus topic: `twelve-factor.agents.results`

**Read results**:
```bash
# Get last 10 agent results
.claude/skills/twelve-factor/scripts/bus.sh read twelve-factor.agents.results 10
```

**Aggregate results**:
```bash
# Automatic aggregation after agents-runner.sh run
.claude/skills/twelve-factor/scripts/agents-runner.sh run
```

## Creating New Agents

### Template

```bash
#!/usr/bin/env bash
# Micro-agent: [Agent Name]
# Specialized task: [Description]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/bus.sh"

AGENT_NAME="your-agent-name"

log() {
    echo "[$(date -u +"%H:%M:%S")] [$AGENT_NAME] $*" >&2
}

main() {
    log "Starting agent..."

    # Your logic here
    local result=$(jq -n \
        --arg agent "$AGENT_NAME" \
        --arg status "completed" \
        '{agent:$agent, status:$status, findings:{}}')

    # Publish to bus
    publish_event "twelve-factor.agents.results" "$result"

    log "Agent completed"
    echo "$result"
}

main "$@"
```

### Steps

1. Create new agent script in `agents/` directory
2. Make it executable: `chmod +x agents/your-agent.sh`
3. Add to `AGENTS` array in `scripts/agents-runner.sh`
4. Test: `agents-runner.sh test your-agent.sh`
5. Document in this README

## Integration with Claude Code

Agents are invoked by Claude Code when:
- User requests compliance check
- Skill is activated for twelve-factor review
- Manual trigger via agents-runner.sh

**From Claude Code**:
```
Check twelve-factor compliance for this project
```

Claude will automatically:
1. Run all agents in parallel
2. Aggregate results from bus
3. Present findings to user
4. Suggest fixes for violations

## Performance & Reliability

**Timeouts**:
- Individual agent: 30s max
- Overall agents run: Depends on parallelism

**Failures**:
- Agents fail gracefully (non-blocking)
- Results published before timeout when possible
- Failed agents logged but don't stop others

**Resource Usage**:
- Low CPU (bash scripts with grep/jq)
- Minimal memory footprint
- No network dependencies (except Redis/Neo4j backends)

## Debugging

**Enable verbose output**:
```bash
set -x  # Add to agent script for trace
```

**Test single agent**:
```bash
bash -x .claude/skills/twelve-factor/agents/compliance-checker.sh
```

**Check bus for results**:
```bash
.claude/skills/twelve-factor/scripts/bus.sh read twelve-factor.agents.results | jq .
```

## Future Agents (Ideas)

- **security-scanner.sh**: Check for known vulnerabilities
- **port-binding-checker.sh**: Validate Factor VII compliance
- **log-analyzer.sh**: Analyze logging patterns for Factor XI
- **concurrency-validator.sh**: Check process model (Factor VIII)
- **admin-processes-checker.sh**: Validate Factor XII compliance
