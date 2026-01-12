# agents.md

> **Living Document**: This file grows with your project. It captures patterns, decisions, mistakes, and standards discovered during development.

**Last Updated**: 2026-01-13  
**Project**: [Your Project Name]  
**Tech Stack**: [Your Stack - e.g., React/TypeScript, Python/FastAPI, PostgreSQL]

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Code Standards](#code-standards)
3. [Architecture Principles](#architecture-principles)
4. [Implementation Best Practices](#implementation-best-practices)
5. [Database Conventions](#database-conventions)
6. [API Design Guidelines](#api-design-guidelines)
7. [Testing Strategy](#testing-strategy)
8. [Security Requirements](#security-requirements)
9. [Performance Guidelines](#performance-guidelines)
10. [Common Mistakes](#common-mistakes)
11. [AI Assistant Guidelines](#ai-assistant-guidelines)
12. [Deployment Process](#deployment-process)
13. [Third-Party Integrations](#third-party-integrations)
14. [Archive](#archive)

---

## Project Overview

**Purpose**: [Brief description of what your project does]

**Target Users**: [Who uses this application]

**Key Features**:
- [Feature 1]
- [Feature 2]
- [Feature 3]

**Architecture Overview**:
- Frontend: [Technology]
- Backend: [Technology]
- Database: [Database system]
- Hosting: [Hosting platform]
- CI/CD: [CI/CD platform]

---

## Code Standards

### File Organization

**Backend Structure**
```
src/
├── models/          # Data models and schemas
├── services/        # Business logic (no HTTP concerns)
├── routes/          # API endpoints (HTTP only)
├── middleware/      # Request/response middleware
├── utils/           # Pure utility functions
└── config/          # Configuration management
```

**Frontend Structure**
```
src/
├── components/      # Reusable UI components
├── pages/           # Route-specific page components
├── services/        # API client and business logic
├── hooks/           # Custom React hooks
├── utils/           # Pure utility functions
└── types/           # TypeScript type definitions
```

**Rationale**: Separation by concern, not by feature. Makes it easy to find code by its purpose.  
**Added**: 2026-01-05

---

### Naming Conventions

**Files and Directories**
- Use kebab-case for all files: `user-service.ts`, `auth-middleware.ts`
- Use PascalCase for component files: `UserProfile.tsx`, `LoginForm.tsx`
- Test files match source: `user-service.test.ts`

**Variables and Functions**
- Use camelCase: `getUserById`, `isAuthenticated`
- Boolean variables start with `is`, `has`, `should`: `isValid`, `hasPermission`
- Functions are verbs: `calculateTotal`, `fetchUser`, `validateInput`

**Constants**
- Use UPPER_SNAKE_CASE: `MAX_RETRY_ATTEMPTS`, `API_BASE_URL`
- Group related constants in objects: `AUTH_ERRORS.INVALID_TOKEN`

**Classes and Types**
- Use PascalCase: `UserService`, `AuthMiddleware`, `UserProfile`

**Rationale**: Consistency reduces cognitive load. Naming reveals intent.  
**Added**: 2026-01-05

---

### Language-Specific Standards

**TypeScript**
```typescript
// ✅ Good: Explicit return types
function calculateTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ❌ Bad: Implicit return type
function calculateTotal(items: CartItem[]) {
  return items.reduce((sum, item) => sum + item.price, 0);
}
```

**Always specify return types for functions**
- Mistake: Relying on type inference for function returns
- Why wrong: Type inference can change unexpectedly, breaking contracts
- Correct: Explicit return type acts as documentation and contract
- Rationale: Prevents subtle bugs from type changes
- Added: 2026-01-05

---

**Python**
```python
# ✅ Good: Type hints and docstrings
def calculate_total(items: list[CartItem]) -> Decimal:
    """Calculate total price of cart items.
    
    Args:
        items: List of cart items with prices
        
    Returns:
        Total price as Decimal for precision
    """
    return sum(item.price for item in items)

# ❌ Bad: No type hints
def calculate_total(items):
    return sum(item.price for item in items)
```

**Always use type hints and docstrings**
- Mistake: Skipping type hints for "simple" functions
- Why wrong: Simple functions become complex; missing hints compound
- Correct: Type hints on all function signatures
- Rationale: Makes refactoring safe, enables better IDE support
- Added: 2026-01-08

---

### Code Formatting

**We Use**:
- **JavaScript/TypeScript**: Prettier with default settings
- **Python**: Black with line length 100
- **SQL**: SQL Formatter with uppercase keywords

**Pre-commit Hooks**:
```bash
# Install pre-commit hooks
pre-commit install

# Runs on every commit:
# - Format code
# - Lint code
# - Run tests (fast suite)
```

**Rationale**: Formatting is not a discussion point. Tools handle it.  
**Added**: 2026-01-05

---

## Architecture Principles

### Service Layer Pattern

**All business logic lives in services**

```python
# ✅ Good: Route is thin, service contains logic
@app.post("/users")
async def create_user(user_data: UserCreate):
    try:
        user = await user_service.create_user(user_data)
        return {"user": user}
    except ValidationError as e:
        raise HTTPException(400, str(e))

# ❌ Bad: Business logic in route
@app.post("/users")
async def create_user(user_data: UserCreate):
    # 50 lines of validation, hashing, database operations...
```

**Benefits**:
- Business logic testable without HTTP mocks
- Routes stay thin (< 10 lines typically)
- Service layer reusable across different interfaces

**Rationale**: Separation of concerns. HTTP is just one interface.  
**Added**: 2026-01-05

---

### Database Access Pattern

**Use repository pattern for data access**

```python
# ✅ Good: Repository abstracts database
class UserRepository:
    async def create(self, user_data: UserCreate) -> User:
        # Database-specific code here
        pass
    
    async def get_by_email(self, email: str) -> User | None:
        # Database-specific code here
        pass

# Service uses repository
class UserService:
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo
    
    async def create_user(self, data: UserCreate) -> User:
        existing = await self.user_repo.get_by_email(data.email)
        if existing:
            raise ValidationError("Email already exists")
        return await self.user_repo.create(data)
```

**Benefits**:
- Easy to mock for testing
- Can swap database implementations
- Clear separation between business logic and data access

**Rationale**: Business logic shouldn't know about SQL  
**Added**: 2026-01-12

---

### Error Handling Strategy

**Use custom exception hierarchy**

```python
# Base exception
class AppError(Exception):
    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(message)

# Specific exceptions
class ValidationError(AppError):
    def __init__(self, message: str):
        super().__init__(message, status_code=400)

class NotFoundError(AppError):
    def __init__(self, resource: str, identifier: str):
        super().__init__(
            f"{resource} not found: {identifier}",
            status_code=404
        )

class AuthenticationError(AppError):
    def __init__(self, message: str = "Authentication required"):
        super().__init__(message, status_code=401)
```

**Error Response Format**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Email address is invalid",
    "details": {
      "field": "email",
      "value": "notanemail"
    }
  }
}
```

**Rationale**: Consistent error handling across application  
**Added**: 2026-01-07

---

### API Versioning Strategy

**We use URL versioning: `/api/v1/...`**

```typescript
// ✅ Good: Version in URL
const API_BASE = '/api/v1';

// Routes
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/auth', authRoutes);

// When breaking changes needed, create v2
app.use('/api/v2/users', userRoutesV2);
```

**Breaking Changes**:
- Removing a field from response
- Changing field type
- Changing required fields in request
- Changing authentication method

**Non-Breaking Changes**:
- Adding optional fields
- Adding new endpoints
- Deprecating (but not removing) endpoints

**Rationale**: URL versioning is explicit and easy to route  
**Added**: 2026-01-05

---

## Implementation Best Practices

### Authentication Flow

**We use JWT tokens in HTTP-only cookies**

```typescript
// ✅ Good: HTTP-only cookie
res.cookie('access_token', token, {
  httpOnly: true,      // Prevents JavaScript access
  secure: true,        // HTTPS only
  sameSite: 'strict',  // CSRF protection
  maxAge: 15 * 60 * 1000  // 15 minutes
});

// ❌ Bad: Token in localStorage
localStorage.setItem('token', token);  // Vulnerable to XSS
```

**Token Lifespan**:
- Access token: 15 minutes (short-lived)
- Refresh token: 7 days (longer-lived)
- Token rotation: New refresh token on every refresh

**Rationale**: HTTP-only cookies prevent XSS attacks  
**Added**: 2026-01-06

---

### Input Validation

**Always validate at the boundary**

```python
# ✅ Good: Pydantic validation at API boundary
from pydantic import BaseModel, EmailStr, validator

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    
    @validator('password')
    def validate_password(cls, v):
        if len(v) < 12:
            raise ValueError('Password must be at least 12 characters')
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain uppercase letter')
        return v

@app.post("/users")
async def create_user(user_data: UserCreate):  # Validated automatically
    return await user_service.create_user(user_data)
```

**Never trust client-side validation alone**
- Mistake: Relying only on frontend validation
- Why wrong: Attackers bypass frontend, hit API directly
- Correct: Validate on backend, frontend is UX enhancement only
- Rationale: Security requires server-side validation
- Added: 2026-01-06

---

### Database Migrations

**Our migration pattern**

```sql
-- File: migrations/20260113_add_user_preferences.sql
-- Migration: Add user_preferences table
-- Date: 2026-01-13

-- Forward migration
CREATE TABLE user_preferences (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    preference_key VARCHAR(100) NOT NULL,
    preference_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, preference_key)
);

CREATE INDEX idx_user_preferences_user_id 
ON user_preferences(user_id);

-- Rollback (keep commented for reference)
-- DROP INDEX idx_user_preferences_user_id;
-- DROP TABLE user_preferences;
```

**Migration Naming**: `YYYYMMDD_description.sql`

**Migration Rules**:
1. Never modify existing migrations (create new one instead)
2. Always include rollback instructions (commented)
3. Test rollback before committing
4. Include comments explaining why

**Rationale**: Migrations are permanent history, must be safe  
**Added**: 2026-01-08

---

### Async/Await Patterns

**JavaScript/TypeScript async patterns**

```typescript
// ✅ Good: Handle errors properly
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Failed to fetch user:', error);
    throw error;  // Re-throw after logging
  }
}

// ❌ Bad: Silent failure
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return await response.json();  // What if fetch failed?
}
```

**Always handle async errors**
- Mistake: Missing try-catch around async operations
- Why wrong: Unhandled promise rejections crash Node.js
- Correct: Every async function has error handling
- Rationale: Fail gracefully, don't crash
- Added: 2026-01-09

---

## Database Conventions

### Table Naming

**Use snake_case and plural nouns**
```sql
-- ✅ Good
CREATE TABLE users (...);
CREATE TABLE user_preferences (...);
CREATE TABLE password_resets (...);

-- ❌ Bad
CREATE TABLE User (...);           -- Not snake_case
CREATE TABLE user_preference (...); -- Singular
CREATE TABLE passwordReset (...);  -- camelCase
```

**Rationale**: PostgreSQL convention, case-insensitive  
**Added**: 2026-01-05

---

### Column Naming

**Standard columns for every table**:
```sql
id SERIAL PRIMARY KEY,           -- Auto-incrementing ID
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

**Boolean columns**:
```sql
-- ✅ Good: Start with is_, has_, should_
is_active BOOLEAN DEFAULT TRUE,
has_verified_email BOOLEAN DEFAULT FALSE,
should_notify BOOLEAN DEFAULT TRUE

-- ❌ Bad: Ambiguous naming
active BOOLEAN,     -- What does true mean?
verified BOOLEAN,   -- Verified what?
notify BOOLEAN      -- Notify when?
```

**Rationale**: Clear intent, no ambiguity  
**Added**: 2026-01-05

---

### Foreign Key Naming

**Use `<table>_id` pattern**
```sql
-- ✅ Good: Clear relationship
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    category_id INTEGER REFERENCES categories(id)
);

-- ❌ Bad: Ambiguous
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    author INTEGER,  -- References what? users? authors?
    category INTEGER -- Not clearly a foreign key
);
```

**Rationale**: Obvious what table is referenced  
**Added**: 2026-01-05

---

### Indexing Strategy

**Index foreign keys and frequently queried columns**

```sql
-- ✅ Good: Index foreign keys
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_category_id ON posts(category_id);

-- Index frequently queried columns
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Composite index for common query patterns
CREATE INDEX idx_posts_user_created 
ON posts(user_id, created_at DESC);
```

**When to index**:
- Foreign keys (for JOINs)
- Columns in WHERE clauses
- Columns in ORDER BY
- Columns used in GROUP BY

**When NOT to index**:
- Small tables (< 1000 rows)
- Columns that change frequently
- Low cardinality columns (few unique values)

**Rationale**: Indexes speed up reads but slow writes  
**Added**: 2026-01-10

---

## API Design Guidelines

### Endpoint Naming

**Use nouns, not verbs**
```
✅ Good:
GET    /api/v1/users
POST   /api/v1/users
GET    /api/v1/users/:id
PUT    /api/v1/users/:id
DELETE /api/v1/users/:id

❌ Bad:
POST   /api/v1/createUser
POST   /api/v1/getUser
POST   /api/v1/deleteUser
```

**Rationale**: HTTP verbs define action, URL defines resource  
**Added**: 2026-01-05

---

### Query Parameters vs Path Parameters

**Path parameters for resource identity**
```
GET /api/v1/users/:id          # Specific user
GET /api/v1/posts/:id/comments # Comments for specific post
```

**Query parameters for filtering/pagination**
```
GET /api/v1/users?role=admin&limit=20&offset=0
GET /api/v1/posts?author=123&status=published&sort=created_desc
```

**Rationale**: URL structure shows hierarchy, query shows options  
**Added**: 2026-01-05

---

### Response Format Standards

**Success Response**:
```json
{
  "data": {
    "id": 123,
    "email": "user@example.com",
    "created_at": "2026-01-13T10:30:00Z"
  }
}
```

**List Response**:
```json
{
  "data": [...items...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 157,
    "pages": 8
  }
}
```

**Error Response** (see Error Handling Strategy above):
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "...",
    "details": {...}
  }
}
```

**Rationale**: Consistent structure simplifies client code  
**Added**: 2026-01-07

---

### HTTP Status Codes

**Use appropriate status codes**

**Success**:
- `200 OK` - Successful GET, PUT, PATCH, DELETE
- `201 Created` - Successful POST (resource created)
- `204 No Content` - Successful DELETE (no response body)

**Client Errors**:
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Authenticated but not authorized
- `404 Not Found` - Resource doesn't exist
- `409 Conflict` - Resource conflict (e.g., duplicate email)
- `422 Unprocessable Entity` - Validation failed

**Server Errors**:
- `500 Internal Server Error` - Unexpected error
- `503 Service Unavailable` - Temporary downtime

**Rationale**: Status codes communicate semantics  
**Added**: 2026-01-05

---

## Testing Strategy

### Test Organization

**Mirror source structure**
```
src/
├── services/
│   └── user-service.ts
tests/
├── services/
│   └── user-service.test.ts
```

**Test file naming**: `<source-file>.test.<ext>`

**Rationale**: Easy to find tests for any source file  
**Added**: 2026-01-05

---

### Test Pyramid

**Our test distribution**:
- 70% Unit tests (fast, isolated)
- 20% Integration tests (database, external services)
- 10% E2E tests (full user flows)

**Unit Test Example**:
```typescript
describe('UserService.validateEmail', () => {
  it('accepts valid email addresses', () => {
    expect(validateEmail('user@example.com')).toBe(true);
  });
  
  it('rejects invalid email addresses', () => {
    expect(validateEmail('not-an-email')).toBe(false);
    expect(validateEmail('missing@domain')).toBe(false);
  });
});
```

**Integration Test Example**:
```python
@pytest.mark.asyncio
async def test_create_user_stores_in_database():
    # Arrange
    user_data = UserCreate(email="test@example.com", password="SecurePass123")
    
    # Act
    user = await user_service.create_user(user_data)
    
    # Assert
    stored = await user_repo.get_by_id(user.id)
    assert stored is not None
    assert stored.email == "test@example.com"
```

**Rationale**: Fast feedback loop, high confidence  
**Added**: 2026-01-11

---

### Test Coverage Requirements

**Minimum coverage**: 80% overall
- Services: 90% (business logic must be well-tested)
- Routes: 70% (thin layer, less critical)
- Utilities: 95% (reused everywhere, must be bulletproof)

**What we DON'T count**:
- Configuration files
- Type definitions
- Database migrations

**Run coverage**:
```bash
pytest --cov=src --cov-report=html
```

**Rationale**: High coverage prevents regressions  
**Added**: 2026-01-11

---

## Security Requirements

### Authentication & Authorization

**Never store passwords in plain text**
```python
# ✅ Good: Hash with bcrypt
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

# ❌ Bad: Plain text storage
def store_password(password: str):
    user.password = password  # NEVER DO THIS
```

**Rationale**: Passwords must never be recoverable  
**Added**: 2026-01-06

---

### SQL Injection Prevention

**Always use parameterized queries**

```python
# ✅ Good: Parameterized query
async def get_user_by_email(email: str) -> User:
    query = "SELECT * FROM users WHERE email = $1"
    result = await db.fetchrow(query, email)
    return User(**result)

# ❌ Bad: String concatenation
async def get_user_by_email(email: str) -> User:
    query = f"SELECT * FROM users WHERE email = '{email}'"
    result = await db.fetchrow(query)  # SQL injection vulnerable!
    return User(**result)
```

**Rationale**: Parameterized queries prevent SQL injection  
**Added**: 2026-01-06

---

### CORS Configuration

**Strict CORS in production**

```python
# ✅ Good: Specific origins
ALLOWED_ORIGINS = [
    "https://app.example.com",
    "https://staging.example.com"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# ❌ Bad: Wildcard in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # NEVER in production
    allow_credentials=True,
)
```

**Rationale**: Prevent cross-origin attacks  
**Added**: 2026-01-06

---

### Rate Limiting

**Implement rate limiting on all public endpoints**

```python
# Authentication endpoints: 5 requests per minute
@limiter.limit("5 per minute")
@app.post("/auth/login")
async def login():
    ...

# API endpoints: 100 requests per minute
@limiter.limit("100 per minute")
@app.get("/api/v1/users")
async def get_users():
    ...
```

**Rationale**: Prevent brute force and DoS attacks  
**Added**: 2026-01-07

---

## Performance Guidelines

### Database Query Optimization

**Avoid N+1 queries**

```python
# ✅ Good: Single query with JOIN
async def get_posts_with_authors():
    query = """
        SELECT 
            posts.*,
            users.name as author_name,
            users.email as author_email
        FROM posts
        JOIN users ON posts.user_id = users.id
        WHERE posts.published = true
    """
    return await db.fetch(query)

# ❌ Bad: N+1 queries
async def get_posts_with_authors():
    posts = await db.fetch("SELECT * FROM posts WHERE published = true")
    for post in posts:
        author = await db.fetchrow(  # Separate query for EACH post!
            "SELECT * FROM users WHERE id = $1", post.user_id
        )
        post.author = author
    return posts
```

**Rationale**: One query is always faster than N queries  
**Added**: 2026-01-10

---

### Caching Strategy

**Cache expensive computations and queries**

```python
from functools import lru_cache

# ✅ Good: Cache rarely-changing data
@lru_cache(maxsize=100)
async def get_categories() -> list[Category]:
    return await db.fetch("SELECT * FROM categories")

# Use Redis for distributed caching
async def get_user_stats(user_id: int) -> dict:
    cache_key = f"user:stats:{user_id}"
    
    # Try cache first
    cached = await redis.get(cache_key)
    if cached:
        return json.loads(cached)
    
    # Compute if not cached
    stats = await compute_user_stats(user_id)
    await redis.setex(cache_key, 3600, json.dumps(stats))  # 1 hour TTL
    return stats
```

**What to cache**:
- Reference data (categories, countries, etc.)
- Expensive computations
- Frequently accessed data
- Data with low write frequency

**Rationale**: Don't recompute what doesn't change  
**Added**: 2026-01-10

---

### Pagination

**Always paginate list endpoints**

```python
# ✅ Good: Paginated response
@app.get("/api/v1/posts")
async def get_posts(
    page: int = 1,
    limit: int = 20,
    sort: str = "created_desc"
):
    offset = (page - 1) * limit
    
    posts = await db.fetch(
        "SELECT * FROM posts ORDER BY created_at DESC LIMIT $1 OFFSET $2",
        limit, offset
    )
    
    total = await db.fetchval("SELECT COUNT(*) FROM posts")
    
    return {
        "data": posts,
        "pagination": {
            "page": page,
            "limit": limit,
            "total": total,
            "pages": math.ceil(total / limit)
        }
    }

# ❌ Bad: Return all records
@app.get("/api/v1/posts")
async def get_posts():
    return await db.fetch("SELECT * FROM posts")  # Could be 100,000 rows!
```

**Default pagination**: 20 items per page
**Max pagination**: 100 items per page

**Rationale**: Unbounded queries kill performance  
**Added**: 2026-01-07

---

## Common Mistakes

### Don't Mix Business Logic with HTTP

**Mistake**: Putting business logic directly in route handlers

**Example of the mistake**:
```python
@app.post("/users")
async def create_user(user_data: UserCreate):
    # 50 lines of validation, hashing, database operations here
    # This is ALL business logic in the HTTP layer!
```

**Why it's wrong**:
- Business logic not reusable (locked to HTTP)
- Can't test without HTTP mocking
- Violates single responsibility principle
- Makes routes fat and hard to maintain

**Correct approach**:
```python
# Service layer (business logic)
class UserService:
    async def create_user(self, data: UserCreate) -> User:
        # All validation and business logic here
        pass

# Route layer (HTTP only)
@app.post("/users")
async def create_user(user_data: UserCreate):
    try:
        user = await user_service.create_user(user_data)
        return {"user": user}
    except ValidationError as e:
        raise HTTPException(400, str(e))
```

**Rationale**: Separation of concerns. HTTP is just one interface.  
**Added**: 2026-01-05

---

### Don't Skip Database Indexes on Foreign Keys

**Mistake**: Creating foreign keys without indexes

**Example of the mistake**:
```sql
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id)  -- No index!
);

-- Query will be slow:
SELECT * FROM posts WHERE user_id = 123;
```

**Why it's wrong**:
- PostgreSQL doesn't auto-index foreign keys
- Queries using foreign keys do full table scans
- JOINs become extremely slow
- Performance degrades as table grows

**Correct approach**:
```sql
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id)
);

-- Always add index to foreign keys
CREATE INDEX idx_posts_user_id ON posts(user_id);
```

**Rationale**: Foreign keys are almost always queried  
**Added**: 2026-01-08

---

### Don't Use Floating Point for Money

**Mistake**: Using `FLOAT` or `DOUBLE` for currency amounts

**Example of the mistake**:
```python
# ❌ Bad: Floating point precision issues
price = 0.1 + 0.2  # Returns 0.30000000000000004
total = price * 3  # Unexpected results
```

**Why it's wrong**:
- Floating point arithmetic is imprecise
- Rounding errors accumulate
- Financial calculations become incorrect
- Violates legal requirements for precision

**Correct approach**:
```python
# ✅ Good: Use Decimal for money
from decimal import Decimal

price = Decimal('0.10') + Decimal('0.20')  # Exactly 0.30
total = price * 3  # Exactly 0.90

# Database schema
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    price NUMERIC(10, 2) NOT NULL  -- NUMERIC, not FLOAT
);
```

**Rationale**: Money requires exact precision  
**Added**: 2026-01-09

---

### Don't Commit Secrets to Git

**Mistake**: Committing API keys, passwords, tokens to version control

**Example of the mistake**:
```python
# ❌ Bad: Secrets in code
DATABASE_URL = "postgresql://user:password123@localhost/db"
STRIPE_SECRET_KEY = "sk_live_abc123xyz789"
JWT_SECRET = "my-super-secret-key"
```

**Why it's wrong**:
- Git history is permanent (even if deleted later)
- Exposed to anyone with repo access
- Security breach if repo becomes public
- Violates security best practices

**Correct approach**:
```python
# ✅ Good: Secrets in environment variables
import os

DATABASE_URL = os.getenv("DATABASE_URL")
STRIPE_SECRET_KEY = os.getenv("STRIPE_SECRET_KEY")
JWT_SECRET = os.getenv("JWT_SECRET")

# .env file (gitignored)
DATABASE_URL=postgresql://user:password123@localhost/db
STRIPE_SECRET_KEY=sk_live_abc123xyz789
JWT_SECRET=my-super-secret-key

# .gitignore
.env
.env.local
```

**Rationale**: Secrets must never be in version control  
**Added**: 2026-01-05

---

### Don't Trust Client-Side Validation Alone

**Mistake**: Only validating input on the frontend

**Example of the mistake**:
```typescript
// Frontend validation only
function createUser(email: string) {
  if (!isValidEmail(email)) {
    showError("Invalid email");
    return;
  }
  // Send to backend without further validation
  await api.post('/users', { email });
}

// Backend accepts without validation
@app.post("/users")
def create_user(email: str):
    user = User(email=email)  # No validation!
    db.add(user)
```

**Why it's wrong**:
- Attackers bypass frontend, hit API directly
- Curl/Postman can send any data to API
- No protection against malicious input
- Vulnerability to injection attacks

**Correct approach**:
```python
# ✅ Backend validation (required)
from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    email: EmailStr  # Validated automatically

@app.post("/users")
async def create_user(user_data: UserCreate):
    # user_data.email is guaranteed valid
    user = await user_service.create_user(user_data)
    return user

# Frontend validation (optional, for UX)
function createUser(email: string) {
  if (!isValidEmail(email)) {
    showError("Invalid email");  // Immediate feedback
    return;
  }
  await api.post('/users', { email });  // Backend validates again
}
```

**Rationale**: Never trust client input, always validate server-side  
**Added**: 2026-01-06

---

## AI Assistant Guidelines

### Communication Defaults

**Summaries and results should be communicated in chat, not written to files**

- **Mistake**: Creating markdown report files (e.g., `ANALYSIS.md`, `FIXES-IMPLEMENTED.md`) to document work done
- **Why wrong**: Creates unnecessary files, adds maintenance overhead, results are self-evident from code changes
- **Correct**: Communicate findings, fixes, and summaries directly in chat response
- **Exception**: Only create documentation files when explicitly requested by user
- **Rationale**: Chat is the primary communication medium; files should only exist when they serve a specific purpose
- **Added**: 2026-01-13

---

## Deployment Process

### Pre-Deployment Checklist

**Before deploying to production**:
- [ ] All tests passing (`pytest && npm test`)
- [ ] Code reviewed and approved
- [ ] Database migrations tested on staging
- [ ] Environment variables configured
- [ ] Rollback plan documented
- [ ] Monitoring alerts configured

**Rationale**: Prevent deployment disasters  
**Added**: 2026-01-12

---

### Database Migration Deployment

**Our migration process**:

1. **Deploy code with migration (backward compatible)**
2. **Run migration on production**
3. **Verify migration succeeded**
4. **Monitor for issues**
5. **Rollback if needed (within 1 hour window)**

**Backward compatible migrations**:
```sql
-- ✅ Good: Add optional column
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- ❌ Bad: Drop column immediately (breaks old code)
ALTER TABLE users DROP COLUMN phone;

-- ✅ Good: Multi-step for dropping
-- Step 1: Deploy code that doesn't use column
-- Step 2: Wait 24 hours
-- Step 3: Drop column
ALTER TABLE users DROP COLUMN phone;
```

**Rationale**: Zero-downtime deployments require compatibility  
**Added**: 2026-01-12

---

### Environment Configuration

**We use these environments**:

1. **Local** - Developer machine
   - Database: Docker PostgreSQL
   - No external services
   - Hot reload enabled

2. **Staging** - Pre-production testing
   - Database: Managed PostgreSQL
   - Real external services (test mode)
   - Mirrors production config
   - Auto-deploys from `develop` branch

3. **Production** - Live application
   - Database: Managed PostgreSQL with backups
   - Real external services (live mode)
   - Manual deploys from `main` branch
   - Auto-scaling enabled

**Rationale**: Test realistic scenarios before production  
**Added**: 2026-01-05

---

## Third-Party Integrations

### Payment Processing (Stripe)

**Always use Stripe webhooks for payment confirmation**

```python
# ❌ Bad: Trust client-side confirmation
@app.post("/checkout")
async def checkout():
    # Create payment intent
    intent = stripe.PaymentIntent.create(amount=1000)
    
    # Wait for client to confirm... NEVER DO THIS
    # Client could lie about payment success!

# ✅ Good: Verify via webhook
@app.post("/stripe/webhook")
async def stripe_webhook(request: Request):
    payload = await request.body()
    sig_header = request.headers['stripe-signature']
    
    # Verify webhook signature
    event = stripe.Webhook.construct_event(
        payload, sig_header, STRIPE_WEBHOOK_SECRET
    )
    
    if event['type'] == 'payment_intent.succeeded':
        # NOW we know payment succeeded
        payment_intent = event['data']['object']
        await fulfill_order(payment_intent['id'])
```

**Rationale**: Never trust client for payment confirmation  
**Added**: 2026-01-11

---

### Email Service (SendGrid)

**Email sending pattern**:

```python
# Queue emails instead of sending inline
@app.post("/users")
async def create_user(user_data: UserCreate):
    user = await user_service.create_user(user_data)
    
    # ✅ Good: Queue email for background processing
    await email_queue.enqueue(
        'welcome_email',
        user_id=user.id,
        email=user.email
    )
    
    return {"user": user}  # Don't wait for email to send

# Background worker sends emails
async def process_email_queue():
    while True:
        job = await email_queue.dequeue()
        if job['type'] == 'welcome_email':
            await send_welcome_email(job['email'])
```

**Rationale**: Email failures shouldn't block user requests  
**Added**: 2026-01-11

---

## Archive

*Entries moved here are outdated but kept for historical reference*

### [Archived] Python 3.8 Type Hints

**Note**: We upgraded to Python 3.11 on 2026-01-10. Use modern syntax.

**Old syntax** (Python 3.8):
```python
from typing import List, Dict, Optional

def get_users() -> List[Dict[str, Any]]:
    pass
```

**New syntax** (Python 3.11+):
```python
def get_users() -> list[dict[str, Any]]:
    pass
```

**Archived**: 2026-01-10

---

## Document Maintenance

**Review Schedule**:
- Weekly: Quick scan for outdated info during implementation
- Monthly: Dedicated review session (use `/review-agents`)
- After major milestones: Comprehensive review and reorganization

**Adding Entries**:
Use this template:
```markdown
### Entry Title

**Pattern/Mistake description**

Example code...

**Rationale**: Why this matters  
**Added**: YYYY-MM-DD
```

**For mistakes, use extended template**:
```markdown
### Don't [Mistake Title]

**Mistake**: Brief description

**Example of the mistake**:
```code
...
```

**Why it's wrong**:
- Reason 1
- Reason 2

**Correct approach**:
```code
...
```

**Rationale**: Core reason this matters  
**Added**: YYYY-MM-DD
```

---

**Remember**: This document should grow organically. Add entries as you discover patterns. Use `/review-agents` monthly to identify gaps.
