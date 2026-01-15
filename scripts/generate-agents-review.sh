#!/bin/bash
# generate-agents-review.sh
# Generates a comprehensive review report for all agent documentation

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if agents.md exists
AGENTS_FILE=".cursor/agents.md"

if [ ! -f "$AGENTS_FILE" ]; then
    echo -e "${RED}Error: agents.md not found: $AGENTS_FILE${NC}"
    echo "Initialize project first with: /init-project"
    exit 1
fi

# Check which agent-docs files exist
AGENT_DOCS_DIR=".cursor/agent-docs"
API_DOCS="$AGENT_DOCS_DIR/api.md"
DATABASE_DOCS="$AGENT_DOCS_DIR/database.md"
TESTING_DOCS="$AGENT_DOCS_DIR/testing.md"
ARCHITECTURE_DOCS="$AGENT_DOCS_DIR/architecture.md"
FAILURE_MODES_DOCS="$AGENT_DOCS_DIR/failure-modes.md"

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)
REVIEW_FILE=".cursor/agents-review-${CURRENT_DATE}.md"

echo -e "${BLUE}📊 Generating agent documentation review report...${NC}"
echo ""

# Count learnings in agents.md
AGENTS_LEARNING_COUNT=$(grep -c "Added:" "$AGENTS_FILE" || echo "0")

# Count by category in agents.md
AGENTS_ARCHITECTURE_COUNT=$(grep -c "^## Architecture\|^###.*Architecture" "$AGENTS_FILE" || echo "0")
AGENTS_MISTAKES_COUNT=$(grep -c "^## Common Mistakes\|^### Don't" "$AGENTS_FILE" || echo "0")
AGENTS_STANDARDS_COUNT=$(grep -c "^## Code Standards\|^###.*Standard" "$AGENTS_FILE" || echo "0")

# Count patterns in agent-docs files
API_PATTERNS=$(if [ -f "$API_DOCS" ]; then grep -c "^##\|^###" "$API_DOCS" || echo "0"; else echo "0"; fi)
DATABASE_PATTERNS=$(if [ -f "$DATABASE_DOCS" ]; then grep -c "^##\|^###" "$DATABASE_DOCS" || echo "0"; else echo "0"; fi)
TESTING_PATTERNS=$(if [ -f "$TESTING_DOCS" ]; then grep -c "^##\|^###" "$TESTING_DOCS" || echo "0"; else echo "0"; fi)
ARCHITECTURE_PATTERNS=$(if [ -f "$ARCHITECTURE_DOCS" ]; then grep -c "^##\|^###" "$ARCHITECTURE_DOCS" || echo "0"; else echo "0"; fi)
FAILURE_MODES_COUNT=$(if [ -f "$FAILURE_MODES_DOCS" ]; then grep -c "^#### Failure:\|^#### Edge Case:\|^#### Failure Point:" "$FAILURE_MODES_DOCS" || echo "0"; else echo "0"; fi)

# Total learnings across all files
TOTAL_LEARNINGS=$((AGENTS_LEARNING_COUNT + API_PATTERNS + DATABASE_PATTERNS + TESTING_PATTERNS + ARCHITECTURE_PATTERNS + FAILURE_MODES_COUNT))

# Get last updated dates
AGENTS_LAST_UPDATED=$(grep "Last Updated\|Last updated\|Updated:" "$AGENTS_FILE" | head -1 | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "Unknown")
API_LAST_UPDATED=$(if [ -f "$API_DOCS" ]; then grep "Last Updated\|Last updated\|Updated:" "$API_DOCS" | head -1 | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "Unknown"; else echo "N/A"; fi)
DATABASE_LAST_UPDATED=$(if [ -f "$DATABASE_DOCS" ]; then grep "Last Updated\|Last updated\|Updated:" "$DATABASE_DOCS" | head -1 | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "Unknown"; else echo "N/A"; fi)
FAILURE_MODES_LAST_UPDATED=$(if [ -f "$FAILURE_MODES_DOCS" ]; then grep "Last updated:" "$FAILURE_MODES_DOCS" | head -1 | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "Unknown"; else echo "N/A"; fi)

# Count entries with dates
AGENTS_ENTRIES_WITH_DATES=$(grep -c "Added:.*[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" "$AGENTS_FILE" || echo "0")

# Find most recent addition across all files
MOST_RECENT=$(grep -h "Added:" "$AGENTS_FILE" "$API_DOCS" "$DATABASE_DOCS" "$TESTING_DOCS" "$ARCHITECTURE_DOCS" "$FAILURE_MODES_DOCS" 2>/dev/null | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" | sort -r | head -1 || echo "None")

# Build file list string
FILES_LIST="agents.md"
[ -f "$API_DOCS" ] && FILES_LIST="api.md, $FILES_LIST"
[ -f "$DATABASE_DOCS" ] && FILES_LIST="database.md, $FILES_LIST"
[ -f "$TESTING_DOCS" ] && FILES_LIST="testing.md, $FILES_LIST"
[ -f "$ARCHITECTURE_DOCS" ] && FILES_LIST="architecture.md, $FILES_LIST"
[ -f "$FAILURE_MODES_DOCS" ] && FILES_LIST="failure-modes.md, $FILES_LIST"

# Build agent-docs section
AGENT_DOCS_SECTION=""
[ -f "$API_DOCS" ] && AGENT_DOCS_SECTION="${AGENT_DOCS_SECTION}**agent-docs/api.md:**
- Patterns: ${API_PATTERNS}
- Last Updated: ${API_LAST_UPDATED}

"
[ -f "$DATABASE_DOCS" ] && AGENT_DOCS_SECTION="${AGENT_DOCS_SECTION}**agent-docs/database.md:**
- Patterns: ${DATABASE_PATTERNS}
- Last Updated: ${DATABASE_LAST_UPDATED}

"
[ -f "$TESTING_DOCS" ] && AGENT_DOCS_SECTION="${AGENT_DOCS_SECTION}**agent-docs/testing.md:**
- Patterns: ${TESTING_PATTERNS}

"
[ -f "$ARCHITECTURE_DOCS" ] && AGENT_DOCS_SECTION="${AGENT_DOCS_SECTION}**agent-docs/architecture.md:**
- Patterns: ${ARCHITECTURE_PATTERNS}

"
[ -f "$FAILURE_MODES_DOCS" ] && AGENT_DOCS_SECTION="${AGENT_DOCS_SECTION}**agent-docs/failure-modes.md:**
- Failure Modes: ${FAILURE_MODES_COUNT}
- Last Updated: ${FAILURE_MODES_LAST_UPDATED}

"

# Build file statistics section
FILE_STATS_SECTION=""
[ -f "$API_DOCS" ] && FILE_STATS_SECTION="${FILE_STATS_SECTION}### agent-docs/api.md
\`\`\`
Size: $(wc -l < "$API_DOCS" | tr -d ' ') lines
Last Modified: $(stat -f "%Sm" "$API_DOCS" 2>/dev/null || stat -c "%y" "$API_DOCS" 2>/dev/null || echo "Unknown")
\`\`\`

"
[ -f "$DATABASE_DOCS" ] && FILE_STATS_SECTION="${FILE_STATS_SECTION}### agent-docs/database.md
\`\`\`
Size: $(wc -l < "$DATABASE_DOCS" | tr -d ' ') lines
Last Modified: $(stat -f "%Sm" "$DATABASE_DOCS" 2>/dev/null || stat -c "%y" "$DATABASE_DOCS" 2>/dev/null || echo "Unknown")
\`\`\`

"
[ -f "$FAILURE_MODES_DOCS" ] && FILE_STATS_SECTION="${FILE_STATS_SECTION}### agent-docs/failure-modes.md
\`\`\`
Size: $(wc -l < "$FAILURE_MODES_DOCS" | tr -d ' ') lines
Last Modified: $(stat -f "%Sm" "$FAILURE_MODES_DOCS" 2>/dev/null || stat -c "%y" "$FAILURE_MODES_DOCS" 2>/dev/null || echo "Unknown")
\`\`\`

"

# Build recent additions section
RECENT_ADDITIONS="**agents.md:**
$(grep "Added:" "$AGENTS_FILE" 2>/dev/null | grep -E "$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)" | head -3 | sed 's/^/  - /' || echo "  (None in last 30 days)")

"
[ -f "$FAILURE_MODES_DOCS" ] && RECENT_ADDITIONS="${RECENT_ADDITIONS}**agent-docs/failure-modes.md:**
$(grep "Added:" "$FAILURE_MODES_DOCS" 2>/dev/null | grep -E "$(date -v-30d +%Y-%m-%d 2>/dev/null || date -d '30 days ago' +%Y-%m-%d)" | head -3 | sed 's/^/  - /' || echo "  (None in last 30 days)")

"

# Build patterns section
PATTERNS_SECTION="### agents.md Patterns

$(grep -E "^##|^###" "$AGENTS_FILE" | head -10 | sed 's/^/  - /')

"
[ -f "$API_DOCS" ] && PATTERNS_SECTION="${PATTERNS_SECTION}### agent-docs/api.md Patterns
$(grep -E "^##|^###" "$API_DOCS" | head -5 | sed 's/^/  - /')

"
[ -f "$DATABASE_DOCS" ] && PATTERNS_SECTION="${PATTERNS_SECTION}### agent-docs/database.md Patterns
$(grep -E "^##|^###" "$DATABASE_DOCS" | head -5 | sed 's/^/  - /')

"
[ -f "$FAILURE_MODES_DOCS" ] && PATTERNS_SECTION="${PATTERNS_SECTION}### agent-docs/failure-modes.md Failure Modes
$(grep -E "^#### Failure:|^#### Edge Case:" "$FAILURE_MODES_DOCS" | head -5 | sed 's/^/  - /')

"

# Create review report
cat > "$REVIEW_FILE" << EOF
# Agent Documentation Review Report

**Date**: ${CURRENT_DATE}  
**Most Recent Addition**: ${MOST_RECENT}

---

## Summary

- **Total Learnings**: ${TOTAL_LEARNINGS} (across all files)
- **Files Reviewed**: ${FILES_LIST}

### By File

**agents.md:**
- Total Learnings: ${AGENTS_LEARNING_COUNT}
- Architecture Principles: ${AGENTS_ARCHITECTURE_COUNT}
- Common Mistakes: ${AGENTS_MISTAKES_COUNT}
- Code Standards: ${AGENTS_STANDARDS_COUNT}
- Entries with Dates: ${AGENTS_ENTRIES_WITH_DATES}
- Last Updated: ${AGENTS_LAST_UPDATED}

${AGENT_DOCS_SECTION}

---

## File Statistics

### agents.md
\`\`\`
File: ${AGENTS_FILE}
Size: $(wc -l < "$AGENTS_FILE" | tr -d ' ') lines
Last Modified: $(stat -f "%Sm" "$AGENTS_FILE" 2>/dev/null || stat -c "%y" "$AGENTS_FILE" 2>/dev/null || echo "Unknown")
\`\`\`

${FILE_STATS_SECTION}

---

## Content Analysis

### Learning Entries by Date (All Files)

$(grep -h "Added:" "$AGENTS_FILE" "$API_DOCS" "$DATABASE_DOCS" "$TESTING_DOCS" "$ARCHITECTURE_DOCS" "$FAILURE_MODES_DOCS" 2>/dev/null | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" | sort | uniq -c | sort -rn | head -10 | while read -r count date; do
    echo "- ${date}: ${count} entries"
done)

### Recent Additions (Last 30 Days)

${RECENT_ADDITIONS}

---

## Recommendations

### 1. Review Frequency

**Current Status**: Review generated on ${CURRENT_DATE}

**Recommendation**: 
- Review agents.md monthly for active projects
- Review quarterly for maintenance mode
- Review after major milestones

**Next Review**: $(date -v+30d +%Y-%m-%d 2>/dev/null || date -d '30 days' +%Y-%m-%d)

### 2. Content Quality

**agents.md entries with dates**: ${AGENTS_ENTRIES_WITH_DATES} / ${AGENTS_LEARNING_COUNT}

$(if [ "$AGENTS_ENTRIES_WITH_DATES" -lt "$AGENTS_LEARNING_COUNT" ]; then
    echo "⚠️  Some entries in agents.md are missing dates. Consider adding dates to all entries."
else
    echo "✅ All entries in agents.md have dates."
fi)

### 3. File Organization

**Recommendation**: Ensure domain-specific content is in appropriate agent-docs files:
- API patterns → agent-docs/api.md
- Database patterns → agent-docs/database.md
- Testing patterns → agent-docs/testing.md
- Architecture patterns → agent-docs/architecture.md
- Failure modes → agent-docs/failure-modes.md
- General principles → agents.md


---

## Patterns Detected

${PATTERNS_SECTION}

---

## Action Items

- [ ] Review all entries across all files for accuracy and relevance
- [ ] Route domain-specific content from agents.md to appropriate agent-docs files
- [ ] Archive outdated entries (older than 1 year if unused)
- [ ] Add examples to vague entries
- [ ] Merge duplicate entries if found (check both within files and across files)
- [ ] Add cross-references between related patterns in different files
- [ ] Update "Last Updated" dates in all files
- [ ] Ensure failure modes have complete structure (what happens, why, how to prevent, examples)

---

## Next Steps

1. **Review this report** for insights
2. **Update documentation files** based on findings:
   - Route domain-specific content to appropriate agent-docs files
   - Add failure modes to agent-docs/failure-modes.md
   - Keep only general principles in agents.md
3. **Add cross-references** between related patterns in different files
4. **Run consistency checks** on related files
5. **Schedule next review** in 30 days

---

## Regeneration

To regenerate this report:

\`\`\`bash
bash .cursor/scripts/generate-agents-review.sh
\`\`\`

---

**Report Generated**: ${CURRENT_DATE}  
**Generated By**: agents.md review script
EOF

echo -e "${GREEN}✅ Review report generated${NC}"
echo ""
echo -e "${BLUE}📄 Report: ${REVIEW_FILE}${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  Total Learnings: ${TOTAL_LEARNINGS} (across all files)"
echo "  agents.md: ${AGENTS_LEARNING_COUNT} learnings"
[ -f "$API_DOCS" ] && echo "  agent-docs/api.md: ${API_PATTERNS} patterns"
[ -f "$DATABASE_DOCS" ] && echo "  agent-docs/database.md: ${DATABASE_PATTERNS} patterns"
[ -f "$TESTING_DOCS" ] && echo "  agent-docs/testing.md: ${TESTING_PATTERNS} patterns"
[ -f "$ARCHITECTURE_DOCS" ] && echo "  agent-docs/architecture.md: ${ARCHITECTURE_PATTERNS} patterns"
[ -f "$FAILURE_MODES_DOCS" ] && echo "  agent-docs/failure-modes.md: ${FAILURE_MODES_COUNT} failure modes"
echo ""
echo -e "${YELLOW}💡 Review the report and update documentation files as needed${NC}"
echo -e "${YELLOW}💡 Route domain-specific content to appropriate agent-docs files${NC}"
