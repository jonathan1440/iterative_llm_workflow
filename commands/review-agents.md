---
description: Automated review and maintenance of all agent documentation (agents.md and agent-docs/) to identify patterns, mistakes, and optimization opportunities from project history.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command analyzes project history (git commits, completed tasks, documentation evolution) to identify patterns worth capturing as learnings and mistakes to document for future prevention. It routes learnings to the appropriate documentation file:
- **agents.md**: General project standards, principles, and high-level conventions
- **agent-docs/api.md**: API-specific patterns, endpoints, error formats
- **agent-docs/database.md**: Database patterns, migrations, query conventions
- **agent-docs/testing.md**: Testing patterns, frameworks, test organization
- **agent-docs/architecture.md**: Architecture decisions, system design patterns
- **agent-docs/failure-modes.md**: Failure patterns, edge cases, common mistakes

### Step 1: Load All Documentation Files

```bash
bash .cursor/scripts/load-agents.sh
```

The script will:
- Verify `.cursor/agents.md` exists
- Check which agent-docs files exist
- Display current learning count across all files
- Show recent additions
- Output file paths

### Step 2: Analyze Git History

```bash
bash .cursor/scripts/analyze-git-patterns.sh "$ARGUMENTS"
```

The script examines git history for:

#### Pattern Detection
- Repeated fixes (same issue fixed 3+ times → needs systematic solution)
- Common refactors (suggests unclear initial requirements)
- Frequent reverts (indicates rushed decisions)
- Consistent naming patterns (good conventions to document)
- Repeated file structure changes (suggests better organization needed)

#### Mistake Detection  
- Committed secrets/keys (security issue)
- Broken migrations (database pattern issue)
- Test failures in main branch (CI/CD gap)
- Large files committed then removed (git practice issue)
- Circular dependencies introduced (architecture issue)

#### Success Patterns
- Consistent test coverage (good practice to continue)
- Clean commit messages (document the template)
- Modular file organization (capture the pattern)
- Effective error handling (extract the pattern)

### Step 3: Review Completed Tasks

Analyze tasks from tasks files:

```markdown
## Analyzing Completed Tasks

Checking: docs/specs/*/tasks.md and docs/specs/*-tasks.md (for backward compatibility)

**Pattern: Missing Verification Steps**
Found: 12 tasks completed without explicit verification checkpoints

Examples:
- T023: "Create PasswordReset model" - No verification mentioned
- T045: "Add email service" - No test written
- T087: "Implement rate limiting" - No validation done

**Recommendation**: 
Route to appropriate file based on content:

**For general implementation practices** → `agents.md`:
```markdown
## Implementation Best Practices

**Always include verification checkpoint in task completion**
- Mistake: Marking tasks complete without verification
- Why wrong: Can't prove it works, may have subtle bugs
- Correct: Every task completion includes:
  1. Manual test OR automated test
  2. Verification output/screenshot
  3. Edge cases considered
- Rationale: Prevents "it worked for me" bugs
- Added: 2026-01-13
```

**For testing-specific patterns** → `agent-docs/testing.md`:
```markdown
## Task Verification

**Always write tests before marking tasks complete**
- Pattern: Every implementation task should have corresponding test
- Rationale: Prevents "it worked for me" bugs
- Added: 2026-01-13
```

Add to which file? [agents.md/testing.md/both/skip]
```

### Step 4: Identify Duplicate Knowledge

Check for redundant entries across all documentation files:

```markdown
## Duplicate Detection

**Within agents.md:**

**Entry #1 (Added: 2026-01-05)**
Title: "Don't use var in JavaScript"
Content: Prefer const/let over var for block scoping

**Entry #2 (Added: 2026-01-10)**  
Title: "Use const/let instead of var"
Content: var has function scope issues, use const/let

**Recommendation**: Merge into single entry with complete rationale

**Across files:**

**agents.md (Added: 2026-01-08)**
Title: "Always validate user input"
Content: Validate all inputs for security

**agent-docs/api.md (Added: 2026-01-11)**
Title: "Input validation prevents injection"  
Content: Check user input to prevent SQL injection

**Recommendation**: 
- Keep general principle in agents.md
- Keep API-specific details in agent-docs/api.md
- Add cross-reference between files

**agent-docs/failure-modes.md (Added: 2026-01-12)**
Title: "SQL Injection via unvalidated input"
Content: Always validate user input to prevent SQL injection

**Recommendation**: 
- This is a failure mode, belongs in failure-modes.md
- Remove from agents.md (too specific)
- Add reference in agent-docs/api.md

Merge/route duplicates? [yes/review/no]
```

### Step 5: Suggest Missing Learnings

Based on project patterns, suggest additions and route to appropriate files:

```markdown
## Suggested Learnings

**From Pattern Analysis:**

1. Database Migration Pattern (Detected: Used 8 times consistently)
   
   **Route to**: `agent-docs/database.md`
   
   **Suggested entry**:
   ```markdown
   ## Migration Naming Convention
   
   **Our Standard Approach**
   - Location: src/migrations/YYYYMMDD_description.sql
   - Naming: Timestamp + snake_case description
   - Content: Always include:
     1. -- Migration: [description]
     2. -- Date: YYYY-MM-DD
     3. Forward migration
     4. Rollback commands (commented)
   - Rationale: Consistent, timestamps prevent conflicts
   - Added: 2026-01-13
   ```
   
   Add to agent-docs/database.md? [yes/edit/no]

2. Error Response Format (Detected: Used consistently in 15 endpoints)
   
   **Route to**: `agent-docs/api.md`
   
   **Suggested entry**:
   ```markdown
   ## Error Response Format
   
   **Standard JSON error structure**
   ```json
   {
     "error": {
       "code": "VALIDATION_ERROR",
       "message": "Human-readable message",
       "details": {
         "field": "email",
         "issue": "Invalid format"
       }
     }
   }
   ```
   - Always include: code, message
   - Optional: details object for field-specific errors
   - Rationale: Consistent error handling across API
   - Added: 2026-01-13
   ```
   
   Add to agent-docs/api.md? [yes/edit/no]

3. Repeated Database Connection Failures (Detected: Fixed 3 times)
   
   **Route to**: `agent-docs/failure-modes.md`
   
   **Suggested entry**:
   ```markdown
   ## Database Connection Failures
   
   **Failure**: Database connection pool exhaustion
   
   **What happens:**
   - Application hangs on database queries
   - Error: "too many connections"
   - Occurs during high load
   
   **Why it fails:**
   - Connection pool not sized correctly
   - Connections not properly released
   - No connection timeout configured
   
   **How to prevent:**
   - Size pool based on expected load (default: 10 connections)
   - Always use try/finally to release connections
   - Set connection timeout (default: 30s)
   - Monitor pool usage metrics
   
   **Example:**
   ```typescript
   // ❌ Bad: No connection management
   const result = await db.query('SELECT * FROM users');
   
   // ✅ Good: Proper connection handling
   const connection = await pool.getConnection();
   try {
     const result = await connection.query('SELECT * FROM users');
     return result;
   } finally {
     connection.release();
   }
   ```
   
   **Related patterns:**
   - See `agent-docs/database.md` for connection pool configuration
   
   - Added: 2026-01-13
   ```
   
   Add to agent-docs/failure-modes.md? [yes/edit/no]

4. General Testing Principle (Detected: Consistent test coverage)
   
   **Route to**: `agents.md` (general principle)
   
   **Suggested entry**:
   ```markdown
   ## Testing Standards
   
   **Always write tests for new features**
   - Minimum: Integration tests for API endpoints
   - Unit tests for complex business logic
   - Rationale: Prevents regressions, documents expected behavior
   - Added: 2026-01-13
   ```
   
   Add to agents.md? [yes/edit/no]
```

### Step 6: Organize and Categorize

Review structure across all documentation files:

```markdown
## Organization Review

**Current Structure:**
- agents.md: 47 learnings
  - Categories: Code Standards (18), Architecture (12), Mistakes (17)
  - Uncategorized: 8 entries
- agent-docs/api.md: 12 patterns
- agent-docs/database.md: 8 patterns
- agent-docs/testing.md: 6 patterns
- agent-docs/architecture.md: 5 patterns
- agent-docs/failure-modes.md: 3 failure modes

**Recommendations:**

1. **Move domain-specific content from agents.md:**
   - 6 API patterns → agent-docs/api.md
   - 4 database patterns → agent-docs/database.md
   - 5 testing patterns → agent-docs/testing.md
   - 3 failure modes → agent-docs/failure-modes.md
   - Keep only general principles in agents.md

2. **Reorganize failure-modes.md:**
   - Add categories: Authentication, Database, API Integration
   - Currently flat list of 3 items

3. **Archive old learnings**
   - 3 entries about deprecated libraries (agents.md)
   - Move to "Archive" section at bottom

4. **Add cross-references:**
   - Link failure modes to related patterns in other files
   - Link API patterns to failure modes that apply

Apply reorganization? [yes/review/no]
```

### Step 7: Quality Check Existing Entries

Validate all current learnings across all files:

```markdown
## Quality Checks

**agents.md:**

**Incomplete Entries (Missing Rationale):**
Entry: "Don't use nested ternaries"
└─ Missing: Why this is a problem, what to use instead
└─ Fix: Add rationale and alternative

**Vague Entries (Need Examples):**
Entry: "Keep functions small"
└─ Missing: How small? What's the metric?
└─ Fix: Add specific guideline (e.g., "<20 lines typically")

**Outdated Entries:**
Entry: "Use Python 3.8 features"
└─ Issue: We're now on Python 3.11
└─ Fix: Update or archive

**agent-docs/failure-modes.md:**

**Incomplete Failure Modes:**
Entry: "Database connection issues"
└─ Missing: What happens, why it fails, how to prevent
└─ Fix: Add complete failure mode structure

**Missing Examples:**
Entry: "SQL injection vulnerability"
└─ Missing: Code examples showing bad vs good
└─ Fix: Add code examples

**agent-docs/api.md:**

**Missing Error Handling:**
Entry: "Rate limiting pattern"
└─ Missing: What happens when rate limit exceeded
└─ Fix: Add error response format

**agent-docs/database.md:**

**Vague Patterns:**
Entry: "Use transactions"
└─ Missing: When to use, examples
└─ Fix: Add specific use cases and examples

Review and fix? [yes/skip]
```

### Step 8: Generate Review Report

Create comprehensive report across all documentation:

```bash
bash .cursor/scripts/generate-agents-review.sh
```

Creates `.cursor/agents-review-[date].md`:

```markdown
# Agent Documentation Review Report
Date: 2026-01-13

## Summary
- Total Learnings: 81 (across all files)
- Files Reviewed: 6
  - agents.md: 47 learnings
  - agent-docs/api.md: 12 patterns
  - agent-docs/database.md: 8 patterns
  - agent-docs/testing.md: 6 patterns
  - agent-docs/architecture.md: 5 patterns
  - agent-docs/failure-modes.md: 3 failure modes
- Patterns Detected: 12 new
- Duplicates Found: 6 pairs (2 within files, 4 across files)
- Quality Issues: 8 entries
- Suggested Additions: 10 new learnings

## Actions Taken

**agents.md:**
✅ Added 2 new learnings from git patterns
✅ Merged 2 duplicate entries
✅ Moved 6 domain-specific entries to agent-docs/
✅ Fixed 3 incomplete entries
✅ Reorganized into 5 categories
⏭️  Archived 3 outdated entries

**agent-docs/api.md:**
✅ Added 1 new pattern (error response format)
✅ Fixed 1 missing error handling section

**agent-docs/database.md:**
✅ Added 1 new pattern (migration naming)
✅ Added 2 examples to vague entries

**agent-docs/failure-modes.md:**
✅ Added 2 new failure modes (connection pool, SQL injection)
✅ Added 3 code examples
✅ Organized into categories

**Cross-file improvements:**
✅ Added cross-references between related patterns
✅ Removed duplicates across files

## Patterns Worth Capturing
1. Database migration naming convention → agent-docs/database.md
2. API error response format → agent-docs/api.md
3. Test file organization → agent-docs/testing.md
4. Connection pool exhaustion → agent-docs/failure-modes.md
[... more patterns ...]

## File-Specific Recommendations

**agents.md:**
- Review "Testing Best Practices" section monthly
- Keep only general principles (move specifics to agent-docs/)

**agent-docs/failure-modes.md:**
- Add more failure modes as discovered
- Include code examples for each failure mode
- Link to related patterns in other files

**agent-docs/api.md:**
- Document all error response formats
- Add rate limiting failure modes

## Next Review: 2026-02-13 (30 days)
```

### Step 9: Commit Changes

If changes were made to any documentation files:

```bash
git diff .cursor/agents.md .cursor/agent-docs/*.md
```

Show changes and confirm commit:

```markdown
## Changes Summary

**agents.md:**
Added:
+ 2 new learnings (general testing principle, code standards)
+ 1 example to existing entry

Moved:
- 6 domain-specific entries → appropriate agent-docs files

Merged:
- 2 duplicate entries → 1 comprehensive entry

Fixed:
- 3 incomplete rationales
- 1 outdated Python version reference

**agent-docs/api.md:**
Added:
+ 1 new pattern (error response format)

Fixed:
- 1 missing error handling section

**agent-docs/database.md:**
Added:
+ 1 new pattern (migration naming convention)
+ 2 examples to vague entries

**agent-docs/failure-modes.md:**
Added:
+ 2 new failure modes (connection pool exhaustion, SQL injection)
+ 3 code examples

Organized:
- Created categories: Database, API Integration

**Cross-file:**
- Added cross-references between related patterns
- Removed 4 duplicate entries across files

Commit these changes? [yes/edit/no]

Suggested commit message:
"Update agent documentation: Add patterns and route to appropriate files

- Add database migration naming to agent-docs/database.md
- Add API error response format to agent-docs/api.md
- Add 2 failure modes to agent-docs/failure-modes.md
- Move domain-specific content from agents.md to agent-docs/
- Merge duplicate entries across files
- Add cross-references between related patterns
- Fix incomplete entries and add examples"
```

## Guidelines

### Routing Learnings to Appropriate Files

**Route to agents.md** (general principles):
- Project-wide standards and conventions
- High-level architectural decisions
- General coding principles
- Team decisions on ambiguous issues
- Cross-cutting concerns

**Route to agent-docs/api.md** (API-specific):
- API endpoint patterns
- Request/response formats
- Error response structures
- Authentication/authorization patterns
- Rate limiting approaches
- API versioning strategies

**Route to agent-docs/database.md** (database-specific):
- Schema conventions
- Migration patterns
- Query patterns
- Indexing strategies
- Connection pool configuration
- Transaction patterns

**Route to agent-docs/testing.md** (testing-specific):
- Test organization patterns
- Test framework usage
- Test data management
- Coverage standards
- Test naming conventions

**Route to agent-docs/architecture.md** (architecture-specific):
- System design patterns
- Service communication patterns
- Data flow patterns
- Deployment architecture
- Infrastructure decisions

**Route to agent-docs/failure-modes.md** (failure patterns):
- Common failure scenarios
- Edge cases that cause failures
- Integration failure points
- Silent failures
- Performance failure modes
- Security vulnerabilities
- Data consistency issues
- Environment-specific failures

### What to Capture

**Good learnings** (should be added):
- Repeated patterns used 3+ times
- Mistakes made 2+ times
- Team decisions on ambiguous issues
- Project-specific conventions
- Hard-won architectural insights
- Failure modes discovered during debugging

**Bad learnings** (don't add):
- One-off solutions
- Language fundamentals (e.g., "use semicolons in JS")
- Library documentation rewrites
- Personal preferences without rationale
- Overly specific solutions
- Generic patterns that don't need project-specific documentation

### Review Frequency

**Monthly**: For active projects
**Quarterly**: For maintenance mode  
**After major milestones**: After MVP, releases
**When stuck**: If making same mistake repeatedly

### Handling Controversial Learnings

If a pattern is debatable:

```markdown
## Debatable Pattern: Async vs Sync

**Pattern**: Using async/await everywhere

**Argument For**:
- Consistent code style
- Handles future async needs
- Modern JavaScript standard

**Argument Against**:
- Unnecessary for sync operations
- Adds complexity
- Slightly worse performance

**Our Decision**: Use async only when actually needed

**Rationale**: Clarity over consistency here. Premature async adds mental overhead.

**Review this decision in**: 3 months

Add? [yes/no]
```

### Organizing Documentation

**agents.md structure** (keep general, move specifics to agent-docs/):
```markdown
# agents.md

## Project Overview
[Context about project]

## Code Standards
[General language/framework conventions]

## Architecture Principles
[High-level design decisions]

## Implementation Best Practices
[General implementation guidance]

## Testing Standards
[High-level testing principles - details in agent-docs/testing.md]

## Deployment Process
[How we ship]

## Archive
[Outdated but historically important]
```

**agent-docs/failure-modes.md structure**:
```markdown
# Failure Modes

## Common Failure Patterns
[By category: Authentication, Database, API Integration, etc.]

## Edge Cases
[Edge cases that cause failures]

## Integration Failure Points
[Third-party integrations, services, etc.]

## Silent Failures
[Failures that don't throw errors]

## Performance Failure Modes
[Performance issues that cause failures]

## Security Failure Modes
[Security vulnerabilities]

## Data Consistency Failures
[Race conditions, transaction issues, etc.]

## Environment-Specific Failures
[Dev/staging/prod differences]
```

### Automation Opportunities

Set up automated review reminders:

```bash
# In .cursor/scripts/monthly-review.sh
if [ "$(date +%d)" -eq "01" ]; then
    echo "🔔 Monthly agent documentation review due"
    echo "Run: /review-agents"
fi
```

### Integration with Other Commands

**After major implementation**:
```bash
/implement-story "User Story 3"
# ... complete implementation ...
/review-agents  # Capture learnings while fresh
```

**Before starting new project**:
```bash
/review-agents  # Clean up and organize
# Then start new feature with clean documentation
```

**During retrospectives**:
```bash
/review-agents  # Generate review report
# Discuss in team meeting
```

## Context

Git analysis depth: Last 90 days (default), or specify with `--days=N`

**Important**: 
- This command suggests changes but requires user approval
- It never auto-commits to any documentation files without confirmation
- It routes learnings to the most appropriate file (agents.md or specific agent-docs file)
- It checks for duplicates both within files and across files
- It maintains cross-references between related patterns in different files
