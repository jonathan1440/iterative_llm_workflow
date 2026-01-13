# Architecture

> Read this before implementing new features or refactoring.

## High-Level Design

[Describe the overall system architecture in 3-5 sentences. What are the main components and how do they interact?]

## Key Patterns

### Service Layer
All business logic lives in `src/services/`. Routes should be thin (< 15 lines) and delegate to services.

```
Route → Service → Repository → Database
         ↓
    Validation
```

### Error Handling
Use the custom exception hierarchy in `src/errors/`:
- `ValidationError` (400)
- `NotFoundError` (404)
- `AuthenticationError` (401)

### Data Flow
[Describe how data moves through the system. Reference specific files with `file:line` notation.]

## File References

- Entry point: `src/index.ts:1`
- Service base class: `src/services/base.ts:10`
- Error types: `src/errors/index.ts:1`
- Database connection: `src/db/connection.ts:1`

## Decisions Log

| Decision | Rationale | Date |
|----------|-----------|------|
| [Choice made] | [Why] | [YYYY-MM-DD] |
