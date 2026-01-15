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

- **Last updated:** [YYYY-MM-DD]
- **Maintained by:** [Team/individual]
- **Review frequency:** [How often to review/update]

## Contributing

When you discover a new failure mode:

1. Document it in the appropriate category
2. Include: what fails, why, how to prevent, and examples
3. Update the "Last updated" date
4. Consider if it belongs in other agent-docs files too
