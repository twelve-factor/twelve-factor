#!/usr/bin/env bash
# Skill Generator - C.R.A.F.T. Framework
# Generates new twelve-factor-aware skills with full bus integration
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
GENERATOR_DIR="$ROOT/.claude/skills/skill-generator"
SKILLS_DIR="$ROOT/.claude/skills"

# Load bus if available
if [[ -f "$ROOT/.claude/skills/twelve-factor-methodology/scripts/bus.sh" ]]; then
  source "$ROOT/.claude/skills/twelve-factor-methodology/scripts/bus.sh"
fi

# ============================================================================
# Parse arguments
# ============================================================================
SKILL_NAME=""
ARCHETYPE="custom"
DESCRIPTION=""
AUTHOR="${USER:-$(whoami)}"

usage() {
  cat <<USAGE
Skill Generator - C.R.A.F.T. Framework

Usage: $(basename "$0") [options]

Options:
  --name NAME          Skill name (kebab-case, required)
  --archetype TYPE     Archetype: audit|remediation|monitor|custom (default: custom)
  --description DESC   Short description (required)
  --author NAME        Author name (default: $AUTHOR)
  --help               Show this help

Examples:
  # Audit skill
  $0 --name "twelve-factor-security" \\
     --archetype "audit" \\
     --description "Security-focused twelve-factor compliance"

  # Custom workflow
  $0 --name "twelve-factor-migration" \\
     --archetype "custom" \\
     --description "Migrate legacy app to twelve-factor"

Archetypes:
  audit        - Compliance checking and analysis
  remediation  - Automated violation fixing
  monitor      - Continuous compliance monitoring
  custom       - Custom twelve-factor workflow
USAGE
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      SKILL_NAME="$2"
      shift 2
      ;;
    --archetype)
      ARCHETYPE="$2"
      shift 2
      ;;
    --description)
      DESCRIPTION="$2"
      shift 2
      ;;
    --author)
      AUTHOR="$2"
      shift 2
      ;;
    --help|-h)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

# Validate required arguments
if [[ -z "$SKILL_NAME" ]]; then
  echo "ERROR: --name is required" >&2
  usage
fi

if [[ -z "$DESCRIPTION" ]]; then
  echo "ERROR: --description is required" >&2
  usage
fi

# Validate archetype
if [[ ! "$ARCHETYPE" =~ ^(audit|remediation|monitor|custom)$ ]]; then
  echo "ERROR: Invalid archetype: $ARCHETYPE" >&2
  echo "Valid archetypes: audit, remediation, monitor, custom" >&2
  exit 1
fi

# Validate skill name (kebab-case)
if [[ ! "$SKILL_NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "ERROR: Skill name must be kebab-case (e.g., my-skill-name)" >&2
  exit 1
fi

SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

if [[ -d "$SKILL_DIR" ]]; then
  echo "ERROR: Skill already exists: $SKILL_DIR" >&2
  exit 1
fi

echo "=== Generating Skill: $SKILL_NAME ==="
echo "Archetype: $ARCHETYPE"
echo "Description: $DESCRIPTION"
echo "Output: $SKILL_DIR"
echo ""

# ============================================================================
# Create directory structure
# ============================================================================
mkdir -p "$SKILL_DIR"/{scripts,hooks/post-skill-run.d,agents,templates}

# ============================================================================
# Generate SKILL.md
# ============================================================================
cat > "$SKILL_DIR/SKILL.md" <<SKILLMD
---
name: $SKILL_NAME
description: $DESCRIPTION
---

# ${SKILL_NAME^}

$DESCRIPTION

## Quick Start

\`\`\`bash
cd .claude/skills/$SKILL_NAME

# Run main task
./scripts/skill-run.sh run

# Self-test
./scripts/self-test.sh

# Check environment
./scripts/env-check.sh
\`\`\`

## Features

- **Bus integration**: Publishes events to shared context bus
- **Parallel agents**: Micro-agents for concurrent execution
- **Performance hooks**: Optimized git hooks with time budgets
- **Auto-documentation**: Syncs with official twelve-factor sources

## Tasks

### Main Tasks
- \`run\`: Execute primary skill function
- \`check\`: Quick validation
- \`selftest\`: Run skill self-test

## Configuration

Environment variables in \`.env\`:
\`\`\`bash
BUS_BACKEND=json              # Bus backend
SKILL_MODE=standard           # Execution mode
ENABLE_AGENTS=1               # Enable parallel agents
\`\`\`

## Bus Integration

Publishes events:
- \`$SKILL_NAME.start\`: Skill execution started
- \`$SKILL_NAME.complete\`: Skill execution completed
- \`agent.$SKILL_NAME.*.result\`: Agent results

Subscribes to:
- Configure based on dependencies

## Agents

See \`agents/README.md\` for agent documentation.

## Development

Add new agents:
\`\`\`bash
cp agents/agent.template.sh agents/agent.myagent.sh
chmod +x agents/agent.myagent.sh
# Edit agent logic
\`\`\`

## See Also

- **twelve-factor-methodology**: Core reference
- **Context Bus**: \`scripts/bus.sh\`
- **Skill Index**: \`context/skills.index.json\`
SKILLMD

# ============================================================================
# Generate README.md
# ============================================================================
cat > "$SKILL_DIR/README.md" <<README
# $SKILL_NAME

$DESCRIPTION

## Installation

This skill is part of the twelve-factor C.R.A.F.T. skills system.

## Usage

\`\`\`bash
cd .claude/skills/$SKILL_NAME

# Run skill
./scripts/skill-run.sh run

# Self-test
./scripts/self-test.sh
\`\`\`

## Configuration

Copy and customize the environment template:
\`\`\`bash
cp templates/skill.env.example .env
# Edit .env with your settings
\`\`\`

## Architecture

- **Archetype**: $ARCHETYPE
- **Author**: $AUTHOR
- **Created**: $(date -u +"%Y-%m-%d")

## Structure

\`\`\`
$SKILL_NAME/
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
\`\`\`

## Documentation

- See SKILL.md for detailed usage
- See agents/README.md for agent documentation
- See .claude/skills/README.md for system overview

## License

CC BY 4.0 (matches twelve-factor documentation)
README

# ============================================================================
# Generate skill-run.sh
# ============================================================================
cat > "$SKILL_DIR/scripts/skill-run.sh" <<'SKILLRUN'
#!/usr/bin/env bash
# Main entry point for SKILL_NAME_PLACEHOLDER
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/SKILL_NAME_PLACEHOLDER"
source "$SKILL_DIR/scripts/bus.sh"

TASK="${1:-help}"
shift || true

START_TIME=$SECONDS

# ============================================================================
# Task execution
# ============================================================================
run_task() {
  local task="$1"
  shift

  case "$task" in
    run|execute)
      echo "=== SKILL_NAME_PLACEHOLDER: Execute ==="
      publish_event "SKILL_NAME_PLACEHOLDER.start" '{"task":"run"}'

      # TODO: Add your skill logic here
      echo "Running SKILL_NAME_PLACEHOLDER..."

      # Run agents if enabled
      if [[ "${ENABLE_AGENTS:-1}" == "1" ]]; then
        bash "$SKILL_DIR/scripts/agents-runner.sh" run
      fi

      publish_event "SKILL_NAME_PLACEHOLDER.complete" '{"task":"run","status":"success"}'
      ;;

    check|validate)
      echo "=== SKILL_NAME_PLACEHOLDER: Check ==="
      bash "$SKILL_DIR/scripts/env-check.sh"
      ;;

    selftest|test)
      bash "$SKILL_DIR/scripts/self-test.sh" "$@"
      ;;

    help|*)
      cat <<HELP
SKILL_NAME_PLACEHOLDER

Usage: skill-run.sh <task> [options]

Tasks:
  run, execute     Execute primary skill function
  check, validate  Environment validation
  selftest, test   Run self-test
  help             Show this help

Environment:
  BUS_BACKEND      Backend: json|sqlite|redis|graph
  ENABLE_AGENTS    Enable agents (default: 1)
  SKIP_HOOKS       Skip hooks (default: 0)

Examples:
  ./skill-run.sh run
  ./skill-run.sh check
  ./skill-run.sh selftest
HELP
      exit 0
      ;;
  esac
}

# ============================================================================
# Main execution
# ============================================================================
trap 'EXIT_CODE=$?; echo "Task failed with code $EXIT_CODE" >&2' ERR

run_task "$TASK" "$@"

# Post-execution hooks
for hook in "$SKILL_DIR/hooks/post-skill-run.d/"*.sh; do
  [[ -x "$hook" ]] || continue
  ( timeout 15s bash "$hook" "$TASK" ) &
done

DURATION=$((SECONDS - START_TIME))
echo ""
echo "✓ Task complete in ${DURATION}s"

exit 0
SKILLRUN

# Replace placeholder
sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/scripts/skill-run.sh"
chmod +x "$SKILL_DIR/scripts/skill-run.sh"

# ============================================================================
# Create bus.sh symlink
# ============================================================================
ln -sf "$ROOT/.claude/skills/twelve-factor-methodology/scripts/bus.sh" "$SKILL_DIR/scripts/bus.sh"

# ============================================================================
# Generate self-test.sh
# ============================================================================
cat > "$SKILL_DIR/scripts/self-test.sh" <<'SELFTEST'
#!/usr/bin/env bash
# Self-test for SKILL_NAME_PLACEHOLDER
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/SKILL_NAME_PLACEHOLDER"

echo "=== SKILL_NAME_PLACEHOLDER Self-Test ==="

# Check tools
echo "Checking required tools..."
MISSING=()
for tool in bash git jq; do
  command -v "$tool" >/dev/null || MISSING+=("$tool")
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo "✗ Missing tools: ${MISSING[*]}"
  exit 1
fi
echo "✓ All required tools present"

# Check structure
echo "Checking file structure..."
for file in SKILL.md scripts/skill-run.sh scripts/bus.sh; do
  [[ -f "$SKILL_DIR/$file" ]] || { echo "✗ Missing: $file"; exit 1; }
done
echo "✓ File structure valid"

# Check bus
echo "Testing bus..."
source "$SKILL_DIR/scripts/bus.sh"
publish_event "test.selftest" '{"skill":"SKILL_NAME_PLACEHOLDER"}' || {
  echo "✗ Bus publish failed"
  exit 1
}
echo "✓ Bus working"

echo ""
echo "=== Self-Test Complete ==="
exit 0
SELFTEST

sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/scripts/self-test.sh"
chmod +x "$SKILL_DIR/scripts/self-test.sh"

# ============================================================================
# Generate env-check.sh
# ============================================================================
cat > "$SKILL_DIR/scripts/env-check.sh" <<'ENVCHECK'
#!/usr/bin/env bash
# Environment check for SKILL_NAME_PLACEHOLDER
set -euo pipefail

echo "=== Environment Check ==="
echo "Repository: $(git rev-parse --show-toplevel | xargs basename)"
echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Skill: SKILL_NAME_PLACEHOLDER"
echo ""

# Check bus backend
echo "Bus Backend: ${BUS_BACKEND:-json}"
echo "Agents: ${ENABLE_AGENTS:-1}"

exit 0
ENVCHECK

sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/scripts/env-check.sh"
chmod +x "$SKILL_DIR/scripts/env-check.sh"

# ============================================================================
# Generate agents-runner.sh
# ============================================================================
cat > "$SKILL_DIR/scripts/agents-runner.sh" <<'AGENTRUNNER'
#!/usr/bin/env bash
# Agent runner for SKILL_NAME_PLACEHOLDER
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/SKILL_NAME_PLACEHOLDER"
AGENTS_DIR="$SKILL_DIR/agents"

source "$SKILL_DIR/scripts/bus.sh"

MODE="${1:-run}"
MAX_AGENTS="${AGENTS_MAX:-4}"

echo "=== Running Agents (mode: $MODE) ==="

# Discover agents
AGENTS=()
for agent in "$AGENTS_DIR"/agent.*.sh; do
  [[ -f "$agent" ]] && [[ -x "$agent" ]] && AGENTS+=("$agent")
done

if [[ ${#AGENTS[@]} -eq 0 ]]; then
  echo "No agents found"
  exit 0
fi

echo "Found ${#AGENTS[@]} agents"

# Run agents
for agent in "${AGENTS[@]}"; do
  echo "Running: $(basename "$agent")"
  bash "$agent" "$MODE" &
done

wait
echo "✓ All agents complete"
AGENTRUNNER

sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/scripts/agents-runner.sh"
chmod +x "$SKILL_DIR/scripts/agents-runner.sh"

# ============================================================================
# Generate template agent
# ============================================================================
cat > "$SKILL_DIR/agents/agent.template.sh" <<'AGENT'
#!/usr/bin/env bash
# MODES: all
# Template agent for SKILL_NAME_PLACEHOLDER
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/SKILL_NAME_PLACEHOLDER"
source "$SKILL_DIR/scripts/bus.sh"

MODE="${1:-run}"

echo "[agent.template] Starting in mode: $MODE"

# TODO: Add agent logic here

# Publish result
publish_event "agent.SKILL_NAME_PLACEHOLDER.template.result" '{"status":"ok","mode":"'$MODE'"}'

echo "[agent.template] Complete"
exit 0
AGENT

sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/agents/agent.template.sh"
chmod +x "$SKILL_DIR/agents/agent.template.sh"

# Agent README
cat > "$SKILL_DIR/agents/README.md" <<'AGENTREADME'
# Agents for SKILL_NAME_PLACEHOLDER

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
  "topic": "agent.SKILL_NAME_PLACEHOLDER.{name}.result",
  "payload": {
    "status": "ok|failed",
    "data": {...}
  }
}
```
AGENTREADME

sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/agents/README.md"

# ============================================================================
# Generate hooks
# ============================================================================
cat > "$SKILL_DIR/hooks/pre-commit" <<'PRECOMMIT'
#!/usr/bin/env bash
# Pre-commit hook (≤10s budget)
set -euo pipefail

[[ "${SKIP_HOOKS:-0}" == "1" ]] && exit 0

timeout 10s bash -c '
  command -v jq >/dev/null || exit 1
  command -v git >/dev/null || exit 1
' || {
  echo "✗ Pre-commit checks failed" >&2
  exit 1
}

exit 0
PRECOMMIT

chmod +x "$SKILL_DIR/hooks/pre-commit"

cat > "$SKILL_DIR/hooks/post-skill-run.d/10-update-index.sh" <<'POSTRUN'
#!/usr/bin/env bash
# Update skill index after run
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/SKILL_NAME_PLACEHOLDER"

[[ -x "$SKILL_DIR/scripts/bus.sh" ]] || exit 0
source "$SKILL_DIR/scripts/bus.sh"

publish_event "skill.SKILL_NAME_PLACEHOLDER.run" '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}'

exit 0
POSTRUN

sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/hooks/post-skill-run.d/10-update-index.sh"
chmod +x "$SKILL_DIR/hooks/post-skill-run.d/10-update-index.sh"

# ============================================================================
# Generate templates
# ============================================================================
cp "$ROOT/.claude/skills/twelve-factor-methodology/templates/bus.config.yaml" \
   "$SKILL_DIR/templates/bus.config.yaml"

cat > "$SKILL_DIR/templates/skill.env.example" <<ENVEXAMPLE
# $SKILL_NAME Environment Configuration

# Bus Backend
BUS_BACKEND=json  # json|sqlite|redis|graph

# Performance
AGENTS_MAX=4
SKIP_HOOKS=0
FAST=0

# Features
ENABLE_AGENTS=1

# Skill-specific settings
SKILL_MODE=standard
ENVEXAMPLE

# ============================================================================
# Update skills index
# ============================================================================
SKILLS_INDEX="$ROOT/context/skills.index.json"

if [[ -f "$SKILLS_INDEX" ]]; then
  # Add new skill to index
  TMP_INDEX=$(mktemp)
  jq --arg name "$SKILL_NAME" \
     --arg desc "$DESCRIPTION" \
     --arg arch "$ARCHETYPE" \
     --arg path ".claude/skills/$SKILL_NAME" \
     '.skills += [{
       "id": $name,
       "name": $name,
       "version": "1.0.0",
       "archetype": $arch,
       "path": $path,
       "capabilities": ["run"],
       "topics": {
         "publishes": [($name + ".start"), ($name + ".complete")],
         "subscribes": []
       },
       "status": "active"
     }]' "$SKILLS_INDEX" > "$TMP_INDEX"

  mv "$TMP_INDEX" "$SKILLS_INDEX"
  echo "✓ Updated skills index"
fi

# ============================================================================
# Publish event
# ============================================================================
if [[ -f "$ROOT/.claude/skills/twelve-factor-methodology/scripts/bus.sh" ]]; then
  source "$ROOT/.claude/skills/twelve-factor-methodology/scripts/bus.sh"
  publish_event "skill.created" "{\"name\":\"$SKILL_NAME\",\"archetype\":\"$ARCHETYPE\"}"
  echo "✓ Published skill.created event"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                  SKILL GENERATED SUCCESSFULLY                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Skill: $SKILL_NAME"
echo "Location: $SKILL_DIR"
echo "Archetype: $ARCHETYPE"
echo ""
echo "Next steps:"
echo "  1. cd $SKILL_DIR"
echo "  2. Review SKILL.md and customize"
echo "  3. Run: ./scripts/self-test.sh"
echo "  4. Run: ./scripts/skill-run.sh run"
echo ""
echo "Files created:"
tree -L 2 "$SKILL_DIR" 2>/dev/null || find "$SKILL_DIR" -type f | sed 's|^|  |'
echo ""

exit 0
