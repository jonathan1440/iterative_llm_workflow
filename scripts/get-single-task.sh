#!/bin/bash

# get-single-task.sh
# Extracts detailed information for a single task from tasks.md

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

# Normalize task ID (add T prefix if missing, ensure 3 digits)
if ! echo "$TASK_ID" | grep -q "^T"; then
    TASK_ID="T$TASK_ID"
fi

# Find the task line (try both formats: [T017] and T017)
TASK_LINE=$(grep "^- \[.\] \[$TASK_ID\]" "$TASKS_FILE" || grep "^- \[.\] $TASK_ID " "$TASKS_FILE" || true)

if [ -z "$TASK_LINE" ]; then
    echo -e "${RED}Error: Task $TASK_ID not found in tasks file${NC}"
    exit 1
fi

# Check if task is already complete
if echo "$TASK_LINE" | grep -q "^- \[X\]"; then
    echo -e "${YELLOW}Task $TASK_ID is already complete${NC}"
    echo "TASK_COMPLETE=true"
    exit 0
fi

# Extract task details
TASK_DESC=$(echo "$TASK_LINE" | sed 's/^- \[ \] //' | sed 's/\[T[0-9]*\]//' | sed 's/\[P\]//' | sed 's/\[US[0-9]*\]//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

# Extract story number if present
STORY_NUM=$(echo "$TASK_LINE" | grep -oE "\[US[0-9]+\]" | grep -oE "[0-9]+" | head -1)

# Check if parallel
IS_PARALLEL=$(echo "$TASK_LINE" | grep -q "\[P\]" && echo "true" || echo "false")

# Find the phase this task belongs to
TASK_LINE_NUM=$(grep -n "^- \[.\] \[$TASK_ID\]" "$TASKS_FILE" | cut -d: -f1 || grep -n "^- \[.\] $TASK_ID " "$TASKS_FILE" | cut -d: -f1)

if [ -z "$TASK_LINE_NUM" ]; then
    PHASE_NAME="Unknown Phase"
else
    # Find the phase header before this task
    PHASE_HEADER=$(head -n "$TASK_LINE_NUM" "$TASKS_FILE" | grep "^## Phase" | tail -1)
    PHASE_NAME=$(echo "$PHASE_HEADER" | sed 's/^## Phase [0-9]*: //' || echo "Unknown Phase")
fi

# Extract story goal if this is a user story task
STORY_GOAL=""
if [ -n "$STORY_NUM" ]; then
    STORY_GOAL=$(grep -A 5 "## Phase.*User Story $STORY_NUM" "$TASKS_FILE" | grep "^\*\*Story Goal\*\*:" | sed 's/^\*\*Story Goal\*\*: //' | head -1)
fi

# Find related tasks in same phase (for context, but not loaded)
# Get all tasks in this phase
PHASE_START=$(grep -n "$PHASE_HEADER" "$TASKS_FILE" | cut -d: -f1 | head -1)
NEXT_PHASE=$(tail -n +$((PHASE_START + 1)) "$TASKS_FILE" | grep -n "^## Phase" | head -1 | cut -d: -f1)
if [ -n "$NEXT_PHASE" ]; then
    PHASE_END=$((PHASE_START + NEXT_PHASE - 1))
else
    PHASE_END=$(wc -l < "$TASKS_FILE")
fi

# Extract acceptance criteria for this story (if user story)
ACCEPTANCE_CRITERIA=""
if [ -n "$STORY_NUM" ]; then
    ACCEPTANCE_CRITERIA=$(sed -n "${PHASE_START},${PHASE_END}p" "$TASKS_FILE" | sed -n '/^\*\*Acceptance Criteria\*\*/,/^\*\*/p' | grep "^- \[" | head -10)
fi

# Find dependencies (tasks that must be complete before this one)
# Look for prerequisite tasks mentioned in task description or nearby context
DEPENDENCIES=$(echo "$TASK_LINE" | grep -oE "T[0-9]+" | grep -v "$TASK_ID" || echo "")

# Output task details in structured format
echo "TASK_ID=$TASK_ID"
echo "TASK_DESC=$TASK_DESC"
echo "TASK_LINE=$TASK_LINE"
echo "STORY_NUM=$STORY_NUM"
echo "PHASE_NAME=$PHASE_NAME"
echo "IS_PARALLEL=$IS_PARALLEL"
echo "STORY_GOAL=$STORY_GOAL"
echo "DEPENDENCIES=$DEPENDENCIES"
echo "TASK_COMPLETE=false"

# Output formatted task details for display
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📋 Task Details: $TASK_ID${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Task:${NC} $TASK_DESC"
echo ""
if [ -n "$PHASE_NAME" ]; then
    echo -e "${BLUE}Phase:${NC} $PHASE_NAME"
fi
if [ -n "$STORY_NUM" ]; then
    echo -e "${BLUE}User Story:${NC} $STORY_NUM"
    if [ -n "$STORY_GOAL" ]; then
        echo -e "${BLUE}Story Goal:${NC} $STORY_GOAL"
    fi
fi
if [ "$IS_PARALLEL" = "true" ]; then
    echo -e "${YELLOW}Parallel:${NC} Can be worked on simultaneously with other [P] tasks"
fi
if [ -n "$DEPENDENCIES" ]; then
    echo -e "${YELLOW}Dependencies:${NC} $DEPENDENCIES (must be complete first)"
fi
echo ""
