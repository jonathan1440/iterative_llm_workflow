#!/bin/bash

# add-single-task.sh
# Adds a single task to an existing tasks.md file

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
TASK_DESCRIPTION="$2"
STORY_NAME="${3:-}"
INSERT_AFTER="${4:-}"

if [ -z "$TASKS_FILE" ] || [ -z "$TASK_DESCRIPTION" ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: $0 <tasks-file> \"<task description>\" [\"User Story 1\"] [T017]"
    echo "Example: $0 docs/specs/feature-tasks.md \"Create User model in src/models/user.js\" \"User Story 1\" T016"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}📝 Adding task to: $TASKS_FILE${NC}"
echo ""

# Find next task ID
LAST_TASK_ID=$(grep "^- \[.\] T[0-9]" "$TASKS_FILE" | grep -oE "T[0-9]+" | tail -1 | grep -oE "[0-9]+")
if [ -z "$LAST_TASK_ID" ]; then
    NEXT_TASK_ID="T001"
else
    NEXT_NUM=$((LAST_TASK_ID + 1))
    NEXT_TASK_ID=$(printf "T%03d" "$NEXT_NUM")
fi

echo -e "${BLUE}Next task ID: $NEXT_TASK_ID${NC}"

# Determine story number if provided
STORY_NUM=""
if [ -n "$STORY_NAME" ]; then
    STORY_NUM=$(echo "$STORY_NAME" | grep -oE "[0-9]+" | head -1)
    if [ -n "$STORY_NUM" ]; then
        echo -e "${BLUE}Story: User Story $STORY_NUM${NC}"
    fi
fi

# Output task details for AI to format
echo "TASK_ID=$NEXT_TASK_ID"
echo "TASK_DESCRIPTION=$TASK_DESCRIPTION"
echo "STORY_NUM=$STORY_NUM"
echo "INSERT_AFTER=$INSERT_AFTER"

# Find insertion point
if [ -n "$INSERT_AFTER" ]; then
    # Insert after specific task
    INSERT_LINE=$(grep -n "^- \[.\] .*$INSERT_AFTER" "$TASKS_FILE" | cut -d: -f1 | head -1)
    if [ -z "$INSERT_LINE" ]; then
        echo -e "${YELLOW}⚠️  Task $INSERT_AFTER not found, will append to end${NC}"
        INSERT_LINE=$(wc -l < "$TASKS_FILE")
    else
        echo -e "${BLUE}Inserting after task $INSERT_AFTER (line $INSERT_LINE)${NC}"
    fi
elif [ -n "$STORY_NUM" ]; then
    # Insert at end of story phase
    STORY_HEADER=$(grep -n "## Phase.*User Story $STORY_NUM" "$TASKS_FILE" | cut -d: -f1 | head -1)
    if [ -n "$STORY_HEADER" ]; then
        # Find next phase or end of file
        NEXT_PHASE=$(tail -n +$((STORY_HEADER + 1)) "$TASKS_FILE" | grep -n "^## Phase" | head -1 | cut -d: -f1)
        if [ -n "$NEXT_PHASE" ]; then
            INSERT_LINE=$((STORY_HEADER + NEXT_PHASE - 1))
        else
            INSERT_LINE=$(wc -l < "$TASKS_FILE")
        fi
        echo -e "${BLUE}Inserting at end of User Story $STORY_NUM phase${NC}"
    else
        echo -e "${YELLOW}⚠️  User Story $STORY_NUM not found, will append to end${NC}"
        INSERT_LINE=$(wc -l < "$TASKS_FILE")
    fi
else
    # Append to end
    INSERT_LINE=$(wc -l < "$TASKS_FILE")
    echo -e "${BLUE}Appending to end of file${NC}"
fi

echo ""
echo -e "${GREEN}Ready to add task: $NEXT_TASK_ID${NC}"
echo -e "${GRAY}Description: $TASK_DESCRIPTION${NC}"
