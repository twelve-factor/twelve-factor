#!/usr/bin/env bash
# Self-test for twelve-factor skill
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"

FAST_MODE="${1:-}"

echo "=== Twelve-Factor Skill Self-Test ==="

# ============================================================================
# Tool availability
# ============================================================================
echo ""
echo "Checking required tools..."
MISSING=()
OPTIONAL_MISSING=()

# Required
for tool in bash git jq; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  ✓ $tool: $(command -v $tool)"
  else
    MISSING+=("$tool")
    echo "  ✗ $tool: MISSING"
  fi
done

# Optional but recommended
for tool in yq sqlite3 curl timeout parallel; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  ✓ $tool: $(command -v $tool)"
  else
    OPTIONAL_MISSING+=("$tool")
    echo "  ⚠ $tool: missing (optional)"
  fi
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo ""
  echo "✗ Missing required tools: ${MISSING[*]}"
  exit 1
fi

if [[ ${#OPTIONAL_MISSING[@]} -gt 0 ]]; then
  echo ""
  echo "⚠ Missing optional tools: ${OPTIONAL_MISSING[*]}"
  echo "  Some features may be limited"
fi

# ============================================================================
# File structure
# ============================================================================
echo ""
echo "Checking file structure..."
REQUIRED_FILES=(
  "$SKILL_DIR/SKILL.md"
  "$SKILL_DIR/scripts/bus.sh"
  "$SKILL_DIR/scripts/skill-run.sh"
  "$SKILL_DIR/templates/bus.config.yaml"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ -f "$file" ]]; then
    echo "  ✓ $(basename "$file")"
  else
    echo "  ✗ Missing: $file"
    exit 1
  fi
done

# ============================================================================
# Bus functionality
# ============================================================================
if [[ "$FAST_MODE" != "--fast" ]]; then
  echo ""
  echo "Testing bus functionality..."
  source "$SKILL_DIR/scripts/bus.sh"

  # Test event publishing
  publish_event "test.selftest" '{"status":"running"}' || {
    echo "  ✗ Event publishing failed"
    exit 1
  }
  echo "  ✓ Event publishing"

  # Test KV store
  put_kv "test.key" '"test-value"' || {
    echo "  ✗ KV put failed"
    exit 1
  }
  echo "  ✓ KV put"

  VALUE=$(get_kv "test.key")
  if [[ "$VALUE" == '"test-value"' ]]; then
    echo "  ✓ KV get"
  else
    echo "  ✗ KV get failed (got: $VALUE)"
    exit 1
  fi

  # Test event reading
  EVENTS=$(read_events "test\\.selftest" 1)
  if [[ -n "$EVENTS" ]]; then
    echo "  ✓ Event reading"
  else
    echo "  ✗ Event reading failed"
    exit 1
  fi
fi

# ============================================================================
# Script syntax
# ============================================================================
echo ""
echo "Checking script syntax..."
for script in "$SKILL_DIR/scripts/"*.sh "$SKILL_DIR/hooks/pre-"* "$SKILL_DIR/hooks/post-skill-run.d/"*.sh "$SKILL_DIR/agents/"*.sh; do
  [[ -f "$script" ]] || continue
  bash -n "$script" 2>&1 || {
    echo "  ✗ Syntax error in $(basename "$script")"
    exit 1
  }
done
echo "  ✓ All scripts syntax valid"

# ============================================================================
# YAML validation
# ============================================================================
if command -v yq >/dev/null 2>&1; then
  echo ""
  echo "Validating YAML files..."
  yq eval . "$SKILL_DIR/templates/bus.config.yaml" >/dev/null || {
    echo "  ✗ Invalid bus.config.yaml"
    exit 1
  }
  echo "  ✓ YAML files valid"
fi

# ============================================================================
# Permissions
# ============================================================================
echo ""
echo "Checking executable permissions..."
for script in "$SKILL_DIR/scripts/"*.sh; do
  if [[ -x "$script" ]]; then
    echo "  ✓ $(basename "$script")"
  else
    echo "  ⚠ Not executable: $(basename "$script")"
  fi
done

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "=== Self-Test Complete ==="
echo "  Status: ✓ PASSED"
echo "  Backend: ${BUS_BACKEND:-json}"
echo "  Skill Dir: $SKILL_DIR"

exit 0
