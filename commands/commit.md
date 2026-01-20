---
description: Analyze changes and generate meaningful commit messages that connect code changes to tasks, stories, and project context.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command analyzes staged and unstaged changes, connects them to tasks and stories when possible, and generates commit messages that explain what changed and why. It respects git conventions without sounding robotic.

**Usage Pattern:**
```bash
/commit                    # Analyze all changes
/commit "custom message"   # Use custom message (still analyzes)
/commit --amend            # Amend last commit
/commit --no-verify        # Skip hooks (use carefully)
```

### Step 0: Check Git Status

```bash
# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Branch: $BRANCH"

# Check for staged changes
STAGED=$(git diff --cached --name-only)
UNSTAGED=$(git diff --name-only)

if [ -z "$STAGED" ] && [ -z "$UNSTAGED" ]; then
    echo "No changes to commit"
    exit 0
fi
```

### Step 1: Analyze Changes

```bash
# Get detailed diff
git diff --cached --stat
git diff --cached

# If unstaged changes exist, show them too
if [ -n "$UNSTAGED" ]; then
    echo "⚠️  Unstaged changes detected:"
    git diff --stat
fi
```

**Load into context:**
- Git diff (staged and optionally unstaged)
- Tasks file: Find tasks.md and check for completed tasks matching changed files
- Spec/Design: If tasks reference a spec, load relevant sections
- Recent commits: `git log --oneline -10` for context
- Branch name: For feature branch context

### Step 2: Connect Changes to Tasks

```bash
# Find tasks file
TASKS_FILE=$(bash .cursor/scripts/find-tasks-file.sh 2>/dev/null | grep -v "^ERROR:" | head -1 || echo "")

# If tasks file exists, try to match changes to tasks
if [ -n "$TASKS_FILE" ] && [ -f "$TASKS_FILE" ]; then
    # Extract changed files
    CHANGED_FILES=$(git diff --cached --name-only)
    
    # Look for tasks mentioning these files
    for file in $CHANGED_FILES; do
        grep -i "$file" "$TASKS_FILE" | grep -E "^\- \[X\]" | head -3
    done
fi
```

**Display analysis:**

```markdown
## Change Analysis

**Files Changed:**
- src/models/user.js (+145, -23)
- src/services/auth_service.js (+89, -12)
- tests/test_auth.js (+67, -8)

**Change Type:**
- Feature: New user authentication system
- Scope: 3 files, 301 lines added, 43 removed

**Connected Tasks:**
- ✅ T017: Create User model (src/models/user.js)
- ✅ T019: Implement UserService (src/services/auth_service.js)
- ✅ T025: Add auth tests (tests/test_auth.js)

**Story Context:**
- User Story 1: User Registration and Login
- Phase: MVP (P1)
```

### Step 3: Generate Commit Message

**If user provided custom message**, use it but still analyze:

```markdown
Custom message provided: "$ARGUMENTS"

**Analysis still performed:**
- Changes verified
- Tasks connected
- Scope understood

Proceed with custom message? [yes/edit]
```

**If no custom message**, generate one:

**Principles for commit messages:**
- First line: 50-72 chars, high-level overview of changes made, imperative mood, no period
- Body: Explain what and why, not how (code shows how)
- Reference tasks/stories when relevant
- Be specific: "Add rate limiting" not "Update code"
- Connect to business value when clear
- Avoid filler: "Implement", "Update", "Fix" only when necessary

**Good examples:**
```
Add user registration and login endpoints

Implements T019: User registration with email validation.
Returns session token on success, 400 on invalid input.

Part of User Story 1 (MVP).
```

```
Extract authentication logic into service layer

Routes were handling business logic directly. Moved
register/login/logout to AuthService for better testability.

Reduces routes/auth.js from 312 to 187 lines. All tests pass.
```

**Bad examples:**
```
Update files

Fixed some bugs and added features. Everything works now.
```

```
Implement user authentication system with registration and login endpoints and session management
```

**Generate message:**

```markdown
## Suggested Commit Message

```
Add user registration and login endpoints

Implements User Story 1 MVP: users can create accounts and
log in to access the system.

- Create User model with email/password fields (T017)
- Add AuthService with register/login methods (T019)
- Add integration tests for auth flow (T025)

Files: src/models/user.js, src/services/auth_service.js,
tests/test_auth.js
```

**Message Stats:**
- Subject: 44 chars ✓ (high-level overview)
- Body: 3 paragraphs, explains what and why
- References: Tasks T017, T019, T025
- Story: User Story 1 (MVP)

**Options:**
1. Use this message
2. Edit message
3. Custom message
4. Skip commit (just analyze)

[1/2/3/4]: _
```

### Step 4: Verify Before Committing

**If user chose to commit**, show final check:

```markdown
## Pre-Commit Verification

**Changes to commit:**
- 3 files staged
- 301 lines added, 43 removed
- All changes related to User Story 1

**Commit message:**
[Show the message]

**Branch:** feature/user-auth (clean, 3 commits ahead of main)

**Warnings:**
- ⚠️  Unstaged changes in src/config.js (not included)
- ℹ️  No tests modified (tests already exist)

**Ready to commit?** [yes/no]
```

### Step 5: Execute Commit

```bash
if [ "$CONFIRM" = "yes" ]; then
    git commit -m "$COMMIT_MESSAGE"
    
    # Show result
    git log -1 --stat
fi
```

**Display result:**

```markdown
✅ Commit created

[abc1234] Add user registration and login endpoints
 3 files changed, 301 insertions(+), 43 deletions(-)

**Next steps:**
- Push: git push origin feature/user-auth
- Continue: /do-task T020 (next task in story)
- Status: /status (see overall progress)
```

### Step 6: Handle Edge Cases

**If unstaged changes exist:**

```markdown
⚠️  Unstaged Changes Detected

You have uncommitted changes in:
- src/config.js (modified)
- README.md (modified)

**Options:**
1. Stage and include in commit
2. Commit only staged changes (recommended)
3. Stash unstaged changes
4. Cancel

[1/2/3/4]: _
```

**If no tasks file found:**

```markdown
ℹ️  No tasks file detected

Can't connect changes to tasks, but commit message generated
from code analysis.

**Suggested message:**
[Generate from code changes only]
```

**If changes don't match any tasks:**

```markdown
ℹ️  Changes not connected to tasks

Modified files don't appear in tasks.md. This might be:
- Refactoring work
- Bug fixes
- Documentation updates
- New work not yet planned

**Suggested message:**
[Generate from code analysis]
```

## Guidelines

### Commit Message Quality

**Subject line rules:**
- 50-72 characters (GitHub truncates at 72)
- High-level overview of changes made
- Imperative mood: "Add feature" not "Added feature"
- No period at end
- Capitalize first letter
- Be specific: "Add rate limiting to auth endpoints" not "Update auth"

**Body rules:**
- Explain what changed and why
- Reference tasks/stories when relevant
- Include context: "Part of MVP" or "Fixes #123"
- Separate paragraphs with blank lines
- Wrap at 72 characters

**When to use conventional commits:**
Only if your team uses them. Otherwise, plain messages are fine.

**Examples:**
```
feat: Add user registration endpoint

Implements T019. Part of User Story 1 MVP.
```

vs.

```
Add user registration endpoint

Implements T019. Part of User Story 1 MVP.
```

Both are fine. Pick one style and stick with it.

### Connecting to Workflow

**Task references:**
- If file matches a task, mention it: "Implements T019"
- If multiple tasks, list them: "Completes T017, T019, T025"
- If task is part of story, mention story: "T019 (User Story 1)"

**Story context:**
- MVP stories: "Part of User Story 1 (MVP)"
- Later stories: "Part of User Story 2 (P2)"
- Foundation: "Foundation task T008"

**When changes span multiple stories:**
```
Refactor authentication code

Extracts auth logic into service layer. Affects:
- User Story 1: Routes simplified
- User Story 2: Password reset uses same service

No functional changes, all tests pass.
```

### Commit Frequency

**Good commit cadence:**
- One logical change per commit
- Complete a task, then commit
- Don't wait for "perfect" commits
- Small, frequent commits > large, infrequent

**When to combine:**
- Multiple files for one task (T017 touches 3 files, one commit)
- Related refactoring (extract service + update routes)

**When to split:**
- Unrelated changes (auth + payment in same commit = bad)
- Large feature spanning days (commit incrementally)

### Handling Mistakes

**If you commit wrong message:**
```bash
git commit --amend -m "Correct message"
```

**If you forgot to stage a file:**
```bash
git add forgotten-file.js
git commit --amend --no-edit
```

**If you committed to wrong branch:**
```bash
# Create new branch from current commit
git branch feature/correct-branch

# Reset current branch
git reset --hard HEAD~1

# Switch to correct branch
git checkout feature/correct-branch
```

### Integration with Workflow

**After completing a task:**
```bash
/do-task T019
# ... implementation ...
/commit  # Automatically connects to T019
```

**After implementing a story:**
```bash
/implement-story "User Story 1"
# ... all tasks complete ...
/commit  # One commit per task, or one per story?
```

**Before pushing:**
```bash
/commit  # Review all commits
git log origin/main..HEAD  # See what you're pushing
git push
```

**For feature branches:**
```bash
# Start feature
git checkout -b feature/user-auth
/do-task T017
/commit
/do-task T019
/commit
# ... more work ...
git push origin feature/user-auth
```

## Context

Working directory: Current git repository
Branch: From `git rev-parse --abbrev-ref HEAD`
Changes: From `git diff --cached` and `git diff`

**Important**: This command analyzes changes and suggests messages. It doesn't force a commit style. Use what works for your team.
