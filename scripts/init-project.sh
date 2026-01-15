#!/bin/bash

# init-project.sh
# Initialize project structure for AI-assisted development with Cursor

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
ARGS="$*"

echo -e "${BLUE}🚀 Initializing project structure...${NC}\n"

# Create .cursor directory structure
echo -e "${GREEN}📁 Creating .cursor/ directory structure...${NC}"
mkdir -p .cursor/commands
mkdir -p .cursor/scripts

# Create docs/specs directory
echo -e "${GREEN}📁 Creating docs/specs/ directory...${NC}"
mkdir -p docs/specs

# Create agents.md from template
echo -e "${GREEN}📝 Creating .cursor/agents.md from template...${NC}"

# Check for template in .cursor/templates/ first (after installation), then templates/ (before installation)
TEMPLATE_PATH=""
if [ -f ".cursor/templates/agents-example.md" ]; then
    TEMPLATE_PATH=".cursor/templates/agents-example.md"
elif [ -f "templates/agents-example.md" ]; then
    TEMPLATE_PATH="templates/agents-example.md"
fi

if [ -z "$TEMPLATE_PATH" ]; then
    echo -e "${YELLOW}⚠️  Template not found at .cursor/templates/agents-example.md or templates/agents-example.md${NC}"
    echo -e "${YELLOW}   Creating basic agents.md instead...${NC}"
    # Fallback to basic template if example doesn't exist
    cat > .cursor/agents.md << 'EOF'
# Project Context

- **Purpose**: [What problem does this solve?]
- **Users**: [Who are the primary users?]
- **Core Constraints**: [Performance/cost/compliance requirements]

# Code Standards (Non-Negotiable)

1. **Testing**: All business logic MUST have tests
   - Rationale: Catch bugs before production, enable confident refactoring
   
2. **Security**: Input validation REQUIRED on all external-facing endpoints
   - Rationale: Prevent injection attacks, data corruption
   
3. **Formatting**: [Tool name] with [configuration]
   - Rationale: Consistent code style reduces cognitive load
   
4. **Error Handling**: Never expose internal errors to users
   - Rationale: Security (don't leak system info) + UX (user-friendly messages)

# Architecture Principles

1. **[Principle Name]**: [MUST/SHOULD statement]
   - Rationale: [Why this matters for this project]
   - Example: "Stateless Services: All services MUST be stateless for horizontal scaling"

# Common Mistakes

<!-- This section grows over time as you learn -->
<!-- Format: -->
<!-- ## Mistake: [Short description] -->
<!-- - **What happened**: [Description] -->
<!-- - **Why wrong**: [Explanation] -->
<!-- - **Correct pattern**: [What to do instead] -->
<!-- - **Added**: YYYY-MM-DD -->

# Last Updated
EOF
    echo "$(date +%Y-%m-%d)" >> .cursor/agents.md
else
    # Copy template and update date
    cp "$TEMPLATE_PATH" .cursor/agents.md
    
    # Update the Last Updated date in the file
    CURRENT_DATE=$(date +%Y-%m-%d)
    # Use sed to replace the date line (works on both macOS and Linux)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS sed
        sed -i '' "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $CURRENT_DATE/" .cursor/agents.md
    else
        # Linux sed
        sed -i "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $CURRENT_DATE/" .cursor/agents.md
    fi
    
    echo -e "${GREEN}✅ Created .cursor/agents.md from $TEMPLATE_PATH${NC}"
fi

# Create agent-docs directory structure
echo -e "${GREEN}📁 Creating .cursor/agent-docs/ directory...${NC}"
mkdir -p .cursor/agent-docs

# Copy agent-docs templates if they exist
AGENT_DOCS_SOURCE=""
if [ -d "agent-docs" ]; then
    AGENT_DOCS_SOURCE="agent-docs"
elif [ -d ".cursor/agent-docs" ] && [ "$(ls -A .cursor/agent-docs/*.md 2>/dev/null)" ]; then
    # Already has files, skip
    AGENT_DOCS_SOURCE=""
fi

if [ -n "$AGENT_DOCS_SOURCE" ]; then
    echo -e "${GREEN}📝 Copying agent-docs templates...${NC}"
    for file in "$AGENT_DOCS_SOURCE"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            cp "$file" ".cursor/agent-docs/$filename"
            echo -e "  ✅ Copied $filename"
        fi
    done
else
    # Create basic agent-docs files from templates if they don't exist
    if [ ! -f ".cursor/agent-docs/api.md" ]; then
        echo -e "${GREEN}📝 Creating .cursor/agent-docs/api.md template...${NC}"
        cat > .cursor/agent-docs/api.md << 'EOF'
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

## Background Jobs

- Queue: [Redis / SQS / etc]
- Workers in `src/workers/`
- Enqueue via `src/services/queue.ts`

## Error Codes

| Code | HTTP Status | When to use |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Invalid input |
| `UNAUTHORIZED` | 401 | Missing/invalid auth |
| `FORBIDDEN` | 403 | Valid auth but not permitted |
| `NOT_FOUND` | 404 | Resource doesn't exist |
| `CONFLICT` | 409 | Duplicate or state conflict |
| `RATE_LIMITED` | 429 | Too many requests |

**Last Updated**: $(date +%Y-%m-%d)
EOF
    fi

    if [ ! -f ".cursor/agent-docs/architecture.md" ]; then
        echo -e "${GREEN}📝 Creating .cursor/agent-docs/architecture.md template...${NC}"
        cat > .cursor/agent-docs/architecture.md << 'EOF'
# Architecture

> Read this before implementing new features or refactoring.

## High-Level Design

[Describe the overall system architecture in 3-5 sentences. What are the main components and how do they interact?]

## Key Patterns

### Service Layer
All business logic lives in `src/services/`. Routes should be thin (< 15 lines) and delegate to services.

### Error Handling
Use the custom exception hierarchy in `src/errors/`:
- `ValidationError` (400)
- `NotFoundError` (404)
- `AuthenticationError` (401)

## File References

- Entry point: `src/index.ts:1`
- Service base class: `src/services/base.ts:10`
- Error types: `src/errors/index.ts:1`
- Database connection: `src/db/connection.ts:1`

**Last Updated**: $(date +%Y-%m-%d)
EOF
    fi

    if [ ! -f ".cursor/agent-docs/database.md" ]; then
        echo -e "${GREEN}📝 Creating .cursor/agent-docs/database.md template...${NC}"
        cat > .cursor/agent-docs/database.md << 'EOF'
# Database

> Read this before schema changes or complex queries.

## Stack

- **Database:** [PostgreSQL / MySQL / SQLite]
- **ORM/Query Builder:** [Prisma / Drizzle / SQLAlchemy / raw SQL]
- **Migrations:** [Tool used]

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

**Last Updated**: $(date +%Y-%m-%d)
EOF
    fi

    if [ ! -f ".cursor/agent-docs/testing.md" ]; then
        echo -e "${GREEN}📝 Creating .cursor/agent-docs/testing.md template...${NC}"
        cat > .cursor/agent-docs/testing.md << 'EOF'
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

# Full suite (before PR only)
[npm test]
```

## Test Structure

Tests live alongside source files or in `tests/` mirroring `src/` structure.

## Writing Tests

**Good test:**
- Tests one thing
- Uses descriptive names
- Sets up and tears down properly
- Doesn't depend on execution order

**Avoid:**
- Tests that depend on execution order
- Hardcoded IDs or timestamps
- Mocking everything (prefer integration tests where reasonable)

**Last Updated**: $(date +%Y-%m-%d)
EOF
    fi

    if [ ! -f ".cursor/agent-docs/failure-modes.md" ]; then
        echo -e "${GREEN}📝 Creating .cursor/agent-docs/failure-modes.md template...${NC}"
        cat > .cursor/agent-docs/failure-modes.md << 'EOF'
# Failure Modes

> Read this before implementing features to avoid common mistakes and edge cases.

## Purpose

This document captures project-specific failure modes, edge cases, and gotchas discovered during development. Update it whenever you encounter a new failure pattern or learn how to prevent a mistake.

## Common Failure Patterns

### [Category: e.g., Authentication, Database, API Integration]

#### Failure: [Brief description of what fails]

**What happens:**
- [Specific failure scenario]
- [When it occurs]

**Why it fails:**
- [Root cause or underlying issue]

**How to prevent:**
- [Specific prevention steps]
- [Code patterns to use]
- [What to check]

**Example:**
```typescript
// ❌ Bad: [Example of the failure]
// ✅ Good: [Example of correct approach]
```

**Related patterns:**
- See `agent-docs/api.md` for [related pattern]
- See `agent-docs/database.md` for [related pattern]

---

## Edge Cases

### [Category: e.g., Data Validation, Concurrency, External Services]

#### Edge Case: [Description]

**Scenario:**
- [When this edge case occurs]

**Expected behavior:**
- [What should happen]

**Common mistakes:**
- [What people often get wrong]

**Correct handling:**
- [How to handle it properly]

**Example:**
```typescript
// Handle edge case: [code example]
```

---

## Integration Failure Points

### [Integration: e.g., Third-party API, Database, Queue System]

#### Failure Point: [What can fail]

**Symptoms:**
- [How you know it's failing]
- [Error messages or behaviors]

**Root causes:**
- [Why it fails]

**Prevention:**
- [How to prevent]
- [Monitoring/alerting to add]

**Recovery:**
- [How to recover if it happens]
- [Fallback strategies]

---

## Silent Failures

### [Category: e.g., Background Jobs, Caching, Logging]

#### Silent Failure: [Description]

**What fails silently:**
- [What doesn't throw errors but should]

**How to detect:**
- [Ways to catch this]
- [Monitoring/metrics to watch]

**How to prevent:**
- [Explicit checks to add]
- [Validation to include]

---

## Performance Failure Modes

### [Category: e.g., Database Queries, API Calls, Memory]

#### Performance Issue: [Description]

**When it occurs:**
- [Conditions that trigger it]

**Impact:**
- [What gets slow or breaks]

**How to prevent:**
- [Optimization strategies]
- [What to avoid]

**How to monitor:**
- [Metrics to track]

---

## Security Failure Modes

### [Category: e.g., Authentication, Authorization, Data Exposure]

#### Security Issue: [Description]

**Vulnerability:**
- [What's exposed or exploitable]

**How it's exploited:**
- [Attack scenario]

**How to prevent:**
- [Security measures]
- [Validation to add]

**Related:**
- See security section in `agents.md`

---

## Data Consistency Failures

### [Category: e.g., Race Conditions, Transaction Boundaries, Cache Invalidation]

#### Consistency Issue: [Description]

**When it occurs:**
- [Concurrency scenario]

**What breaks:**
- [Data inconsistency symptoms]

**How to prevent:**
- [Locks, transactions, or patterns to use]

**Example:**
```typescript
// Prevent race condition: [code example]
```

---

## Environment-Specific Failures

### [Environment: e.g., Development, Staging, Production]

#### Environment Issue: [Description]

**What's different:**
- [Environment-specific behavior]

**Common mistakes:**
- [What people assume incorrectly]

**How to handle:**
- [Environment checks to add]
- [Configuration to verify]

---

## Notes

- **Last updated:** $(date +%Y-%m-%d)
- **Maintained by:** [Team/individual]
- **Review frequency:** [How often to review/update]

## Contributing

When you discover a new failure mode:

1. Document it in the appropriate category
2. Include: what fails, why, how to prevent, and examples
3. Update the "Last updated" date
4. Consider if it belongs in other agent-docs files too
EOF
    fi
fi

# Move this script to .cursor/scripts/
echo -e "${GREEN}📦 Installing initialization script...${NC}"
cp "$0" .cursor/scripts/init-project.sh 2>/dev/null || true
chmod +x .cursor/scripts/init-project.sh 2>/dev/null || true

# Initialize git if not already a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}📦 Initializing git repository...${NC}"
    git init
    
    # Create .gitignore based on detected files
    echo -e "${GREEN}📝 Creating .gitignore...${NC}"
    cat > .gitignore << 'GITIGNORE'
# Dependencies
node_modules/
vendor/
.venv/
venv/
__pycache__/

# Build outputs
dist/
build/
out/
target/
*.egg-info/

# Environment variables
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Testing
coverage/
.coverage
*.coveragerc

# Temporary files
*.tmp
*.cache
.temp/
GITIGNORE

    git add .gitignore
    echo -e "${GREEN}✅ Git repository initialized${NC}"
else
    echo -e "${BLUE}ℹ️  Git repository already exists${NC}"
    
    # Check if .gitignore exists and append if needed
    if [ ! -f .gitignore ]; then
        echo -e "${GREEN}📝 Creating .gitignore...${NC}"
        cat > .gitignore << 'GITIGNORE'
# Dependencies
node_modules/
vendor/
.venv/
venv/
__pycache__/

# Build outputs
dist/
build/
out/
target/
*.egg-info/

# Environment variables
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Testing
coverage/
.coverage
*.coveragerc

# Temporary files
*.tmp
*.cache
.temp/
GITIGNORE
    fi
fi

# Create README if it doesn't exist
if [ ! -f README.md ]; then
    echo -e "${GREEN}📝 Creating README.md...${NC}"
    cat > README.md << 'README'
# Project Name

## Overview

[Brief description of what this project does]

## Getting Started

### Prerequisites

- [List prerequisites]

### Installation

```bash
# Installation steps
```

### Usage

```bash
# Usage examples
```

## Development

This project uses AI-assisted development with Cursor. See `.cursor/agents.md` for project standards and principles.

### Project Structure

```
.cursor/          # Cursor AI configuration
  agents.md       # Project constitution and standards
  commands/       # Custom slash commands
  scripts/        # Helper scripts
docs/
  specs/          # Feature specifications
```

### Creating Features

1. Create spec: Use `/spec-feature` command
2. Design system: Use `/design-system` command  
3. Plan tasks: Use `/plan-tasks` command
4. Implement: Use `/implement-story` command

## Contributing

[Contributing guidelines]

## License

[License information]
README
fi

# Create example spec template for reference
echo -e "${GREEN}📝 Creating example spec template...${NC}"
cat > docs/specs/TEMPLATE.md << 'TEMPLATE'
# Feature: [Feature Name]

## Problem Statement

**Who**: [Specific user persona with real example - e.g., "Sarah, a property manager who oversees 47 rental units"]
**What**: [Exact problem they face - be specific]
**Why**: [Why current solutions don't work]

## User Stories (Priority Order)

### P1 (MVP) - [Story Name]
As a [user type], I want to [action] so that [benefit]

**Acceptance Criteria:**
- [ ] [Measurable, testable criterion]
- [ ] [Another criterion]

### P2 - [Story Name]
[Next priority story]

### P3 - [Nice to Have]
[Lower priority story]

## Success Criteria (Technology-Agnostic)

- [ ] Users complete [task] in under [X] seconds
- [ ] System handles [N] concurrent users  
- [ ] 95% of [action] succeed without errors
- [ ] [Other measurable outcomes]

## Functional Requirements

1. [Testable requirement with clear acceptance]
2. [Another requirement]

**Example**: "System MUST validate email format before creating account"

## Data Model

```
EntityName
  - field_name: type (constraints)
  - relationship: foreign key reference
  
Example:
User
  - id: uuid (primary key)
  - email: string (unique, validated)
  - created_at: timestamp (auto-generated)
```

## Constraints

- **Performance**: [Specific targets - e.g., "API response < 200ms for 95% of requests"]
- **Security**: [Specific requirements - e.g., "Passwords MUST be hashed with bcrypt"]
- **Cost**: [Budget limits if any]

## Out of Scope

- [Explicitly excluded features]
- [Things we're NOT building in this iteration]

---
**Created**: YYYY-MM-DD  
**Status**: [Draft/In Review/Approved/In Progress/Complete]
TEMPLATE

# Create a sample command template
echo -e "${GREEN}📝 Creating sample command template...${NC}"
cat > .cursor/commands/EXAMPLE-command.md << 'EXAMPLE'
---
description: Brief description of what this command does
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Step 1**: Do something
   - Action details
   - Expected outcome

2. **Step 2**: Do something else
   - Action details
   - Expected outcome

## Guidelines

- Key principle 1
- Key principle 2

## Example Usage

```
User: /example-command "some input"

AI: [Expected AI response]
```

## Context

Additional context from user input: $ARGUMENTS
EXAMPLE

echo ""
echo -e "${GREEN}✅ Project initialization complete!${NC}\n"
echo -e "${BLUE}📁 Created directories:${NC}"
echo "  - .cursor/"
echo "  - .cursor/commands/"
echo "  - .cursor/scripts/"
echo "  - .cursor/agent-docs/"
echo "  - docs/specs/"
echo ""
echo -e "${BLUE}📝 Created files:${NC}"
echo "  - .cursor/agents.md (project constitution - EDIT THIS)"
echo "  - .cursor/agent-docs/*.md (domain-specific patterns - EDIT AS NEEDED)"
echo "  - .cursor/scripts/init-project.sh"
echo "  - docs/specs/TEMPLATE.md (reference)"
echo "  - .cursor/commands/EXAMPLE-command.md (reference)"
if [ ! -f README.md ]; then
    echo "  - README.md"
fi
echo "  - .gitignore"
echo ""
echo -e "${YELLOW}🎯 Next steps:${NC}"
echo "  1. Edit .cursor/agents.md with your project details"
echo "  2. Review and customize .cursor/agent-docs/*.md files for your stack"
echo "  3. Review the standards and principles"
echo "  4. Create your first feature spec"
echo ""
echo -e "${BLUE}💡 Tip: agents.md will grow over time as you learn.${NC}"
echo -e "${BLUE}   Update it whenever you discover mistakes or patterns.${NC}"
echo ""
