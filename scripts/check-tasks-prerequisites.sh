#!/bin/bash

# check-tasks-prerequisites.sh
# Verifies prerequisites before creating task breakdown

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get spec file path from arguments
SPEC_PATH="$1"

if [ -z "$SPEC_PATH" ]; then
    echo -e "${RED}Error: No spec file path provided${NC}"
    echo "Usage: $0 <path-to-spec.md>"
    exit 1
fi

echo -e "${BLUE}🔍 Checking prerequisites for task planning...${NC}"
echo ""

# Check if spec file exists
if [ ! -f "$SPEC_PATH" ]; then
    echo -e "${RED}✗ Spec file not found: $SPEC_PATH${NC}"
    echo ""
    echo -e "${YELLOW}Action required:${NC}"
    echo "  Create the spec first with: /spec-feature \"your feature\""
    exit 1
fi
echo -e "${GREEN}✓ Spec file exists: $SPEC_PATH${NC}"

# Generate design file path (handle both old and new formats)
if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
    # New format: feature-name/spec.md -> feature-name/design.md
    SPEC_DIR=$(dirname "$SPEC_PATH")
    DESIGN_PATH="${SPEC_DIR}/design.md"
else
    # Old or new format check
    SPEC_DIR=$(dirname "$SPEC_PATH")
    SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
    FEATURE_DIR="${SPEC_DIR}/${SPEC_FILENAME}"
    
    # Prefer new format if directory exists, otherwise old format
    if [ -d "$FEATURE_DIR" ]; then
        DESIGN_PATH="${FEATURE_DIR}/design.md"
    else
        DESIGN_PATH="${SPEC_DIR}/${SPEC_FILENAME}-design.md"
    fi
fi

# Check if design file exists
if [ ! -f "$DESIGN_PATH" ]; then
    echo -e "${RED}✗ Design file not found: $DESIGN_PATH${NC}"
    echo ""
    echo -e "${YELLOW}Action required:${NC}"
    echo "  Create the design first with: /design-system $SPEC_PATH"
    exit 1
fi
echo -e "${GREEN}✓ Design file exists: $DESIGN_PATH${NC}"

# Check if agents.md exists
if [ ! -f ".cursor/agents.md" ]; then
    echo -e "${RED}✗ agents.md not found${NC}"
    echo ""
    echo -e "${YELLOW}Action required:${NC}"
    echo "  Initialize project first with: /init-project"
    exit 1
fi
echo -e "${GREEN}✓ Project standards exist: .cursor/agents.md${NC}"

# Check for user stories in spec
echo ""
echo -e "${BLUE}Analyzing spec for user stories...${NC}"
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
REQUIREMENTS=$(grep -c "^[0-9]\+\." "$SPEC_PATH" || true)
if [ "$REQUIREMENTS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No functional requirements found${NC}"
    echo -e "${YELLOW}   Tasks should map to requirements${NC}"
fi

# Check for database schema in design
if grep -q "## 2. Database Schema" "$DESIGN_PATH"; then
    TABLES=$(grep -c "^CREATE TABLE" "$DESIGN_PATH" || true)
    echo -e "${GREEN}✓ Design includes $TABLES database tables${NC}"
else
    echo -e "${YELLOW}⚠️  No database schema found in design${NC}"
fi

# Check for API endpoints in design
if grep -q "## 3. API Contracts" "$DESIGN_PATH"; then
    ENDPOINTS=$(grep -c "^### Endpoint:" "$DESIGN_PATH" || true)
    echo -e "${GREEN}✓ Design includes $ENDPOINTS API endpoints${NC}"
else
    echo -e "${YELLOW}⚠️  No API contracts found in design${NC}"
fi

# Generate tasks and research file paths (handle both old and new formats)
if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
    # New format
    TASKS_PATH="${SPEC_DIR}/tasks.md"
    RESEARCH_PATH="${SPEC_DIR}/research.md"
else
    # Old or new format check
    if [ -d "$FEATURE_DIR" ]; then
        # New format
        TASKS_PATH="${FEATURE_DIR}/tasks.md"
        RESEARCH_PATH="${FEATURE_DIR}/research.md"
    else
        # Old format
        TASKS_PATH="${SPEC_DIR}/${SPEC_FILENAME}-tasks.md"
        RESEARCH_PATH="${SPEC_DIR}/${SPEC_FILENAME}-research.md"
    fi
fi

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
