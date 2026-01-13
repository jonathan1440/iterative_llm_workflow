# API Patterns

> Read this before making backend changes.

## Authentication

[Describe auth mechanism: JWT / session / API keys]

Protected routes use `authMiddleware`. The authenticated user is available at `req.user`.

## Rate Limiting

- Public endpoints: [X] requests/minute
- Authenticated: [Y] requests/minute
- Configured in `src/middleware/rateLimit.ts`

## External Services

### [Service Name, e.g., Stripe]
- Wrapper: `src/services/stripe.ts`
- **Always** verify webhooks before trusting payment status
- Test mode in dev, live mode in prod (controlled by env vars)

### [Service Name, e.g., SendGrid]
- Wrapper: `src/services/email.ts`
- Queue emails for background processing, don't send inline
- Templates stored in `src/templates/email/`

## Background Jobs

- Queue: [Redis / SQS / etc]
- Workers in `src/workers/`
- Enqueue via `src/services/queue.ts`

```typescript
// Don't await email sends in request handlers
await emailQueue.enqueue('welcome', { userId: user.id });
```

## Error Codes

| Code | HTTP Status | When to use |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Invalid input |
| `UNAUTHORIZED` | 401 | Missing/invalid auth |
| `FORBIDDEN` | 403 | Valid auth but not permitted |
| `NOT_FOUND` | 404 | Resource doesn't exist |
| `CONFLICT` | 409 | Duplicate or state conflict |
| `RATE_LIMITED` | 429 | Too many requests |
