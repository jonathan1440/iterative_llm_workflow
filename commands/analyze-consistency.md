---
description: Validate consistency across spec, design, and tasks documents to catch drift and missing implementations.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command performs cross-artifact validation to ensure spec, design, and tasks documents remain consistent. It catches common issues like requirements without tasks, database tables without migrations, and API endpoints without implementation plans.

### Step 0: Prerequisites

Verify that all required documents exist:

```bash
bash .cursor/scripts/check-consistency-prerequisites.sh "$ARGUMENTS"
```

The script will:
- Verify spec file exists
- Verify design file exists
- Verify tasks file exists
- Output file paths

If any files are missing, instruct user to create them first.

### Step 1: Run Consistency Checks

Execute comprehensive validation:

```bash
bash .cursor/scripts/check-consistency.sh "docs/specs/[feature-name].md"
```

The script performs these checks:

#### 1. Spec → Tasks Validation
- Every functional requirement has corresponding tasks
- Every user story has tasks in tasks file
- Acceptance criteria match between spec and tasks
- Success criteria are addressed in tasks

#### 2. Design → Tasks Validation
- Every database table has migration task
- Every API endpoint has implementation task
- Every service/model in design has creation task
- Security measures in design have implementation tasks

#### 3. MVP Definition Consistency
- MVP scope matches across all three files
- P1 stories are same in spec and tasks
- MVP database schema matches design
- MVP API surface area consistent

#### 4. Task Dependencies
- All task dependencies are valid (referenced tasks exist)
- No circular dependencies
- Sequential tasks properly ordered
- Parallel markers ([P]) are appropriate

#### 5. Completeness Checks
- All spec sections addressed in design
- All design components addressed in tasks
- Independent test scenarios defined
- Acceptance criteria testable

### Step 2: Review Findings

Display categorized issues:

```markdown
╔════════════════════════════════════════════════╗
║     Consistency Analysis Results               ║
╚════════════════════════════════════════════════╝

🔴 CRITICAL ISSUES (3)
Issues that will cause implementation failures:

1. Missing Task for Requirement
   - Spec requirement #4: "User can reset password"
   - No corresponding tasks found in any phase
   - Action: Add tasks T045-T048 for password reset

2. Database Table Without Migration
   - Design defines `password_resets` table
   - No migration task in Phase 2 (Foundation)
   - Action: Add T010: Create password_resets migration

3. API Endpoint Without Task
   - Design specifies POST /api/auth/reset-password
   - No implementation task found
   - Action: Add to User Story 2 tasks

🟡 WARNINGS (5)
Issues that may cause confusion or inconsistency:

1. MVP Definition Mismatch
   - Spec says MVP = US1 only
   - Tasks say MVP = US1 + US2
   - Action: Align MVP definition

2. Acceptance Criteria Drift
   - Spec US1 has 7 criteria
   - Tasks US1 has 5 criteria
   - Missing: "Session expires after 24 hours", "User can log out"
   - Action: Add missing criteria to tasks

[... more warnings ...]

🟢 GOOD (12)
Things that are consistent:

✓ All P1 user stories have complete task breakdowns
✓ Database schema matches between design and migrations
✓ Security measures in design have implementation tasks
✓ All models in design have creation tasks
✓ Task IDs are sequential with no gaps
[... more successes ...]

═══════════════════════════════════════════════════
Summary: 3 critical, 5 warnings, 12 good
═══════════════════════════════════════════════════

Recommendation: Fix critical issues before implementation
```

### Step 3: Fix Critical Issues

For each critical issue, provide actionable fix:

```markdown
Fix #1: Missing Task for Password Reset

**Problem**: Spec requirement "User can reset password" has no tasks

**Solution Options**:

A. Add to existing User Story 2 (if US2 is about auth)
   - Add tasks T045-T048 in Phase 4
   - Update US2 goal to include password reset

B. Create new User Story 3 for password reset
   - Add new Phase 5 section
   - Tasks T045-T052 for complete feature

**Recommended**: Option A (keeps related auth features together)

**Implementation**:
1. Update tasks file Phase 4
2. Add 4 tasks:
   - T045: Create PasswordReset model
   - T046: Implement password reset service
   - T047: Add reset password endpoint
   - T048: Test password reset flow
3. Update US2 acceptance criteria in spec

Apply this fix? [yes/no/manual]
```

If user says "yes", update the relevant file(s).

### Step 4: Fix Warnings

Address warning-level issues:

```markdown
Fix Warning #1: MVP Definition Mismatch

**Current state**:
- spec.md Line 89: "MVP = User Story 1 (core auth)"
- tasks.md Line 45: "MVP = Phase 1 + Phase 2 + Phase 3 + Phase 4"

**Impact**: Team confusion about what to build first

**Recommended fix**: 
Update tasks.md to match spec.md (US1 only is true MVP)

**Rationale**: 
- US1 provides complete authentication
- US2 (password reset) is enhancement, not core
- Aligns with "minimal viable" principle

Apply this fix? [yes/no/skip]
```

### Step 5: Update Agents.md (If Patterns Found)

If consistency checks reveal common mistakes:

```markdown
## Learnings from Consistency Analysis

**Pattern detected**: Design → Tasks drift

Found 3 instances where design specified components but tasks didn't include them:
- password_resets table (missing migration)
- Email service (missing implementation)
- Rate limiting (missing middleware task)

**Should add to agents.md**:

## Common Mistakes

**Don't skip tasks for "obvious" components**
- Mistake: Design specifies email service, but no task to implement it
- Why wrong: "Obvious" components still need explicit tasks for tracking
- Correct: Every component in design gets a task in tasks file
- Rationale: Prevents forgotten implementations
- Added: 2026-01-12

Add this learning? [yes/no]
```

### Step 6: Generate Consistency Report

Create detailed report file:

```bash
bash .cursor/scripts/generate-consistency-report.sh "docs/specs/[feature-name].md"
```

This creates `docs/specs/[feature-name]-consistency-report.md` with:
- All issues found (critical, warnings, good)
- Recommended fixes
- Diff snippets showing what to change
- Rerun instructions

### Step 7: Final Summary

```markdown
✅ Consistency Analysis Complete

📊 Results:
- Critical Issues: 3 (must fix before implementation)
- Warnings: 5 (recommended to fix)
- Good: 12 (consistent and correct)

📝 Actions Taken:
- Fixed 2 critical issues automatically
- Generated consistency report
- Added 1 learning to agents.md

📄 Report: docs/specs/[feature-name]-consistency-report.md

🎯 Next Steps:
1. Review remaining 1 critical issue
2. Fix manually or with /add-story command
3. Re-run /analyze-consistency to verify
4. Proceed with implementation

💡 Tip: Run this before starting implementation and after major design changes
```

## Guidelines

### What Consistency Means

**Spec ↔ Design**:
- Every requirement in spec has solution in design
- Design doesn't include features not in spec
- MVP scope matches
- Success criteria achievable with design

**Design ↔ Tasks**:
- Every component in design has creation task
- Every API endpoint has implementation task
- Database schema has migration tasks
- Tasks sufficient to build design

**Spec ↔ Tasks**:
- Every user story has tasks
- Acceptance criteria match
- MVP definition identical
- Out-of-scope items not in tasks

### When to Run This Command

**Required**:
- Before starting implementation (after spec/design/tasks done)
- After major design changes
- When adding new user stories
- Before marking a phase complete

**Optional but Recommended**:
- Weekly during long projects
- After team members make changes
- When something "feels off"

### Common Consistency Issues

**Critical (Must Fix)**:
1. **Missing Tasks**: Requirement exists but no implementation plan
2. **Missing Migrations**: Design has table but no migration task
3. **Missing Endpoints**: Design specifies API but no implementation task
4. **Orphaned Tasks**: Task references non-existent user story
5. **Circular Dependencies**: Task A depends on B, B depends on A

**Warnings (Should Fix)**:
1. **MVP Mismatch**: Different definitions across files
2. **Criteria Drift**: Acceptance criteria don't match
3. **Scope Creep**: Tasks include out-of-scope features
4. **Vague Tasks**: Task descriptions don't specify file paths
5. **Missing Test Scenarios**: User story has no independent test

**Good (Ignore)**:
1. **Different Wording**: Same meaning, different phrasing is fine
2. **Additional Detail**: Design or tasks add detail not in spec
3. **Task Breakdown**: One requirement → multiple tasks is expected

### Auto-Fix Capabilities

The command can automatically fix:
- ✅ Adding missing task references
- ✅ Updating MVP definitions
- ✅ Syncing acceptance criteria
- ✅ Fixing task numbering sequences

The command cannot automatically fix:
- ❌ Creating entirely new tasks (use /add-story)
- ❌ Designing missing components (use /design-system)
- ❌ Resolving architectural conflicts (manual review needed)

### Handling False Positives

Sometimes the tool flags non-issues:

```markdown
Issue: "Success criterion 'Users complete registration in <2 min' not addressed"

Why it's flagged: No task explicitly mentions this metric

Why it's actually fine: This is a performance requirement tested at the end

Action: Mark as "Understood - will verify in testing phase"
```

Add `--skip-checks` flag to suppress specific checks on re-run.

## Context

Feature specification path: $ARGUMENTS

**Important**: This command reads only, never writes (except with explicit user approval). It's safe to run frequently.
