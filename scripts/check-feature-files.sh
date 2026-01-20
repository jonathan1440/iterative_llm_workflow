#!/bin/bash
# check-feature-files.sh
# Check that feature files exist before adding a story

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=check-prerequisites.sh
source "${SCRIPT_DIR}/check-prerequisites.sh"

SPEC_PATH="$1"
STORY_DESC="$2"

check_feature_files_prereqs "$SPEC_PATH" "$STORY_DESC"
exit $?
