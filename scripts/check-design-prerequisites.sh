#!/bin/bash

# check-design-prerequisites.sh
# Verifies prerequisites before creating system design

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

echo -e "${BLUE}🔍 Checking prerequisites for system design...${NC}"
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

# Check if agents.md exists
if [ ! -f ".cursor/agents.md" ]; then
    echo -e "${RED}✗ agents.md not found${NC}"
    echo ""
    echo -e "${YELLOW}Action required:${NC}"
    echo "  Initialize project first with: /init-project"
    exit 1
fi
echo -e "${GREEN}✓ Project standards exist: .cursor/agents.md${NC}"

# Validate spec completeness
echo ""
echo -e "${BLUE}Validating spec completeness...${NC}"

# Check for placeholder markers
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
MISSING_SECTIONS=()
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
    exit 1
else
    echo -e "${GREEN}✓ All required sections present${NC}"
fi

# Generate file paths (handle both old and new formats)
SPEC_DIR=$(dirname "$SPEC_PATH")
if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
    # New format: feature-name/spec.md -> feature-name/design.md
    DESIGN_PATH="${SPEC_DIR}/design.md"
    RESEARCH_PATH="${SPEC_DIR}/research.md"
else
    # Old or new format check
    SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
    FEATURE_DIR="${SPEC_DIR}/${SPEC_FILENAME}"
    
    # Prefer new format if directory exists, otherwise old format
    if [ -d "$FEATURE_DIR" ]; then
        DESIGN_PATH="${FEATURE_DIR}/design.md"
        RESEARCH_PATH="${FEATURE_DIR}/research.md"
    else
        DESIGN_PATH="${SPEC_DIR}/${SPEC_FILENAME}-design.md"
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
echo "  Research: $RESEARCH_PATH"
echo ""

# Output paths in a format easy for the AI to parse
echo "SPEC_FILE=$SPEC_PATH"
echo "DESIGN_FILE=$DESIGN_PATH"
echo "RESEARCH_FILE=$RESEARCH_PATH"
echo "AGENTS_FILE=.cursor/agents.md"
