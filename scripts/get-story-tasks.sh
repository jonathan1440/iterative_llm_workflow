#!/bin/bash

# get-story-tasks.sh
# Thin wrapper around shared task-utils

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"
# shellcheck source=task-utils.sh
source "${SCRIPT_DIR}/task-utils.sh"

get_story_tasks "$@"
