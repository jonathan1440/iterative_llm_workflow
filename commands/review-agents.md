---
description: Automated review and maintenance of agents.md to identify patterns, mistakes, and optimization opportunities from project history.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command analyzes project history (git commits, completed tasks, agents.md evolution) to identify patterns worth capturing as learnings and mistakes to document for future prevention.

### Step 1: Load Current agents.md

```bash
bash .cursor/scripts/load-agents.sh
```

The script will:
- Verify `.cursor/agents.md` exists
- Display current learning count
- Show recent additions
- Output file path

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
Add to agents.md:

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

Add this learning? [yes/no]
```

### Step 4: Identify Duplicate Knowledge

Check for redundant entries in agents.md:

```markdown
## Duplicate Detection

Found potential duplicates:

**Entry #1 (Added: 2026-01-05)**
Title: "Don't use var in JavaScript"
Content: Prefer const/let over var for block scoping

**Entry #2 (Added: 2026-01-10)**  
Title: "Use const/let instead of var"
Content: var has function scope issues, use const/let

**Recommendation**: Merge into single entry with complete rationale

**Entry #3 (Added: 2026-01-08)**
Title: "Always validate user input"
Content: Validate all inputs for security

**Entry #4 (Added: 2026-01-11)**
Title: "Input validation prevents injection"  
Content: Check user input to prevent SQL injection

**Recommendation**: Merge and expand with specific examples

Merge duplicates? [yes/review/no]
```

### Step 5: Suggest Missing Learnings

Based on project patterns, suggest additions:

```markdown
## Suggested Learnings

**From Pattern Analysis:**

1. Database Migration Pattern (Detected: Used 8 times consistently)
   
   **Suggested entry**:
   ```markdown
   ## Database Migration Pattern
   
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
   
   Add this? [yes/edit/no]

2. Error Response Format (Detected: Used consistently in 15 endpoints)
   
   **Suggested entry**:
   ```markdown
   ## API Error Response Format
   
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
   
   Add this? [yes/edit/no]
```

### Step 6: Organize and Categorize

Review agents.md structure:

```markdown
## Organization Review

**Current Structure:**
- 47 learnings
- Categories: Code Standards (18), Architecture (12), Mistakes (17)
- Uncategorized: 8 entries

**Recommendations:**

1. **Add new category**: "Testing Best Practices"
   - Move 6 entries from Code Standards
   - Add 2 new entries from recent patterns

2. **Reorganize Mistakes section**
   - Subcategories: Security, Performance, Architecture
   - Currently flat list of 17 items

3. **Archive old learnings**
   - 3 entries about deprecated libraries
   - Move to "Archive" section at bottom

Apply reorganization? [yes/review/no]
```

### Step 7: Quality Check Existing Entries

Validate all current learnings:

```markdown
## Quality Checks

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

Review and fix? [yes/skip]
```

### Step 8: Generate Review Report

Create comprehensive report:

```bash
bash .cursor/scripts/generate-agents-review.sh
```

Creates `.cursor/agents-review-[date].md`:

```markdown
# agents.md Review Report
Date: 2026-01-13

## Summary
- Total Learnings: 47
- Patterns Detected: 8 new
- Duplicates Found: 4 pairs
- Quality Issues: 6 entries
- Suggested Additions: 8 new learnings

## Actions Taken
✅ Added 3 new learnings from git patterns
✅ Merged 2 duplicate entries
✅ Fixed 4 incomplete entries
✅ Reorganized into 5 categories
⏭️  Archived 3 outdated entries

## Patterns Worth Capturing
1. Database migration naming convention
2. API error response format
3. Test file organization
[... more patterns ...]

## Recommendations
1. Review "Testing Best Practices" section monthly
2. Archive learnings older than 1 year if unused
3. Add examples to vague entries

## Next Review: 2026-02-13 (30 days)
```

### Step 9: Commit Changes

If changes were made to agents.md:

```bash
git diff .cursor/agents.md
```

Show changes and confirm commit:

```markdown
## Changes to agents.md

Added:
+ 3 new learnings (database migrations, error responses, test org)
+ 2 examples to existing entries

Merged:
- 2 duplicate entries → 1 comprehensive entry

Fixed:
- 4 incomplete rationales
- 1 outdated Python version reference

Reorganized:
- Created "Testing Best Practices" category
- Moved 6 entries to better categories

Commit these changes? [yes/edit/no]

Suggested commit message:
"Update agents.md: Add patterns from recent development

- Add database migration naming convention
- Add API error response format
- Merge duplicate input validation entries
- Fix incomplete rationales
- Reorganize into clearer categories"
```

## Guidelines

### What to Capture in agents.md

**Good learnings** (should be added):
- Repeated patterns used 3+ times
- Mistakes made 2+ times
- Team decisions on ambiguous issues
- Project-specific conventions
- Hard-won architectural insights

**Bad learnings** (don't add):
- One-off solutions
- Language fundamentals (e.g., "use semicolons in JS")
- Library documentation rewrites
- Personal preferences without rationale
- Overly specific solutions

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

### Organizing agents.md

**Recommended structure**:
```markdown
# agents.md

## Project Overview
[Context about project]

## Code Standards
[Language/framework conventions]

## Architecture Principles
[High-level design decisions]

## Implementation Best Practices
[How to implement features]

## Common Mistakes
[Things that went wrong]

## Testing Guidelines
[How we test]

## Deployment Process
[How we ship]

## Archive
[Outdated but historically important]
```

### Automation Opportunities

Set up automated review reminders:

```bash
# In .cursor/scripts/monthly-review.sh
if [ "$(date +%d)" -eq "01" ]; then
    echo "🔔 Monthly agents.md review due"
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
# Then start new feature with clean agents.md
```

**During retrospectives**:
```bash
/review-agents  # Generate review report
# Discuss in team meeting
```

## Context

Git analysis depth: Last 90 days (default), or specify with `--days=N`

**Important**: This command suggests changes but requires user approval. It never auto-commits to agents.md without confirmation.
