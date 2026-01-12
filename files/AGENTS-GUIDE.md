# agents.md Guide

**What is agents.md?**

The `agents.md` file is your project's living knowledge base. It captures patterns, decisions, standards, and mistakes discovered during development. It's the single source of truth for "how we do things here."

---

## 🎯 Purpose

**For the AI Assistant:**
- Reference when generating code
- Follow project-specific conventions
- Avoid documented mistakes
- Understand architectural decisions

**For Developers:**
- Onboarding reference
- Decision documentation
- Pattern library
- Mistake prevention

**For the Team:**
- Shared understanding
- Consistent practices
- Knowledge preservation
- Continuous improvement

---

## 📋 What's Included in the Sample

The sample `agents.md` includes:

### 1. Project Overview
- Purpose, users, tech stack
- High-level architecture

### 2. Code Standards (37 entries)
- File organization patterns
- Naming conventions
- Language-specific standards (TypeScript, Python)
- Code formatting rules

### 3. Architecture Principles (5 entries)
- Service layer pattern
- Repository pattern
- Error handling strategy
- API versioning
- Database access patterns

### 4. Implementation Best Practices (4 entries)
- Authentication flow
- Input validation
- Database migrations
- Async/await patterns

### 5. Database Conventions (4 entries)
- Table naming
- Column standards
- Foreign key patterns
- Indexing strategy

### 6. API Design Guidelines (4 entries)
- Endpoint naming
- Query parameters
- Response formats
- HTTP status codes

### 7. Testing Strategy (3 entries)
- Test organization
- Test pyramid distribution
- Coverage requirements

### 8. Security Requirements (4 entries)
- Authentication/authorization
- SQL injection prevention
- CORS configuration
- Rate limiting

### 9. Performance Guidelines (3 entries)
- Query optimization
- Caching strategy
- Pagination

### 10. Common Mistakes (6 entries)
- Business logic in routes
- Missing database indexes
- Floating point for money
- Committing secrets
- Client-side validation only
- More...

### 11. Deployment Process (3 entries)
- Pre-deployment checklist
- Database migration deployment
- Environment configuration

### 12. Third-Party Integrations (2 entries)
- Stripe payment processing
- SendGrid email service

### 13. Archive
- Outdated entries preserved for history

**Total**: ~850 lines, 70+ documented patterns

---

## 🚀 How to Use

### For New Projects

1. **Copy the sample** to `.cursor/agents.md`
2. **Customize** the Project Overview section
3. **Keep** relevant sections for your tech stack
4. **Remove** sections you don't need
5. **Start adding** your own patterns

### During Development

**When to add entries:**
- Discover a useful pattern → Document it
- Make a mistake → Document why it was wrong
- Make an architectural decision → Explain rationale
- Establish a convention → Write it down
- Find a better approach → Update and note date

**When NOT to add:**
- General programming knowledge (Google-able)
- Framework documentation (link instead)
- Temporary hacks (unless documenting why to avoid)

### Monthly Review

Use `/review-agents` command to:
- Identify patterns from git history
- Find duplicate entries
- Validate entry quality
- Organize and categorize
- Archive outdated entries

---

## ✍️ Writing Good Entries

### Standard Entry Format

```markdown
### Entry Title

**Pattern/principle description**

```code
Example code here
```

**Rationale**: Why this matters  
**Added**: YYYY-MM-DD
```

### Extended Format for Mistakes

```markdown
### Don't [Mistake Title]

**Mistake**: Brief description of the mistake

**Example of the mistake**:
```code
// Bad code example
```

**Why it's wrong**:
- Specific reason 1
- Specific reason 2
- Specific reason 3

**Correct approach**:
```code
// Good code example
```

**Rationale**: Core reason this matters  
**Added**: YYYY-MM-DD
```

### Key Elements

1. **Clear Title** - Scannable and descriptive
2. **Code Examples** - Show, don't just tell
3. **Rationale** - Always explain WHY
4. **Date Added** - Track evolution over time
5. **Specificity** - Concrete, not vague

---

## 📖 Entry Categories Explained

### Code Standards
**What**: Naming, formatting, organization  
**Why**: Consistency reduces cognitive load  
**Examples**: "Use camelCase for functions", "Files in kebab-case"

### Architecture Principles
**What**: High-level design decisions  
**Why**: Guides major structural choices  
**Examples**: "Service layer pattern", "No business logic in routes"

### Implementation Best Practices
**What**: How to implement specific features  
**Why**: Proven approaches save time  
**Examples**: "JWT in HTTP-only cookies", "Always validate at boundary"

### Common Mistakes
**What**: Things that went wrong  
**Why**: Learn from failures  
**Examples**: "Don't use float for money", "Index foreign keys"

---

## 🔄 Lifecycle

### Phase 1: Initial Setup
```bash
/init-project "My Project"
# Creates agents.md with sample content
```

### Phase 2: Customization
- Remove irrelevant sections
- Add project specifics
- Update tech stack references

### Phase 3: Growth
- Add entries during development
- Document decisions as made
- Capture mistakes when found

### Phase 4: Maintenance
```bash
/review-agents  # Monthly
# Identifies patterns, duplicates, gaps
```

### Phase 5: Maturity
- 100+ entries
- Comprehensive coverage
- Team reference
- Onboarding goldmine

---

## 💡 Pro Tips

### Start Small
Don't try to document everything upfront. Let it grow organically. Add entries when you encounter the situation.

### Be Specific
❌ Bad: "Write good code"  
✅ Good: "Functions should be < 20 lines; extract helpers if longer"

### Show Examples
Code examples are worth 1000 words. Always include them.

### Explain Why
The rationale is often more important than the rule itself.

### Keep It Updated
When you find a better approach, update the entry and note the date.

### Use Real Code
Copy actual code from your project. Real examples are more valuable than theoretical ones.

### Link to Decisions
Reference issues, PRs, or docs where decisions were made.

### Archive, Don't Delete
Move outdated entries to Archive section. History matters.

---

## 🎯 Quality Checklist

A good agents.md entry has:
- [ ] Clear, descriptive title
- [ ] Code example (if applicable)
- [ ] Explanation of why it matters
- [ ] Date added
- [ ] Specific, not vague
- [ ] Actionable guidance

A great Common Mistakes entry also has:
- [ ] Example of the mistake
- [ ] Explanation of why it's wrong
- [ ] Correct approach shown
- [ ] Consequences explained

---

## 🔧 Maintenance

### Weekly
- Quick scan during implementation
- Add entries for new patterns
- Note mistakes made

### Monthly
- Run `/review-agents`
- Review and merge duplicates
- Update outdated entries
- Organize categories

### Quarterly
- Comprehensive review
- Archive old entries
- Reorganize structure
- Share highlights with team

---

## 🚫 Anti-Patterns

**Don't**:
- Copy documentation from frameworks
- Write vague principles
- Skip rationales
- Forget to date entries
- Let it become stale
- Make it too rigid
- Add every tiny detail

**Do**:
- Document project-specific patterns
- Write concrete guidelines
- Always explain why
- Date every entry
- Review regularly
- Keep it practical
- Focus on what matters

---

## 📊 Success Metrics

**Good agents.md has:**
- 50+ entries after 3 months
- Regular additions (weekly)
- Clear organization
- Real code examples
- Team actually uses it
- References in PRs
- Cited in discussions

**Great agents.md has:**
- 100+ entries after 6 months
- Monthly reviews
- No duplicates
- Archived outdated entries
- Team contributes
- Part of onboarding
- Evolves with project

---

## 🎓 Integration with Workflow

### With Other Commands

**During spec-feature:**
```bash
/spec-feature "New feature"
# References agents.md for project standards
```

**During design-system:**
```bash
/design-system docs/specs/feature.md
# Loads agents.md for architecture principles
```

**During implement-story:**
```bash
/implement-story "User Story 1"
# Follows patterns from agents.md
# Adds learnings to agents.md
```

**During refactor:**
```bash
/refactor "Extract service"
# May add new pattern to agents.md
```

**Monthly review:**
```bash
/review-agents
# Analyzes git history
# Suggests new entries
# Identifies duplicates
```

---

## 📝 Customization Guide

### For Your Tech Stack

**If you use different languages:**
- Replace TypeScript/Python examples with your languages
- Keep the principles, change the syntax

**If you use different frameworks:**
- Update examples to match your framework
- Keep architectural patterns

**If you use different databases:**
- Update SQL examples for your DB
- Keep the principles (indexes, naming, etc.)

### For Your Team

**Solo developer:**
- Focus on personal patterns and mistakes
- Document decisions for future you

**Small team (2-5):**
- Shared agents.md in repo
- Team discusses additions
- Quick to reach consensus

**Larger team:**
- May need separate sections per squad
- Regular review meetings
- Designated maintainer

---

## 🎉 Benefits

**For Solo Developers:**
- External memory
- Consistent practices
- Future-proof decisions
- AI assistant works better

**For Teams:**
- Shared understanding
- Faster onboarding
- Consistent codebase
- Knowledge preservation

**For Projects:**
- Better architecture
- Fewer mistakes
- Higher quality
- Faster development

---

## 📚 Resources

**Sample entries in this file:**
- 70+ patterns across 13 categories
- Real code examples
- Good/bad comparisons
- Comprehensive coverage

**Creating your own:**
1. Start with sample
2. Customize for your stack
3. Add as you build
4. Review monthly
5. Let it grow organically

**Remember**: agents.md is a living document. It should evolve with your project. Start small, stay consistent, and let it grow naturally.

---

*The best agents.md is the one you actually maintain and use.*
