---
description: Safely refactor code with automatic test verification, rollback capability, and learning capture.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command performs safe code refactoring by running tests before and after changes, offering automatic rollback if tests fail, and capturing learnings about the refactoring.

**Usage Pattern:**
```bash
/refactor "Refactor description" [file-or-directory]
```

Example: `/refactor "Extract authentication logic into service" src/routes/auth.py`

### Step 0: Prerequisites

Verify refactoring readiness:

```bash
bash .cursor/scripts/check-refactor-prerequisites.sh "$ARGUMENTS"
```

The script will:
- Verify tests exist and can run
- Check working directory is clean (no uncommitted changes)
- Verify target files exist
- Ensure no blocking issues (failing tests, syntax errors)
- Create safety checkpoint

Output:
```markdown
✅ Refactor Prerequisites Check

Working directory: Clean (no uncommitted changes)
Tests: Found 47 tests
Test command: pytest tests/
Target: src/routes/auth.py (312 lines)
Git branch: main (clean)

Ready to refactor ✓
```

### Step 1: Run Pre-Refactor Tests

Establish baseline by running all tests:

```bash
bash .cursor/scripts/run-tests.sh --baseline
```

```markdown
🧪 Running Pre-Refactor Tests (Baseline)

Running: pytest tests/ -v

════════════════════════════════════════════════════════════
tests/test_auth.py::test_user_registration PASSED
tests/test_auth.py::test_user_login PASSED
tests/test_auth.py::test_invalid_credentials FAILED
tests/test_auth.py::test_password_reset PASSED
[... more tests ...]

47 tests ran in 2.34s
45 passed, 2 failed

════════════════════════════════════════════════════════════

⚠️  BASELINE FAILURES DETECTED

Failed tests:
1. test_invalid_credentials - Expected 401, got 500
2. test_email_validation - Email regex broken

**Decision Required:**
A. Fix failing tests first (recommended)
B. Proceed with refactor (risky - can't verify if refactor breaks things)
C. Exclude failing tests from safety check

[A/B/C]: _
```

**If user chooses A**: Stop and direct them to fix tests first
**If user chooses B**: Continue with warning
**If user chooses C**: Mark tests as excluded

### Step 2: Create Safety Checkpoint

Take snapshot before refactoring:

```bash
bash .cursor/scripts/create-refactor-checkpoint.sh "$TARGET_FILES"
```

```markdown
📸 Creating Safety Checkpoint

Snapshot created: .refactor-checkpoint-[timestamp]

Files backed up:
- src/routes/auth.py (312 lines)
- src/services/auth_service.py (156 lines)
- tests/test_auth.py (89 lines)

Git commit: a7f3c2d "Feature: User authentication"

You can rollback with:
  bash .cursor/scripts/rollback-refactor.sh [timestamp]

Checkpoint saved ✓
```

### Step 3: Plan Refactoring

Generate refactoring plan:

```markdown
**Load into context:**
- Target files: [files to refactor]
- Related tests: [test files]
- Project standards: .cursor/agents.md
- Architecture patterns: .cursor/agent-docs/architecture.md (if exists)
- Testing patterns: .cursor/agent-docs/testing.md (if exists)
- Failure modes: .cursor/agent-docs/failure-modes.md (if exists, for avoiding mistakes during refactoring)

Based on refactor goal: "$REFACTOR_DESCRIPTION"

Create a refactoring plan with:

1. **What's being refactored**: Specific code blocks
2. **Why**: Benefits of refactoring (readability, performance, maintainability)
3. **Approach**: Step-by-step transformation
4. **Risk assessment**: What could break
5. **Test strategy**: How to verify correctness
```

Display plan:

```markdown
## Refactoring Plan: Extract Authentication Logic into Service

**Current State:**
- 8 authentication functions scattered across routes
- Business logic mixed with HTTP handling
- Difficult to test logic in isolation
- Code duplication (password hashing in 3 places)

**Target State:**
- Centralized AuthService class
- Routes handle only HTTP concerns
- Business logic testable without HTTP mocks
- Single source of truth for auth operations

**Approach:**

Step 1: Create AuthService class (src/services/auth_service.py)
- Methods: register(), login(), logout(), validate_token()
- Consolidate password hashing
- Centralize token generation

Step 2: Update routes to use AuthService
- Replace inline logic with service calls
- Keep routes thin (HTTP only)
- Update error handling

Step 3: Update tests
- Add unit tests for AuthService
- Update integration tests for routes
- Verify behavior unchanged

**Risk Assessment:**
- 🟢 Low risk: Logic extraction, not changing behavior
- ⚠️  Test coverage for routes may need expansion
- 🟢 Rollback easy (checkpoint created)

**Estimated time**: 90 minutes

Proceed with this plan? [yes/edit/no]
```

### Step 4: Execute Refactoring

Execute refactoring:

```markdown
**Prompt:**

Using the approved refactoring plan, refactor these files:
- [list of files]

For each change:
1. Show clear before/after
2. Maintain all existing behavior
3. Preserve test coverage
4. Update imports/dependencies
5. Add comments explaining changes

**Critical**: Do not change any business logic, only reorganize.

Start refactoring...
```

Progress indicator:

```markdown
🔧 Executing Refactoring

[1/3] Creating AuthService class...
├─ Created: src/services/auth_service.py
├─ Moved: register() from routes
├─ Moved: login() from routes
├─ Moved: validate_token() from routes
└─ Consolidated password hashing logic

[2/3] Updating routes...
├─ Updated: register endpoint to use AuthService
├─ Updated: login endpoint to use AuthService
├─ Simplified: Error handling now delegated
└─ Reduced routes/auth.py from 312 → 187 lines

[3/3] Updating tests...
├─ Added: tests/services/test_auth_service.py (12 unit tests)
├─ Updated: tests/test_auth.py (integration tests)
└─ All existing test cases preserved

Refactoring complete ✓
```

### Step 5: Run Post-Refactor Tests

Verify nothing broke:

```bash
bash .cursor/scripts/run-tests.sh --verify
```

```markdown
🧪 Running Post-Refactor Tests (Verification)

Running: pytest tests/ -v

════════════════════════════════════════════════════════════
tests/test_auth.py::test_user_registration PASSED
tests/test_auth.py::test_user_login PASSED
tests/test_auth.py::test_invalid_credentials FAILED
tests/test_auth.py::test_password_reset PASSED
tests/services/test_auth_service.py::test_register_user PASSED
[... more tests ...]

59 tests ran in 3.12s (+12 new tests)
57 passed, 2 failed

════════════════════════════════════════════════════════════

✅ REFACTOR VERIFICATION PASSED

Comparison with baseline:
- Baseline: 45 passed, 2 failed (47 total)
- Current:  57 passed, 2 failed (59 total)
- New tests: +12 (all passing)
- Regressions: 0

**Result**: Refactor successful ✓

Same tests that failed before still fail (expected)
No new failures introduced
Added tests all pass
```

### Step 6: Manual Verification (Optional)

Suggest manual testing:

```markdown
💡 Recommended Manual Verification

Run these quick checks:

1. Start the application:
   ```bash
   python src/main.py
   ```

2. Test authentication flow:
   - Register new user
   - Login with credentials
   - Verify session token
   - Logout

3. Check logs for errors:
   ```bash
   tail -f logs/app.log
   ```

Expected behavior: Identical to before refactor

Manual verification complete? [yes/skip]
```

### Step 7: Code Review

Display side-by-side comparison:

```markdown
## Refactoring Review

**Metrics:**
- Files changed: 3
- Lines added: +245
- Lines removed: -167
- Net change: +78 lines (tests added)
- Complexity reduced: Cyclomatic 45 → 32

**Key Changes:**

Before (routes/auth.py):
```python
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    # 45 lines of business logic here
    # Password hashing
    # User creation
    # Token generation
    # Error handling
    return jsonify(response)
```

After (routes/auth.py):
```python
@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    try:
        result = auth_service.register(data)
        return jsonify(result)
    except ValidationError as e:
        return jsonify({'error': str(e)}), 400
```

**Improvements:**
✅ Routes now < 10 lines each
✅ Business logic testable in isolation
✅ No code duplication
✅ Clear separation of concerns
✅ Easier to maintain

Approve refactoring? [yes/revise/rollback]
```

### Step 8: Update Agents.md

Capture refactoring learnings:

```markdown
## Learnings from Refactoring

**Pattern: Service Layer Extraction**

Detected opportunity:
- Routes had 312 lines of mixed concerns
- Business logic not testable in isolation
- Code duplication across 3 endpoints

Applied refactoring:
- Extracted AuthService class
- Moved business logic to service layer
- Routes now handle only HTTP concerns

**Results:**
- Routes reduced: 312 → 187 lines
- Test coverage increased: 47 → 59 tests
- Complexity reduced: 45 → 32 cyclomatic
- No regressions introduced

**Recommend adding to agents.md:**

## Refactoring Pattern: Service Layer

**When to use:**
- Routes/controllers > 200 lines
- Business logic mixed with HTTP handling
- Code duplication across endpoints
- Difficult to unit test logic

**How to refactor:**
1. Create service class
2. Move business logic to service
3. Update routes to call service
4. Add unit tests for service
5. Verify integration tests still pass

**Benefits:**
- Testable business logic
- Thinner routes/controllers
- Better separation of concerns
- Less code duplication

- Rationale: Maintainability and testability
- Added: 2026-01-13

Add this learning? [yes/edit/no]
```

### Step 9: Commit or Rollback

Final decision:

```markdown
## Refactoring Complete - Next Steps

✅ All tests passing (57/59)
✅ No regressions detected
✅ Code quality improved
✅ Manual verification complete

**Option A: Commit Changes**
```bash
git add src/ tests/
git commit -m "Refactor: Extract auth logic into service layer

- Create AuthService with register(), login(), logout() methods
- Consolidate password hashing logic
- Simplify routes to < 10 lines each
- Add 12 unit tests for service layer
- Reduce cyclomatic complexity 45 → 32

Tests: 57/59 passing (2 pre-existing failures)
No regressions introduced"
```

**Option B: Rollback (discard changes)**
```bash
bash .cursor/scripts/rollback-refactor.sh [timestamp]
```
Restores all files to pre-refactor state

**Option C: Save for later**
Creates branch: `refactor/extract-auth-service`
Can merge later after review

Choose: [commit/rollback/branch]: _
```

## Guidelines

### When to Refactor

**Good times**:
- After completing a feature (code is fresh)
- When test coverage is solid
- During dedicated refactoring sprints
- When making nearby changes anyway

**Bad times**:
- During feature development
- With failing tests
- Without test coverage
- Under time pressure

### Refactoring Red Flags

**Stop and reconsider if:**
- ❌ Tests aren't passing before refactor
- ❌ No tests exist for code being refactored
- ❌ Working directory has uncommitted changes
- ❌ You're changing behavior, not just structure
- ❌ Refactor touches > 5 files (too big)

**Warning signs during refactor:**
- ⚠️  Tests start failing
- ⚠️  Need to skip/disable tests
- ⚠️  Changing function signatures extensively
- ⚠️  Adding new features "while we're here"
- ⚠️  Can't explain why refactoring improves code

### Safe Refactoring Practices

**Always**:
- ✅ Run tests before refactoring
- ✅ Create git checkpoint
- ✅ Refactor in small steps
- ✅ Run tests after each step
- ✅ Commit when tests pass

**Never**:
- ❌ Refactor and add features simultaneously
- ❌ Change behavior during refactoring
- ❌ Skip tests "because nothing changed"
- ❌ Refactor without automated tests

### Measuring Refactoring Success

**Good refactoring metrics**:
- ✅ All tests still pass
- ✅ Code complexity reduced
- ✅ Duplicate code removed
- ✅ Files are shorter
- ✅ Easier to understand

**Bad metrics** (don't optimize for):
- ❌ Fewer lines of code (may reduce readability)
- ❌ More abstraction (may add complexity)
- ❌ Clever patterns (may reduce clarity)

### Handling Test Failures

**If tests fail after refactoring:**

```markdown
❌ Test Failure Detected

test_user_login: AssertionError: Expected 200, got 500

**Options:**
A. Debug and fix (recommended if obvious fix)
B. Rollback refactoring (recommended if unclear)
C. Skip this test (NOT recommended)

Time elapsed: 45 minutes
Rollback cost: Low (checkpoint exists)

Recommendation: Rollback and try different approach

[A/B/C]: _
```

### Refactoring Patterns

Common refactorings this command handles well:

1. **Extract Method/Function**
   - Before: One long function
   - After: Multiple focused functions

2. **Extract Class/Service**
   - Before: Mixed concerns in one file
   - After: Separate classes for separate concerns

3. **Consolidate Duplicates**
   - Before: Same logic in 3 places
   - After: Single shared implementation

4. **Simplify Conditionals**
   - Before: Nested if/else chains
   - After: Early returns or strategy pattern

5. **Rename for Clarity**
   - Before: `data`, `temp`, `x`
   - After: `user_profile`, `password_hash`, `retry_count`

### Integration with Other Commands

**After implementing a story:**
```bash
/implement-story "User Story 2"
# ... implementation complete ...
/refactor "Clean up authentication code"  # Polish before next story
```

**During code review:**
```bash
# Review reveals duplication
/refactor "Extract shared validation logic"
```

**Maintenance cycle:**
```bash
/status  # Check current state
/review-agents  # Identify refactoring opportunities
/refactor "Apply pattern from agents.md"
```

## Context

Refactoring target: $ARGUMENTS

**Important**: This command is destructive (modifies code) but safe (creates checkpoints, verifies tests). Always run in a clean working directory.
