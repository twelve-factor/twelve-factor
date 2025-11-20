#!/usr/bin/env bash
# Environment check for twelve-factor-docker
set -euo pipefail

echo "=== Environment Check ==="
echo "Repository: $(git rev-parse --show-toplevel | xargs basename)"
echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Skill: twelve-factor-docker"
echo ""

# Check bus backend
echo "Bus Backend: ${BUS_BACKEND:-json}"
echo "Agents: ${ENABLE_AGENTS:-1}"

exit 0
