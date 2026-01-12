---
description: Display comprehensive project progress overview with phase completion, MVP status, and task metrics.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command provides a comprehensive project status overview by analyzing the tasks file to show phase completion, MVP progress, and overall project metrics.

### Step 1: Locate Tasks File

```bash
bash .cursor/scripts/find-tasks-file.sh "$ARGUMENTS"
```

The script will:
- Find tasks file from provided spec path or by searching
- Verify tasks file exists
- Output tasks file path

### Step 2: Analyze Progress

```bash
bash .cursor/scripts/analyze-status.sh "[tasks-file-path]"
```

The script performs analysis:
- Counts total tasks
- Counts completed tasks (checked boxes)
- Calculates completion percentage per phase
- Identifies MVP status
- Finds current phase
- Lists next tasks

### Step 3: Display Status Dashboard

Generate formatted status report:

```markdown
╔═══════════════════════════════════════════════════════╗
║          PROJECT STATUS - [Feature Name]              ║
╚═══════════════════════════════════════════════════════╝

📊 PHASE OVERVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase 1: Setup & Configuration
├─ Status: ✅ Complete
├─ Tasks: 7/7 (100%)
├─ Duration: 2 hours (estimated)
└─ Key Deliverable: Project structure, dependencies installed

Phase 2: Foundation (Blocking Prerequisites)  
├─ Status: ✅ Complete
├─ Tasks: 9/9 (100%)
├─ Duration: 4 hours (estimated)
└─ Key Deliverable: Database schema, auth middleware

Phase 3: User Story 1 - User Authentication (P1 - MVP)
├─ Status: ✅ Complete
├─ Tasks: 13/13 (100%)
├─ Duration: 8 hours (estimated)
└─ Key Deliverable: Login, registration, session management

Phase 4: User Story 2 - Password Reset (P2)
├─ Status: 🔄 In Progress
├─ Tasks: 3/9 (33%)
├─ Duration: 6 hours (estimated, 4 hours remaining)
├─ Completed:
│   ├─ ✅ T023: Create PasswordReset model
│   ├─ ✅ T024: Create password reset service
│   └─ ✅ T025: Add email service integration
└─ Next Tasks:
    ├─ ⏭️  T026: Implement reset password endpoint
    ├─ ⏭️  T027: Add reset token validation
    └─ ⏭️  T028: Create email templates

Phase 5: User Story 3 - User Profile Management (P3)
├─ Status: ⏸️  Not Started
├─ Tasks: 0/12 (0%)
└─ Duration: 7 hours (estimated)

Phase 6: Polish & Cross-Cutting Concerns
├─ Status: ⏸️  Not Started
├─ Tasks: 0/8 (0%)
└─ Duration: 5 hours (estimated)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 OVERALL PROGRESS

Total Tasks:     32/58 (55%)
Completed:       32 tasks
Remaining:       26 tasks
Time Spent:      ~14 hours
Time Remaining:  ~18 hours (estimated)

Progress Bar: ████████████░░░░░░░░░ 55%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 MVP STATUS

Definition: User Story 1 (User Authentication)
Status: ✅ Complete
├─ All acceptance criteria met
├─ Independent test scenario: PASSED
├─ Ready for: Deployment to staging
└─ Deployed: Yes (staging - 2026-01-10)

Next Milestone: User Story 2 completion (P2)
Target: 2026-01-15
Progress: 33% (3/9 tasks)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 CURRENT FOCUS

Active Phase: Phase 4 (User Story 2)
Current Task: T026 - Implement reset password endpoint

Next 3 Tasks:
1. T026: Implement reset password endpoint (src/routes/auth.py)
   └─ Depends on: T025 ✅
   
2. T027: Add reset token validation (src/services/auth_service.py)
   └─ Depends on: T026
   
3. T028: Create email templates (templates/emails/)
   └─ Can run in parallel with T027 [P]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 VELOCITY METRICS

Tasks per day (last 7 days): 2.3 tasks/day
Estimated completion: 2026-01-23 (11 days)
Ahead/Behind schedule: On track ✓

Recent Velocity:
├─ Jan 10: 4 tasks ████
├─ Jan 11: 3 tasks ███
├─ Jan 12: 2 tasks ██
└─ Jan 13: 0 tasks (today, in progress)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  BLOCKERS & RISKS

Current Blockers: None
At Risk:
└─ Email service integration (T025) may need 3rd party API keys

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 RECOMMENDATIONS

1. Complete Phase 4 (6 tasks remaining) before starting Phase 5
2. Consider deploying US2 independently after T031 complete
3. Schedule code review for authentication flow (Phases 2-3)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔗 QUICK LINKS

Tasks File:  docs/specs/user-auth-tasks.md
Spec File:   docs/specs/user-auth.md
Design File: docs/specs/user-auth-design.md

Last Updated: 2026-01-13 14:23:00
```

### Step 4: Detailed Task List (Optional)

If user wants to see detailed task list:

```markdown
📝 DETAILED TASK BREAKDOWN

Phase 4: User Story 2 - Password Reset (P2)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ T023: Create PasswordReset model (src/models/password_reset.py)
   └─ Completed: 2026-01-12 09:15
   
✅ T024: Create password reset service (src/services/password_service.py)  
   └─ Completed: 2026-01-12 10:30
   
✅ T025: Add email service integration (src/services/email_service.py)
   └─ Completed: 2026-01-12 11:45
   
⏭️  T026: Implement reset password endpoint (src/routes/auth.py)
   ├─ Depends on: T025 ✅
   ├─ Estimated: 45 minutes
   └─ Status: Ready to start

⏭️  T027: Add reset token validation (src/services/auth_service.py)
   ├─ Depends on: T026
   ├─ Estimated: 30 minutes
   └─ Status: Blocked by T026

⏭️  T028: Create email templates (templates/emails/)
   ├─ Can run in parallel [P]
   ├─ Estimated: 30 minutes
   └─ Status: Ready to start

⏭️  T029: Add rate limiting for reset requests (src/middleware/rate_limit.py)
   ├─ Depends on: T026
   ├─ Estimated: 45 minutes
   └─ Status: Blocked by T026

⏭️  T030: Test password reset flow (tests/test_password_reset.py)
   ├─ Depends on: T027, T028, T029
   ├─ Estimated: 1 hour
   └─ Status: Blocked by T027, T029

⏭️  T031: Document password reset API (docs/api/auth.md)
   ├─ Depends on: T030
   ├─ Estimated: 30 minutes
   └─ Status: Blocked by T030

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase Progress: 3/9 tasks (33%)
Estimated Remaining: 4 hours
```

### Step 5: Export Options

Offer export formats:

```markdown
📤 Export Status

Available formats:
1. Markdown report (detailed)
2. JSON (for dashboards/tools)
3. CSV (for spreadsheets)
4. Plain text (for commit messages)

Export as: [1/2/3/4/skip]
```

If user chooses export, create file:

```bash
bash .cursor/scripts/export-status.sh "[tasks-file]" "[format]" "[output-file]"
```

## Guidelines

### Interpreting Status

**Phase Status Indicators**:
- ✅ Complete: All tasks checked off
- 🔄 In Progress: Some tasks checked, some not
- ⏸️ Not Started: No tasks checked
- 🚫 Blocked: Dependencies not met

**Progress Colors** (if terminal supports):
- 🔴 Red: < 25% (just starting)
- 🟡 Yellow: 25-75% (in progress)
- 🟢 Green: > 75% (nearly done)

**MVP Status**:
- ✅ Complete: All MVP tasks done, tests pass
- 🔄 In Progress: Some MVP tasks remain
- ⏸️ Not Started: MVP phase not begun
- ⚠️ At Risk: Blockers or delays affecting MVP

### When to Check Status

**Daily**:
- At start of day (plan work)
- After completing tasks (celebrate progress)
- Before standup meetings

**Weekly**:
- During sprint planning
- For stakeholder updates
- To adjust estimates

**Ad-hoc**:
- When feeling lost or overwhelmed
- Before context switching
- When asked "how's it going?"

### Using Status for Planning

**If ahead of schedule**:
- Consider adding polish tasks
- Tackle technical debt
- Start next story early

**If behind schedule**:
- Identify blockers
- Reduce scope (move P3 → Future)
- Ask for help on parallel tasks

**If blocked**:
- List blockers explicitly
- Estimate unblock time
- Work on parallel tasks meanwhile

### Status-Driven Workflows

**Start of day**:
```bash
/status  # See what's next
/implement-story "User Story 2"  # Work on current story
```

**End of day**:
```bash
/status  # See progress made
# Update task checkboxes
/status  # Confirm changes reflected
```

**Before meetings**:
```bash
/status > status-report.md  # Generate report
# Share with team
```

### Integration with Other Commands

**After implementation**:
```bash
/implement-story "User Story 1"
# ... work happens ...
/status  # Should show updated progress
```

**Before adding scope**:
```bash
/status  # See current workload
/add-story "New Feature"  # Only if capacity exists
```

**Before consistency check**:
```bash
/status  # See which phase you're on
/analyze-consistency docs/specs/feature.md  # Verify current phase
```

### Customizing Status Display

Add to `agents.md` preferences:

```markdown
## Status Display Preferences

**Show in status report**:
- Velocity metrics: Yes
- Time estimates: Yes
- Detailed next tasks: First 5 only
- Completed task list: Last 10 only

**Alert thresholds**:
- Behind schedule: > 2 days
- Low velocity: < 1 task/day for 3+ days
- Phase stalled: No progress in 2+ days
```

## Context

Tasks file path: $ARGUMENTS (optional - will search if not provided)

**Important**: This command is read-only and safe to run anytime. It doesn't modify any files.
