#!/bin/bash
# Analyze git history for patterns worth capturing

set -e

DAYS="${1:-90}"  # Default to last 90 days

echo "## Analyzing Git History (Last $DAYS Days)"
echo ""

# Get date for filtering
SINCE_DATE=$(date -d "$DAYS days ago" +%Y-%m-%d 2>/dev/null || date -v-${DAYS}d +%Y-%m-%d 2>/dev/null)

# Check if git repo exists
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not a git repository"
    exit 1
fi

# Pattern 1: Repeated fixes (same file modified many times)
echo "**Pattern: Frequent File Changes**"
echo ""
git log --since="$SINCE_DATE" --name-only --pretty=format: | \
    sort | uniq -c | sort -rn | head -10 | \
    while read -r count file; do
        if [ "$count" -gt 5 ] && [ -n "$file" ]; then
            echo "- $file: modified $count times (may need refactoring)"
        fi
    done
echo ""

# Pattern 2: Common commit message patterns
echo "**Pattern: Common Changes**"
echo ""
git log --since="$SINCE_DATE" --pretty=format:"%s" | \
    grep -oE "^(Fix|Refactor|Add|Update|Remove)" | \
    sort | uniq -c | sort -rn | \
    while read -r count pattern; do
        echo "- $pattern: $count commits"
    done
echo ""

# Pattern 3: Large commits (potential mistakes)
echo "**Pattern: Large Commits (Potential Issues)**"
echo ""
git log --since="$SINCE_DATE" --pretty=format:"%h %s" --shortstat | \
    awk '/^[0-9a-f]{7}/ {msg=$0} /file.*changed/ {if($4+$6 > 100) print msg, $0}' | \
    head -5
echo ""

# Pattern 4: Reverts (indicates rushed decisions)
echo "**Pattern: Reverted Commits**"
echo ""
REVERTS=$(git log --since="$SINCE_DATE" --grep="Revert" --pretty=format:"%s" | wc -l)
if [ "$REVERTS" -gt 0 ]; then
    echo "Found $REVERTS reverted commits"
    git log --since="$SINCE_DATE" --grep="Revert" --pretty=format:"- %s (%cr)" | head -5
else
    echo "No reverted commits (good sign)"
fi
echo ""

# Pattern 5: Test file changes
echo "**Pattern: Test Coverage**"
echo ""
TEST_COMMITS=$(git log --since="$SINCE_DATE" --grep="test" -i --pretty=format:"%h" | wc -l)
TOTAL_COMMITS=$(git log --since="$SINCE_DATE" --pretty=format:"%h" | wc -l)
if [ "$TOTAL_COMMITS" -gt 0 ]; then
    TEST_PERCENTAGE=$((TEST_COMMITS * 100 / TOTAL_COMMITS))
    echo "Test-related commits: $TEST_COMMITS / $TOTAL_COMMITS ($TEST_PERCENTAGE%)"
fi
echo ""

# Pattern 6: Commit message quality
echo "**Pattern: Commit Message Quality**"
echo ""
SHORT_MSGS=$(git log --since="$SINCE_DATE" --pretty=format:"%s" | awk 'length($0) < 20' | wc -l)
if [ "$SHORT_MSGS" -gt 10 ]; then
    echo "Warning: $SHORT_MSGS commits with short messages (< 20 chars)"
    echo "Consider adding commit message standards to agents.md"
else
    echo "✓ Commit messages are generally descriptive"
fi
echo ""

echo "Analysis complete. Review patterns above for potential learnings."
