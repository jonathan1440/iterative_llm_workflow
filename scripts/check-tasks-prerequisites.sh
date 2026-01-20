#!/bin/bash
# check-tasks-prerequisites.sh
# Verifies prerequisites before creating task breakdown

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=check-prerequisites.sh
source "${SCRIPT_DIR}/check-prerequisites.sh"

SPEC_PATH="$1"

check_tasks_prereqs "$SPEC_PATH"
exit $?
