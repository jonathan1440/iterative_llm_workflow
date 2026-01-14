#!/bin/bash

# get-next-task.sh
# Finds the next incomplete task in a story or across all tasks

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get arguments
TASKS_FILE="$1"
STORY_NAME="${2:-}"

if [ -z "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Missing tasks file${NC}"
    echo "Usage: $0 <tasks-file> [\"User Story 1\"]"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    exit 1
fi

# Extract story number if provided
STORY_NUM=""
if [ -n "$STORY_NAME" ]; then
    STORY_NUM=$(echo "$STORY_NAME" | grep -oE "[0-9]+" | head -1)
fi

# Find next incomplete task
if [ -n "$STORY_NUM" ]; then
    # Find next incomplete task in this story
    NEXT_TASK=$(grep "^- \[ \] .*\[US$STORY_NUM\]" "$TASKS_FILE" | head -1)
else
    # Find next incomplete task overall
    NEXT_TASK=$(grep "^- \[ \] " "$TASKS_FILE" | head -1)
fi

if [ -z "$NEXT_TASK" ]; then
    echo "NEXT_TASK_ID="
    echo "NO_MORE_TASKS=true"
    if [ -n "$STORY_NUM" ]; then
        echo -e "${GREEN}✅ All tasks complete for User Story $STORY_NUM${NC}"
    else
        echo -e "${GREEN}✅ All tasks complete!${NC}"
    fi
    exit 0
fi

# Extract task ID
NEXT_TASK_ID=$(echo "$NEXT_TASK" | grep -oE "T[0-9]+" | head -1)

if [ -z "$NEXT_TASK_ID" ]; then
    echo -e "${RED}Error: Could not extract task ID from: $NEXT_TASK${NC}"
    exit 1
fi

echo "NEXT_TASK_ID=$NEXT_TASK_ID"
echo "NO_MORE_TASKS=false"
echo "NEXT_TASK_LINE=$NEXT_TASK"
