#!/bin/bash

# validate-tasks.sh
# Validates task breakdown format and completeness

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get tasks file path
TASKS_FILE="$1"

if [ -z "$TASKS_FILE" ]; then
    echo -e "${RED}Error: No tasks file provided${NC}"
    echo "Usage: $0 <path-to-tasks.md>"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Validating task breakdown: $TASKS_FILE${NC}"
echo ""

# Initialize counters
ERRORS=0
WARNINGS=0

# Extract all tasks (lines starting with - [ ])
TASKS=$(grep "^- \[ \]" "$TASKS_FILE" || true)
TASK_COUNT=$(echo "$TASKS" | grep -v "^$" | wc -l | tr -d ' ')

if [ "$TASK_COUNT" -eq 0 ]; then
    echo -e "${RED}✗ No tasks found in file${NC}"
    echo -e "${RED}  Expected format: - [ ] [TaskID] Description${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Found $TASK_COUNT tasks${NC}"
echo ""

# Check task format
echo -e "${BLUE}Checking task format...${NC}"

# Tasks without TaskID
MISSING_ID=$(echo "$TASKS" | grep -v "\[T[0-9]\+\]" | wc -l | tr -d ' ')
if [ "$MISSING_ID" -gt 0 ]; then
    echo -e "${RED}✗ $MISSING_ID tasks missing TaskID [T001, T002, etc.]${NC}"
    echo "$TASKS" | grep -v "\[T[0-9]\+\]" | head -3
    ((ERRORS++))
else
    echo -e "${GREEN}✓ All tasks have TaskID${NC}"
fi

# Tasks without file paths (look for tasks without "/" or ".js" or ".py" etc)
# This is a heuristic - phase/section headers might not have paths
TASKS_LIKELY_NEEDING_PATHS=$(echo "$TASKS" | grep -E "\[(US[0-9]+|P)\]")
if [ -n "$TASKS_LIKELY_NEEDING_PATHS" ]; then
    MISSING_PATHS=$(echo "$TASKS_LIKELY_NEEDING_PATHS" | grep -v -E "(\.|/|src/|tests/|config/)" | wc -l | tr -d ' ')
    if [ "$MISSING_PATHS" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $MISSING_PATHS user story tasks might be missing file paths${NC}"
        echo "$TASKS_LIKELY_NEEDING_PATHS" | grep -v -E "(\.|/|src/|tests/|config/)" | head -3
        ((WARNINGS++))
    else
        echo -e "${GREEN}✓ User story tasks have file paths${NC}"
    fi
fi
echo ""

# Check user story labels
echo -e "${BLUE}Checking user story labels...${NC}"

# Count tasks with [US1], [US2], etc.
US_TASKS=$(echo "$TASKS" | grep -E "\[US[0-9]+\]" | wc -l | tr -d ' ')
if [ "$US_TASKS" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $US_TASKS tasks with user story labels${NC}"
    
    # Check each story label is used consistently
    for story in US1 US2 US3 US4 US5; do
        COUNT=$(echo "$TASKS" | grep "\[$story\]" | wc -l | tr -d ' ')
        if [ "$COUNT" -gt 0 ]; then
            echo -e "${BLUE}  [$story]: $COUNT tasks${NC}"
        fi
    done
else
    echo -e "${YELLOW}⚠️  No user story labels found ([US1], [US2], etc.)${NC}"
    echo -e "${YELLOW}  This might be ok for non-feature tasks${NC}"
    ((WARNINGS++))
fi
echo ""

# Check parallel markers
echo -e "${BLUE}Checking parallel markers...${NC}"
PARALLEL_TASKS=$(echo "$TASKS" | grep "\[P\]" | wc -l | tr -d ' ')
if [ "$PARALLEL_TASKS" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $PARALLEL_TASKS tasks marked [P] for parallel execution${NC}"
else
    echo -e "${YELLOW}⚠️  No tasks marked [P] for parallel execution${NC}"
    echo -e "${YELLOW}  Consider marking independent tasks as parallelizable${NC}"
    ((WARNINGS++))
fi
echo ""

# Check for sequential TaskIDs
echo -e "${BLUE}Checking TaskID sequence...${NC}"
TASK_IDS=$(echo "$TASKS" | grep -oE "T[0-9]+" | sed 's/T//' | sort -n)
EXPECTED=1
SEQUENCE_OK=true
for id in $TASK_IDS; do
    if [ "$id" -ne "$EXPECTED" ]; then
        echo -e "${YELLOW}⚠️  TaskID gap: Expected T$(printf "%03d" $EXPECTED), found T$(printf "%03d" $id)${NC}"
        SEQUENCE_OK=false
        ((WARNINGS++))
        break
    fi
    EXPECTED=$((id + 1))
done
if [ "$SEQUENCE_OK" = true ]; then
    echo -e "${GREEN}✓ TaskIDs are sequential${NC}"
fi
echo ""

# Check for required sections
echo -e "${BLUE}Checking required sections...${NC}"
REQUIRED_SECTIONS=("## Phase 1: Setup" "## Phase 2: Foundation" "## MVP Definition" "## Dependencies")
for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "$section" "$TASKS_FILE"; then
        echo -e "${GREEN}✓ Has section: $section${NC}"
    else
        echo -e "${RED}✗ Missing section: $section${NC}"
        ((ERRORS++))
    fi
done
echo ""

# Check for independent test scenarios
echo -e "${BLUE}Checking for independent test scenarios...${NC}"
if grep -q "Independent Test" "$TASKS_FILE" || grep -q "Independent Test Scenario" "$TASKS_FILE"; then
    echo -e "${GREEN}✓ Contains independent test scenarios${NC}"
else
    echo -e "${YELLOW}⚠️  No independent test scenarios found${NC}"
    echo -e "${YELLOW}  Each user story should define how to test it independently${NC}"
    ((WARNINGS++))
fi
echo ""

# Check for acceptance criteria
echo -e "${BLUE}Checking for acceptance criteria...${NC}"
ACCEPTANCE_COUNT=$(grep -c "Acceptance Criteria" "$TASKS_FILE" || true)
if [ "$ACCEPTANCE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $ACCEPTANCE_COUNT acceptance criteria sections${NC}"
else
    echo -e "${YELLOW}⚠️  No acceptance criteria sections found${NC}"
    echo -e "${YELLOW}  Each user story should reference acceptance criteria from spec${NC}"
    ((WARNINGS++))
fi
echo ""

# Check for MVP definition
echo -e "${BLUE}Checking MVP definition...${NC}"
if grep -q "## MVP Definition" "$TASKS_FILE"; then
    if grep -A 10 "## MVP Definition" "$TASKS_FILE" | grep -q "Phase 1.*Phase 2.*Phase 3"; then
        echo -e "${GREEN}✓ MVP scope clearly defined${NC}"
    else
        echo -e "${YELLOW}⚠️  MVP definition exists but scope unclear${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}✗ No MVP definition found${NC}"
    ((ERRORS++))
fi
echo ""

# Check for mermaid diagram
echo -e "${BLUE}Checking for dependency visualization...${NC}"
if grep -q "```mermaid" "$TASKS_FILE"; then
    echo -e "${GREEN}✓ Contains mermaid diagram for dependencies${NC}"
else
    echo -e "${YELLOW}⚠️  No mermaid diagram found${NC}"
    echo -e "${YELLOW}  Consider adding visual dependency graph${NC}"
    ((WARNINGS++))
fi
echo ""

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Tasks Found: $TASK_COUNT${NC}"
echo -e "${BLUE}User Story Tasks: $US_TASKS${NC}"
echo -e "${BLUE}Parallel Tasks: $PARALLEL_TASKS${NC}"
echo ""

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✅ Task breakdown validation passed!${NC}"
    echo ""
    echo -e "${GREEN}Ready for implementation:${NC}"
    echo "  1. Review tasks for accuracy"
    echo "  2. Start with /implement-story \"User Story 1\""
    echo ""
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Task breakdown has $WARNINGS warning(s)${NC}"
    echo ""
    echo -e "${YELLOW}Recommendations:${NC}"
    echo "  - Address warnings to improve task quality"
    echo "  - Ensure all user story tasks have file paths"
    echo "  - Define MVP scope clearly"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Task breakdown has $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo ""
    echo -e "${RED}Action required:${NC}"
    echo "  - Fix critical errors before proceeding"
    echo "  - Ensure all tasks follow format: - [ ] [TaskID] [P?] [Story?] Description"
    echo "  - Include all required sections"
    echo ""
    exit 1
fi
