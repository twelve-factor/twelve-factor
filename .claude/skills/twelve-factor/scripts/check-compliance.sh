#!/bin/bash
# Twelve-Factor Compliance Checker
# Quick automated check for common twelve-factor violations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

echo "🔍 Twelve-Factor Compliance Check"
echo "=================================="
echo ""

VIOLATIONS=0
WARNINGS=0

# Factor III: Config - Check for hardcoded credentials
echo "✓ Factor III: Config"
if grep -r -n --include="*.js" --include="*.py" --include="*.rb" --include="*.go" \
    -E "(password|api_key|secret|token)\s*=\s*['\"][^'\"]+['\"]" "$PROJECT_ROOT" 2>/dev/null | \
    grep -v "process\.env\|os\.environ\|ENV\[" | head -5; then
    echo "  ❌ Found hardcoded credentials/secrets"
    ((VIOLATIONS++))
else
    echo "  ✓ No obvious hardcoded credentials found"
fi
echo ""

# Factor II: Dependencies - Check for dependency manifests
echo "✓ Factor II: Dependencies"
HAS_DEPS=0
if [ -f "$PROJECT_ROOT/package.json" ]; then
    echo "  ✓ Found package.json (Node.js)"
    ((HAS_DEPS++))
fi
if [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/Pipfile" ]; then
    echo "  ✓ Found Python dependency file"
    ((HAS_DEPS++))
fi
if [ -f "$PROJECT_ROOT/Gemfile" ]; then
    echo "  ✓ Found Gemfile (Ruby)"
    ((HAS_DEPS++))
fi
if [ -f "$PROJECT_ROOT/go.mod" ]; then
    echo "  ✓ Found go.mod (Go)"
    ((HAS_DEPS++))
fi
if [ $HAS_DEPS -eq 0 ]; then
    echo "  ⚠️  No dependency manifest found"
    ((WARNINGS++))
fi
echo ""

# Factor XI: Logs - Check for file logging
echo "✓ Factor XI: Logs"
if grep -r -n --include="*.js" --include="*.py" --include="*.rb" \
    -E "FileHandler|createWriteStream.*log|open\(['\"].*\.log" "$PROJECT_ROOT" 2>/dev/null | head -5; then
    echo "  ❌ Found file logging (should use stdout)"
    ((VIOLATIONS++))
else
    echo "  ✓ No file logging detected"
fi
echo ""

# Factor I: Codebase - Check for version control
echo "✓ Factor I: Codebase"
if [ -d "$PROJECT_ROOT/.git" ]; then
    echo "  ✓ Git repository detected"
else
    echo "  ❌ No version control detected"
    ((VIOLATIONS++))
fi
echo ""

# Factor X: Dev/Prod Parity - Check for SQLite in production code
echo "✓ Factor X: Dev/Prod Parity"
if grep -r -n --include="*.js" --include="*.py" --include="*.rb" \
    -E "sqlite|db\.sqlite" "$PROJECT_ROOT" 2>/dev/null | \
    grep -v "test\|spec\|mock" | head -5; then
    echo "  ⚠️  SQLite usage detected (may violate dev/prod parity)"
    ((WARNINGS++))
else
    echo "  ✓ No SQLite usage in production code"
fi
echo ""

# Summary
echo "=================================="
echo "Summary:"
echo "  ❌ Violations: $VIOLATIONS"
echo "  ⚠️  Warnings: $WARNINGS"
echo ""

if [ $VIOLATIONS -gt 0 ]; then
    echo "❌ Compliance check FAILED"
    echo "Run: claude 'Review this project for twelve-factor compliance'"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  Compliance check passed with warnings"
    echo "Consider reviewing the warnings above"
    exit 0
else
    echo "✓ Compliance check PASSED"
    exit 0
fi
