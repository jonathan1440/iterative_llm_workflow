# File Structure Guide

Complete reference for all files in the Cursor AI-Assisted Development Workflow.

---

## 📁 Distribution Package Structure

**What you download/clone:**

```
cursor-workflow/
├── README.md                           # Main documentation (START HERE)
├── QUICK-REFERENCE.md                  # One-page command cheat sheet
├── NEW-COMMANDS-README.md              # Detailed docs for new commands
├── CONSISTENCY-FIXES.md                # QA report and fixes
├── TEMPLATE-VERIFICATION.md            # Template loading verification
├── install.sh                          # Installation script (run this)
│
├── commands/                           # 10 Cursor commands
│   ├── init-project.md                 # Initialize project structure
│   ├── spec-feature.md                 # Create feature specification
│   ├── design-system.md                # Design system architecture
│   ├── plan-tasks.md                   # Break feature into tasks
│   ├── implement-story.md              # Implement user story
│   ├── analyze-consistency.md          # Validate spec/design/tasks
│   ├── status.md                       # Project progress dashboard
│   ├── add-story.md                    # Add new user story
│   ├── refactor.md                     # Safe code refactoring
│   └── review-agents.md                # Maintain agents.md
│
├── scripts/                            # 18 automation scripts
│   ├── init-project.sh                 # Create project structure
│   ├── create-spec.sh                  # Create spec file from template
│   ├── create-design.sh                # Create design file from template
│   ├── create-tasks.sh                 # Create tasks file from template
│   ├── check-consistency-prerequisites.sh
│   ├── check-consistency.sh            # Validate consistency
│   ├── find-tasks-file.sh              # Locate tasks file
│   ├── analyze-status.sh               # Calculate progress metrics
│   ├── load-agents.sh                  # Display agents.md status
│   ├── analyze-git-patterns.sh         # Analyze git history
│   ├── check-feature-files.sh          # Verify feature files exist
│   ├── check-refactor-prerequisites.sh # Verify refactor prerequisites
│   ├── run-tests.sh                    # Run and compare tests
│   ├── create-refactor-checkpoint.sh   # Create safety checkpoint
│   ├── rollback-refactor.sh            # Restore from checkpoint
│   └── ... (3 more utility scripts)
│
├── templates/                          # 4 production-quality templates
│   ├── spec-template-example.md        # Feature specification example
│   ├── design-template-example.md      # System design example
│   ├── tasks-template-example.md       # Task breakdown example
│   └── implementation-example.md       # Implementation walkthrough
│
└── agents.md                           # Template for project standards
```

---

## 📁 Installed Structure

**After running `install.sh`, your project will have:**

```
your-project/
│
├── .cursor/                            # Cursor IDE configuration
│   │
│   ├── commands/                       # Custom commands (Cmd+K)
│   │   ├── init-project.md
│   │   ├── spec-feature.md
│   │   ├── design-system.md
│   │   ├── plan-tasks.md
│   │   ├── implement-story.md
│   │   ├── analyze-consistency.md
│   │   ├── status.md
│   │   ├── add-story.md
│   │   ├── refactor.md
│   │   └── review-agents.md
│   │
│   ├── scripts/                        # Automation scripts
│   │   ├── init-project.sh
│   │   ├── create-spec.sh
│   │   ├── create-design.sh
│   │   ├── create-tasks.sh
│   │   ├── check-consistency-prerequisites.sh
│   │   ├── check-consistency.sh
│   │   ├── find-tasks-file.sh
│   │   ├── analyze-status.sh
│   │   ├── load-agents.sh
│   │   ├── analyze-git-patterns.sh
│   │   ├── check-feature-files.sh
│   │   ├── check-refactor-prerequisites.sh
│   │   ├── run-tests.sh
│   │   ├── create-refactor-checkpoint.sh
│   │   └── rollback-refactor.sh
│   │
│   ├── templates/                      # Quality reference examples
│   │   ├── spec-template-example.md
│   │   ├── design-template-example.md
│   │   ├── tasks-template-example.md
│   │   └── implementation-example.md
│   │
│   └── agents.md                       # YOUR project standards
│       # This file grows with your project!
│       # Contains learnings, patterns, mistakes
│
├── docs/                               # Generated specifications
│   └── specs/
│       ├── [feature-1].md              # Feature spec
│       ├── [feature-1]-design.md       # System design
│       ├── [feature-1]-tasks.md        # Task breakdown
│       ├── [feature-1]-research.md     # Research notes (optional)
│       │
│       ├── [feature-2].md
│       ├── [feature-2]-design.md
│       ├── [feature-2]-tasks.md
│       └── ...
│
├── src/                                # Your application code
│   ├── models/                         # Data models
│   ├── services/                       # Business logic
│   ├── routes/                         # API endpoints
│   ├── middleware/                     # Middleware
│   └── utils/                          # Utilities
│
├── tests/                              # Your tests
│   ├── test_models.py
│   ├── test_services.py
│   └── test_routes.py
│
├── .git/                               # Git repository
├── .gitignore                          # Git ignore rules
├── README.md                           # Your project README
└── ... (your other project files)
```

---

## 📄 File Details

### Commands (`.cursor/commands/*.md`)

Each command file contains:
- **YAML frontmatter** - Command description for Cursor
- **User Input** section - How arguments are handled
- **Outline** - Step-by-step workflow
- **Guidelines** - Best practices and edge cases
- **Context** - What gets passed to the command

**Format:**
```markdown
---
description: Command description
---

## User Input
$ARGUMENTS

## Outline
Step-by-step process...

## Guidelines
Best practices...

## Context
Arguments and context...
```

---

### Scripts (`.cursor/scripts/*.sh`)

Each script follows bash best practices:
- `set -e` - Exit on error
- Input validation
- Helpful error messages
- Exit codes (0=success, 1=error)
- Clear output formatting

**Categories:**

**Project Setup:**
- `init-project.sh` - Creates .cursor/ structure

**File Generation:**
- `create-spec.sh` - Generates spec from template
- `create-design.sh` - Generates design from template
- `create-tasks.sh` - Generates tasks from template

**Validation:**
- `check-consistency-prerequisites.sh` - Verify files exist
- `check-consistency.sh` - Run consistency checks

**Progress Tracking:**
- `find-tasks-file.sh` - Locate tasks file
- `analyze-status.sh` - Calculate metrics

**Learning Management:**
- `load-agents.sh` - Show agents.md status
- `analyze-git-patterns.sh` - Analyze git history

**Story Management:**
- `check-feature-files.sh` - Verify prerequisites

**Refactoring:**
- `check-refactor-prerequisites.sh` - Pre-refactor checks
- `run-tests.sh` - Test comparison
- `create-refactor-checkpoint.sh` - Safety backup
- `rollback-refactor.sh` - Restore backup

---

### Templates (`.cursor/templates/*.md`)

Production-quality examples that serve as references:

**spec-template-example.md** (312 lines)
- Complete feature spec example
- Real user stories with acceptance criteria
- Measurable success metrics
- Data models with relationships
- Out-of-scope boundaries

**design-template-example.md** (487 lines)
- Architecture diagrams (Mermaid)
- Complete database schemas (SQL)
- API contracts with request/response
- Security considerations
- Performance targets

**tasks-template-example.md** (392 lines)
- Phase-organized task breakdown
- Clear dependencies
- Parallel execution markers
- Independent test scenarios
- MVP definition

**implementation-example.md** (508 lines)
- Complete 13-task walkthrough
- Real code examples
- Verification checkpoints
- Learning capture process
- Final story report

---

### agents.md (`.cursor/agents.md`)

**The Living Document** - Grows with your project

**Typical Structure:**
```markdown
# agents.md

## Project Overview
Brief description of the project

## Code Standards
- Language/framework conventions
- Formatting preferences
- Naming conventions

## Architecture Principles
- High-level design decisions
- Technology choices
- Patterns to follow/avoid

## Implementation Best Practices
- How to implement features
- Reusable patterns
- Integration approaches

## Common Mistakes
- What went wrong
- Why it was wrong
- How to do it correctly
- When the mistake was made

## Testing Guidelines
- Testing strategy
- Coverage requirements
- Test organization

## Deployment Process
- How to deploy
- Environments
- Release checklist

## Archive
- Outdated but historically important
```

**Example Entry:**
```markdown
## Authentication Pattern

**Our Standard Approach**
- JWT tokens in HTTP-only cookies
- 15-minute access token, 7-day refresh token
- Token rotation on every refresh

**Don't use:**
- localStorage for tokens (XSS vulnerable)
- Long-lived access tokens (> 1 hour)
- No token rotation (security issue)

**Rationale**: Balance security and UX
**Added**: 2026-01-10
```

---

## 🔄 File Lifecycle

### 1. Initial Setup
```
/init-project "My Project"
→ Creates .cursor/agents.md
```

### 2. Feature Development
```
/spec-feature "User auth"
→ Creates docs/specs/user-auth.md

/design-system docs/specs/user-auth.md
→ Creates docs/specs/user-auth-design.md

/plan-tasks docs/specs/user-auth.md
→ Creates docs/specs/user-auth-tasks.md
```

### 3. Implementation
```
/implement-story "User Story 1"
→ Modifies code in src/
→ Updates docs/specs/user-auth-tasks.md (checkboxes)
→ May append to .cursor/agents.md (learnings)
```

### 4. Scope Changes
```
/add-story docs/specs/user-auth.md "2FA"
→ Modifies docs/specs/user-auth.md (adds story)
→ Modifies docs/specs/user-auth-design.md (extends)
→ Modifies docs/specs/user-auth-tasks.md (adds phase)
```

### 5. Quality Improvements
```
/refactor "Extract service"
→ Creates .refactor-checkpoint-TIMESTAMP/
→ Modifies src/ code
→ Creates .refactor-baseline.env
→ May append to .cursor/agents.md

/review-agents
→ May modify .cursor/agents.md
→ Creates .cursor/agents-review-DATE.md
```

---

## 📊 File Ownership

**You Own (Edit Directly):**
- `src/` - Your application code
- `tests/` - Your tests
- `.cursor/agents.md` - Project standards (but commands help)
- Project README, gitignore, etc.

**Commands Own (Don't Edit Manually):**
- `docs/specs/*.md` - Generated by commands
- Generated spec/design/tasks files

**Workflow Owns (Don't Edit):**
- `.cursor/commands/*.md` - Command definitions
- `.cursor/scripts/*.sh` - Automation scripts
- `.cursor/templates/*.md` - Reference examples

**Generated by Commands (Temporary):**
- `.refactor-checkpoint-*` - Refactor backups (can delete after)
- `.refactor-baseline.env` - Test baseline (temporary)
- `.cursor/agents-review-*.md` - Review reports (can archive)

---

## 🗑️ What to Git Ignore

```gitignore
# Temporary refactor files
.refactor-checkpoint-*
.refactor-baseline.env
.refactor-results-*
.refactor-current.env

# Temporary review files (optional - may want to keep)
.cursor/agents-review-*.md

# Everything else in .cursor/ should be committed!
```

---

## 📦 What to Commit

**Always Commit:**
- `.cursor/agents.md` - Project standards
- `docs/specs/*.md` - All specifications
- All code in `src/`
- All tests in `tests/`

**Optionally Commit:**
- `.cursor/commands/*.md` - If you customized
- `.cursor/scripts/*.sh` - If you customized
- `.cursor/templates/*.md` - If you customized

**Never Commit:**
- `.refactor-checkpoint-*` - Temporary backups
- `.refactor-*.env` - Temporary test data

---

## 🔍 Finding Files

**By Command:**
```bash
# What files does init-project create?
ls .cursor/

# What files does spec-feature create?
ls docs/specs/*auth*.md

# What files does refactor create?
ls .refactor-checkpoint-*
```

**By Purpose:**
```bash
# All specs
ls docs/specs/*.md | grep -v "design\|tasks"

# All designs
ls docs/specs/*-design.md

# All tasks
ls docs/specs/*-tasks.md

# All learnings
cat .cursor/agents.md
```

**By Recency:**
```bash
# Recent specs
ls -lt docs/specs/*.md | head -5

# Recent changes to agents.md
git log -p .cursor/agents.md | head -50
```

---

## 💡 Pro Tips

### Organizing Large Projects

For projects with 10+ features:
```
docs/
└── specs/
    ├── auth/
    │   ├── user-authentication.md
    │   ├── user-authentication-design.md
    │   └── user-authentication-tasks.md
    │
    ├── tasks/
    │   ├── task-management.md
    │   ├── task-management-design.md
    │   └── task-management-tasks.md
    │
    └── teams/
        ├── team-workspaces.md
        ├── team-workspaces-design.md
        └── team-workspaces-tasks.md
```

### Archiving Completed Features

```bash
# After feature is deployed and stable
mkdir -p docs/archive/2026-01/
mv docs/specs/old-feature* docs/archive/2026-01/
```

### Backing Up agents.md

```bash
# Before major refactoring or cleanup
cp .cursor/agents.md .cursor/agents-backup-$(date +%Y%m%d).md
```

---

## 🎓 Understanding the Flow

```
1. init-project.sh
   → Creates .cursor/ structure
   → Initializes agents.md

2. create-spec.sh
   → Copies spec-template-example.md
   → Creates docs/specs/[feature].md

3. create-design.sh
   → Copies design-template-example.md
   → Creates docs/specs/[feature]-design.md

4. create-tasks.sh
   → Copies tasks-template-example.md
   → Creates docs/specs/[feature]-tasks.md

5. check-consistency.sh
   → Reads all three files
   → Validates alignment
   → Outputs report

6. implement-story (Composer Mode)
   → Reads tasks file
   → Writes to src/
   → Updates task checkboxes
   → Appends learnings to agents.md

7. analyze-status.sh
   → Parses tasks file
   → Calculates metrics
   → Displays dashboard

8. refactor (Composer Mode)
   → Creates checkpoint
   → Modifies src/
   → Runs tests
   → May rollback
```

---

Need help navigating files? Check the troubleshooting section in README.md.
