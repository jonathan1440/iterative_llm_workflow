# Database

> Read this before schema changes or complex queries.

## Stack

- **Database:** [PostgreSQL / MySQL / SQLite]
- **ORM/Query Builder:** [Prisma / Drizzle / SQLAlchemy / raw SQL]
- **Migrations:** [Tool used]

## Connection

```bash
# Local development
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# Run migrations
[npx prisma migrate dev / alembic upgrade head]
```

## Schema Conventions

- Table names: plural, snake_case (`user_accounts`)
- Columns: snake_case (`created_at`)
- Primary keys: `id` (UUID or auto-increment)
- Foreign keys: `[table]_id` (`user_id`)
- Timestamps: `created_at`, `updated_at` on all tables

## Migration Rules

**Safe (backward compatible):**
- Adding nullable columns
- Adding new tables
- Adding indexes

**Requires coordination:**
- Adding non-nullable columns (add nullable first, backfill, then add constraint)
- Renaming columns (deploy code reading both names first)
- Dropping columns (remove from code first, wait, then drop)

## Query Patterns

Use the repository pattern. All database access through `src/repositories/`.

```typescript
// Good: Repository method
const user = await userRepo.findByEmail(email);

// Avoid: Direct queries scattered in services
const user = await db.query('SELECT * FROM users WHERE email = ?', [email]);
```

## Indexes

Document non-obvious indexes here:
- `users(email)` - unique lookup
- `posts(user_id, created_at)` - feed queries
