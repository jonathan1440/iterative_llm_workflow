#!/bin/bash

# common.sh
# Shared utilities for workflow scripts:
# - Color output
# - Spec/design/tasks path helpers (old + new format)

set -e

# Colors (only define if not already defined to avoid conflicts)
if [ -z "${GREEN+x}" ]; then
  GREEN='\033[0;32m'
fi
if [ -z "${BLUE+x}" ]; then
  BLUE='\033[0;34m'
fi
if [ -z "${YELLOW+x}" ]; then
  YELLOW='\033[1;33m'
fi
if [ -z "${RED+x}" ]; then
  RED='\033[0;31m'
fi
if [ -z "${GRAY+x}" ]; then
  GRAY='\033[0;90m'
fi
if [ -z "${NC+x}" ]; then
  NC='\033[0m'
fi

# Resolve design file path from spec path (old + new formats)
# Usage: get_design_path "docs/specs/feature-name.md" or "docs/specs/feature-name/spec.md"
get_design_path() {
  local SPEC_PATH="$1"

  if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
    # New format: feature-name/spec.md -> feature-name/design.md
    local SPEC_DIR
    SPEC_DIR=$(dirname "$SPEC_PATH")
    echo "${SPEC_DIR}/design.md"
  else
    # Old format or new format check
    local SPEC_DIR
    SPEC_DIR=$(dirname "$SPEC_PATH")
    local SPEC_FILENAME
    SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
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

# Resolve tasks file path from spec path (old + new formats)
get_tasks_path() {
  local SPEC_PATH="$1"

  if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
    local SPEC_DIR
    SPEC_DIR=$(dirname "$SPEC_PATH")
    echo "${SPEC_DIR}/tasks.md"
  else
    local SPEC_DIR
    SPEC_DIR=$(dirname "$SPEC_PATH")
    local SPEC_FILENAME
    SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
    local FEATURE_DIR="${SPEC_DIR}/${SPEC_FILENAME}"

    if [ -d "$FEATURE_DIR" ]; then
      echo "${FEATURE_DIR}/tasks.md"
    else
      echo "${SPEC_DIR}/${SPEC_FILENAME}-tasks.md"
    fi
  fi
}

# Resolve research file path from spec path (old + new formats)
get_research_path() {
  local SPEC_PATH="$1"

  if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
    local SPEC_DIR
    SPEC_DIR=$(dirname "$SPEC_PATH")
    echo "${SPEC_DIR}/research.md"
  else
    local SPEC_DIR
    SPEC_DIR=$(dirname "$SPEC_PATH")
    local SPEC_FILENAME
    SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
    local FEATURE_DIR="${SPEC_DIR}/${SPEC_FILENAME}"

    if [ -d "$FEATURE_DIR" ]; then
      echo "${FEATURE_DIR}/research.md"
    else
      echo "${SPEC_DIR}/${SPEC_FILENAME}-research.md"
    fi
  fi
}

