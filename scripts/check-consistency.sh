#!/bin/bash
# Perform consistency checks across spec, design, and tasks

set -e

SPEC_PATH="$1"

# Extract paths
FEATURE_NAME=$(basename "$SPEC_PATH" .md)
SPEC_DIR=$(dirname "$SPEC_PATH")
DESIGN_PATH="${SPEC_DIR}/${FEATURE_NAME}-design.md"
TASKS_PATH="${SPEC_DIR}/${FEATURE_NAME}-tasks.md"

echo "╔════════════════════════════════════════════════╗"
echo "║   Running Consistency Checks                   ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

# Create temp files for issues
CRITICAL_FILE=$(mktemp)
WARNINGS_FILE=$(mktemp)
GOOD_FILE=$(mktemp)

# Track counts
CRITICAL_COUNT=0
WARNING_COUNT=0
GOOD_COUNT=0

# Function to add issue
add_critical() {
    echo "$1" >> "$CRITICAL_FILE"
    ((CRITICAL_COUNT++))
}

add_warning() {
    echo "$1" >> "$WARNINGS_FILE"
    ((WARNING_COUNT++))
}

add_good() {
    echo "$1" >> "$GOOD_FILE"
    ((GOOD_COUNT++))
}

# Check 1: User Stories in Spec have Tasks
echo "Checking: User Stories → Tasks..."
USER_STORIES=$(grep -E "^(### |## )User Story [0-9]" "$SPEC_PATH" | wc -l || true)
if [ "$USER_STORIES" -gt 0 ]; then
    # Check each story has tasks
    for i in $(seq 1 "$USER_STORIES"); do
        if grep -q "Phase.*User Story $i" "$TASKS_PATH"; then
            add_good "✓ User Story $i has task breakdown"
        else
            add_critical "✗ User Story $i: No tasks found in tasks file"
        fi
    done
else
    add_warning "⚠ No user stories found in spec"
fi

# Check 2: Database Tables have Migrations
echo "Checking: Database Tables → Migrations..."
if grep -q "## Database Schema" "$DESIGN_PATH"; then
    TABLES=$(grep -E "^(CREATE TABLE|Table:)" "$DESIGN_PATH" | wc -l || true)
    MIGRATIONS=$(grep -E "migration|Migration|CREATE TABLE" "$TASKS_PATH" | wc -l || true)
    
    if [ "$TABLES" -gt 0 ] && [ "$MIGRATIONS" -eq 0 ]; then
        add_critical "✗ Design has $TABLES tables but no migration tasks found"
    elif [ "$TABLES" -gt 0 ] && [ "$MIGRATIONS" -gt 0 ]; then
        add_good "✓ Database tables have migration tasks"
    fi
fi

# Check 3: API Endpoints have Implementation Tasks
echo "Checking: API Endpoints → Implementation..."
if grep -q "## API Endpoints" "$DESIGN_PATH"; then
    ENDPOINTS=$(grep -E "^(POST|GET|PUT|DELETE|PATCH) /" "$DESIGN_PATH" | wc -l || true)
    ENDPOINT_TASKS=$(grep -i "endpoint\|api\|route" "$TASKS_PATH" | wc -l || true)
    
    if [ "$ENDPOINTS" -gt 0 ] && [ "$ENDPOINT_TASKS" -eq 0 ]; then
        add_warning "⚠ Design has $ENDPOINTS API endpoints but few/no implementation tasks"
    elif [ "$ENDPOINTS" -gt 0 ]; then
        add_good "✓ API endpoints have implementation tasks"
    fi
fi

# Check 4: MVP Definition Consistency
echo "Checking: MVP Definition..."
SPEC_MVP=$(grep -i "MVP" "$SPEC_PATH" | head -1 || echo "")
TASKS_MVP=$(grep -i "MVP" "$TASKS_PATH" | head -1 || echo "")

if [ -n "$SPEC_MVP" ] && [ -n "$TASKS_MVP" ]; then
    # Basic check - both mention same user story number
    SPEC_US=$(echo "$SPEC_MVP" | grep -oE "User Story [0-9]" | head -1 || echo "")
    TASKS_US=$(echo "$TASKS_MVP" | grep -oE "User Story [0-9]" | head -1 || echo "")
    
    if [ "$SPEC_US" = "$TASKS_US" ] && [ -n "$SPEC_US" ]; then
        add_good "✓ MVP definition consistent across spec and tasks"
    elif [ -n "$SPEC_US" ] && [ -n "$TASKS_US" ]; then
        add_warning "⚠ MVP definition may differ (Spec: $SPEC_US, Tasks: $TASKS_US)"
    fi
fi

# Check 5: Task Dependencies Valid
echo "Checking: Task Dependencies..."
INVALID_DEPS=0
while IFS= read -r line; do
    if [[ "$line" =~ "Depends:" ]]; then
        # Extract task IDs from dependency line
        DEPS=$(echo "$line" | grep -oE "T[0-9]+" || true)
        for dep in $DEPS; do
            if ! grep -q "^- \[ \] $dep:" "$TASKS_PATH"; then
                ((INVALID_DEPS++))
            fi
        done
    fi
done < "$TASKS_PATH"

if [ "$INVALID_DEPS" -eq 0 ]; then
    add_good "✓ All task dependencies are valid"
else
    add_critical "✗ Found $INVALID_DEPS invalid task dependencies"
fi

# Check 6: All Sections Complete
echo "Checking: Document Completeness..."
if grep -q "TODO\|TBD\|\[placeholder\]" "$SPEC_PATH"; then
    add_warning "⚠ Spec contains TODO/TBD placeholders"
else
    add_good "✓ Spec is complete (no placeholders)"
fi

if grep -q "TODO\|TBD\|\[placeholder\]" "$DESIGN_PATH"; then
    add_warning "⚠ Design contains TODO/TBD placeholders"
else
    add_good "✓ Design is complete (no placeholders)"
fi

# Output Results
echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║     Consistency Analysis Results               ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

if [ "$CRITICAL_COUNT" -gt 0 ]; then
    echo "🔴 CRITICAL ISSUES ($CRITICAL_COUNT)"
    echo "Issues that will cause implementation failures:"
    echo ""
    cat "$CRITICAL_FILE"
    echo ""
fi

if [ "$WARNING_COUNT" -gt 0 ]; then
    echo "🟡 WARNINGS ($WARNING_COUNT)"
    echo "Issues that may cause confusion or inconsistency:"
    echo ""
    cat "$WARNINGS_FILE"
    echo ""
fi

if [ "$GOOD_COUNT" -gt 0 ]; then
    echo "🟢 GOOD ($GOOD_COUNT)"
    echo "Things that are consistent:"
    echo ""
    cat "$GOOD_FILE"
    echo ""
fi

echo "═══════════════════════════════════════════════════"
echo "Summary: $CRITICAL_COUNT critical, $WARNING_COUNT warnings, $GOOD_COUNT good"
echo "═══════════════════════════════════════════════════"
echo ""

if [ "$CRITICAL_COUNT" -gt 0 ]; then
    echo "⚠️  Recommendation: Fix critical issues before implementation"
elif [ "$WARNING_COUNT" -gt 0 ]; then
    echo "💡 Recommendation: Review and fix warnings"
else
    echo "✅ All checks passed! Documents are consistent."
fi

# Cleanup
rm "$CRITICAL_FILE" "$WARNINGS_FILE" "$GOOD_FILE"

exit 0
