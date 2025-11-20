# twelve-factor-docker

Docker and containerization compliance for twelve-factor apps

## Installation

This skill is part of the twelve-factor C.R.A.F.T. skills system.

## Usage

```bash
cd .claude/skills/twelve-factor-docker

# Run skill
./scripts/skill-run.sh run

# Self-test
./scripts/self-test.sh
```

## Configuration

Copy and customize the environment template:
```bash
cp templates/skill.env.example .env
# Edit .env with your settings
```

## Architecture

- **Archetype**: audit
- **Author**: root
- **Created**: 2025-11-20

## Structure

```
twelve-factor-docker/
├── SKILL.md                  # Skill definition
├── README.md                 # This file
├── scripts/
│   ├── skill-run.sh          # Main entry point
│   ├── bus.sh                # Context bus (symlink)
│   ├── self-test.sh          # Validation
│   ├── env-check.sh          # Environment check
│   └── agents-runner.sh      # Agent orchestrator
├── agents/
│   └── agent.template.sh     # Agent template
├── hooks/
│   ├── pre-commit            # Git pre-commit hook
│   └── post-skill-run.d/
│       └── 10-update-index.sh
└── templates/
    ├── bus.config.yaml       # Bus configuration
    └── skill.env.example     # Environment template
```

## Documentation

- See SKILL.md for detailed usage
- See agents/README.md for agent documentation
- See .claude/skills/README.md for system overview

## License

CC BY 4.0 (matches twelve-factor documentation)
