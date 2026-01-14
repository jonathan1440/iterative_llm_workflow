# TASKS TEMPLATE - Example: User Authentication Implementation

This is a reference template showing what a high-quality task breakdown looks like. Use this as a guide when creating your own task plans.

---

# Implementation Tasks: User Authentication with Email/Password

**Created**: 2026-01-11  
**Status**: In Progress  
**Related Spec**: user-authentication.md  
**Related Design**: user-authentication-design.md

---

## Task Format

**Every task MUST follow this detailed, self-contained format:**

```
- [ ] [TaskID] [P?] [Story?] Description with file path

  **File**: [exact file path]
  
  **Requirements** (from design):
  - [Detailed requirement 1]
  - [Detailed requirement 2]
  
  **Implementation Details**:
  - [Specific implementation detail 1]
  - [Specific implementation detail 2]
  
  **Error Handling**:
  - [Error handling requirements]
  
  **Dependencies**: [Task IDs that must be complete first]
  
  **Acceptance**: [How to verify this task is complete]
```

✅ **Good Examples** (see T017, T019, T021 below for full examples):
- Detailed, self-contained tasks with all context needed
- Include file paths, fields, methods, error handling, dependencies
- Clear acceptance criteria

❌ **Bad Examples** (too brief, not self-contained):
- `- [ ] T017 [US1] Create User model` (missing details, file path, fields, methods)
- `- [ ] T019 [US1] Implement UserService` (missing methods, error handling, dependencies)
- Tasks that require loading design doc to understand (should extract details into task)

---

## MVP Definition

**Minimum Viable Product** = Phase 1 + Phase 2 + Phase 3 (User Story 1)

**What MVP Delivers**:
- User registration with email/password
- User login with session management
- Basic profile access for authenticated users
- Password security with bcrypt hashing

**What MVP Defers**:
- Phase 4 (User Story 2): Password reset via email
- Phase 5 (User Story 3): Two-factor authentication (2FA)
- Email verification (send email but don't require it)
- Session management UI (users can't see/revoke sessions)

**Why This Scope**:
- Validates core auth flow works
- Can be tested by real users
- Provides foundation for password reset and 2FA
- Estimated: ~3-4 days of development

**Success Metrics** (from spec):
- Users complete registration in < 2 minutes
- 95% of login attempts succeed on first try (valid credentials)
- Zero unauthorized account access

---

## Phase 1: Setup

**Goal**: Initialize project structure and dependencies

**Tasks**:
- [ ] T001 Initialize Node.js project structure (src/, tests/, config/)
- [ ] T002 Install dependencies: express, bcrypt, pg, dotenv, winston, jest
- [ ] T003 Configure environment variables in .env.example (DB_URL, JWT_SECRET, PORT)
- [ ] T004 Setup PostgreSQL connection pool in src/db/connection.js (max 20 connections)
- [ ] T005 [P] Create .gitignore (node_modules, .env, logs/, coverage/)
- [ ] T006 [P] Setup ESLint and Prettier per agents.md standards
- [ ] T007 [P] Create basic Express app structure in src/app.js

**Completion Criteria**: 
- Project structure exists
- `npm install` succeeds
- Database connects successfully (test with simple query)
- Environment variables documented

---

## Phase 2: Foundation (Blocking Prerequisites)

**Goal**: Build shared infrastructure required by all user stories

**What Makes This Foundation**:
- Database schema (all tables created upfront)
- Error handling framework
- Logging setup
- Request validation middleware
- Response formatting
- Testing framework

**Tasks**:
- [ ] T008 Create database migration 001_initial_schema.sql (users, sessions, password_resets tables)
- [ ] T009 Run migration to create all tables (verify with \dt in psql)
- [ ] T010 [P] Create base error classes in src/errors/ (ValidationError, AuthError, DatabaseError)
- [ ] T011 [P] Setup Winston logging in src/utils/logger.js (error/warn/info levels)
- [ ] T012 [P] Create request validation middleware in src/middleware/validate.js (uses Joi)
- [ ] T013 [P] Create API response formatter in src/utils/response.js (success/error formats)
- [ ] T014 [P] Setup Jest test framework in tests/ (unit/, integration/ folders)
- [ ] T015 Create global error handler middleware in src/middleware/error-handler.js
- [ ] T016 [P] Create database query helpers in src/db/queries.js (parameterized queries)

**Completion Criteria**:
- All 4 database tables exist (users, sessions, password_resets, audit_log)
- Base utilities work (logger logs, errors throw correctly)
- Jest runs (even with 0 tests)
- Middleware integrated in Express app

---

## Phase 3: User Story 1 (P1 - MVP) - User Registration and Login

**Story Goal**: Users can create accounts and log in to access the system

**Acceptance Criteria** (from spec):
- [ ] User can register with email address and password
- [ ] Email format is validated before account creation
- [ ] Password must meet security requirements (8+ chars, letter + number)
- [ ] User receives session token after registration (no email verification required)
- [ ] User can log in with email/password and receive session token
- [ ] Failed login shows clear error without exposing whether email exists
- [ ] After 5 failed attempts, account locks for 15 minutes

**Independent Test Scenario**:

```bash
# 1. Start server
npm start

# 2. Register new user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"sarah@example.com","password":"SecurePass123"}'
# Expected: 201 Created with user object and session token

# 3. Verify user in database
psql -d auth_db -c "SELECT email, email_verified, status FROM users WHERE email='sarah@example.com';"
# Expected: sarah@example.com | false | active

# 4. Login with same credentials
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"sarah@example.com","password":"SecurePass123"}'
# Expected: 200 OK with session token

# 5. Access protected resource
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer <session_token>"
# Expected: 200 OK with user profile

# 6. Test account lockout
# Make 5 failed login attempts
for i in {1..5}; do
  curl -X POST http://localhost:3000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"sarah@example.com","password":"WrongPass123"}'
done
# Expected: 6th attempt returns 423 Locked

Success = All steps complete without errors
```

**Tasks**:

### Data Models (can be parallel)
- [ ] T017 [P] [US1] Create User model in src/models/user.js

  **File**: src/models/user.js
  
  **Fields** (from design):
  - id: UUID (primary key, auto-generated)
  - email: string (unique, required, validated with regex pattern)
  - password_hash: string (required, bcrypt hashed, never plain text)
  - email_verified: boolean (default: false)
  - status: enum('active', 'inactive') (default: 'active')
  - failed_login_count: integer (default: 0)
  - locked_until: timestamp (nullable, null means not locked)
  
  **Methods** (from design):
  - create(userData): Create new user, hash password using bcrypt cost 10, return user object
  - findByEmail(email): Find user by email, return user object or null
  - updateFailedLoginCount(userId): Increment failed_login_count by 1
  - lockAccount(userId, durationMinutes): Set locked_until to now + durationMinutes
  
  **Error Handling**:
  - Use ValidationError from src/errors/validation-error.js for invalid input
  - Use DatabaseError from src/errors/database-error.js for DB failures
  - Never expose internal errors to callers (per agents.md)
  
  **Dependencies**: T008-T016 (Foundation tasks must be complete)
  
  **Acceptance**: User model can be imported, instantiated, and all methods work correctly

- [ ] T018 [P] [US1] Create Session model in src/models/session.js

  **File**: src/models/session.js
  
  **Fields** (from design):
  - id: UUID (primary key, auto-generated)
  - user_id: UUID (foreign key to users.id, required)
  - token: string (64 random bytes as hex, unique, required)
  - created_at: timestamp (default: now)
  - expires_at: timestamp (required, 24 hours from creation)
  - last_activity_at: timestamp (default: now, updated on use)
  
  **Methods** (from design):
  - create(userId, token): Create session, return session object
  - findByToken(token): Find session by token, return session object or null
  - updateActivity(sessionId): Update last_activity_at to current timestamp
  - delete(sessionId): Delete session by ID
  
  **Error Handling**:
  - Use DatabaseError for DB failures
  - Never expose internal errors to callers
  
  **Dependencies**: T008-T016 (Foundation tasks must be complete)
  
  **Acceptance**: Session model can be imported, all methods work correctly

### Business Logic
- [ ] T019 [US1] Implement UserService in src/services/user-service.js

  **File**: src/services/user-service.js
  
  **Methods** (from design):
  - hashPassword(password): Hash password using bcrypt cost 10, return hash string
  - validateEmail(email): Validate email format with regex pattern, return boolean
  - createUser(email, password): Validate email format, hash password, call User.create(), return user object
  
  **Error Handling**:
  - ValidationError for invalid email format (400)
  - ValidationError for weak password (per design: 8+ chars, letter + number)
  - DatabaseError for duplicate email (409 conflict)
  - Never expose internal errors to callers (per agents.md)
  
  **Dependencies**: T017 (User model must exist)
  
  **Acceptance**: All methods work correctly, error handling follows standards

- [ ] T020 [US1] Implement AuthService in src/services/auth-service.js

  **File**: src/services/auth-service.js
  
  **Methods** (from design):
  - login(email, password): Verify credentials using bcrypt, track failures, create session, return session token
  - handleFailedLogin(userId): Increment failed_login_count, lock account if count >= 5 (15 minute lock)
  - generateSessionToken(): Generate 64 random bytes as hex string
  - checkAccountLock(user): Verify account not locked or lock expired, return boolean
  
  **Error Handling**:
  - AuthError for invalid credentials (401) - don't reveal if email exists
  - AuthError for locked account (423)
  - Never expose internal errors to callers
  
  **Dependencies**: T017 (User model), T018 (Session model), T019 (UserService must exist)
  
  **Acceptance**: Login flow works, account lockout works after 5 failures, lock expires after 15 minutes

### API Layer
- [ ] T021 [US1] Create POST /api/auth/register endpoint in src/routes/auth.js

  **File**: src/routes/auth.js (create new file or add to existing)
  
  **Endpoint**: POST /api/auth/register
  
  **Request Body**: { email: string, password: string }
  
  **Validation**:
  - Email format (per UserService.validateEmail)
  - Password requirements (8+ chars, letter + number)
  
  **Logic**:
  - Call UserService.createUser(email, password)
  - Create session using Session.create(userId, token)
  - Generate session token using AuthService.generateSessionToken()
  - Return 201 Created with { user: {...}, token: "..." }
  
  **Error Handling**:
  - 400 Bad Request for validation errors
  - 409 Conflict for duplicate email
  - Use standard error format from src/utils/response.js
  
  **Dependencies**: T019 (UserService), T018 (Session model), T020 (AuthService for token generation)
  
  **Acceptance**: Endpoint accepts valid requests, returns 201 with user and token

- [ ] T022 [US1] Create POST /api/auth/login endpoint in src/routes/auth.js

  **File**: src/routes/auth.js
  
  **Endpoint**: POST /api/auth/login
  
  **Request Body**: { email: string, password: string }
  
  **Validation**:
  - Request body must have email and password
  
  **Logic**:
  - Call AuthService.login(email, password)
  - Track failed attempts (handled by AuthService)
  - Return 200 OK with { token: "..." }
  
  **Error Handling**:
  - 401 Unauthorized for invalid credentials (don't reveal if email exists)
  - 423 Locked for locked account
  - Use standard error format from src/utils/response.js
  
  **Dependencies**: T020 (AuthService must exist)
  
  **Acceptance**: Endpoint accepts valid credentials, returns 200 with token; rejects invalid credentials with 401

- [ ] T023 [US1] Create GET /api/auth/me endpoint in src/routes/auth.js

  **File**: src/routes/auth.js
  
  **Endpoint**: GET /api/auth/me
  
  **Authentication**: Requires authentication middleware (req.user must exist)
  
  **Logic**:
  - Return current user profile from req.user
  - Return 200 OK with { user: {...} }
  
  **Error Handling**:
  - 401 Unauthorized if invalid/missing token (handled by middleware)
  - Use standard error format from src/utils/response.js
  
  **Dependencies**: T024 (Authentication middleware must exist)
  
  **Acceptance**: Endpoint returns user profile with valid token, rejects with 401 for invalid token

- [ ] T024 [US1] Create authentication middleware in src/middleware/auth.js

  **File**: src/middleware/auth.js
  
  **Functionality**:
  - Extract token from Authorization header (format: "Bearer <token>")
  - Validate session using Session.findByToken(token)
  - Check expiration (expires_at > now)
  - Update activity using Session.updateActivity(sessionId)
  - Attach user to request object (req.user = user object)
  
  **Error Handling**:
  - 401 Unauthorized for missing/invalid token
  - 401 Unauthorized for expired session
  - Use standard error format from src/utils/response.js
  
  **Dependencies**: T018 (Session model must exist)
  
  **Acceptance**: Middleware validates tokens, attaches user to request, rejects invalid tokens with 401

### Testing
- [ ] T025 [P] [US1] Write unit tests for UserService in tests/unit/user-service.test.js

  **File**: tests/unit/user-service.test.js
  
  **Test Cases**:
  - hashPassword creates valid bcrypt hash (can verify with bcrypt.compare)
  - validateEmail accepts valid emails (test@example.com, user.name@domain.co.uk)
  - validateEmail rejects invalid emails (no @, no domain, invalid format)
  - createUser inserts user correctly (verify in test DB)
  - createUser rejects weak passwords (< 8 chars, no letter, no number)
  - createUser rejects duplicate emails (409 error)
  
  **Setup**: Mock database or use test database
  
  **Dependencies**: T019 (UserService implemented)
  
  **Acceptance**: All tests pass, coverage > 80% for UserService

- [ ] T026 [P] [US1] Write unit tests for AuthService in tests/unit/auth-service.test.js

  **File**: tests/unit/auth-service.test.js
  
  **Test Cases**:
  - login succeeds with valid credentials (returns token)
  - login fails with invalid password (returns AuthError)
  - failed login count increments on failed login
  - account locks after 5 failures (locked_until set)
  - locked account rejects login (423 error)
  - lock expires after 15 minutes (can login after expiration)
  
  **Setup**: Mock database or use test database
  
  **Dependencies**: T020 (AuthService implemented)
  
  **Acceptance**: All tests pass, coverage > 80% for AuthService

- [ ] T027 [P] [US1] Write integration tests for auth endpoints in tests/integration/auth.test.js

  **File**: tests/integration/auth.test.js
  
  **Test Cases**:
  - POST /auth/register happy path (201, returns user and token)
  - POST /auth/register with invalid email (400)
  - POST /auth/register with weak password (400)
  - POST /auth/register with duplicate email (409)
  - POST /auth/login happy path (200, returns token)
  - POST /auth/login with invalid credentials (401)
  - POST /auth/login account lockout (423 after 5 failures)
  - GET /auth/me with valid token (200, returns user)
  - GET /auth/me with invalid token (401)
  
  **Setup**: Test server, test database
  
  **Dependencies**: T021, T022, T023, T024 (All endpoints and middleware)
  
  **Acceptance**: All integration tests pass

### Verification Tasks

- [ ] T028 [US1] Verify models milestone (T017, T018)

  **Verification Type**: Milestone Checkpoint
  
  **Dependencies**: T017, T018 (all model tasks complete)
  
  **Checks**:
  - Files exist: src/models/user.js, src/models/session.js
  - Syntax valid (run linter: `npm run lint` - no errors)
  - All required methods present (create, findByEmail, updateFailedLoginCount, lockAccount, etc.)
  - Error classes imported correctly (ValidationError, DatabaseError from src/errors/)
  - JSDoc comments complete for all public methods
  - Can import models without errors
  
  **Manual Test**:
  ```javascript
  const User = require('./src/models/user');
  const Session = require('./src/models/session');
  // Should import without errors
  ```
  
  **Acceptance**: All checks pass, models can be imported and used

- [ ] T029 [US1] Verify services milestone (T019, T020)

  **Verification Type**: Milestone Checkpoint
  
  **Dependencies**: T019, T020 (all service tasks complete), T028 (models verified)
  
  **Checks**:
  - Services import models correctly (no circular dependencies)
  - Error handling follows agents.md standard (never expose internal errors)
  - Business logic matches design specifications
  - All dependencies satisfied (models exist and work)
  
  **Manual Test**:
  - Create temporary test file to invoke services in isolation
  - Test UserService.createUser() with valid data
  - Test AuthService.login() with valid credentials
  - Verify error handling works (invalid input, duplicate email, etc.)
  
  **Acceptance**: All checks pass, services work correctly with models

- [ ] T030 [US1] Verify API milestone (T021-T024)

  **Verification Type**: Milestone Checkpoint
  
  **Dependencies**: T021-T024 (all API tasks complete), T029 (services verified)
  
  **Checks**:
  - All endpoints exist (POST /auth/register, POST /auth/login, GET /auth/me)
  - Middleware integrated correctly (auth middleware works)
  - Request validation present (email format, password requirements)
  - Error responses formatted correctly (use standard format from src/utils/response.js)
  
  **Manual Test**:
  ```bash
  # Start server
  npm start
  
  # Test registration
  curl -X POST http://localhost:3000/api/auth/register \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"SecurePass123"}'
  # Expected: 201 Created with user and token
  
  # Test login
  curl -X POST http://localhost:3000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"SecurePass123"}'
  # Expected: 200 OK with token
  
  # Test protected endpoint
  curl -X GET http://localhost:3000/api/auth/me \
    -H "Authorization: Bearer <token>"
  # Expected: 200 OK with user profile
  
  # Test error cases
  curl -X POST http://localhost:3000/api/auth/register \
    -H "Content-Type: application/json" \
    -d '{"email":"invalid","password":"weak"}'
  # Expected: 400 Bad Request
  ```
  
  **Acceptance**: All endpoints work, error handling correct, manual tests pass

- [ ] T031 [US1] Verify tests milestone (T025-T027)

  **Verification Type**: Milestone Checkpoint
  
  **Dependencies**: T025-T027 (all test tasks complete), T030 (API verified)
  
  **Checks**:
  - All test files exist (tests/unit/user-service.test.js, etc.)
  - Tests can run without errors
  - Test coverage meets requirements (> 80% for new code)
  - No linting errors
  
  **Automated Test**:
  ```bash
  npm test
  ```
  
  **Expected Results**:
  - All unit tests pass (UserService, AuthService)
  - All integration tests pass (auth endpoints)
  - Coverage > 80% for UserService, AuthService, models
  - No linting errors (`npm run lint` passes)
  
  **Acceptance**: All tests pass, coverage meets requirements, no linting errors

- [ ] T032 [US1] Verify story completion (independent test scenario)

  **Verification Type**: Story-Level Verification
  
  **Dependencies**: All previous tasks complete (T017-T031)
  
  **Test Scenario**: Run independent test scenario from story definition above
  
  **Steps** (from story definition):
  1. Start server: `npm start`
  2. Register new user: `POST /api/auth/register` with valid email/password
  3. Verify user in database: `SELECT email, status FROM users WHERE email='sarah@example.com'`
  4. Login with credentials: `POST /api/auth/login`
  5. Access protected resource: `GET /api/auth/me` with token
  6. Test account lockout: Make 5 failed login attempts, verify 6th returns 423
  
  **Expected**: All steps pass, story works independently without US2 or US3
  
  **Acceptance**: Independent test scenario passes, story is complete and verified

- [ ] T033 [US1] Update API documentation with new endpoints (OpenAPI spec)

  **File**: docs/api/openapi.yaml (or existing API docs)
  
  **Requirements**:
  - Document POST /api/auth/register endpoint
  - Document POST /api/auth/login endpoint
  - Document GET /api/auth/me endpoint
  - Include request/response schemas
  - Include error responses (400, 401, 409, 423)
  
  **Dependencies**: T032 (story verified)
  
  **Acceptance**: API documentation updated, all endpoints documented

**Completion Criteria**:
- All tasks T017-T033 marked [X] (including verification tasks T028-T032)
- Independent test scenario passes (T032)
- All 7 acceptance criteria met
- Code reviewed
- All 21 test cases passing
- No linting errors

---

## Phase 4: User Story 2 (P2) - Password Reset via Email

**Story Goal**: Users can reset forgotten passwords via email link

**Acceptance Criteria** (from spec):
- [ ] User can request password reset via email
- [ ] Reset link expires after 1 hour
- [ ] User can set new password meeting security requirements
- [ ] Old password is invalidated after reset
- [ ] User is notified via email when password changes

**Independent Test Scenario**:

```bash
# Assumes US1 complete and user exists

# 1. Request password reset
curl -X POST http://localhost:3000/api/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email":"sarah@example.com"}'
# Expected: 200 OK (email sent)

# 2. Check email (in test: check database for token)
psql -d auth_db -c "SELECT token, expires_at FROM password_resets WHERE user_id=(SELECT id FROM users WHERE email='sarah@example.com') ORDER BY created_at DESC LIMIT 1;"
# Expected: token exists, expires_at is ~1 hour from now

# 3. Reset password with token
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{"token":"<token_from_step2>","password":"NewSecurePass456"}'
# Expected: 200 OK

# 4. Verify old password no longer works
curl -X POST http://localhost:3000/api/auth/login \
  -d '{"email":"sarah@example.com","password":"SecurePass123"}'
# Expected: 401 Unauthorized

# 5. Verify new password works
curl -X POST http://localhost:3000/api/auth/login \
  -d '{"email":"sarah@example.com","password":"NewSecurePass456"}'
# Expected: 200 OK with session token

Success = All steps work correctly
```

**Dependencies**: User Story 1 must be complete (need users and auth working)

**Tasks**:

### Data Model
- [ ] T034 [US2] Create PasswordReset model in src/models/password-reset.js

  **File**: src/models/password-reset.js
  
  **Fields** (from design):
  - id: UUID (primary key, auto-generated)
  - user_id: UUID (foreign key to users.id, required)
  - token: string (64 random bytes as hex, unique, required)
  - created_at: timestamp (default: now)
  - expires_at: timestamp (required, 1 hour from creation)
  - used_at: timestamp (nullable, set when token is used)
  
  **Methods** (from design):
  - create(userId, token, expiresAt): Create reset request, return password reset object
  - findByToken(token): Find reset request by token, return object or null
  - markUsed(resetId): Set used_at to current timestamp
  - cleanupExpired(): Delete expired tokens (for scheduled job)
  
  **Error Handling**:
  - Use DatabaseError for DB failures
  - Never expose internal errors to callers
  
  **Dependencies**: T008-T016 (Foundation tasks), T017-T033 (US1 complete)
  
  **Acceptance**: Model can be imported, all methods work correctly

### Services
- [ ] T035 [US2] Implement PasswordResetService in src/services/password-reset-service.js

  **File**: src/services/password-reset-service.js
  
  **Methods** (from design):
  - generateResetToken(): Generate 64 random bytes as hex string
  - createResetRequest(userId): Create token, set expiration (1 hour), call PasswordReset.create(), send email, return token
  - validateResetToken(token): Check token exists, not used (used_at is null), not expired (expires_at > now), return reset object or null
  - resetPassword(token, newPassword): Validate token, hash new password, update user.password_hash, mark token used, return success
  
  **Error Handling**:
  - ValidationError for expired/invalid token (400)
  - ValidationError for weak password (400)
  - DatabaseError for DB failures
  
  **Dependencies**: T034 (PasswordReset model), T019 (UserService for password hashing)
  
  **Acceptance**: All methods work, password reset flow works end-to-end

- [ ] T036 [US2] Integrate SendGrid email service in src/services/email-service.js

  **File**: src/services/email-service.js
  
  **Methods**:
  - sendPasswordResetEmail(email, resetLink): Send email using SendGrid API with template
  
  **Email Template**:
  - Include company branding
  - Clear reset link
  - Expiration notice (1 hour)
  
  **Error Handling**:
  - Handle SendGrid API errors gracefully (log, don't fail user request)
  - Never expose SendGrid errors to users
  
  **Dependencies**: T035 (PasswordResetService)
  
  **Acceptance**: Emails send successfully, errors handled gracefully

### API Layer
- [ ] T037 [US2] Create POST /api/auth/forgot-password endpoint in src/routes/auth.js

  **File**: src/routes/auth.js
  
  **Endpoint**: POST /api/auth/forgot-password
  
  **Request Body**: { email: string }
  
  **Validation**:
  - Email format (per UserService.validateEmail)
  
  **Logic**:
  - Find user by email (if exists)
  - Call PasswordResetService.createResetRequest(userId)
  - Always return 200 OK (don't reveal if email exists - security)
  - Rate limit: 3 requests per email per hour
  
  **Error Handling**:
  - Always return 200 (security: don't reveal email existence)
  - Rate limit returns 429 Too Many Requests
  
  **Dependencies**: T035 (PasswordResetService), T036 (EmailService)
  
  **Acceptance**: Endpoint accepts requests, sends email if user exists, rate limiting works

- [ ] T038 [US2] Create POST /api/auth/reset-password endpoint in src/routes/auth.js

  **File**: src/routes/auth.js
  
  **Endpoint**: POST /api/auth/reset-password
  
  **Request Body**: { token: string, password: string }
  
  **Validation**:
  - Token format (64 hex chars)
  - Password requirements (8+ chars, letter + number)
  
  **Logic**:
  - Call PasswordResetService.resetPassword(token, password)
  - Return 200 OK on success
  
  **Error Handling**:
  - 400 Bad Request for expired/invalid token
  - 400 Bad Request for weak password
  - Use standard error format from src/utils/response.js
  
  **Dependencies**: T035 (PasswordResetService)
  
  **Acceptance**: Endpoint accepts valid token and password, updates password, rejects invalid tokens

### Testing
- [ ] T039 [P] [US2] Write unit tests for PasswordResetService in tests/unit/password-reset-service.test.js

  **File**: tests/unit/password-reset-service.test.js
  
  **Test Cases**:
  - generateResetToken creates 64 char hex string
  - generateResetToken creates unique tokens
  - validateResetToken accepts valid, unused, unexpired token
  - validateResetToken rejects expired token
  - validateResetToken rejects used token
  - validateResetToken rejects non-existent token
  - resetPassword updates user password correctly
  - resetPassword marks token as used
  - Old password invalidated after reset
  
  **Dependencies**: T035 (PasswordResetService implemented)
  
  **Acceptance**: All tests pass, coverage > 80%

- [ ] T040 [P] [US2] Write integration tests for password reset flow in tests/integration/password-reset.test.js

  **File**: tests/integration/password-reset.test.js
  
  **Test Cases**:
  - POST /auth/forgot-password sends email (if user exists)
  - POST /auth/forgot-password returns 200 even if user doesn't exist
  - POST /auth/reset-password with valid token (200, password updated)
  - POST /auth/reset-password with expired token (400)
  - POST /auth/reset-password with used token (400)
  - POST /auth/reset-password with invalid token (400)
  - Old password no longer works after reset
  - New password works after reset
  - Rate limiting on forgot-password (429 after 3 requests)
  
  **Dependencies**: T037, T038 (All endpoints)
  
  **Acceptance**: All integration tests pass

### Verification Tasks
- [ ] T041 [US2] Verify password reset milestone (T034-T038)

  **Verification Type**: Milestone Checkpoint
  
  **Dependencies**: T034-T038 (all password reset tasks complete)
  
  **Checks**:
  - All files exist (model, services, endpoints)
  - Endpoints work correctly
  - Email sending works (or mocked)
  - Rate limiting works
  
  **Manual Test**: Run independent test scenario from story definition
  
  **Acceptance**: All checks pass, password reset flow works end-to-end

- [ ] T042 [US2] Verify story completion (independent test scenario)

  **Verification Type**: Story-Level Verification
  
  **Dependencies**: All previous tasks complete (T034-T041)
  
  **Test Scenario**: Run independent test scenario from story definition above
  
  **Acceptance**: Independent test scenario passes, story is complete and verified

- [ ] T043 [US2] Update API documentation with new endpoints (OpenAPI spec)

  **File**: docs/api/openapi.yaml
  
  **Requirements**:
  - Document POST /api/auth/forgot-password
  - Document POST /api/auth/reset-password
  - Include request/response schemas
  - Include error responses (400, 429)
  
  **Dependencies**: T042 (story verified)
  
  **Acceptance**: API documentation updated

**Completion Criteria**:
- All tasks T034-T043 marked [X] (including verification tasks T041-T042)
- Independent test passes (T042)
- All acceptance criteria met
- Email delivery tested (at least in staging)

---

## Phase 5: User Story 3 (P3) - Optional Two-Factor Authentication

**Story Goal**: Users can optionally enable 2FA for enhanced security

**Acceptance Criteria** (from spec):
- [ ] User can enable 2FA in account settings
- [ ] 2FA uses time-based codes (TOTP)
- [ ] User can see backup codes during setup
- [ ] Login requires code after password when 2FA enabled
- [ ] User can disable 2FA with password verification

**Independent Test Scenario**:

```bash
# Assumes US1 complete, user logged in

# 1. Enable 2FA
curl -X POST http://localhost:3000/api/auth/2fa/enable \
  -H "Authorization: Bearer <token>"
# Expected: 200 OK with QR code data and backup codes

# 2. Verify 2FA with code from authenticator app
curl -X POST http://localhost:3000/api/auth/2fa/verify \
  -H "Authorization: Bearer <token>" \
  -d '{"code":"123456"}'
# Expected: 200 OK (2FA now active)

# 3. Logout
curl -X POST http://localhost:3000/api/auth/logout \
  -H "Authorization: Bearer <token>"

# 4. Login requires 2FA code
curl -X POST http://localhost:3000/api/auth/login \
  -d '{"email":"sarah@example.com","password":"SecurePass123"}'
# Expected: 200 OK but session marked as "2fa_pending"

# 5. Submit 2FA code
curl -X POST http://localhost:3000/api/auth/2fa/validate \
  -d '{"email":"sarah@example.com","code":"654321"}'
# Expected: 200 OK with full session token

# 6. Access protected resource now works
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer <full_token>"
# Expected: 200 OK

Success = 2FA flow works end-to-end
```

**Dependencies**: User Story 1 must be complete

**Tasks**:

### Database Updates
- [ ] T044 [US3] Add 2FA fields to users table migration

  **File**: migrations/002_add_2fa_fields.sql (or update existing migration)
  
  **Fields to Add**:
  - two_factor_enabled: boolean (default: false)
  - two_factor_secret: text (encrypted, nullable)
  - backup_codes: text (encrypted JSON array, nullable)
  
  **Migration Command**: ALTER TABLE users ADD COLUMN two_factor_enabled BOOLEAN DEFAULT false;
  
  **Dependencies**: T008-T016 (Foundation tasks), T017-T033 (US1 complete)
  
  **Acceptance**: Migration runs successfully, fields added to users table

### Models
- [ ] T045 [US3] Update User model with 2FA methods in src/models/user.js

  **File**: src/models/user.js (update existing)
  
  **New Methods** (from design):
  - enable2FA(secret, backupCodes): Set two_factor_enabled=true, store encrypted secret and backup codes
  - disable2FA(): Set two_factor_enabled=false, clear secret and backup codes
  - verify2FACode(code): Verify TOTP code matches secret (using TwoFactorService)
  - useBackupCode(code): Verify backup code, remove from array if valid
  
  **Error Handling**:
  - ValidationError for invalid code
  - Never expose internal errors
  
  **Dependencies**: T044 (Migration complete), T017 (User model exists)
  
  **Acceptance**: Methods work correctly, 2FA can be enabled/disabled

### Services
- [ ] T046 [US3] Implement TwoFactorService in src/services/two-factor-service.js

  **File**: src/services/two-factor-service.js
  
  **Methods** (from design):
  - generateSecret(): Generate TOTP secret using speakeasy library, return secret string
  - generateQRCode(secret, email): Generate QR code data URI for authenticator apps (Google Authenticator, Authy)
  - generateBackupCodes(count=10): Generate 10 unique 8-digit backup codes, return array
  - verifyTOTP(secret, code): Verify time-based code matches secret (allow ±1 time window), return boolean
  
  **Error Handling**:
  - ValidationError for invalid code format
  - Never expose internal errors
  
  **Dependencies**: T045 (User model updated)
  
  **Acceptance**: All methods work, TOTP verification works with authenticator apps

### API Layer
- [ ] T047 [US3] Create POST /api/auth/2fa/enable endpoint in src/routes/auth.js

  **File**: src/routes/auth.js
  
  **Endpoint**: POST /api/auth/2fa/enable
  
  **Authentication**: Requires authentication middleware (req.user must exist)
  
  **Logic**:
  - Generate secret using TwoFactorService.generateSecret()
  - Generate backup codes using TwoFactorService.generateBackupCodes(10)
  - Generate QR code using TwoFactorService.generateQRCode(secret, email)
  - Return 200 OK with { qrCode: "...", backupCodes: [...] }
  - Don't activate 2FA until verified (separate endpoint)
  
  **Error Handling**:
  - 401 if not authenticated
  - Use standard error format
  
  **Dependencies**: T046 (TwoFactorService), T024 (Auth middleware)
  
  **Acceptance**: Endpoint returns QR code and backup codes, 2FA not active until verified

- [ ] T048 [US3] Create POST /api/auth/2fa/verify endpoint in src/routes/auth.js

  **File**: src/routes/auth.js
  
  **Endpoint**: POST /api/auth/2fa/verify
  
  **Authentication**: Requires authentication middleware
  
  **Request Body**: { code: string }
  
  **Logic**:
  - Verify code matches secret (using TwoFactorService.verifyTOTP())
  - If valid, call User.enable2FA(secret, backupCodes)
  - Return 200 OK on success
  
  **Error Handling**:
  - 400 Bad Request for invalid code
  - 401 if not authenticated
  
  **Dependencies**: T047 (Enable endpoint), T046 (TwoFactorService)
  
  **Acceptance**: Endpoint verifies code and activates 2FA

- [ ] T049 [US3] Update POST /api/auth/login to check 2FA status in src/routes/auth.js

  **File**: src/routes/auth.js (update existing login endpoint)
  
  **Logic**:
  - After successful password verification, check if user has 2FA enabled
  - If 2FA enabled, return partial session (marked as "2fa_pending")
  - Require 2FA validation before full access
  
  **Response Format**:
  - Without 2FA: { token: "...", user: {...} }
  - With 2FA: { token: "...", user: {...}, requires2FA: true }
  
  **Dependencies**: T022 (Login endpoint), T045 (User model with 2FA)
  
  **Acceptance**: Login returns partial session when 2FA enabled

- [ ] T050 [US3] Create POST /api/auth/2fa/validate endpoint in src/routes/auth.js

  **File**: src/routes/auth.js
  
  **Endpoint**: POST /api/auth/2fa/validate
  
  **Request Body**: { email: string, code: string }
  
  **Logic**:
  - Find user by email
  - Validate 2FA code (TOTP or backup code)
  - If valid, upgrade partial session to full session
  - Consume backup code if used
  - Return 200 OK with full session token
  
  **Error Handling**:
  - 400 Bad Request for invalid code
  - 401 if user not found or no partial session
  
  **Dependencies**: T049 (Login with 2FA check), T046 (TwoFactorService)
  
  **Acceptance**: Endpoint validates code and upgrades to full session

- [ ] T051 [US3] Create POST /api/auth/2fa/disable endpoint in src/routes/auth.js

  **File**: src/routes/auth.js
  
  **Endpoint**: POST /api/auth/2fa/disable
  
  **Authentication**: Requires authentication middleware
  
  **Request Body**: { password: string }
  
  **Logic**:
  - Verify password (for security)
  - Call User.disable2FA()
  - Return 200 OK on success
  
  **Error Handling**:
  - 401 if password incorrect
  - 401 if not authenticated
  
  **Dependencies**: T045 (User model), T024 (Auth middleware)
  
  **Acceptance**: Endpoint disables 2FA after password verification

### Testing
- [ ] T052 [P] [US3] Write unit tests for TwoFactorService in tests/unit/two-factor-service.test.js

  **File**: tests/unit/two-factor-service.test.js
  
  **Test Cases**:
  - generateSecret creates valid TOTP secret
  - generateQRCode creates valid QR code data URI
  - generateBackupCodes creates 10 unique 8-digit codes
  - verifyTOTP validates correct code
  - verifyTOTP rejects incorrect code
  - verifyTOTP allows ±1 time window
  - Backup codes are unique
  
  **Dependencies**: T046 (TwoFactorService implemented)
  
  **Acceptance**: All tests pass, coverage > 80%

- [ ] T053 [P] [US3] Write integration tests for 2FA flow in tests/integration/2fa.test.js

  **File**: tests/integration/2fa.test.js
  
  **Test Cases**:
  - POST /auth/2fa/enable returns QR code and backup codes
  - POST /auth/2fa/verify activates 2FA with valid code
  - POST /auth/2fa/verify rejects invalid code
  - POST /auth/login with 2FA enabled returns partial session
  - POST /auth/2fa/validate upgrades to full session with valid code
  - POST /auth/2fa/validate works with backup code
  - POST /auth/2fa/validate rejects invalid code
  - POST /auth/2fa/disable requires password
  - POST /auth/2fa/disable removes 2FA
  - Partial session can't access protected resources
  
  **Dependencies**: T047-T051 (All 2FA endpoints)
  
  **Acceptance**: All integration tests pass

### Verification Tasks
- [ ] T054 [US3] Verify 2FA milestone (T044-T051)

  **Verification Type**: Milestone Checkpoint
  
  **Dependencies**: T044-T051 (all 2FA tasks complete)
  
  **Checks**:
  - All files exist (migration, model updates, services, endpoints)
  - 2FA works with Google Authenticator / Authy
  - Backup codes work as fallback
  - Partial session restrictions work
  
  **Manual Test**: Test 2FA flow with authenticator app
  
  **Acceptance**: All checks pass, 2FA flow works end-to-end

- [ ] T055 [US3] Verify story completion (independent test scenario)

  **Verification Type**: Story-Level Verification
  
  **Dependencies**: All previous tasks complete (T044-T054)
  
  **Test Scenario**: Run independent test scenario from story definition above
  
  **Acceptance**: Independent test scenario passes, story is complete and verified

- [ ] T056 [US3] Update API documentation with new endpoints (OpenAPI spec)

  **File**: docs/api/openapi.yaml
  
  **Requirements**:
  - Document all 2FA endpoints
  - Include request/response schemas
  - Include error responses
  
  **Dependencies**: T055 (story verified)
  
  **Acceptance**: API documentation updated

**Completion Criteria**:
- All tasks T044-T056 marked [X] (including verification tasks T054-T055)
- Independent test passes (T055)
- 2FA works with Google Authenticator / Authy
- Backup codes work as fallback

---

## Phase 6: Polish & Cross-Cutting Concerns

**Goal**: Production readiness and final improvements

**Tasks**:

### Security Hardening
- [ ] T057 [P] Add comprehensive input validation to all endpoints (email, password, token formats)
- [ ] T058 [P] Implement rate limiting per design (5/min login, 3/hour registration)
- [ ] T059 [P] Add security headers using helmet.js (CSP, HSTS, X-Frame-Options)
- [ ] T060 [P] Add request ID tracking for all requests (UUID per request)
- [ ] T061 [P] Sanitize error messages (never expose internal details to users)

### Observability
- [ ] T062 [P] Add structured logging to all services (request_id, user_id, duration)
- [ ] T063 [P] Setup metrics collection (login rate, error rate, latency)
- [ ] T064 [P] Create health check endpoint (database, redis, email service status)
- [ ] T065 [P] Add performance monitoring (slow query alerts)

### Documentation
- [ ] T066 [P] Complete OpenAPI/Swagger documentation for all endpoints
- [ ] T067 [P] Write deployment guide (environment setup, migrations, secrets)
- [ ] T068 [P] Document error codes and meanings for API consumers
- [ ] T069 [P] Create runbook for common operations (user lockouts, password resets)

### Testing & Quality
- [ ] T070 Performance testing (100 concurrent logins, measure latency)
- [ ] T071 Security audit of all endpoints (OWASP checklist)
- [ ] T072 Load testing (1000 users, find breaking point)
- [ ] T073 Final end-to-end test (register → login → use app → reset password → 2FA)

### Deployment Preparation
- [ ] T074 [P] Create Docker configuration (Dockerfile, docker-compose.yml)
- [ ] T075 [P] Setup CI/CD pipeline (test on PR, deploy on merge)
- [ ] T076 [P] Configure production environment variables
- [ ] T077 Database backup and restore procedures

**Completion Criteria**:
- All security measures in place
- Documentation complete
- Performance acceptable (meets spec targets)
- Ready for production deployment

---

## Dependencies & Execution Flow

### Story Completion Order

```mermaid
graph TD
    Setup[Phase 1: Setup<br/>7 tasks]
    Foundation[Phase 2: Foundation<br/>9 tasks]
    US1[Phase 3: User Story 1<br/>17 tasks<br/>MVP Core Auth]
    US2[Phase 4: User Story 2<br/>9 tasks<br/>Password Reset]
    US3[Phase 5: User Story 3<br/>13 tasks<br/>2FA Optional]
    Polish[Phase 6: Polish<br/>21 tasks]
    
    Setup --> Foundation
    Foundation --> US1
    US1 --> US2
    US1 --> US3
    US2 --> Polish
    US3 --> Polish
    
    style US1 fill:#90EE90,stroke:#2d5016,stroke-width:3px
    style Setup fill:#87CEEB
    style Foundation fill:#87CEEB
    style US2 fill:#FFD700
    style US3 fill:#FFD700
    style Polish fill:#DDA0DD
```

### Within-Story Dependencies

**User Story 1 (P1 - MVP)**:
```
T017, T018 (Models - Parallel) 
  ↓
T028 (Verify models milestone)
  ↓
T019 (UserService - depends on T017)
  ↓
T020 (AuthService - depends on T019)
  ↓
T029 (Verify services milestone)
  ↓
T021, T022, T023, T024 (API endpoints and middleware - depend on T020)
  ↓
T030 (Verify API milestone)
  ↓
T025, T026, T027 (Tests - Parallel, depend on implementation)
  ↓
T031 (Verify tests milestone)
  ↓
T032 (Verify story completion)
  ↓
T033 (Update API documentation)
```

**User Story 2 (P2)**:
```
T030 (PasswordReset model)
  ↓
T031 (PasswordResetService)
  ↓
T032 (EmailService - parallel with T031)
  ↓
T033, T034 (API endpoints)
  ↓
T035, T036 (Tests - parallel)
  ↓
T037, T038 (Verification)
```

### Parallel Execution Opportunities

**Within User Story 1** (single developer):
- T017 ∥ T018 (different models, different files)
- T025 ∥ T026 ∥ T027 (different test files)

**Within Foundation** (single developer):
- T010 ∥ T011 ∥ T012 ∥ T013 ∥ T014 ∥ T016 (different files, independent)

**Across Stories** (multi-developer team):
- After US1 complete:
  - Dev 1: US2 (T030-T038)
  - Dev 2: US3 (T039-T050)
  - Dev 3: Polish security tasks (T051-T055)

**Polish Phase** (multi-developer team):
- Most polish tasks (T051-T063) can run in parallel
- Test tasks (T064-T067) should be sequential

**Recommendation for Solo Development**:
- Complete US1 fully before starting US2
- Avoid context switching between stories
- Each story should work independently before moving to next
- Expected timeline: US1 (2 days) → US2 (1 day) → US3 (1.5 days) → Polish (1 day) = 5.5 days total

---

## Task Summary

**Total Tasks**: 77 (updated count with verification tasks)
- Phase 1 (Setup): 7 tasks
- Phase 2 (Foundation): 9 tasks
- Phase 3 (US1 - MVP): 17 tasks (T017-T033, including 5 verification tasks)
- Phase 4 (US2): 10 tasks (T034-T043, including 2 verification tasks)
- Phase 5 (US3): 13 tasks (T044-T056, including 2 verification tasks)
- Phase 6 (Polish): 21 tasks (T057-T077)

**Parallel Tasks**: 26 tasks marked [P] (~37% parallelizable)

**Estimated Effort**:
- MVP (P1 + P2 + P3): ~3-4 days
  - Setup: 0.5 day
  - Foundation: 0.5 day
  - US1: 2-3 days
- P2 (Phase 4): ~1 day
- P3 (Phase 5): ~1.5 days
- Polish: ~1 day
- **Total**: ~6-8 days (single developer, full-time)

---

## Implementation Strategy

### Recommended Approach for Solo Developer

**Week 1: MVP**
- Day 1: Setup + Foundation (T001-T016)
- Days 2-3: User Story 1 (T017-T033, including verification tasks)
- Deploy MVP, gather feedback

**Week 2: Additional Features** (if MVP validates)
- Day 4: User Story 2 Password Reset (T030-T038)
- Days 5-6: User Story 3 Two-Factor Auth (T039-T050) OR skip if users don't need

**Week 3: Production Ready**
- Day 7: Polish & hardening (T051-T071)
- Deploy to production

### Alternative: Parallel Development (3 developers)

**Sprint 1 (1 week): MVP**
- All devs: Setup + Foundation (T001-T016) - 1 day
- Dev 1 (lead): Models + services (T017-T020) - 2 days
- Dev 2: API endpoints (T021-T024) - 2 days (starts after T020)
- Dev 3: Tests (T025-T027) - 2 days (starts after T024)
- All devs: Story verification - 0.5 day
- **Result**: Working MVP in 1 week

**Sprint 2 (1 week): P2 + P3**
- Dev 1: US2 Password Reset (T030-T038) - 3 days
- Dev 2: US3 Two-Factor (T039-T050) - 4 days
- Dev 3: Polish security (T051-T055) - 2 days, then docs (T060-T063)
- **Result**: Full feature set in 2 weeks total

**Sprint 3 (3 days): Production Ready**
- Dev 1: Testing (T064-T067)
- Dev 2: Deployment (T068-T071)
- Dev 3: Monitoring (T056-T059)
- **Result**: Production-ready in 2.5 weeks total

---

**Last Updated**: 2026-01-11

**Status**: [X] Draft [ ] In Progress [ ] Complete

**Progress**: 0/77 tasks complete (0%)
