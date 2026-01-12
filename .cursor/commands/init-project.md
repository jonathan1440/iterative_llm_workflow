---
description: Initialize a new project with agents.md constitution, directory structure, and development standards.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

This command sets up the foundational project structure for AI-assisted development with Cursor.

### 1. Execute Setup Script

Run the initialization script from the repository root:

```bash
bash .cursor/scripts/init-project.sh "$ARGUMENTS"
```

**Script Actions:**
- Creates `.cursor/` directory structure
- Generates `agents.md` with constitution template
- Sets up `docs/specs/` for specifications
- Creates `.cursor/commands/` for custom commands
- Initializes git repository if needed
- Creates appropriate ignore files

### 2. Gather Project Context

After the script completes, help the user fill in the `agents.md` template by asking:

**Project Context:**
1. "What is the main purpose of this project?" → Update `Purpose`
2. "Who are the primary users?" → Update `Users`
3. "What are the core constraints (performance/cost/compliance)?" → Update `Core Constraints`

**Technology Stack:**
4. "What language(s) will you use?" → Update `Code Standards`
5. "What testing framework?" → Update `Testing` standard
6. "What code formatter?" → Update `Formatting` standard

### 3. Establish Non-Negotiable Standards

Propose default standards and ask for confirmation:

**Suggested Code Standards:**
- ✅ Testing: All business logic MUST have tests
- ✅ Security: Input validation REQUIRED on all external-facing endpoints
- ✅ Error Handling: Never expose internal errors to users
- ✅ Formatting: [Detected from language choice]

Ask: "Do you want to add or modify any of these standards?"

### 4. Define Architecture Principles

Based on project type, suggest 2-3 initial principles:

**For Web Applications:**
- Stateless Services: All services MUST be stateless for horizontal scaling
- API-First Design: All features MUST have API endpoints before UI
- [One more based on user's description]

**For CLI Tools:**
- Single Responsibility: Each command MUST do one thing well
- Composability: Commands MUST work in pipelines
- [One more based on user's description]

**For Libraries:**
- Zero Dependencies: MUST avoid external dependencies unless essential
- Backward Compatibility: Public APIs MUST follow semantic versioning
- [One more based on user's description]

Ask: "Which architecture principles are most important for this project?"

### 5. Update agents.md

Write the collected information to `.cursor/agents.md`, replacing all placeholders:

```markdown
# Project Context
- **Purpose**: [Filled from user answers]
- **Users**: [Filled from user answers]
- **Core Constraints**: [Filled from user answers]

# Code Standards (Non-Negotiable)
1. **Testing**: [Filled from user answers]
2. **Security**: [Filled from user answers]
3. **Formatting**: [Filled from user answers]
4. **Error Handling**: [Filled from user answers]

# Architecture Principles
1. **[Principle Name]**: [Rule] - [Rationale]
2. **[Principle Name]**: [Rule] - [Rationale]

# Common Mistakes
<!-- This section will be populated as the project develops -->
<!-- Add mistakes here when you learn from errors -->

# Last Updated
[Today's date]
```

### 6. Validate Setup

After updating `agents.md`, verify:

- [ ] All Code Standards use MUST/SHOULD/MAY language
- [ ] Each Architecture Principle has clear rationale
- [ ] No vague terms without metrics ("robust", "scalable", "fast")
- [ ] Purpose statement is specific (not generic)

If any validation fails, ask clarifying questions to resolve.

### 7. Report Completion

Display a summary:

```
✅ Project initialized successfully!

📁 Created directories:
  - .cursor/
  - .cursor/commands/
  - docs/specs/

📝 Created files:
  - .cursor/agents.md (project constitution)
  - .gitignore (if git repo)

🎯 Next steps:
  1. Review .cursor/agents.md and refine as needed
  2. Create your first feature spec with /spec-feature
  3. Start building!

💡 Tip: agents.md will grow over time as you learn. 
   Update it whenever you discover mistakes or patterns.
```

## Context

Use any user-provided context to inform suggested standards and principles: $ARGUMENTS

## Guidelines

- **Interactive Setup**: Don't auto-fill everything - ask questions to understand the project
- **Practical Defaults**: Suggest standards based on common best practices
- **Flexibility**: Allow users to customize or skip standards
- **Educational**: Explain WHY each standard matters when suggesting
- **Concise**: Keep the conversation focused - 5-7 questions maximum

**Example Conversation Flow:**

```
User: /init-project "Building a SaaS app for property management"

AI: I'll help you set up this project. Let me ask a few questions:

1. **Main purpose**: You said "SaaS app for property management" - 
   can you be more specific? What's the core problem you're solving?
   
   [User answers...]
   
2. **Primary users**: Who will use this?
   - Property managers
   - Tenants  
   - Both
   - Other
   
   [User answers...]
   
3. **Technology stack**: What are you building with?
   - Language: [TypeScript, Python, Go, etc.]
   - Framework: [Next.js, Django, etc.]
   
   [Continue through questions...]

[After gathering context]

Great! I've created .cursor/agents.md with your project standards.
Here's what I set up...
```
