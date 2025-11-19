#!/usr/bin/env bash
# Hook: Update documentation after skill run
# Auto-checks official docs for updates

set -euo pipefail

SKILL_DIR="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")/.claude/skills/twelve-factor"

echo "📚 Updating documentation index..."

# Run the docs update script
bash "$SKILL_DIR/scripts/update-docs.sh" || {
    echo "⚠️  Documentation update failed, skipping..."
    exit 0
}

echo "✅ Documentation index updated"
