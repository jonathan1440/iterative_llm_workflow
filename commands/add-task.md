---
description: Add a single detailed task to an existing tasks.md file, maintaining format consistency and proper placement.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command adds a single task to an existing tasks.md file. The task is inserted in the appropriate location (within a story phase or after a specific task) and follows the detailed, self-contained format required for `/do-task` to work effectively.

**Usage Pattern:**
```bash
/add-task "Create User model in src/models/user.js" "User Story 1"
/add-task "Add rate limiting middleware" "User Story 1" T024
/add-task "Create User model in src/models/user.js"
```

### Step 0: Prerequisites

Find tasks file and extract task details:

```bash
# Find tasks file
TASKS_FILE=$(bash .cursor/scripts/find-tasks-file.sh 2>/dev/null | grep -v "^ERROR:" | head -1 || echo "")

if [ -z "$TASKS_FILE" ] || [ ! -f "$TASKS_FILE" ]; then
    # Look for tasks file in common locations
    for path in docs/specs/*/tasks.md docs/specs/*-tasks.md *-tasks.md; do
        if [ -f "$path" ]; then
            TASKS_FILE="$path"
            break
        fi
    done
fi

if [ -z "$TASKS_FILE" ] || [ ! -f "$TASKS_FILE" ]; then
    echo "Error: No tasks file found. Create one with /plan-tasks"
    exit 1
fi

# Extract task description and optional story/insertion point from arguments
# Format: "task description" ["User Story 1"] [T017]
TASK_DESC=$(echo "$ARGUMENTS" | cut -d'"' -f2)
STORY_NAME=$(echo "$ARGUMENTS" | grep -oE "(User Story [0-9]+|US[0-9]+)" | head -1 || echo "")
INSERT_AFTER=$(echo "$ARGUMENTS" | grep -oE "T[0-9]+" | head -1 || echo "")

**Task Placement Assumption**: Assuming task belongs to current feature (tasks file being edited) unless story name specified. If story name not provided, task will be added to the most appropriate phase based on task description.
```

### Step 1: Determine Task Details

Get next task ID and insertion point:

```bash
TASK_INFO=$(bash .cursor/scripts/add-single-task.sh "$TASKS_FILE" "$TASK_DESC" "$STORY_NAME" "$INSERT_AFTER")
NEXT_TASK_ID=$(echo "$TASK_INFO" | grep "^TASK_ID=" | cut -d= -f2)
```

**Display task information:**

```markdown
📝 Adding Task to: docs/specs/user-authentication-tasks.md

**Task ID**: T034 (next available)
**Description**: Create User model in src/models/user.js
**Story**: User Story 1 (if specified)
**Insert After**: T017 (if specified, otherwise at end of story/phase)

Ready to create detailed task? [yes]
```

### Step 2: Load Context

Load relevant files to understand where task fits:

```markdown
Load into context:
- Tasks file: docs/specs/[feature-name]/tasks.md
  - Focus on: The phase/story where this task belongs
  - Look at: Similar tasks for format reference
- Design: docs/specs/[feature-name]/design.md
  - Focus on: Relevant section for this task
- Spec: docs/specs/[feature-name]/spec.md (if needed for context)
- Standards: .cursor/agents.md
- Task format: .cursor/templates/task-format.md (canonical task format specification)
- Task template: .cursor/templates/tasks-template-example.md
  - Reference: Format for detailed, self-contained tasks
```

### Step 3: Create Detailed Task

**CRITICAL**: Task must be detailed and self-contained, following the format defined in `.cursor/templates/task-format.md`.

**Task Quality Bar** (task meets quality when):
- [ ] Follows task-format.md template exactly (all required sections present)
- [ ] Includes all required sections (File, Requirements, Implementation Details, Error Handling, Dependencies, Acceptance, Test Requirements)
- [ ] File path specified (exact path, not vague "create model")
- [ ] Dependencies valid (all referenced tasks exist)
- [ ] Test Requirements include positive and negative test cases
- [ ] Acceptance criteria testable (specific, measurable, not vague)

**Reference the template for**:
- Complete task format template
- Format rules (checkbox, Task ID, markers, etc.)
- Test Requirements format (with examples for application code, bash scripts, API endpoints)
- Verification task format
- Task self-containment requirements
- Examples (good and bad patterns)

Generate the task following this format:

```markdown
- [ ] T034 [P?] [US1?] Create User model in src/models/user.js

  **File**: src/models/user.js
  
  **Fields** (from design):
  - id: UUID (primary key, auto-generated)
  - email: string (unique, required, validated with regex)
  - password_hash: string (required, bcrypt hashed)
  - email_verified: boolean (default: false)
  - status: enum('active', 'inactive') (default: 'active')
  - failed_login_count: integer (default: 0)
  - locked_until: timestamp (nullable)
  
  **Methods** (from design):
  - create(userData): Create new user, hash password using bcrypt cost 10, return user object
  - findByEmail(email): Find user by email, return user object or null
  - updateFailedLoginCount(userId): Increment failed_login_count by 1
  - lockAccount(userId, durationMinutes): Set locked_until to now + durationMinutes
  
  **Error Handling**:
  - Use ValidationError from src/errors/validation-error.js for invalid input
  - Use DatabaseError from src/errors/database-error.js for DB failures
  - Never expose internal errors to callers (per agents.md)
  
  **Dependencies**: T008-T016 (Foundation tasks must be complete)
  
  **Acceptance**: User model can be imported, instantiated, and all methods work correctly
  
  **Test Requirements**:
  
  **Automated Tests**:
  ```bash
  npm run lint src/models/user.js
  npm test -- tests/unit/user.test.js
  ```
  Expected: No lint errors, all tests pass
  
  **Manual Tests**:
  - [ ] Import: `const User = require('./src/models/user')` succeeds
  - [ ] Call create: `User.create({email: "test@example.com", password: "Pass123"})` returns user object
  
  **Positive Test Cases**:
  - [ ] create with valid data returns user object
  - [ ] findByEmail finds existing user
  
  **Negative Test Cases**:
  - [ ] create with invalid email throws ValidationError
  - [ ] create with duplicate email throws DatabaseError (409)
```
```

**Task Format Requirements**: See `.cursor/templates/task-format.md` for complete format requirements including:
- Format rules (checkbox, Task ID, markers, etc.)
- Required sections (File, Requirements, Implementation Details, Error Handling, Dependencies, Acceptance, Test Requirements)
- Test Requirements format with examples for Bash Scripts, Application Code, and API Endpoints
- Task self-containment requirements
- Examples and common mistakes

### Step 4: Determine Placement

Based on task description and context, determine where to insert:

**If story specified:**
- Insert at end of that story's phase
- After last task in that story

**If INSERT_AFTER specified:**
- Insert immediately after that task
- Maintain same indentation level

**If neither specified:**
- Ask user where to place task
- Or append to end of file

**Display placement:**

```markdown
## Task Placement

**Location**: Phase 3: User Story 1 (P1 - MVP)
**Insert After**: T018 (Create Session model)
**Reason**: This is the next model task in User Story 1

**Context**:
- Previous task: T018 [P] [US1] Create Session model
- Next task: T019 [US1] Implement UserService (depends on T017)

**Placement looks correct?** [yes/edit]
```

### Step 5: Insert Task into File

After user approves task format and placement:

```bash
# Create backup
BACKUP_FILE="${TASKS_FILE}.backup-$(date +%Y%m%d-%H%M%S)"
cp "$TASKS_FILE" "$BACKUP_FILE"

# Insert task at determined line
# (This will be done by editing the file directly)
```

**Insert the task** at the determined location in the tasks.md file, maintaining:
- Proper indentation
- Consistent formatting with other tasks
- Correct phase/story section

### Step 6: Update Task Numbering (If Needed)

If task was inserted in the middle (not at end), check if renumbering is needed:

```markdown
## Task Numbering Check

**Current situation**:
- Last task before insertion: T017
- New task: T034 (inserted here)
- Next existing task: T018

**Options**:
1. Renumber: T017 → T018, T034 → T019, T018 → T020, etc.
2. Keep gaps: Accept non-sequential IDs (T017, T034, T018, T019...)

**Recommendation**: Renumber for consistency (sequential IDs are easier to track)

Renumber subsequent tasks? [yes/no]
```

**If yes, renumber:**

```bash
bash .cursor/scripts/renumber-tasks.sh "$TASKS_FILE" "$NEXT_TASK_ID" "1"
```

This will:
- Renumber the new task to the correct sequential ID
- Renumber all subsequent tasks
- Update dependency references

### Step 7: Validate Task Format

Run validation to ensure task follows format:

```bash
bash .cursor/scripts/validate-tasks.sh "$TASKS_FILE"
```

**Check specifically:**
- Task ID is sequential (or acceptable gap)
- Task has required format elements
- **Task includes "Test Requirements" section**
- **Test Requirements include positive and negative test cases**
- **Acceptance criteria are testable**
- Dependencies are valid (referenced tasks exist)
- File path is included
- Story label matches phase (if applicable)

### Step 8: Display Summary

```markdown
✅ Task added successfully!

**Task**: T034 [US1] Create User model in src/models/user.js
**Location**: Phase 3: User Story 1, after T018
**File**: docs/specs/user-authentication-tasks.md

**Task Details**:
- File: src/models/user.js
- Dependencies: T008-T016
- Story: User Story 1
- Format: Detailed, self-contained ✓

**Next Steps**:
1. Review task in tasks.md file
2. Implement task: /do-task T034
3. Or continue with story: /implement-story "User Story 1"

**Backup**: docs/specs/user-authentication-tasks.md.backup-20260113-143022
```

## Guidelines

### When to Use /add-task

**Good reasons:**
- Adding a missing task discovered during implementation
- Breaking down a large task into smaller ones
- Adding a task that was forgotten in initial planning
- Adding a verification task that was missed
- Adding a polish/optimization task

**Bad reasons:**
- Initial task creation (use `/plan-tasks`)
- Adding multiple related tasks (use `/add-story` or edit tasks.md directly)
- Major scope changes (use `/add-story`)

### Task Detail Requirements

Because tasks are used with `/do-task`, each task must be self-contained. See `.cursor/templates/task-format.md` for complete task self-containment requirements including DO/DON'T guidelines and examples.

### Placement Logic

**Priority order for placement:**

1. **If INSERT_AFTER specified**: Insert after that exact task
2. **If story specified**: Insert at end of that story's phase
3. **If task description matches existing phase**: Insert in that phase
4. **Otherwise**: Ask user or append to end

**Within a story phase:**
- Models → Services → API → Tests → Verification
- Maintain this order when possible

### Parallel Task Marking

See `.cursor/templates/task-format.md` for parallel task marking rules and examples.

### Dependencies

Always list explicit dependencies. See `.cursor/templates/task-format.md` for dependency guidelines and examples.

### Verification Tasks

If adding a verification task, follow the verification task format defined in `.cursor/templates/task-format.md`. The template includes:
- Required elements (Verification Type, Dependencies, Automated Checks, Manual Checks, Test Results, Failure Criteria)
- Example verification task with full format
- Verification task placement guidance

## Context

Tasks file: Automatically detected or specified
Task description: From $ARGUMENTS
Story/Phase: Optional, from $ARGUMENTS
Insert after: Optional task ID from $ARGUMENTS

**Important**: This command adds ONE task. For multiple tasks or new stories, use `/add-story` or edit tasks.md directly.
