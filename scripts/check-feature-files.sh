#!/bin/bash
# Check that feature files exist before adding a story

set -e

SPEC_PATH="$1"
STORY_DESC="$2"

if [ -z "$SPEC_PATH" ] || [ -z "$STORY_DESC" ]; then
    echo "ERROR: Missing arguments"
    echo "Usage: /add-story docs/specs/[feature-name].md \"Story description\""
    exit 1
fi

# Check if spec exists
if [ ! -f "$SPEC_PATH" ]; then
    echo "ERROR: Spec file not found: $SPEC_PATH"
    echo "Create it first with: /spec-feature \"Feature description\""
    exit 1
fi

# Extract paths (handle both old and new formats)
SPEC_DIR=$(dirname "$SPEC_PATH")
if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
    # New format: feature-name/spec.md
    FEATURE_NAME=$(basename "$SPEC_DIR")
    DESIGN_PATH="${SPEC_DIR}/design.md"
    TASKS_PATH="${SPEC_DIR}/tasks.md"
else
    # Old format: feature-name.md
    FEATURE_NAME=$(basename "$SPEC_PATH" .md)
    FEATURE_DIR="${SPEC_DIR}/${FEATURE_NAME}"
    
    # Prefer new format if directory exists, otherwise old format
    if [ -d "$FEATURE_DIR" ]; then
        DESIGN_PATH="${FEATURE_DIR}/design.md"
        TASKS_PATH="${FEATURE_DIR}/tasks.md"
    else
        DESIGN_PATH="${SPEC_DIR}/${FEATURE_NAME}-design.md"
        TASKS_PATH="${SPEC_DIR}/${FEATURE_NAME}-tasks.md"
    fi
fi

# Check for design file
if [ ! -f "$DESIGN_PATH" ]; then
    echo "ERROR: Design file not found: $DESIGN_PATH"
    echo "Create it with: /design-system $SPEC_PATH"
    exit 1
fi

# Check for tasks file
if [ ! -f "$TASKS_PATH" ]; then
    echo "ERROR: Tasks file not found: $TASKS_PATH"
    echo "Create it with: /plan-tasks $SPEC_PATH"
    exit 1
fi

# Count existing user stories
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
