#!/bin/bash
# spec-path-helper.sh
# Helper functions for handling spec file paths in both old and new formats
# Source this file: source .cursor/scripts/spec-path-helper.sh

# Get design file path from spec path
# Usage: get_design_path "docs/specs/feature-name.md" or "docs/specs/feature-name/spec.md"
get_design_path() {
    local SPEC_PATH="$1"
    
    if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
        # New format: feature-name/spec.md -> feature-name/design.md
        local SPEC_DIR=$(dirname "$SPEC_PATH")
        echo "${SPEC_DIR}/design.md"
    else
        # Old format or new format check
        local SPEC_DIR=$(dirname "$SPEC_PATH")
        local SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
        local FEATURE_DIR="${SPEC_DIR}/${SPEC_FILENAME}"
        
        # Prefer new format if directory exists
        if [ -d "$FEATURE_DIR" ]; then
            echo "${FEATURE_DIR}/design.md"
        else
            # Fallback to old format for backward compatibility
            echo "${SPEC_DIR}/${SPEC_FILENAME}-design.md"
        fi
    fi
}

# Get tasks file path from spec path
# Usage: get_tasks_path "docs/specs/feature-name.md" or "docs/specs/feature-name/spec.md"
get_tasks_path() {
    local SPEC_PATH="$1"
    
    if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
        # New format: feature-name/spec.md -> feature-name/tasks.md
        local SPEC_DIR=$(dirname "$SPEC_PATH")
        echo "${SPEC_DIR}/tasks.md"
    else
        # Old format or new format check
        local SPEC_DIR=$(dirname "$SPEC_PATH")
        local SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
        local FEATURE_DIR="${SPEC_DIR}/${SPEC_FILENAME}"
        
        # Prefer new format if directory exists
        if [ -d "$FEATURE_DIR" ]; then
            echo "${FEATURE_DIR}/tasks.md"
        else
            # Fallback to old format for backward compatibility
            echo "${SPEC_DIR}/${SPEC_FILENAME}-tasks.md"
        fi
    fi
}

# Get research file path from spec path
# Usage: get_research_path "docs/specs/feature-name.md" or "docs/specs/feature-name/spec.md"
get_research_path() {
    local SPEC_PATH="$1"
    
    if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
        # New format: feature-name/spec.md -> feature-name/research.md
        local SPEC_DIR=$(dirname "$SPEC_PATH")
        echo "${SPEC_DIR}/research.md"
    else
        # Old format or new format check
        local SPEC_DIR=$(dirname "$SPEC_PATH")
        local SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
        local FEATURE_DIR="${SPEC_DIR}/${SPEC_FILENAME}"
        
        # Prefer new format if directory exists
        if [ -d "$FEATURE_DIR" ]; then
            echo "${FEATURE_DIR}/research.md"
        else
            # Fallback to old format for backward compatibility
            echo "${SPEC_DIR}/${SPEC_FILENAME}-research.md"
        fi
    fi
}

# Ensure feature directory exists (for new format)
# Usage: ensure_feature_dir "docs/specs/feature-name.md"
ensure_feature_dir() {
    local SPEC_PATH="$1"
    
    if [[ "$SPEC_PATH" != *"/spec.md" ]]; then
        local SPEC_DIR=$(dirname "$SPEC_PATH")
        local SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
        local FEATURE_DIR="${SPEC_DIR}/${SPEC_FILENAME}"
        
        # Create directory if it doesn't exist (for new format)
        mkdir -p "$FEATURE_DIR"
    fi
}
