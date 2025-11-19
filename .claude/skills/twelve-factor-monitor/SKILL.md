---
name: twelve-factor-monitor
description: Continuous twelve-factor compliance monitoring. Tracks compliance over time, detects regressions, alerts on violations, and maintains compliance history.
---

# Twelve-Factor Monitor Skill

Continuous compliance monitoring and regression detection.

## Features

- **Continuous checking**: Periodic compliance audits
- **Regression detection**: Alerts when compliance drops
- **Trend analysis**: Track compliance over time
- **Alerting**: Notifications on violations
- **Historical data**: Compliance history in bus

## Quick Start

```bash
# Start monitoring (runs continuously)
./.claude/skills/twelve-factor-monitor/scripts/skill-run.sh start

# Run once
./scripts/skill-run.sh check

# View history
./scripts/skill-run.sh history

# Stop monitoring
./scripts/skill-run.sh stop
```

## Monitoring Modes

### Continuous Mode
```bash
# Check every 5 minutes
MONITOR_INTERVAL=300 ./scripts/skill-run.sh start
```

### Git Hook Mode
Triggered on commits:
```bash
# Install git hooks
./scripts/skill-run.sh install-hooks
```

### CI Integration
```yaml
# GitHub Actions
- name: Twelve-Factor Monitor
  run: ./.claude/skills/twelve-factor-monitor/scripts/skill-run.sh check
```

## Metrics Tracked

- **Compliance score**: 0.0 - 1.0
- **Factor status**: Pass/warn/fail per factor
- **Violation count**: By severity
- **Trend direction**: Improving/stable/degrading
- **Time series**: Historical compliance data

## Alerting

### Conditions
- Compliance drops below threshold
- New critical violations
- Compliance regression (score decreases)
- Factor transitions to fail

### Channels
- Bus events
- Console output
- File reports
- (Configurable: Slack, email, etc.)

## Data Storage

All metrics published to bus:
```json
{
  "topic": "monitor.metrics",
  "ts": "2025-11-19T12:00:00Z",
  "payload": {
    "score": 0.833,
    "factors": {...},
    "trend": "stable",
    "violations": 2
  }
}
```

## Configuration

```bash
MONITOR_INTERVAL=300        # Check every 5 min
MONITOR_THRESHOLD=0.75      # Alert below this
MONITOR_MODE=daemon         # daemon|once|hook
ALERT_ON_REGRESSION=true
HISTORY_RETENTION_DAYS=30
```

## Trend Analysis

```bash
$ ./skill-run.sh history

=== Compliance History ===

2025-11-19 12:00  Score: 0.833 ↑  Violations: 2
2025-11-19 11:00  Score: 0.750 →  Violations: 3
2025-11-19 10:00  Score: 0.667 ↓  Violations: 4

Trend: Improving (+0.166 in 2 hours)
Status: Above threshold (0.75)
```

## Integration Examples

### With Audit
```bash
# Monitor triggers periodic audits
while true; do
  bash ../twelve-factor-audit/scripts/skill-run.sh audit
  sleep $MONITOR_INTERVAL
done
```

### With Remediation
```bash
# Auto-remediate on violations
if [[ $COMPLIANCE_SCORE < $THRESHOLD ]]; then
  bash ../twelve-factor-remediation/scripts/skill-run.sh fix-all
fi
```

## Daemon Management

```bash
# Start as background daemon
./skill-run.sh start

# Check status
./skill-run.sh status

# Stop daemon
./skill-run.sh stop

# Restart
./skill-run.sh restart
```

## Reports

Generates periodic reports:
```bash
# Daily report
./skill-run.sh report --period daily

# Weekly summary
./skill-run.sh report --period weekly
```

## See Also

- **twelve-factor-audit**: On-demand auditing
- **twelve-factor-remediation**: Fix violations
- **Context Bus**: Historical data storage
