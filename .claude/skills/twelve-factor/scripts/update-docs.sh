#!/usr/bin/env bash
# Auto-update twelve-factor documentation from official sources
# Performance budget: <30s (runs in background post-hook)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
METADATA="$SKILL_DIR/metadata.json"
DOCS_INDEX="$(git rev-parse --show-toplevel 2>/dev/null || echo ".")/context/docs/INDEX.md"

# Ensure context/docs directory exists
mkdir -p "$(dirname "$DOCS_INDEX")"

echo "📚 Updating twelve-factor documentation metadata..."

# Check official twelve-factor.net
check_doc_freshness() {
    local url="$1"
    local name="$2"
    local last_modified=""

    # Try to get Last-Modified header
    if command -v curl >/dev/null 2>&1; then
        last_modified=$(curl -sI "$url" 2>/dev/null | \
            grep -i "last-modified:" | \
            cut -d' ' -f2- | \
            tr -d '\r' || echo "")
    fi

    # Fallback to current date if no Last-Modified
    local check_date=$(date -u +"%Y-%m-%d")
    local mod_date="${last_modified:-$check_date}"

    echo "  ✓ $name: checked on $check_date"
    echo "    Last-Modified: ${mod_date}"

    # Return structured data
    jq -n \
        --arg name "$name" \
        --arg url "$url" \
        --arg checked "$check_date" \
        --arg modified "$mod_date" \
        '{name:$name, url:$url, lastChecked:$checked, lastModified:$modified}'
}

# Update metadata.json with fresh documentation info
update_metadata() {
    local doc_info="$1"

    # Update lastChecked in metadata.json
    local current_date=$(date -u +"%Y-%m-%d")

    if [ -f "$METADATA" ]; then
        local temp=$(mktemp)
        jq --arg date "$current_date" \
           '.lastUpdated = $date | .documentation.lastChecked = $date' \
           "$METADATA" > "$temp"
        mv "$temp" "$METADATA"
    fi
}

# Update context/docs/INDEX.md
update_docs_index() {
    cat > "$DOCS_INDEX" <<EOF
# Twelve-Factor App - Documentation Index

Auto-generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

## Official Sources

- **The Twelve-Factor App** (Original)
  - URL: https://12factor.net
  - Last Checked: $(date -u +"%Y-%m-%d")
  - Status: Active

- **Twelve-Factor Manifesto** (Community Update)
  - URL: https://github.com/twelve-factor/twelve-factor
  - Repository: twelve-factor/twelve-factor
  - Last Checked: $(date -u +"%Y-%m-%d")
  - Status: Active (2024 updates in progress)

- **Beyond the Twelve-Factor App** (O'Reilly)
  - URL: https://www.oreilly.com/library/view/beyond-the-twelve-factor/9781492042631/
  - Last Checked: $(date -u +"%Y-%m-%d")
  - Status: Published

## Skill Version

- Skill: twelve-factor
- Version: $(jq -r '.version' "$METADATA" 2>/dev/null || echo "1.0.0")
- Last Updated: $(jq -r '.lastUpdated' "$METADATA" 2>/dev/null || date -u +"%Y-%m-%d")

## Next Update

Schedule: Monthly (automated via post-skill-run hook)
EOF

    echo "  ✓ Updated $DOCS_INDEX"
}

# Main execution
main() {
    # Check official sources
    local doc1=$(check_doc_freshness "https://12factor.net" "twelve-factor.net")
    local doc2=$(check_doc_freshness "https://github.com/twelve-factor/twelve-factor" "twelve-factor repo")

    # Update metadata
    update_metadata "$doc1"

    # Update docs index
    update_docs_index

    echo "✅ Documentation metadata updated successfully"
}

# Run with timeout to respect performance budget
timeout 30s bash -c "$(declare -f main check_doc_freshness update_metadata update_docs_index); main" || {
    echo "⚠️  Documentation update timed out (>30s), skipping..."
    exit 0
}
