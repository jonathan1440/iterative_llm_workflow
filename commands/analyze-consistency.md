---
description: Validate consistency across spec, design, and tasks documents to catch drift and missing implementations.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command performs comprehensive validation including:
1. **Format validation**: Ensures spec, design, and tasks follow proper template formats (required sections, proper syntax, correct structure)
2. **Cross-artifact consistency**: Validates that documents remain consistent with each other (requirements have tasks, design matches spec, tasks match design)
3. **Deep accuracy review**: Analyzes plan files for logical errors, gotchas, security issues, performance problems, and ambiguities
   - **Scope**: Reviews all plan files (spec, design, tasks) for content quality
   - **Categories**: Logical errors, security vulnerabilities, performance problems, data integrity issues, error handling gaps, edge cases, ambiguities
   - **Depth**: Checks relationships between components, analyzes failure modes, identifies missing edge cases

It catches common issues like:
- Requirements without tasks, database tables without migrations, API endpoints without implementation plans
- Format deviations from templates
- Logical errors, contradictions, and circular dependencies
- Security vulnerabilities (missing auth, information leakage, insecure defaults)
- Performance problems (missing indexes, N+1 queries, inefficient algorithms)
- Data integrity issues (missing transactions, race conditions, validation gaps)
- Error handling gaps (missing retry logic, inconsistent error formats)
- Edge cases not handled (null values, boundary conditions, concurrent operations)
- Ambiguities needing clarification (vague requirements, missing details, unclear priorities)

### Step 0: Prerequisites

Verify that all required documents exist:

**File Location Assumption**: Assuming standard file locations (docs/specs/[feature-name]/spec.md, design.md, tasks.md). If files are in different locations, specify paths in $ARGUMENTS.

```bash
bash .cursor/scripts/check-consistency-prerequisites.sh "$ARGUMENTS"
```

The script will:
- Verify spec file exists
- Verify design file exists
- Verify tasks file exists
- Output file paths

If any files are missing, instruct user to create them first.

### Step 1: Run Format Validation

First, validate that each document follows the proper template format:

```bash
# Validate spec format
bash .cursor/scripts/validate-spec.sh "docs/specs/[feature-name]/spec.md"

# Validate tasks format
bash .cursor/scripts/validate-tasks.sh "docs/specs/[feature-name]/tasks.md"
```

**Format validation checks:**

#### Spec Format Validation
- Required sections present (Problem Statement, User Stories, Success Criteria, Functional Requirements)
- User stories follow "As a...I want...so that" format
- Acceptance criteria defined for each user story
- Success criteria contain measurable metrics
- No implementation details in spec (technology choices belong in design)
- No placeholder markers (TODO, TBD, etc.)
- Out of Scope section present (recommended)

#### Tasks Format Validation
- All tasks have TaskID format: `[T001]`, `[T002]`, etc.
- TaskIDs are sequential with no gaps
- Tasks follow format: `- [ ] [TaskID] [P?] [Story?] [RESEARCH?] Description`
- Required sections present (Phase 1: Setup, Phase 2: Foundation, MVP Definition, Dependencies)
- User story tasks have file paths specified
- Independent test scenarios defined for each user story
- Acceptance criteria referenced from spec
- MVP definition clearly scoped
- Mermaid dependency diagram present (recommended)

**Format validation results should be integrated into the overall analysis.**

### Step 2: Run Consistency Checks

Execute cross-artifact consistency validation:

```bash
bash .cursor/scripts/check-consistency.sh "docs/specs/[feature-name]/spec.md"
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

### Step 3: Deep Accuracy Review

After format and consistency checks, perform a deep review of all plan files for accuracy, gotchas, and potential issues. This step analyzes the content for logical errors, common pitfalls, and areas needing clarification.

**Load all plan files into context:**
- Spec: `docs/specs/[feature-name]/spec.md`
- Design: `docs/specs/[feature-name]/design.md`
- Tasks: `docs/specs/[feature-name]/tasks.md`
- Research: `docs/specs/[feature-name]/research.md` (if exists)
- Standards: `.cursor/agents.md`
- Domain patterns: `.cursor/agent-docs/*.md` (if exist)
- Failure modes: `.cursor/agent-docs/failure-modes.md` (if exists)

**Review categories:**

#### 3.1. Logical Errors and Contradictions

Check for:
- Contradictory requirements (spec says X, design says Y)
- Impossible constraints (performance targets that conflict with security requirements)
- Circular dependencies in logic (A requires B, B requires A)
- Missing prerequisites (feature requires X but X isn't defined)
- Invalid assumptions (assumes capability that doesn't exist)

#### 3.2. Security Gotchas

Check for:
- Missing authentication/authorization (endpoints without auth checks)
- Insecure defaults (passwords, tokens, sessions)
- Missing input validation (SQL injection, XSS vulnerabilities)
- Exposed sensitive data (passwords in logs, tokens in URLs)
- Missing rate limiting (brute force attack vectors)
- Insecure data storage (plain text passwords, unencrypted sensitive data)
- Missing HTTPS requirements
- Session management issues (no expiration, insecure tokens)
- Missing CSRF protection
- Insecure error messages (information leakage)

#### 3.3. Performance Gotchas

Check for:
- Missing indexes (database queries without proper indexes)
- N+1 query problems (loops that query database)
- Missing caching strategies (frequently accessed data not cached)
- Inefficient algorithms (O(n²) when O(n) possible)
- Missing pagination (large result sets)
- Missing connection pooling
- Missing async operations (blocking operations)
- Missing load limits (unbounded operations)

#### 3.4. Data Integrity Gotchas

Check for:
- Missing transactions (multi-step operations without atomicity)
- Race conditions (concurrent operations that conflict)
- Missing foreign key constraints
- Missing unique constraints (duplicate data possible)
- Missing validation (invalid data can be stored)
- Missing null checks (nullable fields without handling)
- Missing cascade rules (orphaned records)
- Missing data migration strategy

#### 3.5. Error Handling Gotchas

Check for:
- Missing error handling (operations that can fail without handling)
- Inconsistent error formats (different error structures)
- Missing error logging (failures not logged)
- Missing user-friendly error messages (technical errors exposed)
- Missing retry logic (transient failures not retried)
- Missing circuit breakers (cascading failures)
- Missing fallback mechanisms (service unavailable handling)

#### 3.6. Edge Cases and Boundary Conditions

Check for:
- Missing null/undefined handling
- Missing empty string/array handling
- Missing boundary value checks (max length, min values)
- Missing overflow/underflow handling
- Missing concurrent operation handling
- Missing timeout handling
- Missing resource exhaustion handling (memory, disk, connections)

#### 3.7. Integration Gotchas

Check for:
- Missing API versioning strategy
- Missing backward compatibility considerations
- Missing third-party service failure handling
- Missing timeout configurations for external calls
- Missing retry strategies for external services
- Missing fallback mechanisms for external dependencies
- Missing monitoring/observability for integrations

#### 3.8. Testing Gotchas

Check for:
- Missing test coverage for critical paths
- Missing edge case tests
- Missing integration tests
- Missing error case tests
- Missing performance tests
- Missing security tests
- Missing test data setup/teardown

#### 3.9. Ambiguities and Clarifying Questions

Identify areas needing clarification:
- Vague requirements (unclear what "fast" means)
- Missing details (how should X work exactly?)
- Conflicting interpretations (could mean A or B)
- Missing context (why is this requirement needed?)
- Unclear priorities (what's most important?)
- Missing constraints (what are the limits?)

#### 3.10. Implementation Feasibility

Check for:
- Overly complex solutions (could be simpler)
- Missing technology choices (design doesn't specify how)
- Missing infrastructure requirements (what's needed to run this?)
- Unrealistic timelines (tasks don't account for complexity)
- Missing dependencies (external services not accounted for)
- Missing deployment considerations

**Review Report Quality Bar**: Report is complete when:
- [ ] All categories reviewed (logical errors, security, performance, data integrity, error handling, edge cases, integration, testing, ambiguities, feasibility)
- [ ] All issues categorized (critical errors, gotchas, clarifying questions, feasibility concerns)
- [ ] All fixes actionable (specific location, clear solution, implementation steps)
- [ ] All issues prioritized (critical first, then warnings, then questions)

**Generate comprehensive review report:**

```markdown
## Deep Accuracy Review Results

### 🔴 Critical Errors (Must Fix)

1. **Security: Missing Authentication**
   - Location: Design.md, API Contracts section
   - Issue: POST /api/users endpoint has no authentication requirement
   - Impact: Anyone can create users, security vulnerability
   - Fix: Add authentication middleware requirement
   - Reference: Line 234 in design.md

2. **Logic Error: Circular Dependency**
   - Location: Tasks.md, Task dependencies
   - Issue: T017 depends on T019, T019 depends on T017
   - Impact: Cannot determine implementation order
   - Fix: Break circular dependency, restructure tasks
   - Reference: Tasks T017 and T019

3. **Data Integrity: Missing Transaction**
   - Location: Design.md, User Registration Flow
   - Issue: User creation and email sending not in transaction
   - Impact: User created but email fails = inconsistent state
   - Fix: Wrap in transaction or use compensating action
   - Reference: Design.md, User Registration section

### 🟡 Gotchas (Should Address)

1. **Performance: Missing Index**
   - Location: Design.md, Database Schema
   - Issue: users.email queried frequently but no index specified
   - Impact: Slow login queries as user base grows
   - Fix: Add index on users.email
   - Reference: Design.md, users table definition

2. **Error Handling: Missing Retry Logic**
   - Location: Design.md, Email Service Integration
   - Issue: Email sending has no retry strategy
   - Impact: Transient failures cause permanent failures
   - Fix: Add exponential backoff retry (3 attempts)
   - Reference: Design.md, Third-Party Dependencies section

3. **Edge Case: Missing Null Handling**
   - Location: Spec.md, User Stories
   - Issue: Password reset flow doesn't specify what happens if user doesn't exist
   - Impact: Information leakage (reveals if email exists)
   - Fix: Always return success message, don't reveal existence
   - Reference: Spec.md, P2 Password Recovery story

4. **Security: Information Leakage**
   - Location: Spec.md, Error Handling
   - Issue: Login errors reveal if email exists vs wrong password
   - Impact: Email enumeration attack possible
   - Fix: Use generic error message for both cases
   - Reference: Spec.md, Edge Cases section

5. **Data Integrity: Race Condition**
   - Location: Design.md, User Registration
   - Issue: Two simultaneous registrations with same email not handled
   - Impact: Duplicate users possible
   - Fix: Add unique constraint + handle duplicate key error
   - Reference: Design.md, Database Schema section

### 🟢 Clarifying Questions

1. **Ambiguity: Session Expiration**
   - Location: Spec.md, Functional Requirements
   - Question: "Session expires after 24 hours" - is this 24 hours from creation or 24 hours of inactivity?
   - Impact: Different implementations have different security implications
   - Recommendation: Clarify in spec (recommend: inactivity)

2. **Missing Detail: Rate Limiting Scope**
   - Location: Design.md, Security Considerations
   - Question: Rate limiting is per-IP or per-email? Or both?
   - Impact: Affects security and user experience
   - Recommendation: Specify both (per-IP for brute force, per-email for abuse)

3. **Vague Requirement: "Fast Response"**
   - Location: Spec.md, Success Criteria
   - Question: What does "fast response time" mean? No metric specified.
   - Impact: Cannot verify if requirement met
   - Recommendation: Add specific metric (e.g., "< 500ms for 95% of requests")

4. **Missing Context: Email Verification**
   - Location: Spec.md, User Stories
   - Question: Is email verification required before first login, or optional?
   - Impact: Affects UX and security model
   - Recommendation: Clarify requirement (recommend: optional but send email)

5. **Unclear Priority: Feature Scope**
   - Location: Spec.md, User Stories
   - Question: Are P2 and P3 stories required for MVP, or truly optional?
   - Impact: Affects implementation timeline and scope
   - Recommendation: Clarify if MVP = P1 only or includes P2

### 📋 Implementation Feasibility Concerns

1. **Complexity: Over-Engineered Solution**
   - Location: Design.md, Architecture Overview
   - Issue: Microservices architecture for simple auth feature
   - Concern: Adds complexity without clear benefit
   - Recommendation: Consider monolithic approach for MVP, refactor later if needed

2. **Missing Detail: Deployment Strategy**
   - Location: Design.md, Deployment Architecture
   - Issue: No deployment strategy specified
   - Concern: Unclear how to deploy and scale
   - Recommendation: Add deployment section with strategy

3. **Timeline: Unrealistic Estimates**
   - Location: Tasks.md, Task breakdown
   - Issue: 50 tasks estimated at 2 days total
   - Concern: Average 1 hour per task seems optimistic
   - Recommendation: Review estimates, add buffer time

### ✅ Good Practices Found

- ✓ Comprehensive error handling strategy defined
- ✓ Security considerations well thought out
- ✓ Database schema properly normalized
- ✓ API versioning strategy included
- ✓ Test scenarios defined for each user story
```

### Step 4: Review Findings

Display categorized issues combining format validation, consistency checks, and deep accuracy review:

```markdown
╔════════════════════════════════════════════════╗
║     Comprehensive Plan Review Results          ║
╚════════════════════════════════════════════════╝

📋 FORMAT VALIDATION RESULTS

🔴 Format Errors (2)
Issues that prevent proper parsing or template compliance:

1. Tasks Missing TaskIDs
   - 3 tasks found without [T001] format
   - Lines: 45, 67, 89
   - Action: Add TaskIDs to all tasks

2. Spec Missing Required Section
   - Missing "Success Criteria" section
   - Action: Add Success Criteria section to spec

🟡 Format Warnings (3)
Issues that may cause confusion but don't block parsing:

1. TaskID Sequence Gap
   - Expected T003, found T005
   - Action: Renumber tasks sequentially

2. Vague Success Criteria
   - "Fast response time" lacks metric
   - Action: Add specific metric (e.g., "< 200ms")

3. Missing Mermaid Diagram
   - Tasks file lacks dependency visualization
   - Action: Add mermaid diagram (recommended)

🟢 Format Good (8)
Things that follow templates correctly:

✓ All tasks have proper TaskID format
✓ Spec has all required sections
✓ User stories follow proper format
✓ Tasks have file paths specified
[... more format successes ...]

═══════════════════════════════════════════════════

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

🔍 ACCURACY REVIEW RESULTS

🔴 Critical Errors (3)
Logical errors, contradictions, or issues that will cause failures:

1. Security: Missing Authentication
   - POST /api/users endpoint has no authentication requirement
   - Impact: Security vulnerability
   - Fix: Add authentication middleware requirement

2. Logic Error: Circular Dependency
   - T017 depends on T019, T019 depends on T017
   - Impact: Cannot determine implementation order
   - Fix: Break circular dependency

3. Data Integrity: Missing Transaction
   - User creation and email sending not in transaction
   - Impact: Inconsistent state possible
   - Fix: Wrap in transaction or use compensating action

🟡 Gotchas (5)
Common pitfalls and potential issues:

1. Performance: Missing Index
   - users.email queried frequently but no index
   - Impact: Slow queries as user base grows
   - Fix: Add index on users.email

2. Error Handling: Missing Retry Logic
   - Email sending has no retry strategy
   - Impact: Transient failures cause permanent failures
   - Fix: Add exponential backoff retry

3. Edge Case: Missing Null Handling
   - Password reset doesn't specify behavior if user doesn't exist
   - Impact: Information leakage possible
   - Fix: Always return success, don't reveal existence

4. Security: Information Leakage
   - Login errors reveal if email exists
   - Impact: Email enumeration attack possible
   - Fix: Use generic error message

5. Data Integrity: Race Condition
   - Two simultaneous registrations with same email not handled
   - Impact: Duplicate users possible
   - Fix: Add unique constraint + handle duplicate key error

🟢 Clarifying Questions (5)
Ambiguities needing clarification:

1. Session Expiration: 24 hours from creation or inactivity?
2. Rate Limiting: Per-IP, per-email, or both?
3. "Fast Response": What metric? (recommend: "< 500ms for 95%")
4. Email Verification: Required before login or optional?
5. Feature Scope: Are P2/P3 required for MVP or optional?

📋 Implementation Feasibility (3 concerns)

1. Complexity: Microservices for simple auth may be over-engineered
2. Missing Detail: No deployment strategy specified
3. Timeline: 50 tasks in 2 days seems optimistic

═══════════════════════════════════════════════════
Summary: 
- Format: 2 errors, 3 warnings, 8 good
- Consistency: 3 critical, 5 warnings, 12 good
- Accuracy: 3 critical errors, 5 gotchas, 5 clarifying questions, 3 feasibility concerns
═══════════════════════════════════════════════════

Recommendation: Fix format errors, critical consistency issues, and critical accuracy errors before implementation. Address gotchas and clarifying questions to prevent issues during development.
```

### Step 5: Address Accuracy Review Issues

**Priority Order for Fixing Issues**:
1. **Format errors first** (blocks proper parsing of consistency checks)
2. **Critical consistency issues** (missing tasks, circular dependencies)
3. **Critical accuracy errors** (security vulnerabilities, logical errors)
4. **Warnings** (recommended fixes, may cause confusion)
5. **Gotchas** (common pitfalls, should address)
6. **Clarifying questions** (ambiguities, need answers)

For each critical error and gotcha identified, provide actionable fixes:

```markdown
Fix Accuracy Issue #1: Missing Authentication

**Problem**: POST /api/users endpoint has no authentication requirement

**Location**: Design.md, API Contracts section, Line 234

**Impact**: 
- Security vulnerability: Anyone can create users
- Violates security best practices
- Could lead to spam accounts

**Solution**:
1. Add authentication middleware requirement to endpoint
2. Update API contract to show "Authentication: Required"
3. Add to security considerations section

**Implementation**:
Update design.md:
```markdown
### Endpoint: POST /api/users

**Authentication**: Required (Bearer token or session cookie)
**Authorization**: Admin role required
```

Apply this fix? [yes/no/manual]
```

For clarifying questions, present options:

```markdown
Clarifying Question #1: Session Expiration

**Location**: Spec.md, Functional Requirements, Line 45

**Question**: "Session expires after 24 hours" - is this:
- A) 24 hours from creation (absolute expiration)
- B) 24 hours of inactivity (sliding expiration)
- C) Something else?

**Current State**: Ambiguous, could be interpreted either way

**Impact**: 
- Option A: User logged out even if active
- Option B: User stays logged in if active
- Different security implications

**Recommendation**: Option B (sliding expiration) - better UX, still secure

**Options**:
1. Use recommendation (sliding expiration)
2. Use absolute expiration (24 hours from creation)
3. Specify custom behavior
4. Skip for now

Your choice? [1/2/3/4]
```

### Step 6: Fix Format Issues

**Priority Rationale**: Address format validation errors first because they may prevent proper parsing of consistency checks. If format is wrong, consistency checks may fail or produce incorrect results.

Address format validation errors first (they may affect consistency checks):

```markdown
Fix Format Error #1: Tasks Missing TaskIDs

**Problem**: 3 tasks don't have [T001] format identifiers

**Current state**:
- Line 45: `- [ ] Create user model`
- Line 67: `- [ ] Add authentication endpoint`
- Line 89: `- [ ] Write tests`

**Impact**: Cannot track tasks, breaks dependency validation

**Solution**:
1. Assign sequential TaskIDs starting from next available number
2. Update format to: `- [ ] [T045] Create user model`
3. Update any dependencies that reference these tasks

**Implementation**:
- T045: Create user model
- T046: Add authentication endpoint  
- T047: Write tests

Apply this fix? [yes/no/manual]
```

If user says "yes", update the tasks file with proper TaskIDs.

### Step 7: Fix Critical Issues

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

### Step 8: Fix Warnings

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

### Step 9: Update Agents.md (If Patterns Found)

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

### Step 10: Generate Consistency Report

Create detailed report file:

```bash
bash .cursor/scripts/generate-consistency-report.sh "docs/specs/[feature-name]/spec.md"
```

This creates `docs/specs/[feature-name]/consistency-report.md` with:
- Format validation results (errors, warnings, good)
- Consistency check results (critical, warnings, good)
- Accuracy review results (critical errors, gotchas, clarifying questions, feasibility concerns)
- Recommended fixes for all issues
- Diff snippets showing what to change
- Rerun instructions

### Step 11: Final Summary

**Analysis Completion Criteria** (analysis is complete when):
- [ ] All format errors identified and categorized
- [ ] All consistency issues identified and categorized (critical, warnings, good)
- [ ] All accuracy issues identified and categorized (critical errors, gotchas, questions, feasibility)
- [ ] All issues have actionable fixes (specific location, clear solution)
- [ ] Report generated with all findings

```markdown
✅ Consistency & Format Analysis Complete

📊 Format Validation Results:
- Format Errors: 2 (must fix - blocks proper parsing)
- Format Warnings: 3 (recommended to fix)
- Format Good: 8 (follows templates correctly)

📊 Consistency Check Results:
- Critical Issues: 3 (must fix before implementation)
- Warnings: 5 (recommended to fix)
- Good: 12 (consistent and correct)

📊 Accuracy Review Results:
- Critical Errors: 3 (must fix - logical errors, security issues)
- Gotchas: 5 (should address - common pitfalls)
- Clarifying Questions: 5 (need answers - ambiguities)
- Feasibility Concerns: 3 (review - implementation concerns)

📝 Actions Taken:
- Fixed 2 format errors automatically
- Fixed 2 critical consistency issues automatically
- Fixed 2 critical accuracy errors automatically
- Resolved 3 clarifying questions
- Generated comprehensive report
- Added 1 learning to agents.md

📄 Report: docs/specs/[feature-name]/consistency-report.md

🎯 Next Steps:
1. Review remaining format issues (if any)
2. Review remaining critical consistency issues
3. Review remaining critical accuracy errors and gotchas
4. Answer remaining clarifying questions
5. Address feasibility concerns
6. Fix manually or with appropriate commands
7. Re-run /analyze-consistency to verify
8. Proceed with implementation

💡 Tip: Run this before starting implementation and after major design changes. 
- Format validation ensures documents follow templates
- Consistency checks ensure documents align with each other
- Accuracy review catches logical errors, gotchas, and ambiguities that cause problems during implementation
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

### Common Format Issues

**Format Errors (Must Fix)**:
1. **Missing TaskIDs**: Tasks without [T001] format cannot be tracked
2. **Missing Required Sections**: Spec or tasks missing mandatory sections
3. **Invalid Task Format**: Tasks don't follow format defined in `.cursor/templates/task-format.md` (expected: `- [ ] [TaskID] [P?] [Story?] [RESEARCH?] Description with file path` and required sections)
4. **TaskID Gaps**: Non-sequential TaskIDs break dependency tracking
5. **Implementation Details in Spec**: Technology choices belong in design, not spec

**Format Warnings (Should Fix)**:
1. **Vague Metrics**: Success criteria lack specific measurements
2. **Missing File Paths**: Tasks don't specify which files to modify
3. **Missing Mermaid Diagram**: No visual dependency graph
4. **Placeholder Markers**: TODO/TBD items should be resolved
5. **User Story Format**: Stories don't follow "As a...I want...so that" pattern

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

**Format Fixes**:
- ✅ Adding TaskIDs to tasks missing them
- ✅ Fixing task numbering sequences
- ✅ Updating task format to match template
- ✅ Adding missing required section headers

**Consistency Fixes**:
- ✅ Adding missing task references
- ✅ Updating MVP definitions
- ✅ Syncing acceptance criteria
- ✅ Fixing task dependency references

**Cannot Automatically Fix**:
- ❌ Creating entirely new tasks (use /add-story)
- ❌ Designing missing components (use /design-system)
- ❌ Resolving architectural conflicts (manual review needed)
- ❌ Rewriting vague requirements (manual clarification needed)

### Handling False Positives

Sometimes the tool flags non-issues:

```markdown
Issue: "Success criterion 'Users complete registration in <2 min' not addressed"

Why it's flagged: No task explicitly mentions this metric

Why it's actually fine: This is a performance requirement tested at the end

Action: Mark as "Understood - will verify in testing phase"
```

**Skip Checks Flag**: Add `--skip-checks` flag to suppress specific checks on re-run.

**Available checks to skip** (if you know a check is a false positive):
- `--skip-checks=format` (skip format validation)
- `--skip-checks=consistency` (skip consistency checks)
- `--skip-checks=accuracy` (skip accuracy review)
- `--skip-checks=security` (skip security gotchas)
- `--skip-checks=performance` (skip performance gotchas)

**When to use**: Only if you've verified the check is a false positive. Most issues should be fixed, not skipped.

## Context

Feature specification path: $ARGUMENTS

**Important**: This command reads only, never writes (except with explicit user approval). It's safe to run frequently.

**Format vs Consistency vs Accuracy**: 
- **Format validation**: Ensures documents follow template structure (required sections, proper syntax, etc.)
- **Consistency validation**: Ensures documents align with each other (requirements have tasks, design matches spec, etc.)
- **Accuracy review**: Analyzes content for logical errors, gotchas, security issues, performance problems, and ambiguities

All three are important:
- Format errors can prevent proper parsing
- Consistency errors indicate missing or misaligned content
- Accuracy issues cause problems during implementation (security vulnerabilities, performance problems, bugs)
