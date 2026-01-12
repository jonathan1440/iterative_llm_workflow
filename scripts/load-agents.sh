#!/bin/bash
# Load and display current agents.md status

set -e

AGENTS_FILE=".cursor/agents.md"

if [ ! -f "$AGENTS_FILE" ]; then
    echo "ERROR: agents.md not found at $AGENTS_FILE"
    echo "Create it first or check your directory"
    exit 1
fi

echo "✅ agents.md Status"
echo ""

# Count sections
SECTIONS=$(grep -c "^## " "$AGENTS_FILE" || echo "0")
echo "Sections: $SECTIONS"

# Count learnings (heuristic: look for date patterns)
LEARNINGS=$(grep -c "Added: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" "$AGENTS_FILE" || echo "0")
echo "Total Learnings: $LEARNINGS"

# Find recent additions (last 7 days)
WEEK_AGO=$(date -d '7 days ago' +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d 2>/dev/null || echo "2026-01-06")
RECENT=$(grep "Added: " "$AGENTS_FILE" | grep -c "$WEEK_AGO\|$(date +%Y-%m-%d)" || echo "0")
echo "Recent (last 7 days): $RECENT"

echo ""
echo "File: $AGENTS_FILE"
echo ""

# Show last 5 learnings
echo "📚 Recent Learnings:"
echo ""
grep -B3 "Added: " "$AGENTS_FILE" | tail -20 | head -15 || echo "No learnings found"

echo ""
echo "Ready for review"
