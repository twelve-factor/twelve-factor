---
name: twelve-factor-remediation
description: Automated remediation of twelve-factor violations. Fixes common anti-patterns, generates missing configs, and updates code to comply with twelve-factor principles.
---

# Twelve-Factor Remediation Skill

Automated fixing of twelve-factor compliance violations.

## Features

- **Automated fixes**: Repairs common violations
- **Safe mode**: Preview changes before applying
- **Intelligent refactoring**: Context-aware code updates
- **Template generation**: Creates missing configs
- **Bus coordination**: Uses audit results

## Quick Start

```bash
# Preview fixes (safe, no changes)
./.claude/skills/twelve-factor-remediation/scripts/skill-run.sh preview

# Apply fixes (interactive)
./.claude/skills/twelve-factor-remediation/scripts/skill-run.sh fix

# Auto-fix all (aggressive)
REMEDIATION_MODE=aggressive ./scripts/skill-run.sh fix-all
```

## Remediation Capabilities

### Automated Fixes

#### Factor II: Dependencies
- Generate missing manifest files
- Add lock files
- Fix dependency versions

#### Factor III: Config
- Create `.env.example` from hardcoded values
- Move secrets to environment variables
- Add `.env` to `.gitignore`

#### Factor V: Build/Release/Run
- Generate Dockerfile
- Create Procfile
- Add build scripts

#### Factor VII: Port Binding
- Replace hardcoded ports with `PORT` env var
- Update server startup code

#### Factor XI: Logs
- Replace file logging with stdout
- Remove log rotation code

### Template Generation

Creates missing files:
- `.env.example`
- `Dockerfile`
- `Procfile`
- `docker-compose.yml`
- `.dockerignore`
- `.gitignore` updates

## Safety Features

1. **Backup creation**: Saves original files
2. **Dry-run mode**: Shows changes without applying
3. **Interactive confirmation**: Prompts before each change
4. **Rollback support**: Can undo all changes
5. **Git integration**: Commits changes separately

## Workflow

1. Read audit results from bus
2. Prioritize violations by severity
3. Generate fix plan
4. Preview changes (if safe mode)
5. Apply fixes with confirmation
6. Validate fixes
7. Publish remediation results
8. Update audit status

## Configuration

```bash
REMEDIATION_MODE=safe       # safe|aggressive
BACKUP_DIR=.twelve-factor-backup
AUTO_COMMIT=false
INTERACTIVE=true
```

## Example Session

```bash
$ ./skill-run.sh preview

=== Remediation Preview ===
Found 5 violations to fix:

1. [CRITICAL] Factor III: Hardcoded password in config.py:42
   Fix: Move to PASSWORD env var

2. [WARNING] Factor VII: Hardcoded port in server.js:10
   Fix: Replace with process.env.PORT || 3000

3. [WARNING] Factor XI: File logging in app.py:25
   Fix: Replace FileHandler with StreamHandler(sys.stdout)

Apply these fixes? (y/N)
```

## Integration

Coordinates with audit skill:
```bash
# Read violations from last audit
VIOLATIONS=$(read_events "audit\\.complete" 1 | jq '.payload.violations')
```

## Rollback

```bash
# Undo last remediation
./.claude/skills/twelve-factor-remediation/scripts/skill-undo.sh
```

## See Also

- **twelve-factor-audit**: Identify violations
- **twelve-factor-monitor**: Track compliance over time
