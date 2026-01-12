#!/bin/bash
# Check prerequisites for consistency analysis

set -e

SPEC_PATH="$1"

if [ -z "$SPEC_PATH" ]; then
    echo "ERROR: No spec file provided"
    echo "Usage: /analyze-consistency docs/specs/[feature-name].md"
    exit 1
fi

# Extract feature name from spec path
FEATURE_NAME=$(basename "$SPEC_PATH" .md)
SPEC_DIR=$(dirname "$SPEC_PATH")

# Check if spec exists
if [ ! -f "$SPEC_PATH" ]; then
    echo "ERROR: Spec file not found: $SPEC_PATH"
    exit 1
fi

# Check for design file
DESIGN_PATH="${SPEC_DIR}/${FEATURE_NAME}-design.md"
if [ ! -f "$DESIGN_PATH" ]; then
    echo "ERROR: Design file not found: $DESIGN_PATH"
    echo "Run: /design-system $SPEC_PATH"
    exit 1
fi

# Check for tasks file
TASKS_PATH="${SPEC_DIR}/${FEATURE_NAME}-tasks.md"
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
