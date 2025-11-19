---
name: twelve-factor-audit
description: Automated twelve-factor compliance auditing with detailed reporting. Analyzes codebase against all 12 factors, generates compliance scores, and identifies violations.
---

# Twelve-Factor Audit Skill

Automated compliance auditing for twelve-factor methodology.

## Features

- **Factor-by-factor analysis**: Individual checks for all 12 factors
- **Violation detection**: Identifies anti-patterns and non-compliance
- **Scoring system**: Calculates compliance percentage
- **Detailed reports**: JSON and Markdown outputs
- **Bus integration**: Shares results with other skills

## Quick Start

```bash
# Full audit
./.claude/skills/twelve-factor-audit/scripts/skill-run.sh audit

# Quick check
./.claude/skills/twelve-factor-audit/scripts/skill-run.sh quick

# Report only
./.claude/skills/twelve-factor-audit/scripts/skill-run.sh report
```

## Audit Scope

### Automated Checks
- ✓ I. Codebase: Git repository, single app per repo
- ✓ II. Dependencies: Manifest files, lock files
- ✓ III. Config: Env vars, no hardcoded secrets
- ✓ IV. Backing Services: URL-based connections
- ✓ V. Build/Release/Run: Dockerfile, build scripts
- ✓ VI. Processes: Stateless design patterns
- ✓ VII. Port Binding: PORT env var usage
- ✓ VIII. Concurrency: Process types (Procfile)
- ✓ IX. Disposability: Graceful shutdown handlers
- ✓ X. Dev/Prod Parity: Docker, same services
- ✓ XI. Logs: stdout/stderr, no file logging
- ✓ XII. Admin: One-off process patterns

### Output Format

```json
{
  "audit_id": "audit-2025-11-19-001",
  "timestamp": "2025-11-19T12:00:00Z",
  "project": "my-app",
  "compliance_score": 0.833,
  "factors": [
    {
      "factor": "I. Codebase",
      "status": "pass",
      "details": "Git repository detected",
      "recommendations": []
    },
    ...
  ],
  "violations": [
    {
      "factor": "III. Config",
      "severity": "critical",
      "description": "Hardcoded credentials in config.py:42"
    }
  ],
  "summary": {
    "total_factors": 12,
    "passed": 10,
    "warned": 1,
    "failed": 1
  }
}
```

## Integration

Publishes audit results to bus:
```bash
# Other skills can read results
read_events "audit\\.complete" 1
```

## Configuration

Set in `.env`:
```bash
AUDIT_DEPTH=full        # quick|standard|full
AUDIT_FORMAT=json       # json|markdown|text
COMPLIANCE_THRESHOLD=0.75
```

## Workflow

1. Initialize audit session
2. Run parallel factor checks (via agents)
3. Scan codebase for patterns
4. Aggregate results
5. Calculate compliance score
6. Generate report
7. Publish to bus
8. Output results

## Exit Codes

- `0`: Audit complete (check score for pass/fail)
- `1`: Audit failed (infrastructure error)
- `2`: Below compliance threshold

## See Also

- **twelve-factor-remediation**: Fix violations
- **twelve-factor-monitor**: Continuous checking
- **twelve-factor-methodology**: Reference implementation
