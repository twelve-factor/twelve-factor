#!/usr/bin/env bash
# Environment checker for twelve-factor methodology
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
SKILL_DIR="$ROOT/.claude/skills/twelve-factor-methodology"

QUICK="${1:-}"

echo "=== Environment Check ==="
echo "Repository: $(basename "$ROOT")"
echo "Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')"
echo "Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"

# ============================================================================
# Detect project type
# ============================================================================
echo ""
echo "=== Project Detection ==="

PROJECT_TYPE="unknown"
PACKAGE_MANAGER="unknown"

if [[ -f "$ROOT/package.json" ]]; then
  PROJECT_TYPE="node"
  PACKAGE_MANAGER="npm"
  [[ -f "$ROOT/yarn.lock" ]] && PACKAGE_MANAGER="yarn"
  [[ -f "$ROOT/pnpm-lock.yaml" ]] && PACKAGE_MANAGER="pnpm"
  echo "  Type: Node.js"
  echo "  Package Manager: $PACKAGE_MANAGER"
  echo "  Node: $(node -v 2>/dev/null || echo 'N/A')"
fi

if [[ -f "$ROOT/requirements.txt" ]] || [[ -f "$ROOT/pyproject.toml" ]] || [[ -f "$ROOT/Pipfile" ]]; then
  PROJECT_TYPE="python"
  PACKAGE_MANAGER="pip"
  [[ -f "$ROOT/Pipfile" ]] && PACKAGE_MANAGER="pipenv"
  [[ -f "$ROOT/pyproject.toml" ]] && PACKAGE_MANAGER="poetry"
  echo "  Type: Python"
  echo "  Package Manager: $PACKAGE_MANAGER"
  echo "  Python: $(python3 -V 2>/dev/null || echo 'N/A')"
fi

if [[ -f "$ROOT/Gemfile" ]]; then
  PROJECT_TYPE="ruby"
  PACKAGE_MANAGER="bundler"
  echo "  Type: Ruby"
  echo "  Package Manager: $PACKAGE_MANAGER"
  echo "  Ruby: $(ruby -v 2>/dev/null || echo 'N/A')"
fi

if [[ -f "$ROOT/go.mod" ]]; then
  PROJECT_TYPE="go"
  PACKAGE_MANAGER="go-modules"
  echo "  Type: Go"
  echo "  Package Manager: $PACKAGE_MANAGER"
  echo "  Go: $(go version 2>/dev/null || echo 'N/A')"
fi

if [[ -f "$ROOT/Cargo.toml" ]]; then
  PROJECT_TYPE="rust"
  PACKAGE_MANAGER="cargo"
  echo "  Type: Rust"
  echo "  Package Manager: $PACKAGE_MANAGER"
  echo "  Rust: $(rustc --version 2>/dev/null || echo 'N/A')"
fi

# ============================================================================
# Quick twelve-factor checks
# ============================================================================
if [[ "$QUICK" != "--quick" ]]; then
  echo ""
  echo "=== Quick Twelve-Factor Scan ==="

  # I. Codebase
  if git rev-parse --git-dir >/dev/null 2>&1; then
    echo "  ✓ I. Codebase: Git repository detected"
  else
    echo "  ✗ I. Codebase: Not a Git repository"
  fi

  # II. Dependencies
  DEPS_FILES=0
  for f in package.json requirements.txt Pipfile Gemfile go.mod Cargo.toml pom.xml build.gradle; do
    [[ -f "$ROOT/$f" ]] && ((DEPS_FILES++)) && echo "  ✓ II. Dependencies: $f found"
  done
  [[ $DEPS_FILES -eq 0 ]] && echo "  ⚠ II. Dependencies: No manifest file detected"

  # III. Config
  if [[ -f "$ROOT/.env.example" ]] || [[ -f "$ROOT/.env.template" ]]; then
    echo "  ✓ III. Config: .env.example found"
  else
    echo "  ⚠ III. Config: No .env.example template"
  fi

  if [[ -f "$ROOT/.env" ]] && ! git check-ignore "$ROOT/.env" >/dev/null 2>&1; then
    echo "  ✗ III. Config: .env NOT in .gitignore (security risk!)"
  fi

  # V. Build, Release, Run
  if [[ -f "$ROOT/Dockerfile" ]]; then
    echo "  ✓ V. Build: Dockerfile found"
  fi

  if [[ -f "$ROOT/Procfile" ]]; then
    echo "  ✓ V. Build: Procfile found"
  fi

  # VII. Port Binding
  if grep -r "PORT.*env\|port.*process\.env\|os\.environ.*PORT" "$ROOT" --include="*.js" --include="*.py" --include="*.rb" 2>/dev/null | head -1 >/dev/null; then
    echo "  ✓ VII. Port Binding: PORT env var usage detected"
  else
    echo "  ⚠ VII. Port Binding: No PORT env var pattern found"
  fi

  # XI. Logs
  if grep -r "console\.log\|logger\|logging" "$ROOT" --include="*.js" --include="*.py" --include="*.rb" 2>/dev/null | head -1 >/dev/null; then
    echo "  ✓ XI. Logs: Logging detected"
  fi
fi

# ============================================================================
# Infrastructure files
# ============================================================================
echo ""
echo "=== Infrastructure Files ==="
for file in Dockerfile docker-compose.yml Procfile Makefile .github/workflows .gitlab-ci.yml; do
  if [[ -e "$ROOT/$file" ]]; then
    echo "  ✓ $file"
  fi
done

echo ""
echo "=== Environment Check Complete ==="

exit 0
