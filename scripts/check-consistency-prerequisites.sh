#!/bin/bash
# Check prerequisites for consistency analysis

set -e

SPEC_PATH="$1"

if [ -z "$SPEC_PATH" ]; then
    echo "ERROR: No spec file provided"
    echo "Usage: /analyze-consistency docs/specs/[feature-name]/spec.md"
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

# Check if spec exists
if [ ! -f "$SPEC_PATH" ]; then
    echo "ERROR: Spec file not found: $SPEC_PATH"
    exit 1
fi

# Check for design file
if [ ! -f "$DESIGN_PATH" ]; then
    echo "ERROR: Design file not found: $DESIGN_PATH"
    echo "Run: /design-system $SPEC_PATH"
    exit 1
fi

# Check for tasks file
if [ ! -f "$TASKS_PATH" ]; then
    echo "ERROR: Tasks file not found: $TASKS_PATH"
    echo "Run: /plan-tasks $SPEC_PATH"
    exit 1
fi

# All files exist - output paths
echo "✅ All required files found"
echo ""
echo "Spec:   $SPEC_PATH"
echo "Design: $DESIGN_PATH"
echo "Tasks:  $TASKS_PATH"
echo ""
echo "Ready for consistency analysis"
