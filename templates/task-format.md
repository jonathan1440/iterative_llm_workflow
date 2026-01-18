---
description: Canonical task format specification for all task creation commands. This is the single source of truth for task formatting rules, test requirements, and examples.
---

# Task Format Specification

This document defines the canonical format for all tasks. Commands that create tasks (`/plan-tasks`, `/add-task`, `/add-story`) MUST follow this format.

## Task Format Template

Every task MUST follow this pattern:

```
- [ ] [TaskID] [P?] [Story?] [RESEARCH?] Description with file path

  **File**: [exact file path]
  
  **Requirements** (from design):
  - [Detailed requirement 1]
  - [Detailed requirement 2]
  
  **Implementation Details**:
  - [Specific implementation detail 1]
  - [Specific implementation detail 2]
  
  **Error Handling**:
  - [Error handling requirements]
  
  **Dependencies**: [Task IDs that must be complete first]
  
  **Acceptance**: [How to verify this task is complete - must be testable]
  
  **Test Requirements** (REQUIRED):
  - [Specific test commands or manual steps]
  - [Positive test cases]
  - [Negative test cases]
  - [Edge cases]
  - [Integration checks]
```

## Format Rules

1. **Checkbox**: Always start with `- [ ]`
2. **Task ID**: Sequential number (T001, T002, T003...)
3. **[P] Marker**: ONLY if task is parallelizable
   - Different files than other running tasks
   - No dependencies on incomplete tasks
   - Example: `[P]`
4. **[Story] Label**: REQUIRED for user story phases
   - Format: [US1], [US2], [US3], etc.
   - Setup phase: NO story label
   - Foundation phase: NO story label
   - User Story phases: MUST have story label
   - Polish phase: NO story label
5. **[RESEARCH] Marker**: OPTIONAL, use only if task needs additional investigation
   - New technology not in design/research
   - Ambiguous requirements
   - No existing patterns found
   - Example: `[RESEARCH]`
6. **Description**: Clear action with exact file path
7. **Detailed Requirements**: Self-contained details extracted from design
8. **Dependencies**: Explicitly listed (not inferred)

## Optional [RESEARCH] Marker

Use only if task needs additional investigation:
- New technology not covered in design/research
- Ambiguous requirements needing clarification
- No existing patterns in agents.md or agent-docs/
- Similar implementations not found in codebase

If [RESEARCH] marker is used, add:

```
  **Research Needed**:
  - Check agents.md for: [specific pattern or convention]
  - Review codebase for: [similar implementation to reference]
  - Verify in agent-docs/: [specific domain pattern]
  - Clarify with design: [specific ambiguity]
```

## Test Requirements Format

**CRITICAL**: Every task MUST include a "Test Requirements" section that makes acceptance criteria testable and executable.

### Test Requirements Structure

The Test Requirements section must include:

1. **Automated Tests** (if applicable):
   - Specific commands to run
   - Expected output/results
   - Exit codes or success criteria

2. **Manual Tests** (if applicable):
   - Step-by-step verification steps
   - Expected outcomes for each step

3. **Positive Test Cases** (REQUIRED):
   - Happy path scenarios
   - Valid inputs and expected outputs

4. **Negative Test Cases** (REQUIRED):
   - Invalid inputs
   - Error conditions
   - Expected error messages/codes

5. **Edge Cases** (if applicable):
   - Boundary conditions
   - Special values
   - Empty/null inputs

6. **Integration Checks** (if applicable):
   - Works with dependencies
   - Doesn't break existing functionality

### For Application Code (models, services, APIs)

```markdown
**Test Requirements**:

**Automated Tests**:
```bash
# Unit tests
npm test -- tests/unit/user-service.test.js

# Coverage check
npm test -- --coverage --collectCoverageFrom='src/services/user-service.js' | grep -E "Statements|Branches" | awk '{if ($2 < 80) exit 1}'
```
Expected: All tests pass, coverage >= 80%

**Manual Tests**:
- [ ] Import: `const UserService = require('./src/services/user-service')` succeeds
- [ ] Call method: `UserService.createUser("test@example.com", "Pass123")` returns user object
- [ ] Verify password hashed: `user.password_hash !== "Pass123"`

**Positive Test Cases**:
- [ ] createUser with valid email/password returns user object
- [ ] createUser hashes password correctly (verify with bcrypt.compare)
- [ ] findByEmail finds existing user, returns null for non-existent

**Negative Test Cases**:
- [ ] createUser with invalid email throws ValidationError (400)
- [ ] createUser with weak password "123" throws ValidationError
- [ ] createUser with duplicate email throws DatabaseError (409)

**Edge Cases**:
- [ ] createUser with email exactly 254 chars (max length) works
- [ ] createUser with email 255 chars throws ValidationError
- [ ] findByEmail with empty string returns null

**Integration Checks**:
- [ ] createUser works with User model from T017
- [ ] Error handling uses ValidationError/DatabaseError from foundation tasks
```
```

### For Bash Scripts (when unit tests are overkill)

```markdown
**Script Type**: Bash utility (unit tests overkill)

**Test Requirements**:

**Syntax & Linting**:
```bash
# Syntax check (no execution)
bash -n scripts/backup-database.sh

# Linting (if shellcheck available)
shellcheck scripts/backup-database.sh
```
Expected: No syntax errors, no critical shellcheck warnings

**Dry-Run Test** (REQUIRED for destructive scripts):
```bash
./scripts/backup-database.sh --dry-run test_db
```
Expected: Shows what would happen without actually executing (lists commands, file paths, etc.)

**Debug/Verbose Test** (RECOMMENDED):
```bash
# Run with bash -x to trace execution
bash -x scripts/backup-database.sh --verbose test_db 2>&1 | tee test-output.log
```
Expected: All commands visible, script executes successfully

**Test Run with Sample Data** (REQUIRED):
```bash
# Create test environment
createdb test_backup_db

# Run script
./scripts/backup-database.sh test_backup_db

# Verify output
test -f backups/test_backup_db-*.sql || exit 1
test -s backups/test_backup_db-*.sql || exit 1

# Cleanup
dropdb test_backup_db
```
Expected: Script completes successfully, backup file created and non-empty

**Positive Test Cases**:
- [ ] Run with valid database: `./scripts/backup-database.sh production_db` creates backup file
- [ ] Backup file is non-empty: `test -s backups/production_db-*.sql`
- [ ] Backup file is readable: `head -5 backups/production_db-*.sql` shows SQL

**Negative Test Cases**:
- [ ] Run with non-existent database: `./scripts/backup-database.sh fake_db`
  - Expected: Exit code 1, error message "Database fake_db does not exist"
- [ ] Run with no arguments: `./scripts/backup-database.sh`
  - Expected: Exit code 1, usage message displayed

**Edge Cases**:
- [ ] Run with database name containing special chars: `./scripts/backup-database.sh "test-db_123"`
  - Expected: Handles correctly (quoted or escaped)
- [ ] Run when backup directory is full (if testable): Verify graceful error

**Output Validation**:
```bash
# Capture output and verify
OUTPUT=$(./scripts/backup-database.sh test_db 2>&1)
echo "$OUTPUT" | grep -q "Backup completed successfully" || exit 1
```
```

### For API Endpoints

```markdown
**Test Requirements**:

**Automated Tests**:
```bash
# Integration tests
npm test -- tests/integration/auth.test.js
```

**Manual Tests**:
```bash
# Positive: Valid request
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123"}'
# Expected: 201 Created with user object and session token

# Negative: Invalid email
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"invalid","password":"SecurePass123"}'
# Expected: 400 Bad Request with validation error

# Negative: Duplicate email
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"SecurePass123"}'
# Expected: 409 Conflict with error message
```

**Positive Test Cases**:
- [ ] POST /auth/register with valid email/password returns 201 with token
- [ ] POST /auth/login with valid credentials returns 200 with token
- [ ] GET /auth/me with valid token returns user profile

**Negative Test Cases**:
- [ ] POST /auth/register with invalid email returns 400
- [ ] POST /auth/register with weak password returns 400
- [ ] POST /auth/register with duplicate email returns 409
- [ ] POST /auth/login with wrong password returns 401
- [ ] GET /auth/me with invalid token returns 401

**Edge Cases**:
- [ ] POST /auth/register with email 254 chars works
- [ ] POST /auth/register with email 255 chars returns 400
- [ ] POST /auth/login with locked account returns 423
```
```

### Acceptance Criteria Must Be Testable

❌ **Bad** (vague, not testable):
- "All methods work correctly"
- "Login flow works"
- "Endpoint accepts valid requests"

✅ **Good** (specific, testable):
- "All methods work correctly (verified by: unit tests pass, manual import test passes, error handling tests pass)"
- "Login flow works (verified by: login with valid credentials returns token, 5 failed attempts locks account, locked account rejects login)"
- "Endpoint accepts valid requests (verified by: curl test returns 201, response contains user object and token)"

## Verification Task Format

**CRITICAL**: Include explicit verification tasks at key milestones. These ensure quality and catch issues early.

### Verification Task Placement

1. **After Models** (after all model tasks in a story):
   - Verify files exist, syntax valid, methods present
   - Can import and use models
   - Example: T021 [US1] Verify models milestone (T017, T018)

2. **After Services** (after all service tasks):
   - Verify services work with models
   - Business logic matches design
   - Error handling correct
   - Example: T022 [US1] Verify services milestone (T019, T020)

3. **After API** (after all API/endpoint tasks):
   - Verify all endpoints exist and work
   - Manual testing with curl/Postman
   - Error responses correct
   - Example: T023 [US1] Verify API milestone (T021-T024)

4. **After Tests** (after all test tasks):
   - Run automated test suite
   - Verify coverage meets requirements
   - No linting errors
   - Example: T024 [US1] Verify tests milestone (T025-T027)

5. **After Story** (after all tasks in story):
   - Run independent test scenario
   - Verify story works end-to-end
   - Example: T025 [US1] Verify story completion

### Verification Task Format (REQUIRED elements)

Every verification task MUST include:

1. **Verification Type**: Milestone Checkpoint or Story-Level Verification
2. **Dependencies**: List all tasks that must be complete
3. **Automated Checks**: Specific commands that can be copy-pasted and run
4. **Manual Checks**: Step-by-step checklist with expected results
5. **Test Results**: What output indicates success
6. **Failure Criteria**: What output indicates failure

**Example Verification Task**:

```markdown
- [ ] T022 [US1] Verify services milestone (T019, T020)

  **Verification Type**: Milestone Checkpoint
  
  **Dependencies**: T019, T020 (all service tasks complete)
  
  **Automated Checks**:
  ```bash
  # Syntax and linting
  npm run lint src/services/user-service.js src/services/auth-service.js
  
  # Unit tests
  npm test -- tests/unit/user-service.test.js tests/unit/auth-service.test.js
  
  # Coverage check
  npm test -- --coverage --collectCoverageFrom='src/services/*.js' | grep -E "Statements|Branches|Functions|Lines" | awk '{if ($2 < 80) exit 1}'
  ```
  Expected: 0 lint errors, all tests pass, coverage >= 80%
  
  **Manual Checks**:
  - [ ] Import UserService: `const UserService = require('./src/services/user-service')` succeeds
  - [ ] Call createUser: `UserService.createUser("test@example.com", "Pass123")` returns user object
  - [ ] Verify password hashed: `user.password_hash !== "Pass123"`
  - [ ] Import AuthService: `const AuthService = require('./src/services/auth-service')` succeeds
  - [ ] Call login: `AuthService.login("test@example.com", "Pass123")` returns session token
  - [ ] Call login with wrong password 5 times, verify 6th call throws AuthError with 423 status
  
  **Test Results** (success indicators):
  - Linting passes (0 errors, 0 warnings)
  - All unit tests pass (100% pass rate)
  - Coverage >= 80% for both services
  - All manual checks pass
  
  **Failure Criteria**:
  - Any linting errors or warnings
  - Any test failures
  - Coverage < 80%
  - Any manual check fails
  
  **Acceptance**: All automated and manual checks pass
```

**Before marking verification task complete, verify**:
- [ ] All individual task acceptance criteria have passing tests
- [ ] All test requirements from dependent tasks are satisfied
- [ ] All automated checks pass
- [ ] All manual checks pass

## Task Self-Containment Requirements

**CRITICAL**: For `/do-task` to work effectively, each task must be self-contained. This means:

### DO Include:
- Exact file paths
- All fields with types and constraints
- All methods with signatures and behavior
- Error handling requirements
- Dependencies explicitly listed
- Acceptance criteria for the task
- Implementation approach (if non-obvious)

### DON'T Rely On:
- "See design doc for details" (extract details into task)
- "Similar to T011" (include full details)
- "Standard pattern" (specify the pattern)
- Implied dependencies (list them explicitly)
- "Follow existing pattern" (reference the specific pattern from agents.md/agent-docs/)

### DO Reference:
- Specific patterns from agents.md: "Per agents.md model conventions..."
- Domain patterns from agent-docs/: "Follow agent-docs/api.md endpoint structure..."
- Similar codebase files: "Reference src/models/product.js for structure..."
- Research decisions: "Per research.md decision on email service..."

## Examples

### ✅ CORRECT (Detailed, Self-Contained)

```
- [ ] T017 [P] [US1] Create User model in src/models/user.js

  **File**: src/models/user.js
  
  **Fields** (from design):
  - id: UUID (primary key, auto-generated)
  - email: string (unique, required, validated with regex)
  - password_hash: string (required, bcrypt hashed, never plain text)
  - email_verified: boolean (default: false)
  - status: enum('active', 'inactive') (default: 'active')
  - failed_login_count: integer (default: 0)
  - locked_until: timestamp (nullable, null means not locked)
  
  **Methods** (from design):
  - create(userData): Create new user, hash password using bcrypt cost 10, return user object
  - findByEmail(email): Find user by email, return user object or null
  - updateFailedLoginCount(userId): Increment failed_login_count by 1
  - lockAccount(userId, durationMinutes): Set locked_until to now + durationMinutes
  
  **Error Handling**:
  - Use ValidationError from src/errors/validation-error.js for invalid input
  - Use DatabaseError from src/errors/database-error.js for DB failures
  - Never expose internal errors to callers (per agents.md)
  
  **Patterns to Follow** (from agents.md/agent-docs/):
  - Model structure: Follow pattern from src/models/product.js (if exists)
  - Error handling: Per agent-docs/database.md conventions
  - Field validation: Per agents.md code standards
  
  **Dependencies**: T008-T016 (Foundation tasks must be complete)
  
  **Acceptance**: User model can be imported, instantiated, and all methods work correctly
  
  **Test Requirements**:
  
  **Automated Tests**:
  ```bash
  # Syntax check
  npm run lint src/models/user.js
  
  # Unit tests (if test file exists)
  npm test -- tests/unit/user.test.js
  ```
  Expected: No lint errors, all tests pass
  
  **Manual Tests**:
  - [ ] Import: `const User = require('./src/models/user')` succeeds
  - [ ] Call create: `User.create({email: "test@example.com", password: "Pass123"})` returns user object
  - [ ] Verify password hashed: `user.password_hash !== "Pass123"`
  - [ ] Call findByEmail: `User.findByEmail("test@example.com")` returns user object
  - [ ] Call findByEmail with non-existent: `User.findByEmail("fake@example.com")` returns null
  
  **Positive Test Cases**:
  - [ ] create with valid data returns user object with hashed password
  - [ ] findByEmail finds existing user
  - [ ] updateFailedLoginCount increments count correctly
  - [ ] lockAccount sets locked_until timestamp
  
  **Negative Test Cases**:
  - [ ] create with invalid email throws ValidationError
  - [ ] create with duplicate email throws DatabaseError (409)
  - [ ] findByEmail with null returns null (not error)
  
  **Integration Checks**:
  - [ ] Model works with database connection from foundation tasks
  - [ ] Error classes (ValidationError, DatabaseError) work correctly
```

### ✅ CORRECT (With Research Marker)

```
- [ ] T042 [US2] [RESEARCH] Integrate SendGrid email service in src/services/email-service.js

  **File**: src/services/email-service.js
  
  **Research Needed**:
  - Check agents.md for: Email service patterns or third-party integration conventions
  - Review codebase for: Similar third-party service integrations (e.g., payment service)
  - Verify in agent-docs/: API integration patterns
  - Clarify with design: Email template structure and error handling strategy
  
  **Requirements** (from design):
  - Send password reset emails via SendGrid API
  - Include reset link with expiration notice
  - Handle API errors gracefully (don't fail user request)
  
  **Implementation Details**:
  - Use SendGrid Node.js SDK
  - Template: Password reset email with company branding
  - Error handling: Log SendGrid errors, return success to user (security)
  
  **Dependencies**: T035 (PasswordResetService)
  
  **Acceptance**: Emails send successfully, errors logged but don't expose to users
  
  **Test Requirements**:
  
  **Automated Tests**:
  ```bash
  npm test -- tests/unit/email-service.test.js
  ```
  Expected: All tests pass
  
  **Manual Tests**:
  - [ ] Import: `const EmailService = require('./src/services/email-service')` succeeds
  - [ ] Call sendPasswordReset: `EmailService.sendPasswordReset("test@example.com", "token123")` succeeds
  
  **Positive Test Cases**:
  - [ ] sendPasswordReset with valid email sends email via SendGrid
  - [ ] Email contains reset link with token
  - [ ] Email contains expiration notice
  
  **Negative Test Cases**:
  - [ ] SendGrid API error is logged but doesn't throw (user sees success)
  - [ ] Invalid email format is rejected before API call
  
  **Integration Checks**:
  - [ ] Works with SendGrid SDK from dependencies
  - [ ] Error logging works with logger from foundation tasks
```

### ✅ CORRECT (Simpler task, still detailed)

```
- [ ] T001 Initialize project structure per implementation plan

  **Files**: Create directories: src/, tests/, config/
  
  **Requirements**:
  - Create src/ directory with subdirectories: models/, services/, routes/, middleware/
  - Create tests/ directory with subdirectories: unit/, integration/
  - Create config/ directory for configuration files
  - Create .gitignore with standard Node.js ignores
  
  **Dependencies**: None (first task)
  
  **Acceptance**: All directories exist, .gitignore created
  
  **Test Requirements**:
  
  **Manual Tests**:
  - [ ] Verify directories exist: `test -d src/models && test -d src/services && test -d tests/unit`
  - [ ] Verify .gitignore exists: `test -f .gitignore`
  - [ ] Verify .gitignore contains standard ignores: `grep -q "node_modules" .gitignore`
  
  **Positive Test Cases**:
  - [ ] All required directories created
  - [ ] .gitignore file created with standard content
  
  **Integration Checks**:
  - [ ] Directory structure matches design requirements
```

### ❌ WRONG (Too brief, not self-contained)

```
- [ ] T017 [US1] Create User model in src/models/user.js
  - Fields: id, email, password_hash...
  - Methods: create(), findByEmail()...
```
Problem: Missing field types, method signatures, error handling, dependencies, test requirements

### ❌ WRONG (Missing required elements)

```
- [ ] Create User model  (missing ID and Story label)
T001 [US1] Create model  (missing checkbox)
- [ ] [US1] Create User model  (missing Task ID)
- [ ] T001 [US1] Create model  (missing file path)
```

### ❌ WRONG (Research marker without research section)

```
- [ ] T042 [RESEARCH] Integrate SendGrid email service
  - Use SendGrid API
  - Send emails
```
Problem: [RESEARCH] marker used but no "Research Needed" section provided

## Parallel Task Marking

Mark tasks `[P]` only if:
- It modifies different files than other incomplete tasks
- It has no dependencies on incomplete tasks
- It can safely run simultaneously with other `[P]` tasks

**Example:**
```
- [ ] T017 [P] [US1] Create User model in src/models/user.js
- [ ] T018 [P] [US1] Create Session model in src/models/session.js
```
Both are `[P]` because different files, no dependencies.

```
- [ ] T013 [US1] Create UserService (depends on User model)
- [ ] T014 [US1] Create AuthService (depends on UserService)
```
These are NOT parallel - must be sequential.

## Dependencies

Always list explicit dependencies:

**Good:**
```
**Dependencies**: T008-T016 (Foundation tasks), T017 (User model)
```

**Bad:**
```
**Dependencies**: Previous tasks (vague)
```

## Task Granularity

**Good Task Size**: 30-60 minutes of focused work

**Too Small**:
```
- [ ] T001 Import bcrypt
- [ ] T002 Write hash function
- [ ] T003 Write verify function
```
Combine: "Implement password hashing with bcrypt"

**Too Large**:
```
- [ ] T001 Implement entire authentication system
```
Break down: Registration → Login → Session → Verification

## Common Mistakes to Avoid

❌ **Not organizing by user story**
- Tasks scattered by type instead of feature
- Can't test partially complete work

❌ **Missing file paths**
- "Create User model" → Where?
- Should be: "Create User model in src/models/user.js"

❌ **Incorrect story labels**
- Setup tasks with [US1] label
- Missing [US1] label on story-specific tasks

❌ **No independent test defined**
- Can't verify story works without other stories

❌ **Wrong parallel markers**
- Marking dependent tasks as [P]
- Not marking clearly parallel tasks

❌ **Vague descriptions**
- "Handle errors" → Which errors? How?
- "Add validation" → Which fields? What rules?

❌ **Tasks not self-contained**
- "Create User model" → What fields? What methods? What types?
- "Implement service" → Which methods? What do they do?
- Tasks that require loading design doc to understand

❌ **Missing pattern references**
- "Create model" → Which pattern from agents.md?
- "Implement API endpoint" → Which conventions from agent-docs/api.md?
- Not checking for similar implementations in codebase

❌ **Inappropriate research markers**
- Using [RESEARCH] for tasks with clear patterns in agents.md
- Using [RESEARCH] without providing "Research Needed" section
- Not using [RESEARCH] when task introduces new technology

❌ **Missing test requirements**
- No test commands specified
- No positive/negative test cases
- Acceptance criteria not testable
