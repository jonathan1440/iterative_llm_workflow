#!/bin/bash

# check-implementation-prerequisites.sh
# Verifies prerequisites before implementing a user story

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get story identifier from arguments
STORY_NAME="$1"

if [ -z "$STORY_NAME" ]; then
    echo -e "${RED}Error: No story name provided${NC}"
    echo "Usage: $0 <\"User Story 1\" or \"US1\" or \"Phase 3\">"
    exit 1
fi

echo -e "${BLUE}🔍 Checking prerequisites for implementing: $STORY_NAME${NC}"
echo ""

# Find tasks file (look for tasks.md in directories or *-tasks.md for backward compatibility)
TASKS_FILE=""
for path in docs/specs/*/tasks.md docs/specs/*-tasks.md *-tasks.md; do
    if [ -f "$path" ]; then
        TASKS_FILE="$path"
        break
    fi
done

if [ -z "$TASKS_FILE" ] || [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}✗ No tasks file found${NC}"
    echo ""
    echo -e "${YELLOW}Action required:${NC}"
    echo "  Create task breakdown with: /plan-tasks <spec-file>"
    exit 1
fi
echo -e "${GREEN}✓ Tasks file found: $TASKS_FILE${NC}"

# Check if story exists in tasks file
# Try multiple patterns: "User Story 1", "US1", "Phase 3"
STORY_PATTERN=""
if echo "$STORY_NAME" | grep -qi "User Story [0-9]"; then
    STORY_NUM=$(echo "$STORY_NAME" | grep -oE "[0-9]+" | head -1)
    STORY_PATTERN="User Story $STORY_NUM"
elif echo "$STORY_NAME" | grep -qi "US[0-9]"; then
    STORY_NUM=$(echo "$STORY_NAME" | grep -oE "[0-9]+" | head -1)
    STORY_PATTERN="User Story $STORY_NUM"
elif echo "$STORY_NAME" | grep -qi "Phase [0-9]"; then
    STORY_PATTERN="$STORY_NAME"
else
    # Try as-is
    STORY_PATTERN="$STORY_NAME"
fi

if ! grep -q "## Phase.*$STORY_PATTERN" "$TASKS_FILE"; then
    echo -e "${RED}✗ Story not found in tasks file: $STORY_PATTERN${NC}"
    echo ""
    echo -e "${YELLOW}Available stories:${NC}"
    grep "^## Phase [0-9]" "$TASKS_FILE" | sed 's/^## /  - /'
    exit 1
fi
echo -e "${GREEN}✓ Story found in tasks file${NC}"

# Extract story number for US checks
STORY_NUM=$(echo "$STORY_PATTERN" | grep -oE "[0-9]+" | head -1 || echo "0")

# Check if previous stories are complete (only for US2, US3, etc.)
if [ "$STORY_NUM" -gt 1 ]; then
    echo ""
    echo -e "${BLUE}Checking if previous stories are complete...${NC}"
    
    PREV_NUM=$((STORY_NUM - 1))
    PREV_INCOMPLETE=0
    
    # Check each previous story
    for i in $(seq 1 $PREV_NUM); do
        # Count incomplete tasks for this story
        INCOMPLETE=$(grep "^- \[ \] .*\[US$i\]" "$TASKS_FILE" | wc -l | tr -d ' ')
        TOTAL=$(grep "^- \[.\] .*\[US$i\]" "$TASKS_FILE" | wc -l | tr -d ' ')
        
        if [ "$INCOMPLETE" -gt 0 ]; then
            echo -e "${YELLOW}⚠️  User Story $i has $INCOMPLETE/$TOTAL incomplete tasks${NC}"
            PREV_INCOMPLETE=1
        else
            echo -e "${GREEN}✓ User Story $i complete ($TOTAL/$TOTAL tasks)${NC}"
        fi
    done
    
    if [ "$PREV_INCOMPLETE" -eq 1 ]; then
        echo ""
        echo -e "${YELLOW}Recommendation:${NC}"
        echo "  Complete previous user stories before starting this one"
        echo "  Or continue anyway if you're prototyping"
    fi
fi

# Count tasks for this story
echo ""
echo -e "${BLUE}Analyzing story tasks...${NC}"

TOTAL_TASKS=$(grep "^- \[.\] .*\[US$STORY_NUM\]" "$TASKS_FILE" | wc -l | tr -d ' ')
COMPLETE_TASKS=$(grep "^- \[X\] .*\[US$STORY_NUM\]" "$TASKS_FILE" | wc -l | tr -d ' ')
INCOMPLETE_TASKS=$(grep "^- \[ \] .*\[US$STORY_NUM\]" "$TASKS_FILE" | wc -l | tr -d ' ')

if [ "$TOTAL_TASKS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No tasks found for $STORY_PATTERN${NC}"
    echo "  This might be a non-user-story phase (Setup, Foundation, Polish)"
    TOTAL_TASKS=$(grep "^- \[.\] " "$TASKS_FILE" | grep -A 50 "## Phase.*$STORY_PATTERN" | grep "^- \[.\] " | wc -l | tr -d ' ')
    COMPLETE_TASKS=$(grep "^- \[X\] " "$TASKS_FILE" | grep -A 50 "## Phase.*$STORY_PATTERN" | grep "^- \[X\] " | wc -l | tr -d ' ')
    INCOMPLETE_TASKS=$(grep "^- \[ \] " "$TASKS_FILE" | grep -A 50 "## Phase.*$STORY_PATTERN" | grep "^- \[ \] " | wc -l | tr -d ' ')
fi

echo -e "${BLUE}Tasks: $COMPLETE_TASKS/$TOTAL_TASKS complete${NC}"
if [ "$COMPLETE_TASKS" -gt 0 ]; then
    PERCENT=$((COMPLETE_TASKS * 100 / TOTAL_TASKS))
    echo -e "${BLUE}Progress: $PERCENT%${NC}"
fi

# Check if story is already complete
if [ "$INCOMPLETE_TASKS" -eq 0 ] && [ "$TOTAL_TASKS" -gt 0 ]; then
    echo -e "${GREEN}✓ All tasks complete for this story!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  - Verify story completion if not done"
    echo "  - Move to next story"
    exit 0
fi

# Extract story details
echo ""
echo -e "${BLUE}Extracting story details...${NC}"

# Get story goal
STORY_GOAL=$(grep -A 5 "## Phase.*$STORY_PATTERN" "$TASKS_FILE" | grep "^\*\*Goal\*\*:" | sed 's/^\*\*Goal\*\*: //' || echo "Not specified")
echo -e "${BLUE}Goal: $STORY_GOAL${NC}"

# Check for acceptance criteria
ACC_COUNT=$(grep -A 20 "## Phase.*$STORY_PATTERN" "$TASKS_FILE" | grep -c "^- \[ \].*Criterion" || true)
if [ "$ACC_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $ACC_COUNT acceptance criteria${NC}"
else
    echo -e "${YELLOW}⚠️  No acceptance criteria found${NC}"
fi

# Check for independent test
if grep -A 30 "## Phase.*$STORY_PATTERN" "$TASKS_FILE" | grep -q "Independent Test"; then
    echo -e "${GREEN}✓ Independent test scenario defined${NC}"
else
    echo -e "${YELLOW}⚠️  No independent test scenario${NC}"
    echo -e "${YELLOW}  Add test scenario to verify story works independently${NC}"
fi

# Check if agents.md exists
if [ ! -f ".cursor/agents.md" ]; then
    echo -e "${YELLOW}⚠️  agents.md not found${NC}"
    echo -e "${YELLOW}  Create with: /init-project${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Ready to implement: $STORY_PATTERN${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  Story: $STORY_PATTERN"
echo "  Goal: $STORY_GOAL"
echo "  Tasks: $INCOMPLETE_TASKS remaining out of $TOTAL_TASKS"
if [ "$ACC_COUNT" -gt 0 ]; then
    echo "  Acceptance Criteria: $ACC_COUNT"
fi
echo ""

# Output for AI
echo "TASKS_FILE=$TASKS_FILE"
echo "STORY_NAME=$STORY_PATTERN"
echo "STORY_NUMBER=$STORY_NUM"
echo "TOTAL_TASKS=$TOTAL_TASKS"
echo "COMPLETE_TASKS=$COMPLETE_TASKS"
echo "INCOMPLETE_TASKS=$INCOMPLETE_TASKS"
