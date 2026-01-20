#!/bin/bash

# task-utils.sh
# Shared helpers for working with tasks.md:
# - get_single_task: detailed info for one task
# - get_next_task: next incomplete task (optionally within a story)
# - get_story_tasks: all tasks and context for a story
#
# Expectation: caller has already sourced common.sh for colors.

set -e

get_single_task() {
  local TASKS_FILE="$1"
  local TASK_ID="$2"

  if [ -z "$TASKS_FILE" ] || [ -z "$TASK_ID" ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: get_single_task <tasks-file> <task-id>"
    return 1
  fi

  if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    return 1
  fi

  # Normalize task ID (add T prefix if missing)
  if ! echo "$TASK_ID" | grep -q "^T"; then
    TASK_ID="T$TASK_ID"
  fi

  # Find the task line (try both formats: [T017] and T017)
  local TASK_LINE
  TASK_LINE=$(grep "^- \[.\] \[$TASK_ID\]" "$TASKS_FILE" || grep "^- \[.\] $TASK_ID " "$TASKS_FILE" || true)

  if [ -z "$TASK_LINE" ]; then
    echo -e "${RED}Error: Task $TASK_ID not found in tasks file${NC}"
    return 1
  fi

  # Check if task is already complete
  if echo "$TASK_LINE" | grep -q "^- \[X\]"; then
    echo -e "${YELLOW}Task $TASK_ID is already complete${NC}"
    echo "TASK_COMPLETE=true"
    return 0
  fi

  # Extract task details
  local TASK_DESC
  TASK_DESC=$(echo "$TASK_LINE" | sed 's/^- \[ \] //' | sed 's/\[T[0-9]*\]//' | sed 's/\[P\]//' | sed 's/\[US[0-9]*\]//' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

  # Extract story number if present
  local STORY_NUM
  STORY_NUM=$(echo "$TASK_LINE" | grep -oE "\[US[0-9]+\]" | grep -oE "[0-9]+" | head -1)

  # Check if parallel
  local IS_PARALLEL
  IS_PARALLEL=$(echo "$TASK_LINE" | grep -q "\[P\]" && echo "true" || echo "false")

  # Find the phase this task belongs to
  local TASK_LINE_NUM
  TASK_LINE_NUM=$(grep -n "^- \[.\] \[$TASK_ID\]" "$TASKS_FILE" | cut -d: -f1 || grep -n "^- \[.\] $TASK_ID " "$TASKS_FILE" | cut -d: -f1)

  local PHASE_NAME PHASE_HEADER
  if [ -z "$TASK_LINE_NUM" ]; then
    PHASE_NAME="Unknown Phase"
  else
    PHASE_HEADER=$(head -n "$TASK_LINE_NUM" "$TASKS_FILE" | grep "^## Phase" | tail -1)
    PHASE_NAME=$(echo "$PHASE_HEADER" | sed 's/^## Phase [0-9]*: //' || echo "Unknown Phase")
  fi

  # Extract story goal if this is a user story task
  local STORY_GOAL
  STORY_GOAL=""
  if [ -n "$STORY_NUM" ]; then
    STORY_GOAL=$(grep -A 5 "## Phase.*User Story $STORY_NUM" "$TASKS_FILE" | grep "^\*\*Story Goal\*\*:" | sed 's/^\*\*Story Goal\*\*: //' | head -1)
  fi

  # Get phase bounds
  local PHASE_START NEXT_PHASE PHASE_END
  PHASE_START=$(grep -n "$PHASE_HEADER" "$TASKS_FILE" | cut -d: -f1 | head -1)
  NEXT_PHASE=$(tail -n +$((PHASE_START + 1)) "$TASKS_FILE" | grep -n "^## Phase" | head -1 | cut -d: -f1)
  if [ -n "$NEXT_PHASE" ]; then
    PHASE_END=$((PHASE_START + NEXT_PHASE - 1))
  else
    PHASE_END=$(wc -l < "$TASKS_FILE")
  fi

  # Extract acceptance criteria for this story (if user story)
  local ACCEPTANCE_CRITERIA
  ACCEPTANCE_CRITERIA=""
  if [ -n "$STORY_NUM" ]; then
    ACCEPTANCE_CRITERIA=$(sed -n "${PHASE_START},${PHASE_END}p" "$TASKS_FILE" | sed -n '/^\*\*Acceptance Criteria\*\*/,/^\*\*/p' | grep "^- \[" | head -10)
  fi

  # Dependencies (other task IDs mentioned)
  local DEPENDENCIES
  DEPENDENCIES=$(echo "$TASK_LINE" | grep -oE "T[0-9]+" | grep -v "$TASK_ID" || echo "")

  # Structured output for callers
  echo "TASK_ID=$TASK_ID"
  echo "TASK_DESC=$TASK_DESC"
  echo "TASK_LINE=$TASK_LINE"
  echo "STORY_NUM=$STORY_NUM"
  echo "PHASE_NAME=$PHASE_NAME"
  echo "IS_PARALLEL=$IS_PARALLEL"
  echo "STORY_GOAL=$STORY_GOAL"
  echo "DEPENDENCIES=$DEPENDENCIES"
  echo "TASK_COMPLETE=false"

  # Human-friendly display
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}📋 Task Details: $TASK_ID${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo -e "${BLUE}Task:${NC} $TASK_DESC"
  echo ""
  if [ -n "$PHASE_NAME" ]; then
    echo -e "${BLUE}Phase:${NC} $PHASE_NAME"
  fi
  if [ -n "$STORY_NUM" ]; then
    echo -e "${BLUE}User Story:${NC} $STORY_NUM"
    if [ -n "$STORY_GOAL" ]; then
      echo -e "${BLUE}Story Goal:${NC} $STORY_GOAL"
    fi
  fi
  if [ "$IS_PARALLEL" = "true" ]; then
    echo -e "${YELLOW}Parallel:${NC} Can be worked on simultaneously with other [P] tasks"
  fi
  if [ -n "$DEPENDENCIES" ]; then
    echo -e "${YELLOW}Dependencies:${NC} $DEPENDENCIES (must be complete first)"
  fi
  echo ""
}

get_next_task() {
  local TASKS_FILE="$1"
  local STORY_NAME="${2:-}"

  if [ -z "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Missing tasks file${NC}"
    echo "Usage: get_next_task <tasks-file> [\"User Story 1\"]"
    return 1
  fi

  if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    return 1
  fi

  local STORY_NUM=""
  if [ -n "$STORY_NAME" ]; then
    STORY_NUM=$(echo "$STORY_NAME" | grep -oE "[0-9]+" | head -1)
  fi

  local NEXT_TASK
  if [ -n "$STORY_NUM" ]; then
    NEXT_TASK=$(grep "^- \[ \] .*\[US$STORY_NUM\]" "$TASKS_FILE" | head -1)
  else
    NEXT_TASK=$(grep "^- \[ \] " "$TASKS_FILE" | head -1)
  fi

  if [ -z "$NEXT_TASK" ]; then
    echo "NEXT_TASK_ID="
    echo "NO_MORE_TASKS=true"
    if [ -n "$STORY_NUM" ]; then
      echo -e "${GREEN}✅ All tasks complete for User Story $STORY_NUM${NC}"
    else
      echo -e "${GREEN}✅ All tasks complete!${NC}"
    fi
    return 0
  fi

  local NEXT_TASK_ID
  NEXT_TASK_ID=$(echo "$NEXT_TASK" | grep -oE "T[0-9]+" | head -1)

  if [ -z "$NEXT_TASK_ID" ]; then
    echo -e "${RED}Error: Could not extract task ID from: $NEXT_TASK${NC}"
    return 1
  fi

  echo "NEXT_TASK_ID=$NEXT_TASK_ID"
  echo "NO_MORE_TASKS=false"
  echo "NEXT_TASK_LINE=$NEXT_TASK"
}

get_story_tasks() {
  local TASKS_FILE="$1"
  local STORY_NAME="$2"

  if [ -z "$TASKS_FILE" ] || [ -z "$STORY_NAME" ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo "Usage: get_story_tasks <tasks-file> <\"User Story 1\">"
    return 1
  fi

  if [ ! -f "$TASKS_FILE" ]; then
    echo -e "${RED}Error: Tasks file not found: $TASKS_FILE${NC}"
    return 1
  fi

  local STORY_NUM
  STORY_NUM=$(echo "$STORY_NAME" | grep -oE "[0-9]+" | head -1)

  echo -e "${BLUE}📋 Story Details: $STORY_NAME${NC}"
  echo ""

  # Locate story section
  local STORY_LINE
  STORY_LINE=$(grep -n "## Phase.*$STORY_NAME" "$TASKS_FILE" | cut -d: -f1)
  if [ -z "$STORY_LINE" ]; then
    echo -e "${RED}Error: Story not found in tasks file${NC}"
    return 1
  fi

  local NEXT_PHASE_LINE END_LINE
  NEXT_PHASE_LINE=$(tail -n +$((STORY_LINE + 1)) "$TASKS_FILE" | grep -n "^## Phase" | head -1 | cut -d: -f1)
  if [ -n "$NEXT_PHASE_LINE" ]; then
    END_LINE=$((STORY_LINE + NEXT_PHASE_LINE))
  else
    END_LINE=$(wc -l < "$TASKS_FILE")
  fi

  local STORY_SECTION
  STORY_SECTION=$(sed -n "${STORY_LINE},${END_LINE}p" "$TASKS_FILE")

  # Story goal
  local STORY_GOAL
  STORY_GOAL=$(echo "$STORY_SECTION" | grep "^\*\*Story Goal\*\*:" | sed 's/^\*\*Story Goal\*\*: //')
  if [ -n "$STORY_GOAL" ]; then
    echo -e "${GREEN}Goal:${NC} $STORY_GOAL"
    echo ""
  fi

  # Acceptance criteria
  echo -e "${BLUE}Acceptance Criteria:${NC}"
  local ACC_CRITERIA
  ACC_CRITERIA=$(echo "$STORY_SECTION" | sed -n '/^\*\*Acceptance Criteria\*\*/,/^\*\*/p' | grep "^- \[")
  if [ -n "$ACC_CRITERIA" ]; then
    echo "$ACC_CRITERIA" | while read -r line; do
      if echo "$line" | grep -q "- \[X\]"; then
        echo -e "${GREEN}$line${NC}"
      else
        echo -e "${YELLOW}$line${NC}"
      fi
    done
  else
    echo -e "${GRAY}  (None specified)${NC}"
  fi
  echo ""

  # Independent test scenario
  echo -e "${BLUE}Independent Test Scenario:${NC}"
  local TEST_SCENARIO
  TEST_SCENARIO=$(echo "$STORY_SECTION" | sed -n '/^\*\*Independent Test/,/^```$/p' | grep -v "^\*\*Independent Test" | grep -v "^```")
  if [ -n "$TEST_SCENARIO" ]; then
    echo "$TEST_SCENARIO" | head -5
    local LINE_COUNT
    LINE_COUNT=$(echo "$TEST_SCENARIO" | wc -l)
    if [ "$LINE_COUNT" -gt 5 ]; then
      echo -e "${GRAY}  ... ($LINE_COUNT total steps)${NC}"
    fi
  else
    echo -e "${GRAY}  (None specified)${NC}"
  fi
  echo ""

  # Tasks
  echo -e "${BLUE}Tasks:${NC}"
  echo ""

  local TASKS
  if [ -n "$STORY_NUM" ]; then
    TASKS=$(echo "$STORY_SECTION" | grep "^- \[.\] .*\[US$STORY_NUM\]")
  else
    TASKS=$(echo "$STORY_SECTION" | grep "^- \[.\] T[0-9]")
  fi

  if [ -z "$TASKS" ]; then
    echo -e "${YELLOW}No tasks found with [US$STORY_NUM] marker${NC}"
    echo ""
    echo -e "${YELLOW}Showing all tasks in this phase:${NC}"
    TASKS=$(echo "$STORY_SECTION" | grep "^- \[.\] T[0-9]")
  fi

  local INCOMPLETE COMPLETE
  INCOMPLETE=$(echo "$TASKS" | grep "^- \[ \]" || true)
  COMPLETE=$(echo "$TASKS" | grep "^- \[X\]" || true)

  local INCOMPLETE_COUNT COMPLETE_COUNT TOTAL_COUNT
  INCOMPLETE_COUNT=$(echo "$INCOMPLETE" | grep -c "^- \[ \]" || echo "0")
  COMPLETE_COUNT=$(echo "$COMPLETE" | grep -c "^- \[X\]" || echo "0")
  TOTAL_COUNT=$((INCOMPLETE_COUNT + COMPLETE_COUNT))

  if [ "$TOTAL_COUNT" -eq 0 ]; then
    echo -e "${RED}No tasks found for this story${NC}"
    return 1
  fi

  if [ "$INCOMPLETE_COUNT" > 0 ]; then
    echo -e "${YELLOW}Incomplete ($INCOMPLETE_COUNT):${NC}"
    echo "$INCOMPLETE" | while read -r line; do
      if echo "$line" | grep -q "\[P\]"; then
        echo -e "  ${YELLOW}$line${NC} ${BLUE}(parallel)${NC}"
      else
        echo -e "  ${YELLOW}$line${NC}"
      fi
    done
    echo ""
  fi

  if [ "$COMPLETE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}Complete ($COMPLETE_COUNT):${NC}"
    echo "$COMPLETE" | while read -r line; do
      echo -e "  ${GRAY}$line${NC}"
    done
    echo ""
  fi

  if [ "$TOTAL_COUNT" -gt 0 ]; then
    local PERCENT
    PERCENT=$((COMPLETE_COUNT * 100 / TOTAL_COUNT))
    echo -e "${BLUE}Progress: $COMPLETE_COUNT/$TOTAL_COUNT tasks ($PERCENT%)${NC}"
    echo ""
  fi

  if [ "$INCOMPLETE_COUNT" -gt 0 ]; then
    local NEXT_TASK NEXT_TASK_ID OTHER_PARALLEL
    NEXT_TASK=$(echo "$INCOMPLETE" | head -1)
    NEXT_TASK_ID=$(echo "$NEXT_TASK" | grep -oE "T[0-9]+" | head -1)
    echo -e "${GREEN}Next Task:${NC}"
    echo -e "  $NEXT_TASK"
    echo ""

    if echo "$NEXT_TASK" | grep -q "\[P\]"; then
      OTHER_PARALLEL=$(echo "$INCOMPLETE" | grep "\[P\]" | grep -v "$NEXT_TASK_ID")
      if [ -n "$OTHER_PARALLEL" ]; then
        echo -e "${BLUE}Can work in parallel with:${NC}"
        echo "$OTHER_PARALLEL" | head -3 | while read -r line; do
          echo -e "  ${BLUE}$line${NC}"
        done
        echo ""
      fi
    fi
  fi

  echo -e "${BLUE}Dependencies:${NC}"
  local DEPS
  DEPS=$(echo "$STORY_SECTION" | grep -i "^Dependencies:" || echo "")
  if [ -n "$DEPS" ]; then
    echo "$DEPS"
  else
    echo -e "${GRAY}  (See task descriptions for details)${NC}"
  fi
  echo ""

  local ESTIMATION
  ESTIMATION=$(echo "$STORY_SECTION" | grep "Estimated:" | head -1)
  if [ -n "$ESTIMATION" ]; then
    echo -e "${BLUE}$ESTIMATION${NC}"
    echo ""
  fi

  local PERCENT
  if [ "$TOTAL_COUNT" -gt 0 ]; then
    PERCENT=$((COMPLETE_COUNT * 100 / TOTAL_COUNT))
    echo "SUMMARY: $COMPLETE_COUNT/$TOTAL_COUNT tasks complete ($PERCENT%)"
  fi
}

