#!/bin/bash
# Check prerequisites before refactoring

set -e

REFACTOR_DESC="$1"
TARGET="$2"

if [ -z "$REFACTOR_DESC" ]; then
    echo "ERROR: No refactor description provided"
    echo "Usage: /refactor \"Description\" [target-file]"
    exit 1
fi

echo "✅ Refactor Prerequisites Check"
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "❌ ERROR: Uncommitted changes detected"
    echo ""
    git status --short
    echo ""
    echo "Commit or stash changes before refactoring"
    exit 1
else
    echo "Working directory: Clean ✓"
fi

# Check if tests exist
if [ -d "tests" ]; then
    TEST_COUNT=$(find tests -name "*.py" -o -name "*.js" -o -name "*.ts" 2>/dev/null | wc -l)
    echo "Tests: Found $TEST_COUNT test files ✓"
else
    echo "⚠️  WARNING: No tests directory found"
    echo "Refactoring without tests is risky"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Determine test command
if [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
    TEST_CMD="pytest tests/"
    echo "Test command: $TEST_CMD ✓"
elif [ -f "package.json" ]; then
    TEST_CMD="npm test"
    echo "Test command: $TEST_CMD ✓"
else
    echo "⚠️  WARNING: Could not determine test command"
    TEST_CMD=""
fi

# Check target exists if specified
if [ -n "$TARGET" ]; then
    if [ -f "$TARGET" ]; then
        LINE_COUNT=$(wc -l < "$TARGET")
        echo "Target: $TARGET ($LINE_COUNT lines) ✓"
    elif [ -d "$TARGET" ]; then
        FILE_COUNT=$(find "$TARGET" -type f | wc -l)
        echo "Target: $TARGET ($FILE_COUNT files) ✓"
    else
        echo "❌ ERROR: Target not found: $TARGET"
        exit 1
    fi
else
    echo "Target: Entire codebase (no specific target)"
fi

# Check git branch
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
echo "Git branch: $BRANCH ✓"

echo ""
echo "Ready to refactor ✓"
echo ""
echo "Description: $REFACTOR_DESC"

# Export for use by other scripts
export REFACTOR_DESC
export TARGET
export TEST_CMD
