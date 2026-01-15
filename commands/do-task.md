---
description: Implement a single task with focused context - only one task visible to AI at a time for maximum focus and quality.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command implements a **single task** from the task breakdown, presenting only that task to the AI for focused execution. After completion, it automatically moves to the next task. This approach ensures:

- **Narrow focus**: AI only sees one task, preventing distraction and scope creep
- **Better task definition**: Forces thorough, self-contained task descriptions
- **Focused execution**: One task at a time, complete before moving on
- **Maintains story context**: Still understands which story this task belongs to

**Key difference from `/implement-story`**: Only loads ONE task into context, not all tasks for the story.

### Step 0: Prerequisites

Find tasks file and determine which task to work on:

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
```

If user provided a task ID (e.g., "T017"), use that. Otherwise, find the next incomplete task:

```bash
# If user provided task ID
if echo "$ARGUMENTS" | grep -qE "^T[0-9]+"; then
    TASK_ID=$(echo "$ARGUMENTS" | grep -oE "T[0-9]+" | head -1)
else
    # Extract story name if provided (e.g., "User Story 1" or "US1")
    STORY_NAME=$(echo "$ARGUMENTS" | grep -oE "(User Story [0-9]+|US[0-9]+)" | head -1 || echo "")
    
    # Find next incomplete task
    NEXT_TASK_INFO=$(bash .cursor/scripts/get-next-task.sh "$TASKS_FILE" "$STORY_NAME")
    TASK_ID=$(echo "$NEXT_TASK_INFO" | grep "^NEXT_TASK_ID=" | cut -d= -f2)
    
    if [ -z "$TASK_ID" ]; then
        echo "No incomplete tasks found"
        exit 0
    fi
fi
```

### Step 1: Extract Single Task Details

Get detailed information for ONLY this task:

```bash
TASK_INFO=$(bash .cursor/scripts/get-single-task.sh "$TASKS_FILE" "$TASK_ID")
```

This outputs:
- Task ID and description
- Story number (if user story task)
- Phase name
- Dependencies
- Story goal (for context)
- Acceptance criteria (for reference, not implementation)

**Display task overview:**

```markdown
🔨 Current Task: T017 [P] [US1] Create User model in src/models/user.js

**Task Description**: Create User model with fields and methods

**Phase**: User Story 1 (P1 - MVP) - User Registration and Login
**Story Goal**: Users can create accounts and log in to access the system

**Details from design**:
- Fields: id, email, password_hash, email_verified, status, failed_login_count, locked_until
- Methods: create(), findByEmail(), updateFailedLoginCount(), lockAccount()
- File: src/models/user.js

**Dependencies**: T008-T016 (Foundation tasks must be complete)

**Can run in parallel with**: Other [P] tasks in this phase (different files)

**Acceptance Criteria** (for reference - this task contributes to):
- [ ] User can register with email address and password
- [ ] Email format is validated before account creation
- [ ] User receives session token after registration

Ready to implement? [yes]
```

### Step 2: Open Composer Mode

**CRITICAL**: This command works best with Composer Mode.

Instruct user:

```
Press Cmd+I (Mac) or Ctrl+I (Windows/Linux) to open Composer Mode

Composer Mode is essential for implementation because:
- Multi-file context (see models, services, tests together)
- Better at handling file dependencies
- Can create/edit multiple related files
- Understands larger code context
```

### Step 3: Load Focused Context (ONE TASK ONLY)

**CRITICAL DIFFERENCE**: Only load this ONE task, not all tasks.

Once in Composer Mode, load these files:

```markdown
Load into Composer context:

**CURRENT TASK (ONLY THIS ONE)**:
- Task: T017 [US1] Create User model in src/models/user.js
  - Full description: [extract from task line]
  - File path: src/models/user.js
  - Dependencies: T008-T016 (must be complete)
  - Story context: User Story 1 - User Registration and Login
  - Story goal: Users can create accounts and log in to access the system

**REFERENCE DOCUMENTS** (for context, not for other tasks):
- Design: docs/specs/[feature-name]/design.md
  - Focus on: User model schema and methods (ignore other models)
- Spec: docs/specs/[feature-name]/spec.md
  - Focus on: User Story 1 acceptance criteria (ignore other stories)
- Standards: .cursor/agents.md
- Domain-specific patterns (if relevant to THIS task):
  - .cursor/agent-docs/database.md (for model tasks)
  - .cursor/agent-docs/api.md (for API tasks)
  - .cursor/agent-docs/testing.md (for test tasks)
  - .cursor/agent-docs/architecture.md (for architectural decisions)

**EXISTING CODE** (if any files exist):
- src/ (only files relevant to this task)

**DO NOT LOAD**:
- Other tasks from the story (T018, T019, etc.)
- Future tasks (can't see what's next)
- Tasks from other stories
- Full tasks.md file (only this task's details)
```

**Why this matters:**
- AI can't see T021 when working on T017 (prevents jumping ahead)
- AI can't get distracted by other tasks
- Forces focus on completing THIS task fully
- Reduces context bloat (one task vs 13+ tasks)

### Step 4: Implement the Task

Using Composer Mode, implement ONLY this task:

```markdown
Based on the design document, implement T017: Create User model in src/models/user.js

**Requirements**:
1. Create src/models/user.js
2. Define User class with all fields from design:
   - id, email, password_hash, email_verified, status, failed_login_count, locked_until
3. Implement all methods specified in design:
   - create(), findByEmail(), updateFailedLoginCount(), lockAccount()
4. Error handling per agents.md standard
5. Input validation where appropriate
6. JSDoc documentation for all public methods

**Reference design for**:
- Exact field types and constraints
- Method signatures
- Error handling patterns

**Follow agents.md standards for**:
- Code formatting
- Error handling (never expose internal details)
- Documentation requirements

**Focus**: Complete THIS task only. Don't implement related tasks (T018, T019, etc.) even if they're similar.
```

**AI should:**
- Generate complete, working code for THIS task only
- Follow design specifications exactly
- Apply standards from agents.md
- Add proper error handling
- Include documentation
- Create file with proper imports/exports
- **NOT** implement other tasks, even if they seem related

### Step 5: Verify Task Completion

After implementation, verify the task is complete:

```markdown
## Task Completion Verification

**Checklist**:
- [ ] File created: src/models/user.js
- [ ] All fields defined (id, email, password_hash, etc.)
- [ ] All methods implemented (create, findByEmail, etc.)
- [ ] Error handling follows agents.md standard
- [ ] JSDoc comments added
- [ ] Code follows formatting standards
- [ ] Imports/exports correct
- [ ] No syntax errors (run linter if available)

**Manual test** (if applicable):
- Can import the model?
- Do methods have correct signatures?
- Does error handling work?

Is this task complete? [yes/no]
```

If not complete, fix issues before proceeding.

### Step 6: Mark Task Complete

After verification:

```bash
bash .cursor/scripts/mark-task-complete.sh "$TASKS_FILE" "$TASK_ID"
```

This updates the task from `- [ ]` to `- [X]` in the tasks file.

Display progress:

```markdown
✅ T017 complete

Progress: 1/13 tasks in User Story 1 (8%)
```

### Step 7: Check for Verification Checkpoints

After completing key milestones, run automated verification:

**Milestone 1: Models Complete** (after T017, T018)
```markdown
🔍 Verification Checkpoint: Models

Running checks:
1. Files exist and syntax valid
2. All required methods present
3. Error classes imported correctly
4. JSDoc complete

[If any check fails, fix before proceeding]
```

**Milestone 2: Services Complete** (after T019, T020)
```markdown
🔍 Verification Checkpoint: Services

Running checks:
1. Services import models correctly
2. Error handling follows standard
3. Business logic matches design
4. Dependencies satisfied
```

**Milestone 3: API Complete** (after T021-T024)
```markdown
🔍 Verification Checkpoint: API

Running checks:
1. All endpoints exist
2. Middleware integrated
3. Request validation present
4. Error responses formatted correctly
```

**Milestone 4: Tests Complete** (after T025-T027)
```markdown
🔍 Verification Checkpoint: Tests

Running automated tests:
```bash
npm test
```

Expected:
- All tests pass
- Coverage > 80% for new code
- No linting errors
```

### Step 8: Move to Next Task

After task completion, automatically find next task:

```bash
# Extract story number from completed task
STORY_NUM=$(echo "$TASK_INFO" | grep "^STORY_NUM=" | cut -d= -f2)

# Find next incomplete task
NEXT_TASK_INFO=$(bash .cursor/scripts/get-next-task.sh "$TASKS_FILE" "User Story $STORY_NUM")
NEXT_TASK_ID=$(echo "$NEXT_TASK_INFO" | grep "^NEXT_TASK_ID=" | cut -d= -f2)
NO_MORE=$(echo "$NEXT_TASK_INFO" | grep "^NO_MORE_TASKS=" | cut -d= -f2)
```

**If more tasks exist:**

```markdown
✅ Task $TASK_ID complete!

📋 Next Task: $NEXT_TASK_ID

Would you like to continue with the next task? [yes/no]

To continue: /do-task $NEXT_TASK_ID
Or: /do-task (will automatically find next task)
```

**If story complete:**

```markdown
✅ Task $TASK_ID complete!

🎉 All tasks for User Story $STORY_NUM are complete!

**Next Steps**:
1. Run story verification: bash .cursor/scripts/verify-story.sh "$TASKS_FILE" "User Story $STORY_NUM"
2. Check acceptance criteria
3. Start next story: /do-task "User Story $((STORY_NUM + 1))"
```

### Step 9: Optional Learning Capture

After completing significant tasks, check if new patterns emerged:

```markdown
## Learning Capture

Did we discover any new principles or common mistakes during this task?

**Questions to consider**:
1. Did we solve a problem in a reusable way?
2. Did we catch ourselves making a mistake?
3. Did we find a better way to do something?
4. Did design need adjustment?

Would you like to update agents.md? [yes/no/specific]
```

If yes, update agents.md with approved additions.

## Guidelines

### Single Task Focus

**CRITICAL**: This command is designed for focused, one-task-at-a-time execution.

**DO:**
- Load only the current task into context
- Complete the task fully before moving on
- Reference design/spec for this task only
- Focus on the specific file(s) this task creates/modifies

**DON'T:**
- Load other tasks (even from same story)
- Implement multiple tasks at once
- Jump ahead to "related" tasks
- Show AI what's coming next

### Task Definition Quality

Because AI only sees one task, each task must be:
- **Self-contained**: All context needed in task description
- **Specific**: Exact file paths, method names, requirements
- **Complete**: Can't rely on "you'll figure it out from other tasks"
- **Clear**: Unambiguous what needs to be done

**Good task:**
```
- [ ] T017 [US1] Create User model in src/models/user.js
  - Fields: id (uuid), email (string, unique), password_hash (string), email_verified (boolean), status (enum: active/inactive), failed_login_count (integer), locked_until (timestamp)
  - Methods: create(userData), findByEmail(email), updateFailedLoginCount(userId), lockAccount(userId, duration)
  - Use ValidationError from src/errors/validation-error.js
  - Add JSDoc for all methods
```

**Poor task:**
```
- [ ] T017 [US1] Create User model
```
(Too vague - what fields? what methods? where?)

### When to Use `/do-task` vs `/implement-story`

**Use `/do-task` when:**
- Tasks are well-defined and self-contained
- You want maximum focus (one task at a time)
- Tasks are straightforward implementation
- You prefer incremental progress with clear checkpoints

**Use `/implement-story` when:**
- Tasks need cross-referencing with each other
- You want to see full story context
- Tasks are complex and benefit from seeing related work
- You prefer guided workflow with story-level verification

**Both approaches:**
- Work with the same tasks.md file
- Mark tasks complete the same way
- Use same verification checkpoints
- Maintain story-based organization

### Handling Dependencies

If a task has dependencies that aren't complete:

```markdown
⚠️  Task T017 depends on T008-T016 (Foundation tasks)

**Check dependencies:**
```bash
# Check if dependencies are complete
for dep in T008 T009 T010 T011 T012 T013 T014 T015 T016; do
    if grep -q "^- \[X\] .*$dep" "$TASKS_FILE"; then
        echo "✓ $dep complete"
    else
        echo "✗ $dep incomplete"
    fi
done
```

**If dependencies incomplete:**
- Complete dependencies first: /do-task T008
- Or verify dependencies are actually needed (may be outdated)

**If dependencies complete:**
- Proceed with task implementation
```

### Parallel Tasks

Tasks marked `[P]` can be worked on simultaneously, but `/do-task` still processes them one at a time for focus.

**For parallel tasks:**
- Complete T017 first
- Then complete T018 (even though they're parallel)
- AI still focuses on one at a time

**For multi-developer teams:**
- Different developers can run `/do-task` on different `[P]` tasks
- Each sees only their task
- Merge after both complete

### Task Completion Criteria

A task is complete when:
1. **Code implemented**: File created/modified as specified
2. **Requirements met**: All fields, methods, functionality from task description
3. **Standards followed**: agents.md standards applied
4. **No syntax errors**: Code compiles/runs
5. **Documentation**: Comments/JSDoc added if required

**Not required for task completion:**
- Tests (unless task is specifically a test task)
- Integration with other components (unless specified)
- Story-level verification (happens after all tasks)

### Error Handling

**If task cannot be completed:**

1. **Missing dependency**: Complete dependency first
2. **Design ambiguity**: Update design doc, then implement
3. **Technical issue**: Document in task, mark as blocked, move to next task
4. **Knowledge gap**: Research, prototype, or ask for guidance

**Never:**
- Skip tasks without documenting why
- Mark incomplete tasks as complete
- Implement differently than design without updating design

## Context

Tasks file: Automatically detected or specified in $ARGUMENTS
Task ID: Specified in $ARGUMENTS or automatically found (next incomplete task)

**Important**: This command focuses on ONE task at a time. Complete the task fully before moving to the next task.
