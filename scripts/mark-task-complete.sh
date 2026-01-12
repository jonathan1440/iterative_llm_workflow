#!/bin/bash

# mark-task-complete.sh
# Marks a task as complete in the tasks file

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get arguments
TASKS_FILE="$1"
TASK_ID="$2"

if [ -z "$TASKS_FILE" ] || [ -z "$TASK_ID" ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: $0 <tasks-file> <task-id>"
    echo "Example: $0 docs/specs/feature-tasks.md T017"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    exit 1
fi

# Normalize task ID (add T prefix if missing)
if ! echo "$TASK_ID" | grep -q "^T"; then
    TASK_ID="T$TASK_ID"
fi

echo -e "${BLUE}Marking task complete: $TASK_ID${NC}"
echo ""

# Find the task line (try both formats: [T011] and T011)
TASK_LINE=$(grep "^- \[ \] \[$TASK_ID\]" "$TASKS_FILE" || grep "^- \[ \] $TASK_ID " "$TASKS_FILE" || true)

if [ -z "$TASK_LINE" ]; then
    # Check if already complete (try both formats)
    COMPLETE_LINE=$(grep "^- \[X\] \[$TASK_ID\]" "$TASKS_FILE" || grep "^- \[X\] $TASK_ID " "$TASKS_FILE" || true)
    if [ -n "$COMPLETE_LINE" ]; then
        echo -e "${YELLOW}Task $TASK_ID is already marked complete${NC}"
        echo -e "${GRAY}$COMPLETE_LINE${NC}"
        exit 0
    fi
    
    echo -e "${RED}Error: Task $TASK_ID not found or has incorrect format${NC}"
    echo ""
    echo -e "${YELLOW}Looking for similar tasks:${NC}"
    grep "$TASK_ID" "$TASKS_FILE" | head -3 || echo "  No tasks found with ID $TASK_ID"
    exit 1
fi

echo -e "${YELLOW}Current:${NC}"
echo "  $TASK_LINE"
echo ""

# Create backup
BACKUP_FILE="${TASKS_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
cp "$TASKS_FILE" "$BACKUP_FILE"

# Replace [ ] with [X] for this specific task
# Use sed to replace only the first [ ] on lines containing this task ID
# Try both formats: [T011] and T011
if echo "$TASK_LINE" | grep -q "\[$TASK_ID\]"; then
    sed -i.tmp "/\[$TASK_ID\]/s/^- \[ \]/- \[X\]/" "$TASKS_FILE"
else
    sed -i.tmp "/ $TASK_ID /s/^- \[ \]/- \[X\]/" "$TASKS_FILE"
fi
rm "${TASKS_FILE}.tmp" 2>/dev/null || true

# Verify the change (try both formats)
NEW_LINE=$(grep "^- \[X\] \[$TASK_ID\]" "$TASKS_FILE" || grep "^- \[X\] $TASK_ID " "$TASKS_FILE" || true)

if [ -z "$NEW_LINE" ]; then
    echo -e "${RED}Error: Failed to mark task complete${NC}"
    echo -e "${YELLOW}Restoring from backup${NC}"
    mv "$BACKUP_FILE" "$TASKS_FILE"
    exit 1
fi

echo -e "${GREEN}✓ Marked complete:${NC}"
echo "  $NEW_LINE"
echo ""

# Calculate overall progress
STORY_NUM=$(echo "$TASK_LINE" | grep -oE "US[0-9]+" | grep -oE "[0-9]+" | head -1)

if [ -n "$STORY_NUM" ]; then
    # Count tasks for this story
    TOTAL=$(grep "^- \[.\] .*\[US$STORY_NUM\]" "$TASKS_FILE" | wc -l | tr -d ' ')
    COMPLETE=$(grep "^- \[X\] .*\[US$STORY_NUM\]" "$TASKS_FILE" | wc -l | tr -d ' ')
    PERCENT=$((COMPLETE * 100 / TOTAL))
    
    echo -e "${BLUE}User Story $STORY_NUM Progress: $COMPLETE/$TOTAL tasks ($PERCENT%)${NC}"
else
    # Count all tasks
    TOTAL=$(grep "^- \[.\] T[0-9]" "$TASKS_FILE" | wc -l | tr -d ' ')
    COMPLETE=$(grep "^- \[X\] T[0-9]" "$TASKS_FILE" | wc -l | tr -d ' ')
    PERCENT=$((COMPLETE * 100 / TOTAL))
    
    echo -e "${BLUE}Overall Progress: $COMPLETE/$TOTAL tasks ($PERCENT%)${NC}"
fi

# Clean up old backup (keep only last 3)
BACKUP_COUNT=$(ls -1 "${TASKS_FILE}.backup-"* 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 3 ]; then
    ls -1t "${TASKS_FILE}.backup-"* | tail -n +4 | xargs rm -f
fi

echo ""
echo -e "${GREEN}✅ Task $TASK_ID marked complete${NC}"
echo -e "${GRAY}Backup saved: $BACKUP_FILE${NC}"
