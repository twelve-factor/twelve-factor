#!/usr/bin/env bash
# MODES: all
# Documentation sync agent
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"
source "$SKILL_DIR/scripts/bus.sh"

MODE="${1:-sync}"

# ============================================================================
# Sync documentation
# ============================================================================
DOC_INDEX="$ROOT/context/docs/INDEX.md"

# Official twelve-factor docs
OFFICIAL_DOCS=(
  "https://12factor.net"
  "https://github.com/twelve-factor/twelve-factor"
)

mkdir -p "$(dirname "$DOC_INDEX")"

{
  echo "# Twelve-Factor Documentation Index"
  echo ""
  echo "Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo ""
  echo "## Official Sources"
  echo ""

  for url in "${OFFICIAL_DOCS[@]}"; do
    echo "- [$url]($url)"

    # Try to get last-modified if curl available
    if command -v curl >/dev/null 2>&1; then
      last_mod=$(curl -sI "$url" 2>/dev/null | grep -i "^last-modified:" | cut -d" " -f2- | tr -d "\r" || echo "unknown")
      echo "  - Last checked: $(date -u +%Y-%m-%d)"
      echo "  - Last modified: $last_mod"
    fi
    echo ""
  done

  echo "## Local Content"
  echo ""
  if [[ -d "$ROOT/content" ]]; then
    find "$ROOT/content" -name "*.md" -type f | sort | while read -r file; do
      echo "- [$(basename "$file")]($file)"
    done
  fi
} > "$DOC_INDEX"

# Publish event
publish_event "agent.docs-sync.result" "{\"file\":\"$DOC_INDEX\",\"status\":\"synced\"}"

echo "✓ Documentation index updated: $DOC_INDEX"

exit 0
