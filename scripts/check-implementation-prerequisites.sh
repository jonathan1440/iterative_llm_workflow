#!/bin/bash
# check-implementation-prerequisites.sh
# Verifies prerequisites before implementing a user story

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=check-prerequisites.sh
source "${SCRIPT_DIR}/check-prerequisites.sh"

STORY_NAME="$1"

check_implementation_prereqs "$STORY_NAME"
exit $?
