#!/bin/bash
# Find tasks file from spec path or by searching

set -e

INPUT="$1"

if [ -z "$INPUT" ]; then
    # Search for tasks files (both old and new formats)
    TASKS_FILES=$(find docs/specs -name "tasks.md" -o -name "*-tasks.md" 2>/dev/null | sort || true)
    
    if [ -z "$TASKS_FILES" ]; then
        echo "ERROR: No tasks files found in docs/specs/"
        echo "Create one with: /plan-tasks docs/specs/[feature-name]/spec.md"
        exit 1
    fi
    
    # Count files
    NUM_FILES=$(echo "$TASKS_FILES" | wc -l | tr -d ' ')
    
    if [ "$NUM_FILES" -eq 1 ]; then
        echo "$TASKS_FILES"
        exit 0
    else
        echo "ERROR: Multiple tasks files found. Specify which one:"
        echo "$TASKS_FILES"
        exit 1
    fi
fi

# Check if input is already a tasks file
if [[ "$INPUT" == *"tasks.md" ]]; then
    if [ -f "$INPUT" ]; then
        echo "$INPUT"
        exit 0
    else
        echo "ERROR: Tasks file not found: $INPUT"
        exit 1
    fi
fi

# Assume input is spec file, derive tasks file (handle both formats)
if [[ "$INPUT" == *"/spec.md" ]]; then
    # New format: feature-name/spec.md -> feature-name/tasks.md
    SPEC_DIR=$(dirname "$INPUT")
    TASKS_PATH="${SPEC_DIR}/tasks.md"
else
    # Old format: feature-name.md -> check for feature-name/tasks.md or feature-name-tasks.md
    FEATURE_NAME=$(basename "$INPUT" .md)
    SPEC_DIR=$(dirname "$INPUT")
    FEATURE_DIR="${SPEC_DIR}/${FEATURE_NAME}"
    
    # Prefer new format if directory exists
    if [ -d "$FEATURE_DIR" ] && [ -f "${FEATURE_DIR}/tasks.md" ]; then
        TASKS_PATH="${FEATURE_DIR}/tasks.md"
    elif [ -f "${SPEC_DIR}/${FEATURE_NAME}-tasks.md" ]; then
        TASKS_PATH="${SPEC_DIR}/${FEATURE_NAME}-tasks.md"
    else
        TASKS_PATH="${FEATURE_DIR}/tasks.md"  # Default to new format
    fi
fi

if [ -f "$TASKS_PATH" ]; then
    echo "$TASKS_PATH"
    exit 0
else
    echo "ERROR: Tasks file not found: $TASKS_PATH"
    echo "Create with: /plan-tasks $INPUT"
    exit 1
fi
