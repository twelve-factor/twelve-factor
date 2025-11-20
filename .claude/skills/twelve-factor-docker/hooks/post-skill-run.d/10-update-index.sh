#!/usr/bin/env bash
# Update skill index after run
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-docker"

[[ -x "$SKILL_DIR/scripts/bus.sh" ]] || exit 0
source "$SKILL_DIR/scripts/bus.sh"

publish_event "skill.twelve-factor-docker.run" '{"ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"}'

exit 0
