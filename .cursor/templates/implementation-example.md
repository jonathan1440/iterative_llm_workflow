# IMPLEMENTATION EXAMPLE - User Story 1: User Registration and Login

This document shows a complete implementation walkthrough for User Story 1, demonstrating the entire process from start to finish.

---

## Starting State

**Tasks File**: `docs/specs/user-authentication-tasks.md`
**Current Progress**: Setup (Phase 1) and Foundation (Phase 2) complete
**Starting Story**: User Story 1 (Phase 3) - 0/13 tasks complete

---

## Step 1: Load Story Context

```bash
$ /implement-story "User Story 1"

🔍 Checking prerequisites for implementing: User Story 1

✓ Tasks file found: docs/specs/user-authentication-tasks.md
✓ Story found in tasks file
✓ Phase 1 (Setup) complete (7/7 tasks)
✓ Phase 2 (Foundation) complete (9/9 tasks)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Ready to implement: User Story 1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Implementing: User Story 1 - User Registration and Login

**Goal**: Users can create accounts and log in to access the system

**Acceptance Criteria**:
- [ ] User can register with email address and password
- [ ] Email format is validated before account creation
- [ ] Password must meet security requirements (8+ chars, letter + number)
- [ ] User receives session token after registration
- [ ] User can log in with email/password
- [ ] Failed login shows clear error without exposing whether email exists
- [ ] After 5 failed attempts, account locks for 15 minutes

**Tasks**: 13 tasks (T017-T029)
- Data Models: 2 tasks
- Business Logic: 2 tasks
- API Layer: 4 tasks
- Testing: 3 tasks
- Verification: 2 tasks

**Independent Test**: Defined (will run at end)

**Estimated**: ~2-3 days

Ready to start? [yes]
```

---

## Step 2: Task T017 - Create User Model

### Task Details

```
🔨 Current Task: T017 [P] [US1] Create User model in src/models/user.js

**Can run in parallel with**: T018 (Session model - different file)

**Implementation approach**:
1. Create src/models/user.js
2. Define User class with all fields
3. Implement each method with error handling
4. Add JSDoc comments
5. Export the class

Start implementation? [yes]
```

### Implementation (Composer Mode)

```javascript
// src/models/user.js
const db = require('../db/connection');
const { DatabaseError, ValidationError } = require('../errors');

/**
 * User model for authentication and authorization
 */
class User {
  constructor(data) {
    this.id = data.id;
    this.email = data.email;
    this.password_hash = data.password_hash;
    this.email_verified = data.email_verified || false;
    this.status = data.status || 'active';
    this.failed_login_count = data.failed_login_count || 0;
    this.locked_until = data.locked_until;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }

  /**
   * Create a new user
   * @param {string} email - User email address
   * @param {string} password_hash - Hashed password
   * @returns {Promise<User>} Created user
   * @throws {ValidationError} If email already exists
   * @throws {DatabaseError} If database operation fails
   */
  static async create(email, password_hash) {
    const query = `
      INSERT INTO users (email, password_hash)
      VALUES ($1, $2)
      RETURNING *
    `;
    
    try {
      const result = await db.query(query, [email, password_hash]);
      return new User(result.rows[0]);
    } catch (error) {
      if (error.code === '23505') { // Unique violation
        throw new ValidationError('Email already exists');
      }
      throw new DatabaseError('Failed to create user', error);
    }
  }

  /**
   * Find user by email
   * @param {string} email - User email address
   * @returns {Promise<User|null>} User or null if not found
   * @throws {DatabaseError} If database operation fails
   */
  static async findByEmail(email) {
    const query = 'SELECT * FROM users WHERE email = $1';
    
    try {
      const result = await db.query(query, [email]);
      return result.rows[0] ? new User(result.rows[0]) : null;
    } catch (error) {
      throw new DatabaseError('Failed to find user', error);
    }
  }

  /**
   * Update failed login count
   * @returns {Promise<void>}
   * @throws {DatabaseError} If database operation fails
   */
  async updateFailedLoginCount() {
    const query = `
      UPDATE users 
      SET failed_login_count = failed_login_count + 1,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
    `;
    
    try {
      await db.query(query, [this.id]);
      this.failed_login_count += 1;
    } catch (error) {
      throw new DatabaseError('Failed to update failed login count', error);
    }
  }

  /**
   * Lock user account
   * @param {number} minutes - Duration to lock account
   * @returns {Promise<void>}
   * @throws {DatabaseError} If database operation fails
   */
  async lockAccount(minutes = 15) {
    const locked_until = new Date(Date.now() + minutes * 60 * 1000);
    const query = `
      UPDATE users 
      SET locked_until = $1,
          status = 'locked',
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
    `;
    
    try {
      await db.query(query, [locked_until, this.id]);
      this.locked_until = locked_until;
      this.status = 'locked';
    } catch (error) {
      throw new DatabaseError('Failed to lock account', error);
    }
  }

  /**
   * Check if account is currently locked
   * @returns {boolean}
   */
  isLocked() {
    if (!this.locked_until) return false;
    return new Date() < new Date(this.locked_until);
  }

  /**
   * Reset failed login count
   * @returns {Promise<void>}
   * @throws {DatabaseError} If database operation fails
   */
  async resetFailedLoginCount() {
    const query = `
      UPDATE users 
      SET failed_login_count = 0,
          locked_until = NULL,
          status = 'active',
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
    `;
    
    try {
      await db.query(query, [this.id]);
      this.failed_login_count = 0;
      this.locked_until = null;
      this.status = 'active';
    } catch (error) {
      throw new DatabaseError('Failed to reset failed login count', error);
    }
  }

  /**
   * Convert user to safe JSON (no password hash)
   * @returns {Object}
   */
  toJSON() {
    return {
      id: this.id,
      email: this.email,
      email_verified: this.email_verified,
      status: this.status,
      created_at: this.created_at
    };
  }
}

module.exports = User;
```

### Mark Complete

```bash
$ bash .cursor/scripts/mark-task-complete.sh docs/specs/user-authentication-tasks.md T017

✓ Marked complete:
  - [X] T017 [P] [US1] Create User model in src/models/user.js

User Story 1 Progress: 1/13 tasks (8%)

✅ Task T017 marked complete
```

---

## Step 3: Task T018 - Create Session Model

```
🔨 Current Task: T018 [P] [US1] Create Session model in src/models/session.js

**Can run in parallel with**: T017 (already complete)

[Implementation similar to User model, creates Session class...]

✅ T018 complete
User Story 1 Progress: 2/13 tasks (15%)
```

---

## Verification Checkpoint: Models Complete

```
🔍 Verification Checkpoint: Models

Running checks:
1. Files exist and syntax valid
   $ node -c src/models/user.js
   $ node -c src/models/session.js
   ✓ Both files have valid syntax

2. All required methods present
   ✓ User: create, findByEmail, updateFailedLoginCount, lockAccount
   ✓ Session: create, findByToken, updateActivity, delete

3. Error classes imported correctly
   ✓ ValidationError, DatabaseError imported

4. JSDoc complete
   ✓ All public methods documented

✅ Models verification passed - proceeding to services
```

---

## Step 4: Task T019 - Implement UserService

```
🔨 Current Task: T019 [US1] Implement UserService in src/services/user-service.js

**Depends on**: T017 (User model - complete ✓)

**Implementation details**:
- hashPassword(password) using bcrypt cost 10
- validateEmail(email) using regex
- createUser(email, password) - hash password, insert user
- Error handling for duplicate email
```

### Implementation

```javascript
// src/services/user-service.js
const bcrypt = require('bcrypt');
const User = require('../models/user');
const { ValidationError } = require('../errors');
const logger = require('../utils/logger');

const BCRYPT_COST = 10;
const EMAIL_REGEX = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
const PASSWORD_MIN_LENGTH = 8;

class UserService {
  /**
   * Hash password using bcrypt
   * @param {string} password - Plain text password
   * @returns {Promise<string>} Hashed password
   * @throws {ValidationError} If password is too weak
   */
  static async hashPassword(password) {
    // Validate password strength
    if (password.length < PASSWORD_MIN_LENGTH) {
      throw new ValidationError(
        `Password must be at least ${PASSWORD_MIN_LENGTH} characters`
      );
    }
    
    if (!/[a-zA-Z]/.test(password)) {
      throw new ValidationError('Password must contain at least one letter');
    }
    
    if (!/[0-9]/.test(password)) {
      throw new ValidationError('Password must contain at least one number');
    }

    return await bcrypt.hash(password, BCRYPT_COST);
  }

  /**
   * Validate email format
   * @param {string} email - Email address to validate
   * @returns {boolean} True if valid
   * @throws {ValidationError} If email is invalid
   */
  static validateEmail(email) {
    if (!email || typeof email !== 'string') {
      throw new ValidationError('Email is required');
    }

    if (!EMAIL_REGEX.test(email)) {
      throw new ValidationError('Invalid email format');
    }

    if (email.length > 255) {
      throw new ValidationError('Email is too long (max 255 characters)');
    }

    return true;
  }

  /**
   * Create a new user
   * @param {string} email - User email
   * @param {string} password - Plain text password
   * @returns {Promise<User>} Created user
   * @throws {ValidationError} If validation fails
   */
  static async createUser(email, password) {
    // Validate inputs
    this.validateEmail(email);
    
    // Hash password (this also validates password strength)
    const password_hash = await this.hashPassword(password);

    // Create user
    try {
      const user = await User.create(email, password_hash);
      logger.info('User created', { user_id: user.id, email: user.email });
      return user;
    } catch (error) {
      logger.error('Failed to create user', { email, error: error.message });
      throw error;
    }
  }

  /**
   * Verify password matches hash
   * @param {string} password - Plain text password
   * @param {string} hash - Hashed password
   * @returns {Promise<boolean>}
   */
  static async verifyPassword(password, hash) {
    return await bcrypt.compare(password, hash);
  }
}

module.exports = UserService;
```

```bash
✅ T019 complete
User Story 1 Progress: 3/13 tasks (23%)
```

---

## Step 5: Task T020 - Implement AuthService

```
🔨 Current Task: T020 [US1] Implement AuthService in src/services/auth-service.js

**Depends on**: T019 (UserService - complete ✓)

[Implementation creates login logic, session management, account locking...]

✅ T020 complete
User Story 1 Progress: 4/13 tasks (31%)
```

---

## Verification Checkpoint: Services Complete

```
🔍 Verification Checkpoint: Services

1. Services import models correctly
   ✓ UserService imports User model
   ✓ AuthService imports User and Session models

2. Error handling follows standard
   ✓ All errors are custom error classes
   ✓ No internal errors exposed to users

3. Business logic matches design
   ✓ Password hashing uses bcrypt cost 10
   ✓ Account locks after 5 failed attempts
   ✓ Lock duration is 15 minutes

4. Dependencies satisfied
   ✓ AuthService can use UserService methods

Optional manual test:
$ node
> const UserService = require('./src/services/user-service');
> UserService.createUser('test@example.com', 'TestPass123').then(console.log);
[User object logged]

✅ Services verification passed - proceeding to API
```

---

## Step 6: Tasks T021-T024 - Implement API Endpoints

```
🔨 Tasks T021-T024: API Layer (4 tasks)

- T021: POST /api/auth/register
- T022: POST /api/auth/login
- T023: GET /api/auth/me
- T024: Auth middleware

[Implementation creates Express routes, middleware, error handling...]

✅ All API tasks complete (T021-T024)
User Story 1 Progress: 8/13 tasks (62%)
```

---

## Verification Checkpoint: API Complete

```
🔍 Verification Checkpoint: API

Running manual tests:

1. Start server:
   $ npm start
   Server listening on port 3000 ✓

2. Test registration:
   $ curl -X POST http://localhost:3000/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"TestPass123"}'
   
   Response: 201 Created
   {
     "user": {"id": "...", "email": "test@example.com"},
     "session": {"token": "...", "expires_at": "..."}
   }
   ✓ Registration works

3. Test login:
   $ curl -X POST http://localhost:3000/api/auth/login \
     -d '{"email":"test@example.com","password":"TestPass123"}'
   
   Response: 200 OK with session token ✓

4. Test protected endpoint:
   $ curl -X GET http://localhost:3000/api/auth/me \
     -H "Authorization: Bearer <token>"
   
   Response: 200 OK with user profile ✓

5. Test validation:
   $ curl -X POST http://localhost:3000/api/auth/register \
     -d '{"email":"invalid","password":"weak"}'
   
   Response: 400 Bad Request with field errors ✓

✅ API verification passed - proceeding to tests
```

---

## Step 7: Tasks T025-T027 - Write Tests

```
🔨 Tasks T025-T027: Testing (3 tasks, can run in parallel)

- T025: Unit tests for UserService
- T026: Unit tests for AuthService
- T027: Integration tests for auth endpoints

[Implementation creates comprehensive test suites...]

✅ All test tasks complete (T025-T027)
User Story 1 Progress: 11/13 tasks (85%)
```

---

## Verification Checkpoint: Tests Complete

```
🔍 Verification Checkpoint: Tests

Running test suite:
$ npm test

 PASS  tests/unit/user-service.test.js
  UserService
    hashPassword
      ✓ creates valid bcrypt hash (265ms)
      ✓ rejects password < 8 chars
      ✓ rejects password without letter
      ✓ rejects password without number
    validateEmail
      ✓ accepts valid email
      ✓ rejects invalid format
      ✓ rejects email > 255 chars
    createUser
      ✓ creates user with hashed password
      ✓ rejects duplicate email

 PASS  tests/unit/auth-service.test.js
  AuthService
    login
      ✓ succeeds with valid credentials
      ✓ fails with invalid password
      ✓ increments failed login count
      ✓ locks account after 5 failures
    [8 more tests...]

 PASS  tests/integration/auth.test.js
  POST /auth/register
    ✓ creates user and returns session
    ✓ validates email format
    ✓ validates password strength
    ✓ rejects duplicate email
  POST /auth/login
    ✓ returns session for valid credentials
    ✓ rejects invalid credentials
    ✓ locks account after 5 failures
  [6 more tests...]

Test Suites: 3 passed, 3 total
Tests:       21 passed, 21 total
Coverage:    87.3%

✅ All tests passing - proceeding to verification
```

---

## Step 8: Learning Capture

```
## Learning Capture

Did we discover any new principles or common mistakes during this implementation?

**Pattern discovered**: Always validate before expensive operations

In UserService, we validate email format BEFORE hashing password (which takes ~250ms).
This prevents wasting CPU on invalid requests.

Would you like to add this to agents.md? [yes]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Adding to agents.md:

## Common Mistakes

**Don't do expensive operations before validation**
- Mistake: Hashing password before validating email format
- Why wrong: Wastes ~250ms CPU on invalid requests
- Correct: Validate all inputs first, then do expensive operations
- Example: `validateEmail(email)` before `hashPassword(password)`
- Added: 2026-01-11

✅ Learning captured in agents.md
```

---

## Step 9: Task T028 - Independent Test Scenario

```
🔨 Current Task: T028 [US1] Perform independent test scenario

Running comprehensive story verification...

$ bash .cursor/scripts/verify-story.sh docs/specs/user-authentication-tasks.md "User Story 1"

╔════════════════════════════════════════════════╗
║        Story Verification: User Story 1         ║
╚════════════════════════════════════════════════╝

This independent test proves the story works without US2 or US3.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 1: Start server
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Command: npm start
Expected: Server starts on port 3000

[Server starts successfully]
Did this work? [yes]
✓ Step 1 passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 2: Register new user
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Command: curl -X POST http://localhost:3000/api/auth/register...
Expected: 201 Created with user object and session token

[Executes curl, gets 201 response]
Did this work? [yes]
✓ Step 2 passed

[Continues for all 7 steps...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Final Verification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Did all test steps pass? [y]

╔════════════════════════════════════════════════╗
║  ✅ Story Verification PASSED                  ║
║                                                ║
║  User Story 1 is complete and verified!        ║
╚════════════════════════════════════════════════╝

✅ T028 complete
User Story 1 Progress: 12/13 tasks (92%)
```

---

## Step 10: Task T029 - Update Documentation

```
🔨 Current Task: T029 [US1] Update API documentation with new endpoints

[Updates OpenAPI/Swagger spec with all auth endpoints...]

✅ T029 complete
User Story 1 Progress: 13/13 tasks (100%)
```

---

## Step 11: Final Story Report

```
✅ User Story 1 Implementation Complete!

📊 Summary:
- Tasks: 13/13 complete (100%)
- Tests: 21 tests, all passing
- Coverage: 87.3%
- Acceptance Criteria: 7/7 met ✓
- Independent Test: Passed ✓

📝 Changes Made:
- Created: 6 new files
  - src/models/user.js (User model)
  - src/models/session.js (Session model)
  - src/services/user-service.js (User business logic)
  - src/services/auth-service.js (Auth business logic)
  - src/routes/auth.js (API endpoints)
  - src/middleware/auth.js (Auth middleware)
- Modified: 2 files
  - src/app.js (added auth routes)
  - tests/setup.js (added test database)
- Tests: 3 test files with 21 test cases
  - tests/unit/user-service.test.js (8 tests)
  - tests/unit/auth-service.test.js (6 tests)
  - tests/integration/auth.test.js (7 tests)

🎓 Learnings Captured in agents.md:
1. "Validate inputs before expensive operations"
   - Don't hash passwords before checking email format
   - Saves ~250ms per invalid request

2. "Always use parameterized queries"
   - Prevents SQL injection attacks
   - Example: `query(sql, [param])` not `query(sql + param)`

📈 Time Spent: ~2.5 days
- Models: 0.5 day
- Services: 0.75 day
- API: 0.5 day
- Tests: 0.5 day
- Verification: 0.25 day

🎯 Next Steps:

**Option 1: Polish MVP** (if US1 is your MVP)
- Proceed to Phase 6: Polish & Cross-Cutting
- Add rate limiting, security headers, monitoring
- Deploy to staging/production

**Option 2: Continue to US2**
- /implement-story "User Story 2"
- Add password reset functionality
- Depends on email service (SendGrid)

**Option 3: Deploy and Gather Feedback**
- Deploy US1 to staging
- Test with real users
- Gather feedback before building US2

💡 Recommendation:
Since US1 is MVP (working auth system), deploy to staging and validate
with real users before building US2. This ensures you're building what
users actually need.

Story is independently testable - US2 and US3 are optional enhancements!

$ git commit -m "Implement US1: User registration and login

- Add User and Session models
- Implement UserService and AuthService
- Create auth API endpoints
- Add comprehensive test coverage (87%)
- All acceptance criteria met
"
```

---

## Key Takeaways from This Implementation

### What Worked Well

1. **Task-by-task approach**: Completing T017 before T018 caught import issues early
2. **Verification checkpoints**: Caught a bug in UserService before building AuthService
3. **Learning capture**: Documented "validate before hash" pattern for future features
4. **Independent test**: Proved story works without US2/US3 code

### Common Pitfalls Avoided

1. ❌ **Jumping ahead**: Didn't start API before finishing services
2. ❌ **Accumulating broken code**: Fixed linting errors immediately
3. ❌ **Skipping verification**: Ran tests after each milestone
4. ❌ **Missing documentation**: Updated API docs as part of story

### Why User Story Organization Matters

**Without story organization** (traditional approach):
```
Week 1: Build all models (US1, US2, US3)
Week 2: Build all services
Week 3: Build all endpoints
Week 4: Write all tests
Result: Nothing works until week 4
```

**With story organization** (our approach):
```
Week 1: Complete US1 (models + services + API + tests)
Result: Working auth system, deployable MVP
Week 2: Add US2 if users need it
Week 3: Add US3 if users need it
```

**Benefit**: Incremental value delivery, testable at each step, can stop anytime.

---

## Commands Used in This Example

```bash
# 1. Start story implementation
/implement-story "User Story 1"

# 2. Check prerequisites
bash .cursor/scripts/check-implementation-prerequisites.sh "User Story 1"

# 3. Get story details
bash .cursor/scripts/get-story-tasks.sh docs/specs/user-auth-tasks.md "User Story 1"

# 4. Mark task complete (after each task)
bash .cursor/scripts/mark-task-complete.sh docs/specs/user-auth-tasks.md T017

# 5. Verify story complete
bash .cursor/scripts/verify-story.sh docs/specs/user-auth-tasks.md "User Story 1"

# 6. Manual verification checkpoints
npm start
curl -X POST http://localhost:3000/api/auth/register -d '...'
npm test

# 7. Commit when done
git commit -m "Implement US1: User registration and login"
```

---

**Status**: Story Complete ✅  
**Next**: Deploy MVP or continue to US2  
**Duration**: ~2.5 days  
**Quality**: 87% test coverage, all criteria met
