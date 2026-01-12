#!/bin/bash

# get-story-tasks.sh
# Extracts all tasks and details for a specific user story

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
STORY_NAME="$2"

if [ -z "$TASKS_FILE" ] || [ -z "$STORY_NAME" ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: $0 <tasks-file> <\"User Story 1\">"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    exit 1
fi

# Extract story number
STORY_NUM=$(echo "$STORY_NAME" | grep -oE "[0-9]+" | head -1)

echo -e "${BLUE}📋 Story Details: $STORY_NAME${NC}"
echo ""

# Extract story section from tasks file
# Find line number of story header
STORY_LINE=$(grep -n "## Phase.*$STORY_NAME" "$TASKS_FILE" | cut -d: -f1)

if [ -z "$STORY_LINE" ]; then
    echo -e "${RED}Error: Story not found in tasks file${NC}"
    exit 1
fi

# Find next phase header (or end of file)
NEXT_PHASE_LINE=$(tail -n +$((STORY_LINE + 1)) "$TASKS_FILE" | grep -n "^## Phase" | head -1 | cut -d: -f1)

if [ -n "$NEXT_PHASE_LINE" ]; then
    END_LINE=$((STORY_LINE + NEXT_PHASE_LINE))
else
    END_LINE=$(wc -l < "$TASKS_FILE")
fi

# Extract story section
STORY_SECTION=$(sed -n "${STORY_LINE},${END_LINE}p" "$TASKS_FILE")

# Extract story goal
STORY_GOAL=$(echo "$STORY_SECTION" | grep "^\*\*Story Goal\*\*:" | sed 's/^\*\*Story Goal\*\*: //')
if [ -n "$STORY_GOAL" ]; then
    echo -e "${GREEN}Goal:${NC} $STORY_GOAL"
    echo ""
fi

# Extract acceptance criteria
echo -e "${BLUE}Acceptance Criteria:${NC}"
ACC_CRITERIA=$(echo "$STORY_SECTION" | sed -n '/^\*\*Acceptance Criteria\*\*/,/^\*\*/p' | grep "^- \[")
if [ -n "$ACC_CRITERIA" ]; then
    echo "$ACC_CRITERIA" | while read -r line; do
        if echo "$line" | grep -q "- \[X\]"; then
            echo -e "${GREEN}$line${NC}"
        else
            echo -e "${YELLOW}$line${NC}"
        fi
    done
else
    echo -e "${GRAY}  (None specified)${NC}"
fi
echo ""

# Extract independent test scenario
echo -e "${BLUE}Independent Test Scenario:${NC}"
TEST_SCENARIO=$(echo "$STORY_SECTION" | sed -n '/^\*\*Independent Test/,/^```$/p' | grep -v "^\*\*Independent Test" | grep -v "^```")
if [ -n "$TEST_SCENARIO" ]; then
    echo "$TEST_SCENARIO" | head -5
    LINE_COUNT=$(echo "$TEST_SCENARIO" | wc -l)
    if [ "$LINE_COUNT" -gt 5 ]; then
        echo -e "${GRAY}  ... ($LINE_COUNT total steps)${NC}"
    fi
else
    echo -e "${GRAY}  (None specified)${NC}"
fi
echo ""

# Extract and display tasks
echo -e "${BLUE}Tasks:${NC}"
echo ""

# Get all tasks for this story (with [US#] marker)
if [ -n "$STORY_NUM" ]; then
    TASKS=$(echo "$STORY_SECTION" | grep "^- \[.\] .*\[US$STORY_NUM\]")
else
    # For non-US phases (Setup, Foundation, Polish)
    TASKS=$(echo "$STORY_SECTION" | grep "^- \[.\] T[0-9]")
fi

if [ -z "$TASKS" ]; then
    echo -e "${YELLOW}No tasks found with [US$STORY_NUM] marker${NC}"
    echo ""
    echo -e "${YELLOW}Showing all tasks in this phase:${NC}"
    TASKS=$(echo "$STORY_SECTION" | grep "^- \[.\] T[0-9]")
fi

# Display tasks grouped by status
INCOMPLETE=$(echo "$TASKS" | grep "^- \[ \]" || true)
COMPLETE=$(echo "$TASKS" | grep "^- \[X\]" || true)

INCOMPLETE_COUNT=$(echo "$INCOMPLETE" | grep -c "^- \[ \]" || echo "0")
COMPLETE_COUNT=$(echo "$COMPLETE" | grep -c "^- \[X\]" || echo "0")
TOTAL_COUNT=$((INCOMPLETE_COUNT + COMPLETE_COUNT))

if [ "$TOTAL_COUNT" -eq 0 ]; then
    echo -e "${RED}No tasks found for this story${NC}"
    exit 1
fi

# Show incomplete tasks first
if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}Incomplete ($INCOMPLETE_COUNT):${NC}"
    echo "$INCOMPLETE" | while read -r line; do
        # Extract task ID
        TASK_ID=$(echo "$line" | grep -oE "T[0-9]+" | head -1)
        # Highlight parallel tasks
        if echo "$line" | grep -q "\[P\]"; then
            echo -e "  ${YELLOW}$line${NC} ${BLUE}(parallel)${NC}"
        else
            echo -e "  ${YELLOW}$line${NC}"
        fi
    done
    echo ""
fi

# Show completed tasks
if [ "$COMPLETE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}Complete ($COMPLETE_COUNT):${NC}"
    echo "$COMPLETE" | while read -r line; do
        echo -e "  ${GRAY}$line${NC}"
    done
    echo ""
fi

# Calculate progress
if [ "$TOTAL_COUNT" -gt 0 ]; then
    PERCENT=$((COMPLETE_COUNT * 100 / TOTAL_COUNT))
    echo -e "${BLUE}Progress: $COMPLETE_COUNT/$TOTAL_COUNT tasks ($PERCENT%)${NC}"
    echo ""
fi

# Show next task to work on
if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
    NEXT_TASK=$(echo "$INCOMPLETE" | head -1)
    NEXT_TASK_ID=$(echo "$NEXT_TASK" | grep -oE "T[0-9]+" | head -1)
    echo -e "${GREEN}Next Task:${NC}"
    echo -e "  $NEXT_TASK"
    echo ""
    
    # Check if next task is parallel
    if echo "$NEXT_TASK" | grep -q "\[P\]"; then
        # Find other parallel tasks at same level
        OTHER_PARALLEL=$(echo "$INCOMPLETE" | grep "\[P\]" | grep -v "$NEXT_TASK_ID")
        if [ -n "$OTHER_PARALLEL" ]; then
            echo -e "${BLUE}Can work in parallel with:${NC}"
            echo "$OTHER_PARALLEL" | head -3 | while read -r line; do
                echo -e "  ${BLUE}$line${NC}"
            done
            echo ""
        fi
    fi
fi

# Extract dependencies info if available
echo -e "${BLUE}Dependencies:${NC}"
DEPS=$(echo "$STORY_SECTION" | grep -i "^Dependencies:" || echo "")
if [ -n "$DEPS" ]; then
    echo "$DEPS"
else
    echo -e "${GRAY}  (See task descriptions for details)${NC}"
fi
echo ""

# Show estimation if available
ESTIMATION=$(echo "$STORY_SECTION" | grep "Estimated:" | head -1)
if [ -n "$ESTIMATION" ]; then
    echo -e "${BLUE}$ESTIMATION${NC}"
    echo ""
fi

# Summary line for easy parsing by AI
echo "SUMMARY: $COMPLETE_COUNT/$TOTAL_COUNT tasks complete ($PERCENT%)"
