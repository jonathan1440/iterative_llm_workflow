#!/bin/bash
# check-consistency-prerequisites.sh
# Check prerequisites for consistency analysis

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=check-prerequisites.sh
source "${SCRIPT_DIR}/check-prerequisites.sh"

SPEC_PATH="$1"

check_consistency_prereqs "$SPEC_PATH"
exit $?
