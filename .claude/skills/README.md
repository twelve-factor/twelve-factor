# Twelve-Factor C.R.A.F.T. Skills System

Comprehensive twelve-factor methodology skills built on the **C.R.A.F.T. framework** (Context-aware, Reusable, Automated, Fast, Tested).

## 🏗️ Architecture

```
.claude/skills/
├── twelve-factor-methodology/  # Core methodology & reference
├── twelve-factor-audit/        # Compliance auditing
├── twelve-factor-remediation/  # Automated fixing
├── twelve-factor-monitor/      # Continuous monitoring
└── skill-generator/            # Meta-skill for creating new skills

context/
├── bus/shared-context.jsonl    # Shared data bus
├── events.log                  # Event stream
├── skills.index.json           # Skill registry
└── docs/INDEX.md               # Documentation index
```

## 🚀 Quick Start

### 1. Run Self-Test
```bash
cd .claude/skills/twelve-factor-methodology
./scripts/self-test.sh
```

### 2. Test Context Bus
```bash
./scripts/bus.sh selftest
```

### 3. Run Full Audit
```bash
./scripts/skill-run.sh analyze
```

## 📦 Available Skills

### twelve-factor-methodology
**Purpose**: Core reference implementation and analysis

**Commands**:
```bash
./scripts/skill-run.sh analyze    # Full compliance analysis
./scripts/skill-run.sh check      # Quick check
./scripts/skill-run.sh docs       # Update documentation
```

**Features**:
- Factor-by-factor guidance
- Parallel micro-agents
- Auto-doc updates
- Code examples
- Compliance checklists

### twelve-factor-audit
**Purpose**: Automated compliance auditing

**Commands**:
```bash
./scripts/skill-run.sh audit      # Full audit
./scripts/skill-run.sh quick      # Quick check
./scripts/skill-run.sh report     # Generate report
```

**Output**: Compliance score, violations, recommendations

### twelve-factor-remediation
**Purpose**: Fix violations automatically

**Commands**:
```bash
./scripts/skill-run.sh preview    # Preview fixes
./scripts/skill-run.sh fix        # Apply fixes (interactive)
./scripts/skill-run.sh fix-all    # Auto-fix all
```

**Capabilities**:
- Generate missing configs
- Move hardcoded values to env
- Create Dockerfiles
- Fix logging/session patterns

### twelve-factor-monitor
**Purpose**: Continuous compliance monitoring

**Commands**:
```bash
./scripts/skill-run.sh start      # Start monitoring
./scripts/skill-run.sh history    # View compliance history
./scripts/skill-run.sh stop       # Stop monitoring
```

**Features**:
- Periodic checks
- Regression detection
- Trend analysis
- Alerting

### skill-generator
**Purpose**: Generate new twelve-factor-aware skills

**Commands**:
```bash
./scripts/generate-skill.sh \
  --name "my-skill" \
  --archetype "audit" \
  --description "My custom skill"
```

## 🔄 Context Bus

All skills communicate via shared context bus.

### Architecture
- **Backend**: Switchable (JSON, SQLite, Redis, Neo4j)
- **Events**: JSONL stream in `context/events.log`
- **KV Store**: Shared state in `context/bus/shared-context.jsonl`
- **Registry**: Skill index in `context/skills.index.json`

### Bus Operations

```bash
# Publish event
./scripts/bus.sh publish "my.topic" '{"data":"value"}'

# Read events
./scripts/bus.sh read "my\\.topic" 10

# Store value
./scripts/bus.sh put "my.key" '"my-value"'

# Get value
./scripts/bus.sh get "my.key"
```

### Switch Backend

```bash
# Use SQLite
export BUS_BACKEND=sqlite

# Use Redis (requires Redis server)
export BUS_BACKEND=redis
export REDIS_URL=redis://localhost:6379/0
```

## 🤖 Micro-Agents

Skills use parallel micro-agents for performance.

### Available Agents

**twelve-factor-methodology**:
- `agent.factor-check.sh` - Individual factor compliance
- `agent.code-scan.sh` - Pattern detection
- `agent.docs-sync.sh` - Documentation sync

### Agent Execution

```bash
# Run all agents
./scripts/agents-runner.sh audit

# Custom concurrency
AGENTS_MAX=8 ./scripts/agents-runner.sh audit
```

## ⚡ Performance Hooks

### Pre-Commit (≤10s)
- Tool validation
- YAML syntax check
- Script syntax check

### Pre-Push (≤60s)
- Full self-test
- Bus functionality
- Agent validation

### Post-Skill-Run
- Auto-doc updates (15s)
- Metrics emission (5s)

### Configuration

```bash
# Skip hooks (development)
SKIP_HOOKS=1 git commit

# Fast mode
FAST=1 ./scripts/skill-run.sh check
```

## 📊 Skill Coordination

### Workflow Example: Full Compliance Pipeline

```bash
# 1. Audit
cd .claude/skills/twelve-factor-audit
./scripts/skill-run.sh audit

# Bus now contains: audit.complete event

# 2. Remediation (reads audit results from bus)
cd ../twelve-factor-remediation
./scripts/skill-run.sh fix

# Bus now contains: remediation.complete event

# 3. Verify (re-audit)
cd ../twelve-factor-audit
./scripts/skill-run.sh audit

# Check compliance improvement
../../scripts/bus.sh read "audit\\.complete" 2
```

### Workflow Example: Continuous Monitoring

```bash
# Start monitor (runs indefinitely)
cd .claude/skills/twelve-factor-monitor
./scripts/skill-run.sh start

# In another terminal, watch events
tail -f ../../context/events.log | grep "monitor\\.metrics"
```

## 🔧 Configuration

### Global Config

**Location**: `.claude/skills/twelve-factor-methodology/templates/skill.env.example`

```bash
# Copy and customize
cp .claude/skills/twelve-factor-methodology/templates/skill.env.example .env

# Edit values
BUS_BACKEND=json
AGENTS_MAX=4
COMPLIANCE_THRESHOLD=0.75
```

### Per-Skill Config

Each skill has its own `templates/skill.env.example`

## 📚 Documentation

### Official Sources

See `context/docs/INDEX.md` for:
- Twelve-factor.net links
- GitHub repository
- Content files
- Last-checked dates

### Auto-Updates

Documentation is automatically updated after each skill run via hook.

## 🧪 Testing

### Self-Test All Skills

```bash
for skill in .claude/skills/*/; do
  [[ -x "$skill/scripts/self-test.sh" ]] || continue
  echo "Testing: $(basename "$skill")"
  bash "$skill/scripts/self-test.sh" || echo "FAILED"
done
```

### Test Bus Integration

```bash
cd .claude/skills/twelve-factor-methodology
./scripts/bus.sh selftest
```

## 📈 Metrics & Monitoring

All skills emit metrics to bus:

```bash
# View all skill runs
./scripts/bus.sh read "skill\\." 20

# View agent results
./scripts/bus.sh read "agent\\..*\\.result" 10

# View metrics
./scripts/bus.sh read "metrics\\." 10
```

## 🔐 Security

### Best Practices

1. **Never commit secrets**: Use `.env` (gitignored)
2. **Sanitize logs**: Automatic redaction of passwords/tokens
3. **Validate inputs**: All scripts use `set -euo pipefail`
4. **Time budgets**: Hooks have strict timeouts
5. **Audit trail**: All events logged to bus

### Secrets Management

```bash
# Store in environment
export DATABASE_PASSWORD="secret"

# Skills read from env
# Bus automatically sanitizes logs
```

## 🐛 Troubleshooting

### Bus not working

```bash
# Check backend
echo $BUS_BACKEND

# Test manually
./scripts/bus.sh publish "test" '{"msg":"hello"}'
./scripts/bus.sh read "test" 1
```

### Hooks failing

```bash
# Skip temporarily
SKIP_HOOKS=1 git commit

# Debug
bash -x .claude/skills/twelve-factor-methodology/hooks/pre-commit
```

### Agents not running

```bash
# Check permissions
chmod +x .claude/skills/twelve-factor-methodology/agents/*.sh

# Run manually
bash .claude/skills/twelve-factor-methodology/agents/agent.factor-check.sh audit
```

## 📖 Further Reading

- **C.R.A.F.T. Master Prompt**: Complete framework documentation
- **Twelve-Factor Methodology**: https://12factor.net
- **Context Bus API**: See `scripts/bus.sh` source
- **Agent Development**: See `agents/README.md`

## 🤝 Contributing

To add a new skill:

```bash
# Use skill generator
cd .claude/skills/skill-generator
./scripts/generate-skill.sh --name "my-new-skill"
```

## 📄 License

CC BY 4.0 - Matches twelve-factor documentation license

---

**Status**: ✅ Production Ready
**Version**: 1.0.0
**Last Updated**: 2025-11-19
