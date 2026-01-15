# AGENTS.md

> This file onboards AI coding agents to your project. Keep it under 100 lines.
> Task-specific details belong in `agent_docs/` or nested AGENTS.md files.

**Project:** [Project Name]  
**Stack:** [e.g., React 18 / TypeScript / Vite / Tailwind]  
**Updated:** [YYYY-MM-DD]

## Purpose

[2-3 sentences max. What does this project do and why does it exist?]

## Project Structure

```
src/
├── [folder]/     # [what's here]
├── [folder]/     # [what's here]
└── [folder]/     # [what's here]
tests/            # [test framework and organization]
```

## Commands

```bash
# Build
[npm run build / cargo build / etc]

# Test (prefer single-file runs)
[npm test -- path/to/file.test.ts]

# Lint + format (auto-fix)
[npm run lint --fix && npm run format]

# Type check
[npm run typecheck / tsc --noEmit]
```

Run the relevant command after making changes. Fix errors before proceeding.

## Boundaries

**Always do:**
- Run type checks and tests before considering work complete
- Follow patterns in existing code
- Keep diffs small and focused

**Ask first:**
- Adding new dependencies
- Changing database schemas
- Modifying CI/CD configuration
- Architectural changes

**Never do:**
- Commit secrets, API keys, or credentials
- Modify files in `node_modules/`, `vendor/`, or `.git/`
- Delete tests because they're failing
- Push directly to main/production branches

## Context Files

When working on specific areas, read the relevant file first:

| Area | File | When to read |
|------|------|--------------|
| Architecture | `agent-docs/architecture.md` | New features, refactoring |
| Testing | `agent-docs/testing.md` | Writing or fixing tests |
| API patterns | `agent-docs/api.md` | Backend changes |
| Database | `agent-docs/database.md` | Schema or query changes |
| Failure modes | `agent-docs/failure-modes.md` | Before implementing features, when debugging issues |

## Known Gotchas

- [Specific quirk or footgun in this codebase]
- [Another thing that trips people up]
- [Environment-specific issue]

## Communication

- Summarize work in chat, not in new markdown files
- If stuck or uncertain, ask before making large speculative changes
- When multiple valid approaches exist, propose options briefly
