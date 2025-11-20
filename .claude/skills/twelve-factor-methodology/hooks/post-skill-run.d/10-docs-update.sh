#!/usr/bin/env bash
# Auto-update official documentation metadata
# Runs after skill execution (non-blocking, best-effort)
set -euo pipefail

# Skip if disabled
[[ "${ENABLE_AUTO_DOCS:-1}" == "0" ]] && exit 0

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"
DOC_INDEX="$ROOT/context/docs/INDEX.md"
SKILL_YAML="$SKILL_DIR/SKILL.md"

# Timeout for this hook
TIMEOUT=15

timeout ${TIMEOUT}s bash -c '
  mkdir -p "$(dirname "'"$DOC_INDEX"'")"

  # Extract doc URLs from SKILL.md
  # Looking for patterns like: - [Name](https://example.com) (last checked: YYYY-MM-DD)
  URLS=$(grep -oP "https?://[^\s)]+" "'"$SKILL_YAML"'" 2>/dev/null || true)

  {
    echo "# Twelve-Factor Official Documentation Index"
    echo ""
    echo "Auto-generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo ""
    echo "## Official Sources"
    echo ""

    for url in $URLS; do
      # Try to get Last-Modified header
      last_mod=""
      if command -v curl >/dev/null 2>&1; then
        last_mod=$(curl -sI "$url" 2>/dev/null | grep -i "^last-modified:" | cut -d" " -f2- | tr -d "\r" || true)
      fi

      checked=$(date -u +"%Y-%m-%d")
      echo "- $url"
      echo "  - Last checked: $checked"
      [[ -n "$last_mod" ]] && echo "  - Last modified: $last_mod"
      echo ""
    done

    echo "## Content Files"
    echo ""
    ls -1 "'"$ROOT"'/content/"*.md 2>/dev/null | while read -r file; do
      echo "- $(basename "$file")"
    done
  } > "'"$DOC_INDEX"'"

  # Publish event
  if [[ -x "'"$SKILL_DIR"'/scripts/bus.sh" ]]; then
    source "'"$SKILL_DIR"'/scripts/bus.sh"
    publish_event "docs.updated" "{\"file\":\"$DOC_INDEX\",\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
  fi

  echo "✓ Docs index updated: $DOC_INDEX"
' 2>&1 | head -20 || {
  echo "⚠ Docs update failed or timed out (non-critical)" >&2
}

exit 0
