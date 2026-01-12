#!/bin/bash

# verify-story.sh
# Walks through the independent test scenario for a user story

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

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Story Verification: $STORY_NAME          ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo ""

# Extract story section
STORY_LINE=$(grep -n "## Phase.*$STORY_NAME" "$TASKS_FILE" | cut -d: -f1)

if [ -z "$STORY_LINE" ]; then
    echo -e "${RED}Error: Story not found in tasks file${NC}"
    exit 1
fi

# Find next phase
NEXT_PHASE_LINE=$(tail -n +$((STORY_LINE + 1)) "$TASKS_FILE" | grep -n "^## Phase" | head -1 | cut -d: -f1)
if [ -n "$NEXT_PHASE_LINE" ]; then
    END_LINE=$((STORY_LINE + NEXT_PHASE_LINE))
else
    END_LINE=$(wc -l < "$TASKS_FILE")
fi

STORY_SECTION=$(sed -n "${STORY_LINE},${END_LINE}p" "$TASKS_FILE")

# Extract independent test scenario
echo -e "${BLUE}This independent test proves the story works without other stories.${NC}"
echo ""

# Find test scenario section
TEST_START=$(echo "$STORY_SECTION" | grep -n "^\*\*Independent Test" | cut -d: -f1)

if [ -z "$TEST_START" ]; then
    echo -e "${RED}No independent test scenario found for this story${NC}"
    echo ""
    echo -e "${YELLOW}Action required:${NC}"
    echo "  Add independent test scenario to tasks file"
    echo "  Format:"
    echo "    **Independent Test Scenario**:"
    echo "    1. [Step description]"
    echo "    2. [Step description]"
    exit 1
fi

# Extract test steps (look for lines starting with numbers or "Command:", "Expected:")
TEST_SECTION=$(echo "$STORY_SECTION" | tail -n +$TEST_START)

# Parse test steps
STEP_NUM=0
PASSED=0
FAILED=0
SKIPPED=0

# Extract steps more carefully
# Look for numbered items (1., 2., etc.) or Command:/Expected: patterns
echo "$TEST_SECTION" | while IFS= read -r line; do
    # Check if this is a new step (starts with number)
    if echo "$line" | grep -qE "^[0-9]+\."; then
        STEP_NUM=$((STEP_NUM + 1))
        STEP_DESC=$(echo "$line" | sed -E 's/^[0-9]+\. //')
        
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Step $STEP_NUM: $STEP_DESC${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
    # Check for Command: line
    elif echo "$line" | grep -qE "^(Command|command):"; then
        COMMAND=$(echo "$line" | sed -E 's/^(Command|command): //')
        echo -e "${YELLOW}Command:${NC}"
        echo -e "  ${GRAY}$COMMAND${NC}"
        echo ""
        
    # Check for Expected: line
    elif echo "$line" | grep -qE "^(Expected|expected):"; then
        EXPECTED=$(echo "$line" | sed -E 's/^(Expected|expected): //')
        echo -e "${GREEN}Expected Result:${NC}"
        echo -e "  ${GRAY}$EXPECTED${NC}"
        echo ""
        
        # Prompt user
        echo -e "${YELLOW}Did this step work as expected? [y/n/s=skip]${NC}"
        read -r response
        
        case "$response" in
            [Yy]*)
                echo -e "${GREEN}✓ Step $STEP_NUM passed${NC}"
                PASSED=$((PASSED + 1))
                ;;
            [Nn]*)
                echo -e "${RED}✗ Step $STEP_NUM failed${NC}"
                echo -e "${YELLOW}What went wrong? (optional, press Enter to skip)${NC}"
                read -r error_msg
                if [ -n "$error_msg" ]; then
                    echo -e "${GRAY}Note: $error_msg${NC}"
                fi
                FAILED=$((FAILED + 1))
                ;;
            [Ss]*)
                echo -e "${GRAY}⊘ Step $STEP_NUM skipped${NC}"
                SKIPPED=$((SKIPPED + 1))
                ;;
            *)
                echo -e "${GRAY}⊘ Step $STEP_NUM skipped (invalid response)${NC}"
                SKIPPED=$((SKIPPED + 1))
                ;;
        esac
    fi
done

# Note: Since we're in a while loop (subshell), counters don't persist
# Let's use a simpler interactive approach

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Starting Interactive Test            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Extract all test content between Independent Test and next section
TEST_CONTENT=$(echo "$STORY_SECTION" | sed -n '/^\*\*Independent Test/,/^##\|^---\|^━/p' | grep -v "^\*\*Independent Test" | grep -v "^##" | grep -v "^---" | grep -v "^━")

# Simple line-by-line display with pauses
echo "$TEST_CONTENT"
echo ""
echo ""

# Final verification
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Final Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Did all test steps pass? [y/n]${NC}"
read -r final_response

case "$final_response" in
    [Yy]*)
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ✅ Story Verification PASSED                  ║${NC}"
        echo -e "${GREEN}║                                                ║${NC}"
        echo -e "${GREEN}║  $STORY_NAME is complete and verified!    ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${BLUE}Next steps:${NC}"
        echo "  1. Commit changes: git commit -m \"Implement $STORY_NAME\""
        echo "  2. Update acceptance criteria in tasks file"
        echo "  3. Move to next story or polish phase"
        exit 0
        ;;
    [Nn]*)
        echo ""
        echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ✗ Story Verification FAILED                   ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Debug checklist:${NC}"
        echo "  1. Check server logs for errors"
        echo "  2. Verify database connection and data"
        echo "  3. Test endpoints manually with curl/Postman"
        echo "  4. Run automated tests: npm test"
        echo "  5. Check error handling and validation"
        echo ""
        echo -e "${YELLOW}After fixing issues, re-run:${NC}"
        echo "  bash .cursor/scripts/verify-story.sh \"$TASKS_FILE\" \"$STORY_NAME\""
        exit 1
        ;;
    *)
        echo ""
        echo -e "${GRAY}Verification cancelled${NC}"
        exit 0
        ;;
esac
