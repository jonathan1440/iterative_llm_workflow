---
description: Implement a user story task-by-task with automated verification loops and continuous learning capture.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command implements a complete user story from the task breakdown. It works through tasks sequentially, runs automated verification after key milestones, captures learnings in agents.md, and verifies story completion with the independent test scenario.

### Step 0: Prerequisites

Verify that tasks file exists and story is ready:

```bash
bash .cursor/scripts/check-implementation-prerequisites.sh "$ARGUMENTS"
```

The script will:
- Verify tasks file exists
- Check that story exists in tasks file
- Verify previous stories are complete (if not first story)
- Extract story tasks and status
- Output story details

If prerequisites fail, instruct user to complete prior work.

### Step 1: Load Story Context

Extract all tasks for the specified story:

```bash
bash .cursor/scripts/get-story-tasks.sh "docs/specs/[feature-name]/tasks.md" "User Story 1"
```

This outputs:
- Story goal from tasks file
- Acceptance criteria
- Independent test scenario
- All tasks for this story (with status)
- Dependency information

**Display story overview to user:**

```markdown
📋 Implementing: User Story 1 - User Registration and Login

**Goal**: Users can create accounts and log in to access the system

**Acceptance Criteria**:
- [ ] User can register with email address and password
- [ ] Email format is validated before account creation
- [ ] User receives session token after registration
- [ ] User can log in with email/password
- [ ] After 5 failed attempts, account locks for 15 minutes

**Tasks**: 13 tasks (T017-T029)
- Data Models: 2 tasks
- Business Logic: 2 tasks
- API Layer: 4 tasks
- Testing: 3 tasks
- Verification: 2 tasks

**Independent Test**: Defined (will run at end)

**Estimated**: ~2-3 days

Ready to start? [yes]
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

### Step 3: Load Implementation Context

Once in Composer Mode, load these files:

```markdown
Load into Composer context:
- Tasks: docs/specs/[feature-name]/tasks.md
- Design: docs/specs/[feature-name]/design.md
- Spec: docs/specs/[feature-name]/spec.md
- Standards: .cursor/agents.md
- Domain-specific patterns (if exist):
  - .cursor/agent-docs/api.md (for API/backend tasks)
  - .cursor/agent-docs/database.md (for database/schema tasks)
  - .cursor/agent-docs/testing.md (for test-related tasks)
  - .cursor/agent-docs/architecture.md (for architectural decisions)
- Implementation example: .cursor/templates/implementation-example.md (for reference on completion quality)
- Existing code: src/ (if any files exist)
```

### Step 4: Work Through Tasks Sequentially

**For each task in the story:**

#### 4.1: Display Current Task

```markdown
🔨 Current Task: T017 [P] [US1] Create User model in src/models/user.js

**Description**: Create User model with fields and methods
**Details from design**:
- Fields: id, email, password_hash, email_verified, status, failed_login_count, locked_until
- Methods: create(), findByEmail(), updateFailedLoginCount(), lockAccount()

**Can run in parallel with**: T018 (Session model - different file)

**Prerequisites**: T008-T016 (Foundation tasks must be complete)

**Implementation approach**:
1. Create src/models/user.js
2. Define User class with all fields
3. Implement each method with error handling
4. Add JSDoc comments
5. Export the class

Start implementation? [yes]
```

#### 4.2: Implement Task

Using Composer Mode, implement the task:

```markdown
Based on the design document, create src/models/user.js with:

1. User model class following design schema
2. All methods specified in design
3. Error handling per agents.md standard
4. Input validation where appropriate
5. JSDoc documentation for all public methods

Reference design for:
- Exact field types and constraints
- Method signatures
- Error handling patterns

Follow agents.md standards for:
- Code formatting
- Error handling (never expose internal details)
- Documentation requirements
```

**AI should:**
- Generate complete, working code
- Follow design specifications exactly
- Apply standards from agents.md
- Add proper error handling
- Include documentation
- Create file with proper imports/exports

#### 4.3: Mark Task Complete

After implementation:

```bash
bash .cursor/scripts/mark-task-complete.sh "docs/specs/[feature-name]/tasks.md" "T017"
```

This updates the task from `- [ ]` to `- [X]` in the tasks file.

Display progress:

```markdown
✅ T017 complete

Progress: 1/13 tasks in User Story 1 (8%)
```

#### 4.4: Verification Checkpoints

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

Optional: Run services in isolation (create test file, manually invoke)
```

**Milestone 3: API Complete** (after T021-T024)
```markdown
🔍 Verification Checkpoint: API

Running checks:
1. All endpoints exist
2. Middleware integrated
3. Request validation present
4. Error responses formatted correctly

Test manually:
- Start server: npm start
- Test each endpoint with curl
- Verify error cases
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

[If tests fail, fix implementation or tests before proceeding]
```

### Step 5: Capture Learnings in agents.md

After each significant milestone, check if new patterns emerged:

```markdown
## Learning Capture

Did we discover any new principles or common mistakes during this implementation?

**Questions to consider**:
1. Did we solve a problem in a reusable way?
   Example: "Always validate email before hashing password"

2. Did we catch ourselves making a mistake?
   Example: "Don't store plain text passwords even temporarily"

3. Did we find a better way to do something?
   Example: "Use connection pooling to prevent exhaustion"

4. Did design need adjustment?
   Example: "Added user_id index to sessions table for performance"

Would you like to update agents.md with any of these learnings? [yes/no/specific]
```

**If yes, prompt user:**

```markdown
What should we add to agents.md?

**New Architecture Principle**:
- Principle: [Name]
- Rule: [When to apply]
- Rationale: [Why this matters]

**Common Mistake Found**:
- Mistake: [What we almost/did do wrong]
- Why wrong: [Impact]
- Correct pattern: [How to do it right]

**Design Adjustment**:
- Change: [What we modified]
- Reason: [Why it was necessary]
- Impact: [What this affects]
```

Update agents.md with approved additions.

### Step 6: Story Completion Verification

After all tasks complete, run the independent test scenario:

```bash
bash .cursor/scripts/verify-story.sh "docs/specs/[feature-name]/tasks.md" "User Story 1"
```

This script:
1. Extracts the independent test scenario from tasks file
2. Displays step-by-step test instructions
3. Prompts user to run each step
4. Records results

**Example output:**

```markdown
🧪 Story Verification: User Story 1

This independent test proves the story works without US2 or US3.

**Step 1**: Start server
Command: npm start
Expected: Server starts on port 3000

Did this work? [yes/no]

**Step 2**: Register new user
Command: curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123"}'
Expected: 201 Created with user object and session token

Did this work? [yes/no]

**Step 3**: Verify user in database
Command: psql -d auth_db -c "SELECT email, status FROM users WHERE email='test@example.com';"
Expected: test@example.com | active

Did this work? [yes/no]

[Continues for all steps...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Verification Results: 7/7 steps passed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ User Story 1 is COMPLETE and verified!
```

**If any step fails:**

```markdown
❌ Step 4 failed: Login endpoint returned 500 instead of 200

**Debug checklist**:
1. Check server logs for error
2. Verify database connection
3. Check if service is throwing unhandled error
4. Review error middleware

Fix the issue and re-run verification.
```

### Step 7: Update Acceptance Criteria

Mark all acceptance criteria as complete:

```markdown
## Acceptance Criteria Check

**Original criteria from spec**:
- [X] User can register with email address and password
- [X] Email format is validated before account creation
- [X] User receives session token after registration
- [X] User can log in with email/password
- [X] After 5 failed attempts, account locks for 15 minutes

All criteria met? [yes/no]

[If no, identify which criteria failed and address before marking story complete]
```

### Step 8: Final Story Report

Display completion summary:

```markdown
✅ User Story 1 Implementation Complete!

📊 Summary:
- Tasks: 13/13 complete (100%)
- Tests: 21 tests, all passing
- Coverage: 87%
- Acceptance Criteria: 5/5 met
- Independent Test: Passed

📝 Changes Made:
- Created: 6 new files
  - src/models/user.js
  - src/models/session.js
  - src/services/user-service.js
  - src/services/auth-service.js
  - src/routes/auth.js
  - src/middleware/auth.js
- Modified: 2 files
  - src/app.js (added auth routes)
  - tests/setup.js (added test database)
- Tests: 3 test files with 21 test cases

🎓 Learnings Captured:
- Added to agents.md: "Always hash passwords before storing"
- Added to agents.md: "Use parameterized queries to prevent SQL injection"

🎯 Next Steps:
1. Commit changes: git commit -m "Implement US1: User registration and login"
2. Deploy to staging (optional)
3. Gather feedback (optional)
4. Start next story: /implement-story "User Story 2"
   OR polish MVP: Tasks Phase 6 (if US1 is MVP)

💡 Story is independently testable - US2 and US3 are optional!
```

## Guidelines

### Implementation Reference

For a complete walkthrough of implementing a user story from start to finish, see:
`.cursor/templates/implementation-example.md`

This shows:
- Complete 13-task implementation of User Story 1
- Verification checkpoints at each milestone
- Real code examples for models, services, and API
- Learning capture process
- Independent test scenario execution
- Final story report with metrics

Use this as a reference for:
- Expected level of completeness
- How to structure code examples
- When to run verification checkpoints
- What makes a good final report

### Task Implementation Approach

**1. Follow Design Exactly**
- Don't deviate from design without updating design doc
- Use exact field names, types from schema
- Follow API contracts precisely
- Implement error handling as designed

**2. Apply agents.md Standards**
- Error handling: Never expose internal errors to users
- Testing: Follow testing standard (TDD or test-after)
- Security: Follow security standard (bcrypt, validation, etc.)
- Formatting: Follow code formatting standard

**3. Work Incrementally**
- Complete one task fully before moving to next
- Don't jump ahead to "interesting" tasks
- Respect task dependencies
- Mark tasks complete immediately after finishing

**4. Verify Often**
- Run code after each task to catch issues early
- Test manually before writing automated tests
- Don't accumulate untested code
- Fix issues immediately, don't defer

### Verification Loop Strategy

**When to Run Verification:**
- After models: Check syntax, imports, structure
- After services: Test business logic manually
- After API: Test endpoints with curl/Postman
- After tests: Run full test suite
- After story: Run independent test scenario

**What to Verify:**
1. **Syntax/Static**: Linting, type checking, imports
2. **Unit**: Business logic works in isolation
3. **Integration**: Components work together
4. **Story**: Full user flow works end-to-end

**Verification Levels:**

```
Story Verification (slowest, most comprehensive)
    ↑
Integration Tests (medium speed)
    ↑
Unit Tests (fast)
    ↑
Syntax/Linting (fastest)
```

Use faster verification during development, comprehensive at end.

### Learning Capture

**Good learnings to capture:**

✅ **Architecture Principles**:
- "API responses MUST use consistent format (success/error wrapper)"
- "Database migrations MUST be reversible"
- "Authentication MUST be in middleware, not endpoints"

✅ **Common Mistakes**:
- "Don't hash passwords in models - do it in services (testability)"
- "Don't return different errors for 'user not found' vs 'wrong password' (security)"
- "Don't validate in both middleware and service (DRY violation)"

✅ **Design Adjustments**:
- "Added index on users.email for login performance"
- "Changed session expiration from 1 hour to 24 hours (UX feedback)"
- "Added rate limiting to registration endpoint (prevent spam)"

**Poor learnings (too generic or obvious):**

❌ "Write good code" (not specific)
❌ "Test everything" (not actionable)
❌ "Use Express.js" (tool choice, not principle)

### Handling Blockers

**If task cannot be completed:**

1. **Identify blocker type**:
   - Missing dependency (another task incomplete)
   - Design ambiguity (spec unclear)
   - Technical issue (library bug, config problem)
   - Knowledge gap (don't know how to implement)

2. **Take appropriate action**:
   - Missing dependency: Complete dependency first
   - Design ambiguity: Update design doc, then implement
   - Technical issue: Research, ask for help, document workaround
   - Knowledge gap: Research, prototype, ask for guidance

3. **Document decision**:
   - Update tasks file with notes
   - Add to agents.md if pattern emerges
   - Update design if approach changes

**Never:**
- Skip tasks and come back later (breaks dependencies)
- Implement differently than design without updating design
- Leave broken code uncommitted
- Move to next story with current story incomplete

### Parallel Work (Multi-Developer Teams)

**If multiple developers:**

Tasks marked `[P]` can be worked on simultaneously:

```
Dev 1: T017 [P] [US1] Create User model
Dev 2: T018 [P] [US1] Create Session model
(These can run in parallel - different files, no dependencies)

After both complete:
Dev 1: T019 [US1] Create UserService (depends on T017)
Dev 2: Starts on next parallel task or helps with T019
```

**Coordination points:**
- Beginning of story: Review tasks together
- After models complete: Merge before starting services
- After services complete: Merge before starting API
- End of story: Verify together

**For solo developers:**
- Ignore [P] markers
- Work sequentially through tasks
- Take advantage of milestones for breaks

## Context

User story and tasks file path: $ARGUMENTS

**Important**: This command focuses on ONE user story at a time. Complete the story fully (all tasks, tests, verification) before moving to the next story.