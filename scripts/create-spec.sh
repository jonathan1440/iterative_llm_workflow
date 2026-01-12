#!/bin/bash

# create-spec.sh
# Creates a new feature specification file from template

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get feature description from arguments
FEATURE_DESC="$*"

if [ -z "$FEATURE_DESC" ]; then
    echo -e "${RED}Error: No feature description provided${NC}"
    echo "Usage: $0 \"feature description\""
    exit 1
fi

# Generate safe filename from feature description
# Convert to lowercase, replace spaces with hyphens, remove special chars
SAFE_NAME=$(echo "$FEATURE_DESC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | tr -s ' ' | tr ' ' '-' | cut -c1-50)

# Ensure docs/specs directory exists
mkdir -p docs/specs

# Define spec file path
SPEC_FILE="docs/specs/${SAFE_NAME}.md"

# Check if file already exists
if [ -f "$SPEC_FILE" ]; then
    echo -e "${YELLOW}⚠️  Warning: Spec file already exists: $SPEC_FILE${NC}"
    echo -e "${YELLOW}   Overwrite? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Cancelled. Using existing file.${NC}"
        echo "$SPEC_FILE"
        exit 0
    fi
fi

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Create spec file from template
echo -e "${BLUE}📝 Creating specification: $SPEC_FILE${NC}"

cat > "$SPEC_FILE" << EOF
# Feature: $FEATURE_DESC

## Problem Statement

**Who**: [Specific user persona with real example - e.g., "Sarah, a property manager who oversees 47 rental units across 3 buildings"]

**What**: [Exact problem they face - be specific about the pain point]

**Why**: [Why current solutions don't work - what's the gap?]

## User Stories (Priority Order)

### P1 (MVP) - [Core Story Name]

As a [specific user type], I want to [specific action] so that [specific benefit]

**Acceptance Criteria:**
- [ ] [Measurable, testable criterion]
- [ ] [Another criterion]
- [ ] [Another criterion]

### P2 - [Next Priority Story]

As a [user type], I want to [action] so that [benefit]

**Acceptance Criteria:**
- [ ] [Criterion]
- [ ] [Criterion]

### P3 - [Nice to Have Story]

As a [user type], I want to [action] so that [benefit]

**Acceptance Criteria:**
- [ ] [Criterion]

## Success Criteria (Technology-Agnostic)

*These are measurable outcomes that prove the feature works, without mentioning specific technologies*

- [ ] Users complete [specific task] in under [X] seconds
- [ ] System handles [N] concurrent users without degradation
- [ ] [X]% of [action] succeed without errors
- [ ] [Specific metric] improves by [X]% compared to current state

## Functional Requirements

1. **[Requirement Name]**: System MUST [specific requirement]
   - Acceptance: [How to verify]
   - Rationale: [Why this matters]

2. **[Requirement Name]**: System SHOULD [specific requirement]
   - Acceptance: [How to verify]
   - Rationale: [Why this matters]

## Data Model

\`\`\`
EntityName
  - field_name: data_type (constraints)
  - relationship_name: related_entity (relationship_type)
  
Example:

User
  - id: uuid (primary key, auto-generated)
  - email: string (unique, validated format)
  - password_hash: string (bcrypt, min 60 chars)
  - created_at: timestamp (auto-generated)
  - updated_at: timestamp (auto-updated)
  - status: enum (active, inactive, suspended)

Session
  - id: uuid (primary key)
  - user_id: uuid (foreign key → User.id)
  - token: string (unique, 32 chars)
  - expires_at: timestamp
  - created_at: timestamp
\`\`\`

## Third-Party Dependencies

- **[Service/Library Name]**: [Why we need it]
  - Alternatives considered: [Other options]
  - Decision rationale: [Why this one]

## Constraints

- **Performance**: [Specific targets - e.g., "API responses < 200ms for 95% of requests"]
- **Security**: [Specific requirements - e.g., "Passwords MUST be hashed with bcrypt, min 10 rounds"]
- **Scalability**: [Limits - e.g., "Support up to 10,000 concurrent users"]
- **Cost**: [Budget constraints - e.g., "Hosting costs < \$100/month for first 1000 users"]
- **Compliance**: [Regulations - e.g., "GDPR compliant data handling"]

## Edge Cases & Error Handling

1. **[Edge Case]**: What happens when [scenario]
   - Expected behavior: [How system should respond]

2. **[Error Scenario]**: What happens when [failure condition]
   - User-facing message: [What user sees]
   - System behavior: [Logging, recovery, etc.]

## Out of Scope

*Explicitly excluded from this iteration*

- [Feature/capability we're NOT building now]
- [Another excluded item]
- [Deferred to future iteration with reason]

## Assumptions & Dependencies

**Assumptions:**
- [Assumption about user behavior, environment, etc.]
- [Another assumption]

**Dependencies:**
- [What must be in place before this can be built]
- [External systems or resources required]

## Open Questions

- [ ] [Question to resolve before implementation]
- [ ] [Another question]

## Clarifications

*This section is populated during the clarification process*

---

**Created**: $CURRENT_DATE  
**Status**: Draft  
**Last Updated**: $CURRENT_DATE
EOF

echo -e "${GREEN}✅ Specification created successfully${NC}"
echo ""
echo -e "${BLUE}📄 File: $SPEC_FILE${NC}"
echo ""

# Output the file path for the AI to use
echo "$SPEC_FILE"
