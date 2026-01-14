---
description: Review and update agent-docs files with recent best practices from verified sources. Optionally provide spec file to focus on relevant domains. Changes are applied directly and shown in Cursor's diff viewer for review.
---

## User Input

```text
$ARGUMENTS
```

**Usage:**
- `/update-agent-docs` - Update all agent-docs files
- `/update-agent-docs docs/specs/[feature-name].md` - Update only domains relevant to the spec

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command reviews agent-docs files against recent best practices from verified sources. It searches for articles published in the last 3 months by developers with demonstrated track records, applies updates directly, and shows changes in Cursor's diff viewer for review. Only updates if new information is found.

### Step 0: Prerequisites

Verify agent-docs directory exists:

```bash
if [ ! -d ".cursor/agent-docs" ]; then
  echo "Creating .cursor/agent-docs directory..."
  mkdir -p .cursor/agent-docs
fi
```

Check which agent-docs files exist:
- `.cursor/agent-docs/api.md`
- `.cursor/agent-docs/architecture.md`
- `.cursor/agent-docs/database.md`
- `.cursor/agent-docs/testing.md`
```

**Load project context for project-specific searches:**

Before searching, load these files to understand project context:
- `.cursor/agents.md` - Project stack, standards, and constraints (REQUIRED)
- Current agent-docs files - Existing patterns and conventions (REQUIRED)
- Feature spec (if provided in $ARGUMENTS) - Current feature requirements (OPTIONAL, but recommended)

**Extract project-specific context:**

1. **From agents.md:**
   - Technology stack (from agents.md: Stack field)
   - Framework/language (React, Node.js, Python, etc.)
   - Database (PostgreSQL, MongoDB, etc.)

2. **From spec (if provided):**
   - Determine which agent-docs domains are relevant:
     - Data Model section → Focus on `database.md`
     - User stories mentioning API/endpoints → Focus on `api.md`
     - Testing requirements → Focus on `testing.md`
     - Architecture decisions needed → Focus on `architecture.md`
   - If no spec provided, update all agent-docs files

3. **From existing agent-docs:**
   - Current patterns and conventions
   - Last update dates

**Display extracted context:**

```markdown
📋 Project Context for Search

From .cursor/agents.md:
- Stack: React 18 / TypeScript / Node.js / Express / PostgreSQL
- Framework: Express.js
- Language: TypeScript
- Database: PostgreSQL

From spec (docs/specs/user-authentication.md):
- Data Model section found → Will focus on database.md
- User stories mention API endpoints → Will focus on api.md
- Authentication requirements → Will focus on api.md and architecture.md

Agent-docs to update:
- ✅ database.md (Data Model in spec)
- ✅ api.md (API endpoints in spec)
- ✅ architecture.md (Auth architecture decisions)
- ⏭️  testing.md (Not mentioned in spec, skipping unless explicitly requested)

This context ensures searches find practices relevant to:
1. Your specific technology stack (Express.js, TypeScript, PostgreSQL)
2. The domains actually needed for this feature (API, database, architecture)
```

**Why this order matters:**
- Best practices inform design decisions (design-system loads agent-docs)
- Spec tells us which domains are relevant (don't waste time on irrelevant docs)
- Stack context ensures practices match your technology choices

### Step 1: Check Last Update Dates

For each existing agent-docs file, check when it was last modified:

```bash
for file in .cursor/agent-docs/*.md; do
  if [ -f "$file" ]; then
    echo "$(basename $file): Last modified $(stat -f "%Sm" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null)"
  fi
done
```

**Display to user:**

```markdown
📋 Agent-Docs Status

Existing files:
- api.md: Last updated 2026-01-10 (2 months ago)
- architecture.md: Last updated 2025-12-15 (3+ months ago)
- database.md: Last updated 2026-01-05 (2 months ago)
- testing.md: Not found

Search window: Last 3 months (since 2025-10-15)
```

### Step 2: Search for Recent Best Practices

For each agent-docs file, search for recent articles. Use web search with strict criteria:

**Search Criteria:**
1. **Publication date**: Within last 3 months from today
2. **Author verification**: Author must have:
   - Published multiple technical articles (check author profile)
   - Demonstrated real-world implementation (GitHub repos, case studies, production systems)
   - Track record of excellence (recognized by community, worked at respected companies, or has measurable results)
3. **Content quality**: Article must include:
   - Specific techniques with code examples
   - Real-world results or metrics
   - Not just opinion or theory
4. **Relevance**: Directly applicable to the agent-docs topic

**Search Strategy:**

For each file (api.md, architecture.md, database.md, testing.md):

**First, extract project context from agents.md:**
- Stack: [e.g., React 18 / TypeScript / Node.js / PostgreSQL]
- Framework: [e.g., Express.js, FastAPI, Django]
- Language: [e.g., TypeScript, Python, Go]
- Database: [e.g., PostgreSQL, MongoDB]

**Then search with project-specific queries:**

```markdown
Searching for recent best practices: [Topic] for [Project Stack]

Search queries (project-specific):
1. "[Topic] [Framework/Language] best practices 2026" site:github.com OR site:dev.to OR site:medium.com OR site:hackernoon.com
   Example: "API Express.js TypeScript best practices 2026"
   
2. "[Topic] [Database] patterns [current year]" site:engineering.company.com OR site:*.engineering
   Example: "Database PostgreSQL patterns 2026"
   
3. "[Topic] [Stack] production lessons learned" after:2025-10-15
   Example: "API Node.js TypeScript production lessons learned"

Fallback queries (generic if no project-specific results):
4. "[Topic] best practices 2026" site:github.com OR site:dev.to OR site:medium.com OR site:hackernoon.com
5. "[Topic] patterns [current year]" site:engineering.company.com OR site:*.engineering

Filtering criteria:
- Published in last 3 months
- Author has GitHub profile with real projects
- Article includes code examples or case studies
- Not marketing content or vendor pitches
- **Prefer articles matching project stack/framework** (higher relevance)
```

**Example for api.md (with project context):**

```markdown
📋 Project Context Loaded:
- Stack: React 18 / TypeScript / Node.js / Express / PostgreSQL
- Framework: Express.js
- Language: TypeScript

🔍 Searching: API Design Best Practices for Express.js TypeScript

Search queries used:
1. "API Express.js TypeScript best practices 2026"
2. "API Node.js TypeScript patterns 2026"
3. "API Express.js production lessons learned" after:2025-10-15

Searching for articles published after 2025-10-15...

Found candidates:
1. "Express.js API Design Patterns in Production" by Jane Smith (2026-01-08)
   - Author: Senior engineer at Stripe, 5+ years API design
   - GitHub: 12k stars, multiple production Express.js APIs
   - Article: Real metrics from handling 1M+ requests/day with Express.js
   - Stack match: ✅ Express.js, TypeScript
   - ✅ Meets criteria

2. "TypeScript API Best Practices" by John Engineer (2026-01-10)
   - Author: GitHub profile with Express.js projects
   - Article: TypeScript-specific patterns with code examples
   - Stack match: ✅ TypeScript
   - ✅ Meets criteria

3. "Modern API Design" by John Doe (2026-01-12)
   - Author: No GitHub, no verifiable projects
   - Article: Generic advice, no examples, no stack specificity
   - Stack match: ❌ No stack mentioned
   - ❌ Does not meet criteria

4. "Django REST API Best Practices" by Python Dev (2026-01-15)
   - Author: Verified, but Django-focused
   - Stack match: ❌ Wrong framework (Django vs Express.js)
   - ⚠️  Good article but not relevant to this project's stack
```

**Priority**: Articles matching the project's specific stack are prioritized over generic best practices.

### Step 3: Analyze Findings

For each qualifying article, extract:

1. **New techniques or patterns** not in current agent-docs
2. **Updated recommendations** that contradict or refine existing content
3. **Real-world results** that validate approaches
4. **Code examples** or implementation details

**Compare against current agent-docs:**

```markdown
## Analysis: api.md

**Current content:**
- Rate limiting: 5 requests/minute for public endpoints
- Error codes: Standard HTTP status codes
- Authentication: JWT tokens

**New findings from verified sources:**

1. **Rate Limiting Strategy** (from Jane Smith, Stripe)
   - New: Tiered rate limits (different limits per user tier)
   - New: Rate limit headers in response (X-RateLimit-Remaining)
   - Evidence: Reduced support tickets by 40% with clearer limits
   - Recommendation: Add tiered rate limiting section

2. **Error Response Format** (from John Engineer, GitHub)
   - New: Include request_id in all error responses for tracing
   - New: Structured error details for programmatic handling
   - Evidence: Debug time reduced by 60% with request IDs
   - Recommendation: Update error response format section

**No updates needed:**
- Authentication patterns (no new verified information)
- Background jobs (current content still accurate)
```

### Step 4: Apply Updates Directly

Apply changes to agent-docs files. Cursor will show the diff for review:

```markdown
📝 Applying Updates to agent-docs/

## Summary of Changes:

**api.md:**
- Adding tiered rate limiting section
- Updating error response format to include request_id
- Adding source attribution

**architecture.md:**
- No updates (no new verified information since 2025-12-15)

**database.md:**
- No updates (no new verified information since 2026-01-05)

**testing.md:**
- Creating file from recent best practices (3 verified articles)

**Files being modified:**
- .cursor/agent-docs/api.md
- .cursor/agent-docs/testing.md (new file)

Changes will be shown in Cursor's diff viewer for review.
```

### Step 5: Apply Updates

Apply changes directly to agent-docs files. Cursor will display the diff for review:

1. **Backup current files:**
```bash
mkdir -p .cursor/agent-docs/.backup
cp .cursor/agent-docs/*.md .cursor/agent-docs/.backup/ 2>/dev/null || true
```

2. **Apply updates directly:**
- Add new sections with clear source attribution
- Update existing sections
- Preserve all existing content not being updated
- Add "Last updated" date at top of each file
- Add source attribution section

3. **Source attribution format:**
```markdown
## Sources

- [Article Title](URL) by [Author Name] ([Company/Role], [Date])
  - Key insight: [What was learned]
  - Evidence: [Results/metrics if available]
```

**Note**: All changes are applied directly. Cursor's diff viewer will show the modifications for review. You can accept, reject, or modify individual changes through Cursor's interface.

### Step 6: Report Completion

```markdown
✅ Agent-Docs Update Complete

**Updated:**
- api.md: Added tiered rate limiting, updated error format
  - Sources: 2 verified articles
  - Last updated: 2026-01-15

**Unchanged:**
- architecture.md: No new verified information
- database.md: No new verified information

**Created:**
- testing.md: Created from recent best practices
  - Sources: 3 verified articles
  - Last updated: 2026-01-15

**Next update check:** Run /update-agent-docs again in 3 months, or when you want to check for new practices.

**Backup location:** .cursor/agent-docs/.backup/
```

## Guidelines

### When to Run This Command

**Recommended: Before `/design-system`**
- Best practices inform design decisions
- Design command loads agent-docs, so having current patterns helps
- Spec tells you which domains are relevant (API, database, etc.)
- **Usage**: `/update-agent-docs docs/specs/[feature-name].md`

**Optional: After `/design-system`**
- Only if you want to document patterns you actually used
- But this is better captured in `agents.md` (project-specific learnings)
- Agent-docs are for industry best practices, not project documentation

**Periodic: Quarterly or when patterns change**
- Keep agent-docs current with industry evolution
- Run without spec argument to update all domains
- **Usage**: `/update-agent-docs`

### What Project Docs Inform Updates

**Required Context:**
1. **`.cursor/agents.md`** - Provides:
   - Technology stack (for stack-specific searches)
   - Framework/language (Express.js, TypeScript, etc.)
   - Database (PostgreSQL, MongoDB, etc.)
   - Project constraints and principles

2. **Existing `.cursor/agent-docs/*.md` files** - Provides:
   - Current patterns and conventions
   - Last update dates (to determine if updates needed)
   - What's already documented

**Optional but Recommended:**
3. **Feature spec** (`docs/specs/[feature-name].md`) - Provides:
   - Which domains are relevant (Data Model → database.md, API endpoints → api.md)
   - Feature requirements that might need new patterns
   - Scope boundaries (what to focus on)

**Not Used:**
- Design document (comes after, and we want best practices to inform design)
- Implementation code (agent-docs are for patterns, not documenting what you built)

### Quality Criteria for Sources

**Author Verification:**
- ✅ GitHub profile with real projects (not just forks)
- ✅ Published multiple technical articles
- ✅ Worked at respected tech companies
- ✅ Open source contributions with community recognition
- ✅ Case studies with measurable results

**Article Quality:**
- ✅ Includes code examples or implementation details
- ✅ Provides real-world metrics or results
- ✅ Not generic advice or opinion pieces
- ✅ Not vendor marketing content
- ✅ Published on reputable platforms (GitHub, engineering blogs, dev.to, etc.)

**Red Flags (Exclude):**
- ❌ No author profile or verifiable background
- ❌ Generic "top 10 tips" without depth
- ❌ Vendor marketing or sponsored content
- ❌ No code examples or implementation details
- ❌ Pure theory without practical application
- ❌ Author has no track record of real implementations

### Search Strategy

**Search Terms:**
- Use specific topic + "best practices" + current year
- Include "production" or "real-world" for practical focus
- Search engineering blogs of respected companies
- Use date filters (last 3 months)

**Platforms to Search:**
- GitHub (engineering blogs, technical posts)
- dev.to (developer community)
- Company engineering blogs (Stripe, GitHub, Netflix, etc.)
- Medium (filter for technical, verified authors)
- Hacker News discussions (link to articles)

### Update Philosophy

**Preserve Intent:**
- Don't remove project-specific decisions
- Keep intentional deviations from "standard" practices if they're documented
- Maintain project context and constraints

**Add, Don't Replace:**
- Prefer adding new sections over rewriting existing ones
- Mark new information clearly
- Show evolution of thinking with dates

**Source Attribution:**
- Always cite sources
- Include author credentials
- Note evidence/results if available

### When No Updates Needed

If no qualifying articles found:

```markdown
✅ No Updates Needed

Searched for articles published in last 3 months:
- api.md: 0 qualifying articles found
- architecture.md: 0 qualifying articles found
- database.md: 0 qualifying articles found
- testing.md: 0 qualifying articles found

**Criteria applied:**
- Published after: 2025-10-15
- Author with verified track record
- Real-world implementation examples
- Measurable results or case studies

Current agent-docs files are up to date with recent best practices.

**Next check:** Run /update-agent-docs again in 1-2 months.
```

## Context

Agent-docs directory: `.cursor/agent-docs/`

**Important**: This command requires internet access for web searches. Changes are applied directly and shown in Cursor's diff viewer for review. You can accept, reject, or modify changes through Cursor's interface.
