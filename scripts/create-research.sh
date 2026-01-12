#!/bin/bash

# create-research.sh
# Creates a research document for resolving technical unknowns

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get spec file path
SPEC_PATH="$1"

if [ -z "$SPEC_PATH" ]; then
    echo -e "${RED}Error: No spec file provided${NC}"
    echo "Usage: $0 <path-to-spec.md>"
    exit 1
fi

if [ ! -f "$SPEC_PATH" ]; then
    echo -e "${RED}Error: Spec file not found: $SPEC_PATH${NC}"
    exit 1
fi

# Generate research file path
SPEC_DIR=$(dirname "$SPEC_PATH")
SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
RESEARCH_PATH="${SPEC_DIR}/${SPEC_FILENAME}-research.md"

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Extract feature name from spec
FEATURE_NAME=$(grep -m 1 "^# Feature:" "$SPEC_PATH" | sed 's/^# Feature: //' || echo "Unknown Feature")

echo -e "${BLUE}📋 Creating research document...${NC}"
echo ""

# Check if research file already exists
if [ -f "$RESEARCH_PATH" ]; then
    echo -e "${YELLOW}⚠️  Research file already exists: $RESEARCH_PATH${NC}"
    echo -e "${YELLOW}   Overwrite? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Cancelled. Using existing file.${NC}"
        echo "$RESEARCH_PATH"
        exit 0
    fi
fi

# Create research document template
cat > "$RESEARCH_PATH" << EOF
# Research & Technical Decisions: $FEATURE_NAME

**Created**: $CURRENT_DATE  
**Status**: In Progress  
**Related Spec**: $(basename "$SPEC_PATH")

## Overview

This document captures research, technical decisions, and trade-offs made during the design phase. Each decision includes evaluated alternatives and rationale.

---

## Research Items

### Template for Each Decision

<!-- Copy this template for each technical decision that needs research -->

<!--
## Research Item: [Decision Name]

**Question**: What do we need to decide?

**Context**: Why does this decision matter?
- Requirement from spec: [Relevant requirement]
- Constraint from spec: [Relevant constraint]
- Impact area: [Performance/Security/Cost/Complexity]

**Options Evaluated**:

### Option A: [Name]
- **Description**: [Brief description]
- **Pros**:
  - [Benefit 1]
  - [Benefit 2]
- **Cons**:
  - [Drawback 1]
  - [Drawback 2]
- **Cost**: [Development time, hosting cost, licensing]
- **Complexity**: [Learning curve, maintenance burden]
- **Examples**: [Real-world usage, similar projects]

### Option B: [Name]
- **Description**: [Brief description]
- **Pros**:
  - [Benefit 1]
  - [Benefit 2]
- **Cons**:
  - [Drawback 1]
  - [Drawback 2]
- **Cost**: [Development time, hosting cost, licensing]
- **Complexity**: [Learning curve, maintenance burden]
- **Examples**: [Real-world usage, similar projects]

### Option C: [Name] (if applicable)
- [Same structure as above]

**Decision**: [Chosen option]

**Rationale**: 
[Detailed explanation of why this option was chosen, referencing:
- Specific requirements from spec
- Constraints from agents.md
- Team expertise
- Project timeline
- Budget constraints]

**Trade-offs Accepted**:
- We get: [Benefits of chosen option]
- We give up: [What we're sacrificing]
- We defer: [What we might revisit later]

**Implementation Notes**:
- [Any specific considerations for implementing this decision]

**Risks & Mitigations**:
- Risk: [Potential issue]
  - Mitigation: [How we'll address it]

---
-->

## Decision Log

<!-- AI will populate this section with actual decisions -->

---

## Deferred Decisions

<!-- Decisions that don't need to be made now -->

| Decision | Why Deferred | Revisit When |
|----------|--------------|--------------|
| [Decision topic] | [Reason] | [Condition] |

---

## Assumptions

<!-- Technical assumptions we're making -->

- [Assumption 1 with justification]
- [Assumption 2 with justification]

---

## References

<!-- Useful links, documentation, articles consulted -->

- [Link title](URL) - Brief description
- [Another link](URL) - Brief description

---

**Last Updated**: $CURRENT_DATE
EOF

echo -e "${GREEN}✅ Research document created${NC}"
echo ""
echo -e "${BLUE}📄 File: $RESEARCH_PATH${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. AI will identify technical unknowns from spec"
echo "  2. AI will research options for each unknown"
echo "  3. AI will present options for your decision"
echo "  4. Research file will be populated with decisions"
echo ""

# Output path for AI
echo "$RESEARCH_PATH"
