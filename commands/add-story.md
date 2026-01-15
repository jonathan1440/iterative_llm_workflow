---
description: Add a new user story to an existing feature spec while maintaining consistency across spec, design, and tasks files.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command extends an existing feature specification with a new user story, automatically updating the spec, design, and tasks files to maintain consistency.

**Usage Pattern:**
```bash
/add-story docs/specs/[feature-name]/spec.md "New story description"
```

### Step 0: Prerequisites

Verify existing feature files:

```bash
bash .cursor/scripts/check-feature-files.sh "$ARGUMENTS"
```

The script will:
- Extract spec path and story description
- Verify spec, design, and tasks files exist
- Count existing user stories
- Determine next story number
- Output file paths and story ID

### Step 1: Create Story Specification

Load current spec and add new story section:

```markdown
**Load into context:**
- Existing spec: docs/specs/[feature-name]/spec.md
- Existing design: docs/specs/[feature-name]/design.md
- Existing tasks: docs/specs/[feature-name]/tasks.md
- Project standards: .cursor/agents.md
- Architecture patterns: .cursor/agent-docs/architecture.md (if exists)
- Failure modes: .cursor/agent-docs/failure-modes.md (if exists, for avoiding common mistakes)

Based on the new story description: "$STORY_DESCRIPTION"

Create a new user story following the pattern of existing stories:
```

Generate new story using spec format:

```markdown
### User Story [N]: [Story Title]

**Priority**: P[1/2/3]

**As a** [specific user persona]  
**I want** [specific action]  
**So that** [specific benefit]

**Acceptance Criteria:**
1. [Specific, testable criterion]
2. [Another specific criterion]
3. [...]

**Value**: [Why this story matters]

**Scope**: [What's included vs excluded]

**Dependencies**: [Which existing stories this depends on]
```

### Step 2: Update Design for New Story

Load existing design and extend it:

```markdown
**Prompt for Composer Mode:**

Based on:
- New user story specification
- Existing design: docs/specs/[feature-name]/design.md
- Existing architecture

Extend the design document with:

1. **New Database Schema Changes** (if any)
   - New tables
   - New columns on existing tables
   - New indexes
   - Migration strategy

2. **New API Endpoints** (if any)
   - Routes
   - Request/response formats
   - Authentication requirements

3. **Service Layer Changes**
   - New services
   - Modifications to existing services

4. **Integration Points**
   - How this story integrates with existing stories
   - Shared components
   - Data flow

5. **Updated Architecture Diagram** (if significant changes)

**Important**: Maintain consistency with existing design patterns.
```

Display changes:

```markdown
## Design Changes for User Story [N]

### Database Changes

**New Table: user_preferences**
```sql
CREATE TABLE user_preferences (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    preference_key VARCHAR(100) NOT NULL,
    preference_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);
```

**Modified Table: users**
- Add column: `has_preferences BOOLEAN DEFAULT FALSE`

### API Endpoints

**GET /api/users/:id/preferences**
```json
Response:
{
  "preferences": {
    "theme": "dark",
    "notifications": "enabled",
    "language": "en"
  }
}
```

**PUT /api/users/:id/preferences**
```json
Request:
{
  "preference_key": "theme",
  "preference_value": "dark"
}

Response:
{
  "success": true,
  "preference": {
    "key": "theme",
    "value": "dark"
  }
}
```

Apply these changes to design file? [yes/edit/no]
```

### Step 3: Generate Task Breakdown

Create tasks for the new story:

```markdown
**Load into Plan Mode:**
- New user story specification
- Updated design
- Existing tasks: docs/specs/[feature-name]/tasks.md

Generate task breakdown following existing pattern:

## Phase [N]: User Story [N] - [Story Title] (P[1/2/3])

**Goal**: [What this story accomplishes]

**Tasks:**

- [ ] T[XXX]: [Task description] (file path)
  - Depends on: [Previous tasks]
  - [Details about what to implement]

- [ ] T[XXX]: [Next task]
  - [P] Can run in parallel with T[XXX]

[... more tasks ...]

**Independent Test Scenario:**
[Describe how to test this story independently]

**Acceptance Verification:**
- [ ] [Criterion 1] verified
- [ ] [Criterion 2] verified
[... all acceptance criteria ...]

**Story Complete When:**
- All tasks checked
- All acceptance criteria verified
- Independent test passes
```

Display task preview:

```markdown
## Task Breakdown for User Story [N]

Phase 7: User Story [N] - User Preferences (P2)

**Goal**: Allow users to customize their experience preferences

**Tasks:** (14 total)

Foundation:
- [ ] T082: Create UserPreference model (src/models/user_preference.py)
  - Depends on: T015 (User model)
  
- [ ] T083: Add migration for user_preferences table (src/migrations/)
  - Depends on: T082

Core Implementation:
- [ ] T084: Create preference service (src/services/preference_service.py)
  - Depends on: T083
  
- [ ] T085: Add GET /preferences endpoint (src/routes/preferences.py)
  - Depends on: T084

- [ ] T086: Add PUT /preferences endpoint (src/routes/preferences.py)
  - [P] Can run in parallel with T085

[... more tasks ...]

**Independent Test Scenario:**
```bash
# Test user preferences
1. Create test user
2. Set preference: theme=dark
3. Verify GET /preferences returns theme=dark
4. Update preference: theme=light
5. Verify change persisted
```

**Acceptance Verification:**
- [ ] Users can set custom preferences
- [ ] Preferences persist across sessions
- [ ] Default preferences applied to new users

Add these tasks to tasks file? [yes/edit/no]
```

### Step 4: Update Task Numbering

Renumber subsequent tasks if needed:

```bash
bash .cursor/scripts/renumber-tasks.sh "[tasks-file]" "[start-from]"
```

```markdown
## Task Renumbering

Inserting 14 new tasks at T082

Tasks renumbered:
- Old T082 → New T096
- Old T083 → New T097
[... up to end of file ...]

Total tasks: 67 (was 53, added 14)

Apply renumbering? [yes/no]
```

### Step 5: Update MVP Definition (If Applicable)

If the new story affects MVP:

```markdown
## MVP Impact Assessment

**Current MVP**: User Story 1 (User Authentication)

**New Story**: User Story 4 (User Preferences)  
**Priority**: P2 (not MVP)

**Question**: Should this story be part of MVP?

Consider:
- Critical for launch? No
- Blocks other stories? No
- User expects it? Nice-to-have
- Technical dependency? No

**Recommendation**: Keep as P2 (post-MVP)

**Alternative**: If needed for MVP, update:
1. Story priority: P2 → P1
2. MVP definition in spec
3. Task phase organization

Adjust MVP scope? [yes/no/undecided]
```

### Step 6: Run Consistency Check

Automatically verify consistency:

```bash
bash .cursor/scripts/check-consistency.sh "docs/specs/[feature-name]/spec.md"
```

```markdown
## Consistency Check Results

✅ New story has complete task breakdown
✅ All database changes have migration tasks
✅ All API endpoints have implementation tasks
✅ Task dependencies are valid
⚠️  Warning: New story adds 6 hours to timeline

**Recommendation**: Consistency maintained. Safe to proceed.
```

### Step 7: Update Estimates

Recalculate project timeline:

```markdown
## Updated Project Estimates

**Before adding story:**
- Total tasks: 53
- Estimated time: 32 hours
- Completion: 2026-01-18

**After adding story:**
- Total tasks: 67 (+14)
- Estimated time: 38 hours (+6)
- Completion: 2026-01-20 (+2 days)

**Impact on current work:**
- Currently in Phase 4 (no impact)
- New Phase 7 added at end

Accept new timeline? [yes/no]
```

### Step 8: Commit Changes

Show all changes and offer to commit:

```bash
git diff docs/specs/[feature-name]*.md
```

```markdown
## Summary of Changes

**spec.md**:
+ Added User Story 4: User Preferences (P2)
+ 45 lines added

**design.md**:
+ Added user_preferences table schema
+ Added 2 new API endpoints
+ Updated architecture diagram
+ 87 lines added

**tasks.md**:
+ Added Phase 7 with 14 tasks
+ Renumbered tasks T082-T110 → T096-T124
+ Added independent test scenario
+ 156 lines added

**Total impact**: +288 lines across 3 files

Commit these changes? [yes/edit/no]

Suggested commit message:
"Add User Story 4: User Preferences (P2)

- Add user preferences spec with acceptance criteria
- Extend design with user_preferences table and API endpoints
- Create 14-task breakdown in Phase 7
- Renumber subsequent tasks (T082+ → T096+)
- Maintain consistency across all artifacts

Estimated: 6 hours
Timeline impact: +2 days (now 2026-01-20)"
```

## Guidelines

### When to Use /add-story

**Good reasons**:
- Scope expansion after initial planning
- New requirements emerge mid-project
- Split large story into smaller ones
- Add enhancement after MVP complete

**Bad reasons**:
- Initial story creation (use /spec-feature)
- Complete feature redesign (start over)
- Fixing mistakes in existing stories (edit directly)

### Story Sizing Guidelines

**Ideal new story**:
- 8-15 tasks (2-6 hours)
- Independent from other incomplete stories
- Clear acceptance criteria
- Defined priority (P1/P2/P3)

**Too small** (< 5 tasks):
- Consider merging with existing story
- Or add as tasks to existing phase

**Too large** (> 20 tasks):
- Split into multiple stories
- Run /add-story multiple times

### Maintaining Priority Order

When adding stories:

```markdown
**Current stories**: US1 (P1), US2 (P2), US3 (P3)

**Adding**: US4 as P2

**Result**:
- US1 (P1) - unchanged
- US2 (P2) - unchanged  
- US4 (P2) - NEW (second P2 story)
- US3 (P3) - unchanged

**Tasks placement**:
- Phase 4: US2 (P2) - existing
- Phase 5: US4 (P2) - NEW
- Phase 6: US3 (P3) - existing
```

**Note**: Stories keep their original numbers even if priorities change.

### Handling Dependencies

New story depends on existing incomplete story:

```markdown
**New Story**: User Preferences (US4)
**Depends on**: User Authentication (US1) ✅ complete

**Task dependencies**:
- T082 depends on T015 (User model from US1) ✅

**OK to proceed**: Yes, dependency is complete

---

**New Story**: User Notifications (US5)
**Depends on**: User Preferences (US4) ⏸️ not started

**Warning**: Cannot implement US5 until US4 is complete

**Recommendation**: 
1. Implement US4 first, OR
2. Remove dependency if possible, OR
3. Defer US5 until US4 done
```

### Preventing Scope Creep

Track story additions:

```markdown
## Scope Management

**Original plan** (from initial spec):
- 3 user stories
- 45 tasks
- 28 hours estimated

**Current state**:
- 6 user stories (+3)
- 82 tasks (+37)
- 51 hours estimated (+23)

**Added stories**:
1. US4: User Preferences (P2) - valuable addition ✓
2. US5: Email notifications (P3) - nice to have ✓
3. US6: Advanced search (P2) - scope creep? ⚠️

**Question**: Is US6 really needed now?

**Options**:
A. Keep it (accept 51 hours)
B. Defer to v2 (reduce to 44 hours)
C. Replace lower priority story

**Recommendation**: Review with stakeholders before proceeding
```

### Testing the New Story

After adding story:

```markdown
## Verification Checklist

Before implementing new story:
- [ ] Spec clearly defines value
- [ ] Design has no conflicts with existing architecture
- [ ] Tasks are actionable and sized appropriately
- [ ] Dependencies are met or scheduled
- [ ] Consistency check passes
- [ ] Timeline is acceptable

After implementing new story:
- [ ] All tasks completed
- [ ] All acceptance criteria verified
- [ ] Independent test passes
- [ ] No regression in existing stories
- [ ] Documentation updated
```

## Context

Format: /add-story [spec-path] "[story description]"

Example: /add-story docs/specs/user-auth.md "Allow users to customize notification preferences"

**Important**: This command modifies multiple files (spec, design, tasks). Always run consistency check after adding a story.
