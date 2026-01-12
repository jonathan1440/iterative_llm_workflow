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

# Check if template exists
TEMPLATE_PATH="templates/agents-example.md"
if [ ! -f "$TEMPLATE_PATH" ]; then
    echo -e "${YELLOW}⚠️  Template not found at $TEMPLATE_PATH${NC}"
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
echo "  - docs/specs/"
echo ""
echo -e "${BLUE}📝 Created files:${NC}"
echo "  - .cursor/agents.md (project constitution - EDIT THIS)"
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
echo "  2. Review the standards and principles"
echo "  3. Create your first feature spec"
echo ""
echo -e "${BLUE}💡 Tip: agents.md will grow over time as you learn.${NC}"
echo -e "${BLUE}   Update it whenever you discover mistakes or patterns.${NC}"
echo ""
