#!/bin/bash

# create-tasks.sh
# Creates a task breakdown document organized by user story

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get spec file path
SPEC_PATH="$1"

if [ -z "$SPEC_PATH" ]; then
    echo -e "${RED}Error: No spec file provided${NC}"
    echo "Usage: $0 <path-to-spec.md>"
    exit 1
fi

if [ ! -f "$SPEC_PATH" ]; then
    echo -e "${RED}Error: Spec file not found: $SPEC_PATH${NC}"
    exit 1
fi

# Generate tasks file path
# Handle both old format (feature-name.md) and new format (feature-name/spec.md)
if [[ "$SPEC_PATH" == *"/spec.md" ]]; then
    # New format: feature-name/spec.md -> feature-name/tasks.md
    SPEC_DIR=$(dirname "$SPEC_PATH")
    TASKS_PATH="${SPEC_DIR}/tasks.md"
    mkdir -p "$SPEC_DIR"
else
    # Old format: feature-name.md -> create feature-name/ directory and use new format
    SPEC_DIR=$(dirname "$SPEC_PATH")
    SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
    FEATURE_DIR="${SPEC_DIR}/${SPEC_FILENAME}"
    
    # Create feature directory and use new format
    mkdir -p "$FEATURE_DIR"
    TASKS_PATH="${FEATURE_DIR}/tasks.md"
fi

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Extract feature name from spec
FEATURE_NAME=$(grep -m 1 "^# Feature:" "$SPEC_PATH" | sed 's/^# Feature: //' || echo "Unknown Feature")

echo -e "${BLUE}📋 Creating task breakdown document...${NC}"
echo ""

# Check if tasks file already exists
if [ -f "$TASKS_PATH" ]; then
    echo -e "${YELLOW}⚠️  Tasks file already exists: $TASKS_PATH${NC}"
    echo -e "${YELLOW}   Overwrite? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Cancelled. Using existing file.${NC}"
        echo "$TASKS_PATH"
        exit 0
    fi
fi

# Create comprehensive tasks document template
cat > "$TASKS_PATH" << 'EOF'
# Implementation Tasks: [FEATURE_NAME]

**Created**: [CURRENT_DATE]  
**Status**: Draft  
**Related Spec**: [SPEC_FILENAME]  
**Related Design**: [DESIGN_FILENAME]

---

## Task Format

**Every task MUST follow this format:**

```
- [ ] [TaskID] [P?] [Story?] Description with file path
```

**Format Components:**
- `- [ ]` - Checkbox (always required)
- `[TaskID]` - T001, T002, T003... (sequential)
- `[P]` - Parallel marker (ONLY if different files, no dependencies)
- `[Story]` - [US1], [US2], [US3] (REQUIRED for user story tasks)
- Description - Clear action with specific file path

**Examples:**
- ✅ `- [ ] T001 Initialize project structure per plan`
- ✅ `- [ ] T012 [P] [US1] Create User model in src/models/user.js`
- ✅ `- [ ] T014 [US1] Implement UserService in src/services/user-service.js`

---

## MVP Definition

**Minimum Viable Product** = Phase 1 + Phase 2 + Phase 3 (User Story 1)

**What MVP Delivers**:
- [Core capability from User Story 1]
- [Another capability from User Story 1]

**What MVP Defers**:
- Phase 4 (User Story 2): [Feature name]
- Phase 5 (User Story 3): [Feature name]

**Why This Scope**:
- Validates core value proposition
- Can be tested by real users
- Provides foundation for additional features
- Estimated: ~[X] days of development

**Success Metrics** (from spec):
- [Measurable outcome 1]
- [Measurable outcome 2]

---

## Phase 1: Setup

**Goal**: Initialize project structure and dependencies

**Tasks**:
- [ ] T001 Initialize project structure (src/, tests/, config/)
- [ ] T002 Install dependencies per package.json from design
- [ ] T003 Configure environment variables (.env.example with all required vars)
- [ ] T004 Setup database connection pool per design
- [ ] T005 [P] Create ignore files (.gitignore, .dockerignore)
- [ ] T006 [P] Setup linting and formatting per agents.md

**Completion Criteria**: 
- Project structure exists
- Dependencies installed
- Database connects successfully
- Environment variables documented

---

## Phase 2: Foundation (Blocking Prerequisites)

**Goal**: Build shared infrastructure required by all user stories

**What Makes This Foundation**:
- Shared utilities used by multiple stories
- Database schema (all tables created)
- Authentication/authorization middleware
- Error handling framework
- Logging setup
- Testing framework

**Tasks**:
- [ ] T007 Run database migrations (create all tables from design)
- [ ] T008 [P] Create base error classes in src/errors/
- [ ] T009 [P] Setup logging per design in src/utils/logger.js
- [ ] T010 Create database query helpers in src/db/
- [ ] T011 [P] Setup test framework (Jest/Mocha/pytest per agents.md)
- [ ] T012 [P] Create API response formatter in src/utils/response.js
- [ ] T013 [P] Add request validation middleware in src/middleware/validate.js

**Completion Criteria**:
- All database tables exist
- Base utilities available
- Test framework runs
- Shared middleware works

---

## Phase 3: User Story 1 (P1 - MVP) - [Story Name]

**Story Goal**: [From spec - what user accomplishes]

**Acceptance Criteria** (from spec):
- [ ] [Criterion 1 from spec]
- [ ] [Criterion 2 from spec]
- [ ] [Criterion 3 from spec]

**Independent Test Scenario**:
How to verify this story works without other stories complete:

1. [Step-by-step test procedure]
2. [Expected result at each step]
3. [Success condition]

Example:
```
1. Start server: npm start
2. POST /api/auth/register with valid email/password
3. Expected: 201 Created with user data and session token
4. POST /api/auth/login with same credentials
5. Expected: 200 OK with session token
6. GET /api/auth/me with Authorization: Bearer <token>
7. Expected: 200 OK with user profile
Success = All steps complete without errors
```

**Tasks**:

### Data Models (can be parallel)
- [ ] T014 [P] [US1] Create [Entity] model in src/models/[entity].js
- [ ] T015 [P] [US1] Create [Entity] model in src/models/[entity].js

### Business Logic (sequential within, parallel across services)
- [ ] T016 [US1] Implement [Service] in src/services/[service].js
  - [Specific function 1]
  - [Specific function 2]
  - [Error handling]
- [ ] T017 [P] [US1] Implement [Service] in src/services/[service].js

### API Layer
- [ ] T018 [US1] Create [METHOD] /api/[path] endpoint in src/routes/[route].js
  - Request validation
  - Call service layer
  - Error handling
  - Response formatting
- [ ] T019 [US1] Create [METHOD] /api/[path] endpoint in src/routes/[route].js

### Testing
- [ ] T020 [P] [US1] Write unit tests for [Service] in tests/unit/[service].test.js
  - Test [function 1]
  - Test [function 2]
  - Test error cases
- [ ] T021 [P] [US1] Write integration tests for [endpoints] in tests/integration/[route].test.js
  - Test happy path
  - Test validation errors
  - Test authentication

### Story Verification
- [ ] T022 [US1] Perform independent test scenario (documented above)
- [ ] T023 [US1] Update API documentation with new endpoints

**Completion Criteria**:
- All tasks marked [X]
- Independent test passes
- All acceptance criteria met
- Code reviewed
- Tests passing

---

## Phase 4: User Story 2 (P2) - [Story Name]

**Story Goal**: [From spec]

**Acceptance Criteria** (from spec):
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**Independent Test Scenario**:
[How to test this story independently]

**Dependencies**: User Story 1 must be complete

**Tasks**:
- [ ] T024 [P] [US2] [Task with file path]
- [ ] T025 [US2] [Task with file path]

<!-- Follow same structure as Phase 3 -->

---

## Phase 5: User Story 3 (P3) - [Story Name]

**Story Goal**: [From spec]

**Acceptance Criteria** (from spec):
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**Independent Test Scenario**:
[How to test this story independently]

**Dependencies**: User Story 1 must be complete

**Tasks**:
- [ ] T0XX [P] [US3] [Task with file path]
- [ ] T0XX [US3] [Task with file path]

<!-- Follow same structure as Phase 3 -->

---

## Phase N: Polish & Cross-Cutting Concerns

**Goal**: Production readiness and final improvements

**Tasks**:
- [ ] T0XX [P] Add comprehensive input validation to all endpoints
- [ ] T0XX [P] Add rate limiting middleware per design
- [ ] T0XX [P] Setup monitoring and metrics per design
- [ ] T0XX [P] Add security headers (helmet.js or equivalent)
- [ ] T0XX [P] Write/update API documentation (OpenAPI/Swagger)
- [ ] T0XX [P] Add request/response logging
- [ ] T0XX Performance profiling and optimization
- [ ] T0XX Security audit of all endpoints
- [ ] T0XX Final end-to-end integration test (all stories)
- [ ] T0XX Update README with setup instructions

**Completion Criteria**:
- All endpoints have proper validation
- Security measures in place
- Documentation complete
- Performance acceptable
- Ready for deployment

---

## Dependencies & Execution Flow

### Story Completion Order

```mermaid
graph TD
    Setup[Phase 1: Setup]
    Foundation[Phase 2: Foundation]
    US1[Phase 3: User Story 1<br/>MVP]
    US2[Phase 4: User Story 2]
    US3[Phase 5: User Story 3]
    Polish[Phase N: Polish]
    
    Setup --> Foundation
    Foundation --> US1
    US1 --> US2
    US1 --> US3
    US2 --> Polish
    US3 --> Polish
    
    style US1 fill:#90EE90
    style Setup fill:#87CEEB
    style Foundation fill:#87CEEB
    style US2 fill:#FFD700
    style US3 fill:#FFD700
    style Polish fill:#DDA0DD
```

### Within-Story Dependencies

**Example for User Story 1**:
```
Models (T014, T015) → Services (T016, T017) → API (T018, T019) → Tests (T020, T021) → Verification (T022)
```

Models and Services can be partially parallel, but API depends on Services.

### Parallel Execution Opportunities

**Within User Story 1** (single developer):
- T014, T015 (different models, different files)
- T020, T021 (different test files)

**Across Stories** (multi-developer team):
- After US1 complete: US2 and US3 can start in parallel
- Most Polish tasks can run in parallel

**Recommendation for Solo Development**:
- Complete US1 fully before starting US2
- Avoid context switching between stories
- Each story should work before moving to next

---

## Task Summary

**Total Tasks**: [Count]
- Setup: [Count]
- Foundation: [Count]
- User Story 1 (MVP): [Count]
- User Story 2: [Count]
- User Story 3: [Count]
- Polish: [Count]

**Parallel Tasks**: [Count] tasks marked [P]

**Estimated Effort**:
- MVP (P1 + P2 + P3): ~[X] days
- P2 (Phase 4): ~[X] days
- P3 (Phase 5): ~[X] days
- Polish: ~[X] days
- **Total**: ~[X] days

---

## Implementation Strategy

### Recommended Approach

1. **Complete MVP First** (Phases 1-3)
   - Validates core value
   - Proves technical approach
   - Can be tested by real users

2. **Deploy MVP and Gather Feedback**
   - Real usage data
   - Performance metrics
   - User feedback

3. **Prioritize Next Story Based on Feedback**
   - US2 or US3 based on user need
   - Or additional polish/performance work

### Alternative: Parallel Stories (Multi-Developer)

If multiple developers:
- Dev 1: US1 (blocking, must be done first)
- After US1 complete:
  - Dev 1: US2
  - Dev 2: US3
  - Dev 3: Polish tasks

---

**Last Updated**: [CURRENT_DATE]

**Status**: [ ] Draft [ ] In Progress [ ] Complete
EOF

# Replace placeholders
sed -i.bak "s/\[FEATURE_NAME\]/$FEATURE_NAME/g" "$TASKS_PATH"
sed -i.bak "s/\[CURRENT_DATE\]/$CURRENT_DATE/g" "$TASKS_PATH"
sed -i.bak "s/\[SPEC_FILENAME\]/$(basename "$SPEC_PATH")/g" "$TASKS_PATH"
sed -i.bak "s/\[DESIGN_FILENAME\]/$(basename "$SPEC_PATH" .md)-design.md/g" "$TASKS_PATH"

# Remove backup file
rm "${TASKS_PATH}.bak"

echo -e "${GREEN}✅ Task breakdown document created${NC}"
echo ""
echo -e "${BLUE}📄 File: $TASKS_PATH${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. AI will analyze spec and design"
echo "  2. AI will extract user stories and requirements"
echo "  3. AI will generate concrete tasks organized by story"
echo "  4. AI will define MVP scope"
echo "  5. Review and approve task breakdown"
echo ""

# Output path for AI
echo "$TASKS_PATH"
