---
name: skill-generator
description: Meta-skill for generating new twelve-factor-aware skills using C.R.A.F.T. framework. Use when creating new skills for the twelve-factor project that need bus integration, hooks, and agents.
---

# Skill Generator (C.R.A.F.T. Framework)

This meta-skill generates new twelve-factor-aware skills with complete C.R.A.F.T. framework integration.

## What It Creates

Each generated skill includes:
- **Context bus integration** (bus.config.yaml, bus.sh)
- **Performance-optimized hooks** (pre-commit ≤10s, pre-push ≤60s)
- **Auto-doc updates** (official links with last-checked dates)
- **Micro-agents** (parallel execution support)
- **Complete C.R.A.F.T. structure**

## Usage

```bash
# Generate a new skill
./.claude/skills/skill-generator/scripts/generate-skill.sh \
  --name "my-twelve-factor-skill" \
  --archetype "audit" \
  --description "My custom twelve-factor skill"
```

## Archetypes

- **audit**: Compliance checking and analysis
- **remediation**: Automated fixing of violations
- **monitor**: Continuous compliance monitoring
- **custom**: Custom twelve-factor workflow

## Generated Structure

```
.claude/skills/{skill-name}/
├── SKILL.md
├── README.md
├── templates/
│   ├── bus.config.yaml
│   └── skill.env.example
├── scripts/
│   ├── skill-run.sh
│   ├── bus.sh (symlink)
│   └── self-test.sh
├── hooks/
│   ├── pre-commit
│   └── post-skill-run.d/
└── agents/
    └── agent.{name}.sh
```

## Bus Integration

All generated skills:
- Share context via `context/bus/shared-context.jsonl`
- Publish events to `context/events.log`
- Support multiple backends (JSON, SQLite, Redis, Neo4j)
- Coordinate through skill index

## Best Practices

1. **Skill naming**: Use kebab-case (e.g., `twelve-factor-audit`)
2. **Single responsibility**: One skill, one clear purpose
3. **Bus communication**: Always publish start/complete events
4. **Agent design**: Keep agents focused and fast (≤120s)
5. **Hook performance**: Respect time budgets

## Examples

### Generate Audit Skill
```bash
./scripts/generate-skill.sh \
  --name "twelve-factor-security-audit" \
  --archetype "audit" \
  --description "Security-focused twelve-factor compliance"
```

### Generate Custom Workflow
```bash
./scripts/generate-skill.sh \
  --name "twelve-factor-migration" \
  --archetype "custom" \
  --description "Migrate legacy app to twelve-factor"
```

## Skill Coordination

Skills coordinate via shared bus:
```bash
# Skill A publishes
publish_event "analysis.complete" '{"score":0.85}'

# Skill B reads
SCORE=$(read_events "analysis\\.complete" 1 | jq -r '.payload.score')
```

## See Also

- **C.R.A.F.T. Master Prompt**: Full framework documentation
- **twelve-factor-methodology**: Base skill with all patterns
- **Bus Documentation**: Context bus API reference
