#!/bin/bash
# export-status.sh
# Exports project status in various formats

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get arguments
TASKS_FILE="$1"
FORMAT="$2"
OUTPUT_FILE="$3"

if [ -z "$TASKS_FILE" ] || [ -z "$FORMAT" ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: $0 <tasks-file> <format> [output-file]"
    echo ""
    echo "Formats:"
    echo "  1 or markdown - Markdown report (detailed)"
    echo "  2 or json     - JSON (for dashboards/tools)"
    echo "  3 or csv      - CSV (for spreadsheets)"
    echo "  4 or text     - Plain text (for commit messages)"
    exit 1
fi

if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    exit 1
fi

# Determine output file
if [ -z "$OUTPUT_FILE" ]; then
    FEATURE_NAME=$(basename "$TASKS_FILE" -tasks.md)
    SPEC_DIR=$(dirname "$TASKS_FILE")
    
    case "$FORMAT" in
        1|markdown|md)
            OUTPUT_FILE="${SPEC_DIR}/${FEATURE_NAME}-status.md"
            ;;
        2|json)
            OUTPUT_FILE="${SPEC_DIR}/${FEATURE_NAME}-status.json"
            ;;
        3|csv)
            OUTPUT_FILE="${SPEC_DIR}/${FEATURE_NAME}-status.csv"
            ;;
        4|text|txt)
            OUTPUT_FILE="${SPEC_DIR}/${FEATURE_NAME}-status.txt"
            ;;
        *)
            echo -e "${RED}Error: Invalid format: $FORMAT${NC}"
            exit 1
            ;;
    esac
fi

echo -e "${BLUE}📤 Exporting status to ${FORMAT} format...${NC}"
echo ""

# Get status data using analyze-status.sh
STATUS_DATA=$(bash .cursor/scripts/analyze-status.sh "$TASKS_FILE" 2>/dev/null || echo "")

# Extract feature name
FEATURE_NAME=$(grep -m 1 "^# Feature:" "$(echo "$TASKS_FILE" | sed 's/-tasks\.md$/.md/')" 2>/dev/null | sed 's/^# Feature: //' || basename "$TASKS_FILE" -tasks.md)

# Count tasks
TOTAL_TASKS=$(grep -c "^- \[.\] T[0-9]" "$TASKS_FILE" || echo "0")
COMPLETE_TASKS=$(grep -c "^- \[X\] T[0-9]" "$TASKS_FILE" || echo "0")
INCOMPLETE_TASKS=$((TOTAL_TASKS - COMPLETE_TASKS))
PERCENT=$((COMPLETE_TASKS * 100 / TOTAL_TASKS)) 2>/dev/null || PERCENT=0

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Export based on format
case "$FORMAT" in
    1|markdown|md)
        cat > "$OUTPUT_FILE" << EOF
# Project Status: ${FEATURE_NAME}

**Generated**: ${CURRENT_DATE}  
**Tasks File**: ${TASKS_FILE}

---

## Overall Progress

**Total Tasks**: ${TOTAL_TASKS}  
**Completed**: ${COMPLETE_TASKS}  
**Remaining**: ${INCOMPLETE_TASKS}  
**Progress**: ${PERCENT}%

**Progress Bar**: $(printf "█%.0s" $(seq 1 $((PERCENT / 5))))$(printf "░%.0s" $(seq 1 $((20 - PERCENT / 5))))) ${PERCENT}%

---

## Phase Breakdown

$(grep "^## Phase" "$TASKS_FILE" | while read -r phase_line; do
    PHASE_NUM=$(echo "$phase_line" | grep -oE "Phase [0-9]+" | grep -oE "[0-9]+" || echo "")
    if [ -n "$PHASE_NUM" ]; then
        PHASE_TASKS=$(grep -A 100 "^## Phase $PHASE_NUM" "$TASKS_FILE" | grep "^- \[.\]" | head -20 | wc -l | tr -d ' ')
        PHASE_COMPLETE=$(grep -A 100 "^## Phase $PHASE_NUM" "$TASKS_FILE" | grep "^- \[X\]" | wc -l | tr -d ' ')
        PHASE_PERCENT=$((PHASE_COMPLETE * 100 / PHASE_TASKS)) 2>/dev/null || PHASE_PERCENT=0
        echo "### $phase_line"
        echo "- Tasks: ${PHASE_COMPLETE}/${PHASE_TASKS} (${PHASE_PERCENT}%)"
        echo ""
    fi
done)

---

## Task List

$(grep "^- \[.\] T[0-9]" "$TASKS_FILE" | head -50 | sed 's/^- \[ \]/- [ ] /' | sed 's/^- \[X\]/- [X] /')

$(if [ "$TOTAL_TASKS" -gt 50 ]; then
    echo "... and $((TOTAL_TASKS - 50)) more tasks"
fi)

---

**Last Updated**: ${CURRENT_DATE}
EOF
        echo -e "${GREEN}✅ Markdown report exported${NC}"
        ;;
        
    2|json)
        cat > "$OUTPUT_FILE" << EOF
{
  "feature": "${FEATURE_NAME}",
  "generated": "${CURRENT_DATE}",
  "tasks_file": "${TASKS_FILE}",
  "progress": {
    "total": ${TOTAL_TASKS},
    "completed": ${COMPLETE_TASKS},
    "remaining": ${INCOMPLETE_TASKS},
    "percent": ${PERCENT}
  },
  "phases": [
$(grep "^## Phase" "$TASKS_FILE" | while read -r phase_line; do
    PHASE_NUM=$(echo "$phase_line" | grep -oE "Phase [0-9]+" | grep -oE "[0-9]+" || echo "")
    if [ -n "$PHASE_NUM" ]; then
        PHASE_TASKS=$(grep -A 100 "^## Phase $PHASE_NUM" "$TASKS_FILE" | grep "^- \[.\]" | head -20 | wc -l | tr -d ' ')
        PHASE_COMPLETE=$(grep -A 100 "^## Phase $PHASE_NUM" "$TASKS_FILE" | grep "^- \[X\]" | wc -l | tr -d ' ')
        PHASE_PERCENT=$((PHASE_COMPLETE * 100 / PHASE_TASKS)) 2>/dev/null || PHASE_PERCENT=0
        echo "    {"
        echo "      \"phase\": \"$phase_line\","
        echo "      \"tasks\": ${PHASE_TASKS},"
        echo "      \"completed\": ${PHASE_COMPLETE},"
        echo "      \"percent\": ${PHASE_PERCENT}"
        echo "    },"
    fi
done | sed '$ s/,$//')
  ]
}
EOF
        echo -e "${GREEN}✅ JSON export completed${NC}"
        ;;
        
    3|csv)
        cat > "$OUTPUT_FILE" << EOF
Feature,Date,Total Tasks,Completed,Remaining,Percent
${FEATURE_NAME},${CURRENT_DATE},${TOTAL_TASKS},${COMPLETE_TASKS},${INCOMPLETE_TASKS},${PERCENT}

Phase,Phase Name,Tasks,Completed,Percent
$(grep "^## Phase" "$TASKS_FILE" | while read -r phase_line; do
    PHASE_NUM=$(echo "$phase_line" | grep -oE "Phase [0-9]+" | grep -oE "[0-9]+" || echo "")
    if [ -n "$PHASE_NUM" ]; then
        PHASE_NAME=$(echo "$phase_line" | sed 's/^## Phase [0-9]*: //')
        PHASE_TASKS=$(grep -A 100 "^## Phase $PHASE_NUM" "$TASKS_FILE" | grep "^- \[.\]" | head -20 | wc -l | tr -d ' ')
        PHASE_COMPLETE=$(grep -A 100 "^## Phase $PHASE_NUM" "$TASKS_FILE" | grep "^- \[X\]" | wc -l | tr -d ' ')
        PHASE_PERCENT=$((PHASE_COMPLETE * 100 / PHASE_TASKS)) 2>/dev/null || PHASE_PERCENT=0
        echo "Phase ${PHASE_NUM},\"${PHASE_NAME}\",${PHASE_TASKS},${PHASE_COMPLETE},${PHASE_PERCENT}"
    fi
done)
EOF
        echo -e "${GREEN}✅ CSV export completed${NC}"
        ;;
        
    4|text|txt)
        cat > "$OUTPUT_FILE" << EOF
Project Status: ${FEATURE_NAME}
Generated: ${CURRENT_DATE}

Overall Progress:
  Total Tasks: ${TOTAL_TASKS}
  Completed: ${COMPLETE_TASKS}
  Remaining: ${INCOMPLETE_TASKS}
  Progress: ${PERCENT}%

Phases:
$(grep "^## Phase" "$TASKS_FILE" | while read -r phase_line; do
    PHASE_NUM=$(echo "$phase_line" | grep -oE "Phase [0-9]+" | grep -oE "[0-9]+" || echo "")
    if [ -n "$PHASE_NUM" ]; then
        PHASE_TASKS=$(grep -A 100 "^## Phase $PHASE_NUM" "$TASKS_FILE" | grep "^- \[.\]" | head -20 | wc -l | tr -d ' ')
        PHASE_COMPLETE=$(grep -A 100 "^## Phase $PHASE_NUM" "$TASKS_FILE" | grep "^- \[X\]" | wc -l | tr -d ' ')
        PHASE_PERCENT=$((PHASE_COMPLETE * 100 / PHASE_TASKS)) 2>/dev/null || PHASE_PERCENT=0
        echo "  $phase_line: ${PHASE_COMPLETE}/${PHASE_TASKS} (${PHASE_PERCENT}%)"
    fi
done)
EOF
        echo -e "${GREEN}✅ Plain text export completed${NC}"
        ;;
        
    *)
        echo -e "${RED}Error: Invalid format: $FORMAT${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}📄 Exported to: ${OUTPUT_FILE}${NC}"
