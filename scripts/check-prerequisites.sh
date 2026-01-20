#!/bin/bash
# check-prerequisites.sh
# Consolidated prerequisite checking functions
# Source this file and call the appropriate function

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

# Check prerequisites for creating system design
# Usage: check_design_prereqs <spec-path>
check_design_prereqs() {
    local SPEC_PATH="$1"
    
    if [ -z "$SPEC_PATH" ]; then
        echo -e "${RED}Error: No spec file path provided${NC}"
        echo "Usage: check_design_prereqs <path-to-spec.md>"
        return 1
    fi
    
    echo -e "${BLUE}🔍 Checking prerequisites for system design...${NC}"
    echo ""
    
    # Check if spec file exists
    if [ ! -f "$SPEC_PATH" ]; then
        echo -e "${RED}✗ Spec file not found: $SPEC_PATH${NC}"
        echo ""
        echo -e "${YELLOW}Action required:${NC}"
        echo "  Create the spec first with: /spec-feature \"your feature\""
        return 1
    fi
    echo -e "${GREEN}✓ Spec file exists: $SPEC_PATH${NC}"
    
    # Check if agents.md exists
    if [ ! -f ".cursor/agents.md" ]; then
        echo -e "${RED}✗ agents.md not found${NC}"
        echo ""
        echo -e "${YELLOW}Action required:${NC}"
        echo "  Initialize project first with: /init-project"
        return 1
    fi
    echo -e "${GREEN}✓ Project standards exist: .cursor/agents.md${NC}"
    
    # Validate spec completeness
    echo ""
    echo -e "${BLUE}Validating spec completeness...${NC}"
    
    # Check for placeholder markers
    local PLACEHOLDERS
    PLACEHOLDERS=$(grep -E '\[.*\]|TODO|TBD|FIXME|\?\?\?|NEEDS CLARIFICATION' "$SPEC_PATH" | grep -v '^\[' | grep -v '^- \[' | grep -v 'SPEC TEMPLATE' || true)
    if [ -n "$PLACEHOLDERS" ]; then
        echo -e "${YELLOW}⚠️  Found placeholders in spec:${NC}"
        echo "$PLACEHOLDERS" | head -3
        echo ""
        echo -e "${YELLOW}Recommendation:${NC}"
        echo "  Complete spec clarification before designing"
        echo "  Or proceed anyway if exploratory spike"
    fi
    
    # Check for required sections
    local MISSING_SECTIONS=()
    if ! grep -q "## Problem Statement" "$SPEC_PATH"; then
        MISSING_SECTIONS+=("Problem Statement")
    fi
    if ! grep -q "## User Stories" "$SPEC_PATH"; then
        MISSING_SECTIONS+=("User Stories")
    fi
    if ! grep -q "## Functional Requirements" "$SPEC_PATH"; then
        MISSING_SECTIONS+=("Functional Requirements")
    fi
    
    if [ ${#MISSING_SECTIONS[@]} -gt 0 ]; then
        echo -e "${RED}✗ Missing required sections:${NC}"
        for section in "${MISSING_SECTIONS[@]}"; do
            echo "  - $section"
        done
        echo ""
        echo -e "${RED}Action required:${NC}"
        echo "  Complete the spec with all required sections"
        return 1
    else
        echo -e "${GREEN}✓ All required sections present${NC}"
    fi
    
    # Generate file paths using shared helpers
    local DESIGN_PATH RESEARCH_PATH
    DESIGN_PATH="$(get_design_path "$SPEC_PATH")"
    RESEARCH_PATH="$(get_research_path "$SPEC_PATH")"
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Prerequisites satisfied${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}File Paths:${NC}"
    echo "  Spec:     $SPEC_PATH"
    echo "  Design:   $DESIGN_PATH"
    echo "  Research: $RESEARCH_PATH"
    echo ""
    
    # Output paths in a format easy for the AI to parse
    echo "SPEC_FILE=$SPEC_PATH"
    echo "DESIGN_FILE=$DESIGN_PATH"
    echo "RESEARCH_FILE=$RESEARCH_PATH"
    echo "AGENTS_FILE=.cursor/agents.md"
    
    return 0
}

# Check prerequisites for creating task breakdown
# Usage: check_tasks_prereqs <spec-path>
check_tasks_prereqs() {
    local SPEC_PATH="$1"
    
    if [ -z "$SPEC_PATH" ]; then
        echo -e "${RED}Error: No spec file path provided${NC}"
        echo "Usage: check_tasks_prereqs <path-to-spec.md>"
        return 1
    fi
    
    echo -e "${BLUE}🔍 Checking prerequisites for task planning...${NC}"
    echo ""
    
    # Check if spec file exists
    if [ ! -f "$SPEC_PATH" ]; then
        echo -e "${RED}✗ Spec file not found: $SPEC_PATH${NC}"
        echo ""
        echo -e "${YELLOW}Action required:${NC}"
        echo "  Create the spec first with: /spec-feature \"your feature\""
        return 1
    fi
    echo -e "${GREEN}✓ Spec file exists: $SPEC_PATH${NC}"
    
    # Generate design file path via shared helper
    local DESIGN_PATH
    DESIGN_PATH="$(get_design_path "$SPEC_PATH")"
    
    # Check if design file exists
    if [ ! -f "$DESIGN_PATH" ]; then
        echo -e "${RED}✗ Design file not found: $DESIGN_PATH${NC}"
        echo ""
        echo -e "${YELLOW}Action required:${NC}"
        echo "  Create the design first with: /design-system $SPEC_PATH"
        return 1
    fi
    echo -e "${GREEN}✓ Design file exists: $DESIGN_PATH${NC}"
    
    # Check if agents.md exists
    if [ ! -f ".cursor/agents.md" ]; then
        echo -e "${RED}✗ agents.md not found${NC}"
        echo ""
        echo -e "${YELLOW}Action required:${NC}"
        echo "  Initialize project first with: /init-project"
        return 1
    fi
    echo -e "${GREEN}✓ Project standards exist: .cursor/agents.md${NC}"
    
    # Check for user stories in spec
    echo ""
    echo -e "${BLUE}Analyzing spec for user stories...${NC}"
    local USER_STORIES
    USER_STORIES=$(grep -c "### P[0-9]" "$SPEC_PATH" || true)
    if [ "$USER_STORIES" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No user stories found in spec${NC}"
        echo -e "${YELLOW}   Expected format: ### P1 - Story Name${NC}"
        echo ""
        echo -e "${YELLOW}Recommendation:${NC}"
        echo "  Add user stories to spec (P1/P2/P3 priorities)"
        echo "  Or continue anyway for non-user-story features"
    else
        echo -e "${GREEN}✓ Found $USER_STORIES user stories in spec${NC}"
    fi
    
    # Check for functional requirements
    local REQUIREMENTS
    REQUIREMENTS=$(grep -c "^[0-9]\+\." "$SPEC_PATH" || true)
    if [ "$REQUIREMENTS" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No functional requirements found${NC}"
        echo -e "${YELLOW}   Tasks should map to requirements${NC}"
    fi
    
    # Check for database schema in design
    local TABLES=0
    if grep -q "## 2. Database Schema" "$DESIGN_PATH"; then
        TABLES=$(grep -c "^CREATE TABLE" "$DESIGN_PATH" || true)
        echo -e "${GREEN}✓ Design includes $TABLES database tables${NC}"
    else
        echo -e "${YELLOW}⚠️  No database schema found in design${NC}"
    fi
    
    # Check for API endpoints in design
    local ENDPOINTS=0
    if grep -q "## 3. API Contracts" "$DESIGN_PATH"; then
        ENDPOINTS=$(grep -c "^### Endpoint:" "$DESIGN_PATH" || true)
        echo -e "${GREEN}✓ Design includes $ENDPOINTS API endpoints${NC}"
    else
        echo -e "${YELLOW}⚠️  No API contracts found in design${NC}"
    fi
    
    # Generate tasks and research file paths
    local TASKS_PATH RESEARCH_PATH
    TASKS_PATH="$(get_tasks_path "$SPEC_PATH")"
    RESEARCH_PATH="$(get_research_path "$SPEC_PATH")"
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Prerequisites satisfied${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}File Paths:${NC}"
    echo "  Spec:     $SPEC_PATH"
    echo "  Design:   $DESIGN_PATH"
    echo "  Tasks:    $TASKS_PATH"
    if [ -f "$RESEARCH_PATH" ]; then
        echo "  Research: $RESEARCH_PATH"
    fi
    echo "  Standards: .cursor/agents.md"
    echo ""
    echo -e "${BLUE}Planning Context:${NC}"
    echo "  User Stories: $USER_STORIES"
    echo "  Requirements: $REQUIREMENTS"
    if [ "$TABLES" -gt 0 ]; then
        echo "  DB Tables: $TABLES"
    fi
    if [ "$ENDPOINTS" -gt 0 ]; then
        echo "  API Endpoints: $ENDPOINTS"
    fi
    echo ""
    
    # Output paths for AI
    echo "SPEC_FILE=$SPEC_PATH"
    echo "DESIGN_FILE=$DESIGN_PATH"
    echo "TASKS_FILE=$TASKS_PATH"
    echo "AGENTS_FILE=.cursor/agents.md"
    if [ -f "$RESEARCH_PATH" ]; then
        echo "RESEARCH_FILE=$RESEARCH_PATH"
    fi
    echo "USER_STORIES_COUNT=$USER_STORIES"
    
    return 0
}

# Check prerequisites for consistency analysis
# Usage: check_consistency_prereqs <spec-path>
check_consistency_prereqs() {
    local SPEC_PATH="$1"
    
    if [ -z "$SPEC_PATH" ]; then
        echo "ERROR: No spec file provided"
        echo "Usage: check_consistency_prereqs docs/specs/[feature-name]/spec.md"
        return 1
    fi
    
    # Extract paths using shared helpers
    local DESIGN_PATH TASKS_PATH
    DESIGN_PATH="$(get_design_path "$SPEC_PATH")"
    TASKS_PATH="$(get_tasks_path "$SPEC_PATH")"
    
    # Check if spec exists
    if [ ! -f "$SPEC_PATH" ]; then
        echo "ERROR: Spec file not found: $SPEC_PATH"
        return 1
    fi
    
    # Check for design file
    if [ ! -f "$DESIGN_PATH" ]; then
        echo "ERROR: Design file not found: $DESIGN_PATH"
        echo "Run: /design-system $SPEC_PATH"
        return 1
    fi
    
    # Check for tasks file
    if [ ! -f "$TASKS_PATH" ]; then
        echo "ERROR: Tasks file not found: $TASKS_PATH"
        echo "Run: /plan-tasks $SPEC_PATH"
        return 1
    fi
    
    # All files exist - output paths
    echo "✅ All required files found"
    echo ""
    echo "Spec:   $SPEC_PATH"
    echo "Design: $DESIGN_PATH"
    echo "Tasks:  $TASKS_PATH"
    echo ""
    echo "Ready for consistency analysis"
    
    return 0
}

# Check that feature files exist before adding a story
# Usage: check_feature_files_prereqs <spec-path> <story-desc>
check_feature_files_prereqs() {
    local SPEC_PATH="$1"
    local STORY_DESC="$2"
    
    if [ -z "$SPEC_PATH" ] || [ -z "$STORY_DESC" ]; then
        echo "ERROR: Missing arguments"
        echo "Usage: check_feature_files_prereqs docs/specs/[feature-name]/spec.md \"Story description\""
        return 1
    fi
    
    # Check if spec exists
    if [ ! -f "$SPEC_PATH" ]; then
        echo "ERROR: Spec file not found: $SPEC_PATH"
        echo "Create it first with: /spec-feature \"Feature description\""
        return 1
    fi
    
    # Extract paths using shared helpers
    local DESIGN_PATH TASKS_PATH
    DESIGN_PATH="$(get_design_path "$SPEC_PATH")"
    TASKS_PATH="$(get_tasks_path "$SPEC_PATH")"
    
    # Check for design file
    if [ ! -f "$DESIGN_PATH" ]; then
        echo "ERROR: Design file not found: $DESIGN_PATH"
        echo "Create it with: /design-system $SPEC_PATH"
        return 1
    fi
    
    # Check for tasks file
    if [ ! -f "$TASKS_PATH" ]; then
        echo "ERROR: Tasks file not found: $TASKS_PATH"
        echo "Create it with: /plan-tasks $SPEC_PATH"
        return 1
    fi
    
    # Count existing user stories
    local STORY_COUNT NEXT_STORY
    STORY_COUNT=$(grep -c "^### User Story [0-9]" "$SPEC_PATH" || echo "0")
    NEXT_STORY=$((STORY_COUNT + 1))
    
    # Output results
    echo "✅ All required files found"
    echo ""
    echo "Spec:   $SPEC_PATH"
    echo "Design: $DESIGN_PATH"
    echo "Tasks:  $TASKS_PATH"
    echo ""
    echo "Existing stories: $STORY_COUNT"
    echo "Next story number: $NEXT_STORY"
    echo "New story: \"$STORY_DESC\""
    echo ""
    echo "Ready to add story"
    
    return 0
}

# Check prerequisites for implementing a user story
# Usage: check_implementation_prereqs <story-name>
check_implementation_prereqs() {
    local STORY_NAME="$1"
    
    if [ -z "$STORY_NAME" ]; then
        echo -e "${RED}Error: No story name provided${NC}"
        echo "Usage: check_implementation_prereqs <\"User Story 1\" or \"US1\" or \"Phase 3\">"
        return 1
    fi
    
    echo -e "${BLUE}🔍 Checking prerequisites for implementing: $STORY_NAME${NC}"
    echo ""
    
    # Find tasks file (look for tasks.md in directories or *-tasks.md for backward compatibility)
    local TASKS_FILE=""
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
        return 1
    fi
    echo -e "${GREEN}✓ Tasks file found: $TASKS_FILE${NC}"
    
    # Check if story exists in tasks file
    # Try multiple patterns: "User Story 1", "US1", "Phase 3"
    local STORY_PATTERN=""
    local STORY_NUM
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
        return 1
    fi
    echo -e "${GREEN}✓ Story found in tasks file${NC}"
    
    # Extract story number for US checks
    STORY_NUM=$(echo "$STORY_PATTERN" | grep -oE "[0-9]+" | head -1 || echo "0")
    
    # Check if previous stories are complete (only for US2, US3, etc.)
    if [ "$STORY_NUM" -gt 1 ]; then
        echo ""
        echo -e "${BLUE}Checking if previous stories are complete...${NC}"
        
        local PREV_NUM=$((STORY_NUM - 1))
        local PREV_INCOMPLETE=0
        
        # Check each previous story
        for i in $(seq 1 $PREV_NUM); do
            # Count incomplete tasks for this story
            local INCOMPLETE TOTAL
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
    
    local TOTAL_TASKS COMPLETE_TASKS INCOMPLETE_TASKS
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
        local PERCENT=$((COMPLETE_TASKS * 100 / TOTAL_TASKS))
        echo -e "${BLUE}Progress: $PERCENT%${NC}"
    fi
    
    # Check if story is already complete
    if [ "$INCOMPLETE_TASKS" -eq 0 ] && [ "$TOTAL_TASKS" -gt 0 ]; then
        echo -e "${GREEN}✓ All tasks complete for this story!${NC}"
        echo ""
        echo -e "${YELLOW}Next steps:${NC}"
        echo "  - Verify story completion if not done"
        echo "  - Move to next story"
        return 0
    fi
    
    # Extract story details
    echo ""
    echo -e "${BLUE}Extracting story details...${NC}"
    
    # Get story goal
    local STORY_GOAL
    STORY_GOAL=$(grep -A 5 "## Phase.*$STORY_PATTERN" "$TASKS_FILE" | grep "^\*\*Goal\*\*:" | sed 's/^\*\*Goal\*\*: //' || echo "Not specified")
    echo -e "${BLUE}Goal: $STORY_GOAL${NC}"
    
    # Check for acceptance criteria
    local ACC_COUNT
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
    
    return 0
}

# Check prerequisites before refactoring
# Usage: check_refactor_prereqs <refactor-desc> [target]
check_refactor_prereqs() {
    local REFACTOR_DESC="$1"
    local TARGET="$2"
    
    if [ -z "$REFACTOR_DESC" ]; then
        echo "ERROR: No refactor description provided"
        echo "Usage: check_refactor_prereqs \"Description\" [target-file]"
        return 1
    fi
    
    echo "✅ Refactor Prerequisites Check"
    echo ""
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo "❌ ERROR: Uncommitted changes detected"
        echo ""
        git status --short
        echo ""
        echo "Commit or stash changes before refactoring"
        return 1
    else
        echo "Working directory: Clean ✓"
    fi
    
    # Check if tests exist
    local TEST_CMD=""
    if [ -d "tests" ]; then
        local TEST_COUNT
        TEST_COUNT=$(find tests -name "*.py" -o -name "*.js" -o -name "*.ts" 2>/dev/null | wc -l)
        echo "Tests: Found $TEST_COUNT test files ✓"
    else
        echo "⚠️  WARNING: No tests directory found"
        echo "Refactoring without tests is risky"
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    # Determine test command
    if [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
        TEST_CMD="pytest tests/"
        echo "Test command: $TEST_CMD ✓"
    elif [ -f "package.json" ]; then
        TEST_CMD="npm test"
        echo "Test command: $TEST_CMD ✓"
    else
        echo "⚠️  WARNING: Could not determine test command"
        TEST_CMD=""
    fi
    
    # Check target exists if specified
    if [ -n "$TARGET" ]; then
        if [ -f "$TARGET" ]; then
            local LINE_COUNT
            LINE_COUNT=$(wc -l < "$TARGET")
            echo "Target: $TARGET ($LINE_COUNT lines) ✓"
        elif [ -d "$TARGET" ]; then
            local FILE_COUNT
            FILE_COUNT=$(find "$TARGET" -type f | wc -l)
            echo "Target: $TARGET ($FILE_COUNT files) ✓"
        else
            echo "❌ ERROR: Target not found: $TARGET"
            return 1
        fi
    else
        echo "Target: Entire codebase (no specific target)"
    fi
    
    # Check git branch
    local BRANCH
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    echo "Git branch: $BRANCH ✓"
    
    echo ""
    echo "Ready to refactor ✓"
    echo ""
    echo "Description: $REFACTOR_DESC"
    
    # Export for use by other scripts
    export REFACTOR_DESC
    export TARGET
    export TEST_CMD
    
    return 0
}
