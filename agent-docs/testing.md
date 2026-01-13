# Testing

> Read this before writing or modifying tests.

## Test Framework

- **Unit tests:** [Jest / Pytest / etc]
- **Integration tests:** [Framework]
- **E2E tests:** [Playwright / Cypress / etc]

## Running Tests

```bash
# Single file (preferred for iteration)
[npm test -- path/to/file.test.ts]

# Single test by name
[npm test -- -t "test name pattern"]

# Full suite (before PR only)
[npm test]

# With coverage
[npm test -- --coverage]
```

## Test Structure

Tests live alongside source files or in `tests/` mirroring `src/` structure.

```
src/
├── services/
│   ├── user.ts
│   └── user.test.ts    # co-located
tests/
├── integration/        # cross-service tests
└── e2e/               # full system tests
```

## Writing Tests

**Good test:**
```typescript
it('returns user when found by email', async () => {
  const user = await createTestUser({ email: 'test@example.com' });
  
  const result = await userService.getByEmail('test@example.com');
  
  expect(result.id).toBe(user.id);
});
```

**Avoid:**
- Tests that depend on execution order
- Hardcoded IDs or timestamps
- Mocking everything (prefer integration tests where reasonable)

## Test Data

- Use factories in `tests/factories/`
- Clean up after each test
- Don't rely on seed data
