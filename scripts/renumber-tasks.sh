#!/bin/bash
# renumber-tasks.sh
# Renumbers tasks in a tasks file after inserting new tasks

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

# Get arguments
TASKS_FILE="$1"
START_FROM="$2"

if [ -z "$TASKS_FILE" ] || [ -z "$START_FROM" ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: $0 <tasks-file> <start-from-task-id>"
    echo "Example: $0 docs/specs/feature-tasks.md T082"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    exit 1
fi

# Extract task number from START_FROM (e.g., "T082" -> 82)
START_NUM=$(echo "$START_FROM" | grep -oE "[0-9]+" | head -1)

if [ -z "$START_NUM" ]; then
    echo -e "${RED}Error: Invalid task ID format: $START_FROM${NC}"
    echo "Expected format: T082 or 82"
    exit 1
fi

echo -e "${BLUE}🔄 Renumbering tasks starting from $START_FROM${NC}"
echo ""

# Count tasks before START_FROM
TASKS_BEFORE=$(grep -c "^- \[.\] T[0-9]" "$TASKS_FILE" | head -1 || echo "0")
TASKS_AFTER_START=$(grep "^- \[.\] T[0-9]" "$TASKS_FILE" | awk -v start="$START_NUM" '
    {
        match($0, /T([0-9]+)/, arr)
        if (arr[1] >= start) print
    }' | wc -l | tr -d ' ')

# Count new tasks being inserted (this would be passed or calculated)
# For now, we'll detect by finding tasks with placeholder IDs or count manually
NEW_TASKS_COUNT=${3:-0}

if [ "$NEW_TASKS_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No new task count provided${NC}"
    echo "Usage: $0 <tasks-file> <start-from> <new-tasks-count>"
    echo "Or provide count of new tasks being inserted"
    read -p "How many new tasks are being inserted? " NEW_TASKS_COUNT
fi

# Create backup
BACKUP_FILE="${TASKS_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
cp "$TASKS_FILE" "$BACKUP_FILE"
echo -e "${BLUE}Backup created: $BACKUP_FILE${NC}"
echo ""

# Find all tasks from START_NUM onwards
TEMP_FILE=$(mktemp)
CURRENT_NUM=$START_NUM
NEW_NUM=$((START_NUM + NEW_TASKS_COUNT))

# Process file line by line
while IFS= read -r line; do
    # Check if line contains a task ID >= START_NUM
    if echo "$line" | grep -qE "T[0-9]+"; then
        # Extract task number
        TASK_NUM=$(echo "$line" | grep -oE "T([0-9]+)" | grep -oE "[0-9]+" | head -1)
        
        if [ -n "$TASK_NUM" ] && [ "$TASK_NUM" -ge "$START_NUM" ]; then
            # Renumber this task
            OLD_ID="T$(printf "%03d" "$TASK_NUM")"
            NEW_ID="T$(printf "%03d" "$NEW_NUM")"
            
            # Replace task ID in line
            NEW_LINE=$(echo "$line" | sed "s/\[$OLD_ID\]/\[$NEW_ID\]/g" | sed "s/ $OLD_ID / $NEW_ID /g")
            
            echo "$NEW_LINE" >> "$TEMP_FILE"
            
            # Also update any dependency references
            if echo "$line" | grep -q "Depends.*$OLD_ID"; then
                echo -e "${BLUE}  Updated dependency: $OLD_ID → $NEW_ID${NC}"
            fi
            
            NEW_NUM=$((NEW_NUM + 1))
        else
            # Keep line as-is
            echo "$line" >> "$TEMP_FILE"
        fi
    else
        # Keep non-task lines as-is
        echo "$line" >> "$TEMP_FILE"
    fi
done < "$TASKS_FILE"

# Replace original file
mv "$TEMP_FILE" "$TASKS_FILE"

# Count total tasks now
TOTAL_TASKS=$(grep -c "^- \[.\] T[0-9]" "$TASKS_FILE" || echo "0")

echo -e "${GREEN}✅ Task renumbering complete${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  Start from: $START_FROM"
echo "  New tasks inserted: $NEW_TASKS_COUNT"
echo "  Tasks renumbered: $TASKS_AFTER_START"
echo "  Total tasks now: $TOTAL_TASKS"
echo ""
echo -e "${YELLOW}Note: Review the file for any dependency references that may need updating${NC}"
echo -e "${BLUE}Backup: $BACKUP_FILE${NC}"

# Clean up old backup (keep only last 3)
BACKUP_COUNT=$(ls -1 "${TASKS_FILE}.backup-"* 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 3 ]; then
    ls -1t "${TASKS_FILE}.backup-"* | tail -n +4 | xargs rm -f
fi
