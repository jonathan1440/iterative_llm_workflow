#!/bin/bash

# validate-spec.sh
# Validates a specification file against quality criteria

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get spec file path from arguments
SPEC_FILE="$1"

if [ -z "$SPEC_FILE" ]; then
    echo -e "${RED}Error: No spec file provided${NC}"
    echo "Usage: $0 <path-to-spec.md>"
    exit 1
fi

if [ ! -f "$SPEC_FILE" ]; then
    echo -e "${RED}Error: Spec file not found: $SPEC_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Validating specification: $SPEC_FILE${NC}"
echo ""

# Initialize counters
ISSUES=0
WARNINGS=0

# Check for placeholder markers
echo -e "${BLUE}Checking for placeholder markers...${NC}"
PLACEHOLDERS=$(grep -E '\[.*\]|TODO|TBD|FIXME|\?\?\?' "$SPEC_FILE" | grep -v '^\[' | grep -v '^- \[' || true)
if [ -n "$PLACEHOLDERS" ]; then
    echo -e "${YELLOW}⚠️  Found placeholder markers:${NC}"
    echo "$PLACEHOLDERS" | head -5
    ((WARNINGS++))
else
    echo -e "${GREEN}✓ No placeholder markers${NC}"
fi
echo ""

# Check for vague adjectives without metrics
echo -e "${BLUE}Checking for vague adjectives...${NC}"
VAGUE_TERMS=$(grep -iE '(fast|slow|quick|robust|scalable|secure|intuitive|efficient|reliable|performant)' "$SPEC_FILE" | grep -v 'Success Criteria' || true)
if [ -n "$VAGUE_TERMS" ]; then
    echo -e "${YELLOW}⚠️  Found vague terms that might need metrics:${NC}"
    echo "$VAGUE_TERMS" | head -5
    ((WARNINGS++))
else
    echo -e "${GREEN}✓ No vague adjectives without context${NC}"
fi
echo ""

# Check for implementation details in spec
echo -e "${BLUE}Checking for implementation details...${NC}"
IMPL_DETAILS=$(grep -iE '(React|Vue|Angular|Django|Flask|Node\.js|MongoDB|PostgreSQL|Redis|AWS|Azure|Docker|Kubernetes)' "$SPEC_FILE" | grep -v 'Third-Party Dependencies' | grep -v 'Constraints' || true)
if [ -n "$IMPL_DETAILS" ]; then
    echo -e "${RED}✗ Found implementation details in spec:${NC}"
    echo "$IMPL_DETAILS" | head -5
    ((ISSUES++))
else
    echo -e "${GREEN}✓ No implementation details${NC}"
fi
echo ""

# Check for required sections
echo -e "${BLUE}Checking required sections...${NC}"
REQUIRED_SECTIONS=("Problem Statement" "User Stories" "Success Criteria" "Functional Requirements")
for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "## $section" "$SPEC_FILE"; then
        echo -e "${GREEN}✓ Has $section${NC}"
    else
        echo -e "${RED}✗ Missing $section${NC}"
        ((ISSUES++))
    fi
done
echo ""

# Check for user stories format
echo -e "${BLUE}Checking user stories format...${NC}"
if grep -q "As a .*, I want .* so that" "$SPEC_FILE"; then
    echo -e "${GREEN}✓ User stories follow proper format${NC}"
else
    echo -e "${YELLOW}⚠️  User stories might not follow 'As a...I want...so that' format${NC}"
    ((WARNINGS++))
fi
echo ""

# Check for acceptance criteria
echo -e "${BLUE}Checking acceptance criteria...${NC}"
ACCEPTANCE_COUNT=$(grep -c "Acceptance Criteria:" "$SPEC_FILE" || true)
if [ "$ACCEPTANCE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $ACCEPTANCE_COUNT acceptance criteria sections${NC}"
else
    echo -e "${RED}✗ No acceptance criteria found${NC}"
    ((ISSUES++))
fi
echo ""

# Check for measurable success criteria
echo -e "${BLUE}Checking success criteria for metrics...${NC}"
if grep -A 10 "## Success Criteria" "$SPEC_FILE" | grep -qE '[0-9]+%|[0-9]+ (seconds|minutes|users|requests)|< [0-9]+|> [0-9]+'; then
    echo -e "${GREEN}✓ Success criteria contain measurable metrics${NC}"
else
    echo -e "${YELLOW}⚠️  Success criteria might lack specific metrics${NC}"
    ((WARNINGS++))
fi
echo ""

# Check for out of scope section
echo -e "${BLUE}Checking for scope boundaries...${NC}"
if grep -q "## Out of Scope" "$SPEC_FILE"; then
    echo -e "${GREEN}✓ Has Out of Scope section${NC}"
else
    echo -e "${YELLOW}⚠️  Missing Out of Scope section (recommended)${NC}"
    ((WARNINGS++))
fi
echo ""

# Check for data model if feature involves data
echo -e "${BLUE}Checking for data model...${NC}"
if grep -q "## Data Model" "$SPEC_FILE"; then
    if grep -A 20 "## Data Model" "$SPEC_FILE" | grep -qE '^\w+$'; then
        echo -e "${GREEN}✓ Has data model defined${NC}"
    else
        echo -e "${YELLOW}⚠️  Data model section exists but might be empty${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${BLUE}ℹ️  No data model section (might not be needed)${NC}"
fi
echo ""

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ "$ISSUES" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✅ Specification looks good!${NC}"
    echo ""
    echo -e "${GREEN}Ready for next steps:${NC}"
    echo "  1. Review for accuracy"
    echo "  2. Run /design-system to create system design"
    echo ""
    exit 0
elif [ "$ISSUES" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Specification has $WARNINGS warning(s)${NC}"
    echo ""
    echo -e "${YELLOW}Recommendations:${NC}"
    echo "  - Address warnings to improve spec quality"
    echo "  - Consider adding more specific metrics"
    echo "  - Define scope boundaries clearly"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Specification has $ISSUES issue(s) and $WARNINGS warning(s)${NC}"
    echo ""
    echo -e "${RED}Action required:${NC}"
    echo "  - Fix critical issues before proceeding"
    echo "  - Review spec against project standards"
    echo "  - Ensure all required sections present"
    echo ""
    exit 1
fi
