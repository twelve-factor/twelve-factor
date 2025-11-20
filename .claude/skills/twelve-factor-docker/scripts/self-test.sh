#!/usr/bin/env bash
# Self-test for twelve-factor-docker
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-docker"

echo "=== twelve-factor-docker Self-Test ==="

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
publish_event "test.selftest" '{"skill":"twelve-factor-docker"}' || {
  echo "✗ Bus publish failed"
  exit 1
}
echo "✓ Bus working"

echo ""
echo "=== Self-Test Complete ==="
exit 0
