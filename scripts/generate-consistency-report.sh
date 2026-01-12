#!/bin/bash
# generate-consistency-report.sh
# Generates a detailed consistency report from consistency analysis

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get spec file path
SPEC_PATH="$1"

if [ -z "$SPEC_PATH" ]; then
    echo -e "${RED}Error: No spec file provided${NC}"
    echo "Usage: $0 <path-to-spec.md>"
    exit 1
fi

if [ ! -f "$SPEC_PATH" ]; then
    echo -e "${RED}Error: Spec file not found: $SPEC_PATH${NC}"
    exit 1
fi

# Extract feature name and paths
FEATURE_NAME=$(basename "$SPEC_PATH" .md)
SPEC_DIR=$(dirname "$SPEC_PATH")
DESIGN_PATH="${SPEC_DIR}/${FEATURE_NAME}-design.md"
TASKS_PATH="${SPEC_DIR}/${FEATURE_NAME}-tasks.md"
REPORT_PATH="${SPEC_DIR}/${FEATURE_NAME}-consistency-report.md"

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

echo -e "${BLUE}📊 Generating consistency report...${NC}"
echo ""

# Check if design and tasks exist
if [ ! -f "$DESIGN_PATH" ]; then
    echo -e "${RED}Error: Design file not found: $DESIGN_PATH${NC}"
    exit 1
fi

if [ ! -f "$TASKS_PATH" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_PATH${NC}"
    exit 1
fi

# Run consistency check and capture output
echo -e "${BLUE}Running consistency analysis...${NC}"
CONSISTENCY_OUTPUT=$(bash .cursor/scripts/check-consistency.sh "$SPEC_PATH" 2>&1 || true)

# Extract counts from output
CRITICAL_COUNT=$(echo "$CONSISTENCY_OUTPUT" | grep -oE "CRITICAL ISSUES \([0-9]+\)" | grep -oE "[0-9]+" || echo "0")
WARNING_COUNT=$(echo "$CONSISTENCY_OUTPUT" | grep -oE "WARNINGS \([0-9]+\)" | grep -oE "[0-9]+" || echo "0")
GOOD_COUNT=$(echo "$CONSISTENCY_OUTPUT" | grep -oE "GOOD \([0-9]+\)" | grep -oE "[0-9]+" || echo "0")

# Create report file
cat > "$REPORT_PATH" << EOF
# Consistency Report: ${FEATURE_NAME}

**Generated**: ${CURRENT_DATE}  
**Spec**: ${SPEC_PATH}  
**Design**: ${DESIGN_PATH}  
**Tasks**: ${TASKS_PATH}

---

## Executive Summary

| Category | Count | Status |
|----------|-------|--------|
| Critical Issues | ${CRITICAL_COUNT} | ${([ "$CRITICAL_COUNT" -gt 0 ] && echo "🔴 Action Required" || echo "✅ None")} |
| Warnings | ${WARNING_COUNT} | ${([ "$WARNING_COUNT" -gt 0 ] && echo "🟡 Review Recommended" || echo "✅ None")} |
| Good | ${GOOD_COUNT} | ✅ Consistent |

**Overall Status**: ${([ "$CRITICAL_COUNT" -eq 0 ] && echo "✅ Consistent" || echo "⚠️ Issues Found")}

---

## Detailed Analysis

### Full Consistency Check Output

\`\`\`
${CONSISTENCY_OUTPUT}
\`\`\`

---

## Recommended Fixes

### Critical Issues

$(if [ "$CRITICAL_COUNT" -gt 0 ]; then
    echo "$CONSISTENCY_OUTPUT" | sed -n '/🔴 CRITICAL ISSUES/,/🟡 WARNINGS/p' | sed '/🟡 WARNINGS/d' | sed 's/^/1. /'
else
    echo "✅ No critical issues found"
fi)

### Warnings

$(if [ "$WARNING_COUNT" -gt 0 ]; then
    echo "$CONSISTENCY_OUTPUT" | sed -n '/🟡 WARNINGS/,/🟢 GOOD/p' | sed '/🟢 GOOD/d' | sed 's/^/1. /'
else
    echo "✅ No warnings"
fi)

---

## File Comparison

### Spec → Design Alignment

**User Stories in Spec**: $(grep -c "### P[0-9]" "$SPEC_PATH" || echo "0")
**Components in Design**: $(grep -c "^### " "$DESIGN_PATH" || echo "0")

### Design → Tasks Alignment

**Database Tables in Design**: $(grep -c "CREATE TABLE\|^Table:" "$DESIGN_PATH" || echo "0")
**Migration Tasks**: $(grep -ci "migration\|CREATE TABLE" "$TASKS_PATH" || echo "0")

**API Endpoints in Design**: $(grep -cE "^(POST|GET|PUT|DELETE|PATCH) /" "$DESIGN_PATH" || echo "0")
**Endpoint Tasks**: $(grep -ci "endpoint\|api\|route" "$TASKS_PATH" || echo "0")

---

## Next Steps

1. **Review Critical Issues**: Fix all critical issues before starting implementation
2. **Address Warnings**: Review and fix warnings as time permits
3. **Re-run Analysis**: After making changes, run:
   \`\`\`bash
   bash .cursor/scripts/check-consistency.sh "${SPEC_PATH}"
   \`\`\`
4. **Regenerate Report**: Run this script again to update the report:
   \`\`\`bash
   bash .cursor/scripts/generate-consistency-report.sh "${SPEC_PATH}"
   \`\`\`

---

## Rerun Instructions

To regenerate this report after making changes:

\`\`\`bash
# 1. Fix issues in spec, design, or tasks files
# 2. Re-run consistency check
bash .cursor/scripts/check-consistency.sh "${SPEC_PATH}"

# 3. Regenerate this report
bash .cursor/scripts/generate-consistency-report.sh "${SPEC_PATH}"
\`\`\`

---

**Report Generated**: ${CURRENT_DATE}  
**Next Review**: After making changes to spec, design, or tasks files
EOF

echo -e "${GREEN}✅ Consistency report generated${NC}"
echo ""
echo -e "${BLUE}📄 Report: ${REPORT_PATH}${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  Critical Issues: ${CRITICAL_COUNT}"
echo "  Warnings: ${WARNING_COUNT}"
echo "  Good: ${GOOD_COUNT}"
echo ""
if [ "$CRITICAL_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Action Required: Fix ${CRITICAL_COUNT} critical issue(s) before implementation${NC}"
else
    echo -e "${GREEN}✅ No critical issues - safe to proceed${NC}"
fi
