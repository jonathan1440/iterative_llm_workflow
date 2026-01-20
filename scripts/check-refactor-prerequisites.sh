#!/bin/bash
# check-refactor-prerequisites.sh
# Check prerequisites before refactoring

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=check-prerequisites.sh
source "${SCRIPT_DIR}/check-prerequisites.sh"

REFACTOR_DESC="$1"
TARGET="$2"

check_refactor_prereqs "$REFACTOR_DESC" "$TARGET"
exit $?
