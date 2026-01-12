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

# Extract feature name
FEATURE_NAME=$(basename "$SPEC_PATH" .md)
SPEC_DIR=$(dirname "$SPEC_PATH")

# Check for design file
DESIGN_PATH="${SPEC_DIR}/${FEATURE_NAME}-design.md"
if [ ! -f "$DESIGN_PATH" ]; then
    echo "ERROR: Design file not found: $DESIGN_PATH"
    echo "Create it with: /design-system $SPEC_PATH"
    exit 1
fi

# Check for tasks file
TASKS_PATH="${SPEC_DIR}/${FEATURE_NAME}-tasks.md"
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
