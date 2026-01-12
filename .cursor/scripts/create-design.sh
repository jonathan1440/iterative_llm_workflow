#!/bin/bash

# create-design.sh
# Creates a comprehensive system design document

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Generate design file path
SPEC_DIR=$(dirname "$SPEC_PATH")
SPEC_FILENAME=$(basename "$SPEC_PATH" .md)
DESIGN_PATH="${SPEC_DIR}/${SPEC_FILENAME}-design.md"

# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Extract feature name from spec
FEATURE_NAME=$(grep -m 1 "^# Feature:" "$SPEC_PATH" | sed 's/^# Feature: //' || echo "Unknown Feature")

echo -e "${BLUE}🏗️  Creating system design document...${NC}"
echo ""

# Check if design file already exists
if [ -f "$DESIGN_PATH" ]; then
    echo -e "${YELLOW}⚠️  Design file already exists: $DESIGN_PATH${NC}"
    echo -e "${YELLOW}   Overwrite? (y/n)${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Cancelled. Using existing file.${NC}"
        echo "$DESIGN_PATH"
        exit 0
    fi
fi

# Create comprehensive design document template
cat > "$DESIGN_PATH" << 'EOF'
# System Design: [FEATURE_NAME]

**Created**: [CURRENT_DATE]  
**Status**: Draft  
**Related Spec**: [SPEC_FILENAME]  
**Related Research**: [RESEARCH_FILENAME] (if applicable)

---

## 1. Architecture Overview

### High-Level Architecture

```mermaid
graph TD
    Client[Client Browser/App]
    API[API Layer]
    BL[Business Logic]
    DB[(Database)]
    
    Client -->|HTTPS| API
    API --> BL
    BL --> DB
```

**Note**: Update this diagram based on actual architecture needs (add cache, queue, external services, etc.)

### Component Responsibilities

#### API Layer
- Request validation
- Authentication verification
- Response formatting
- Error handling

#### Business Logic Layer
- Domain logic implementation
- Data validation
- Transaction management

#### Data Layer
- Database queries
- Data persistence
- Data integrity

### Technology Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| Backend | [Language/Framework] | [Why chosen - reference agents.md] |
| Database | [Database system] | [Why chosen - requirements alignment] |
| Authentication | [Method] | [Why chosen - security requirements] |
| API | [REST/GraphQL] | [Why chosen - client needs] |

---

## 2. Database Schema

### Entity Relationship Diagram

```mermaid
erDiagram
    EntityA ||--o{ EntityB : has
    EntityA {
        uuid id PK
        string field1
        timestamp created_at
    }
    EntityB {
        uuid id PK
        uuid entity_a_id FK
        string field2
    }
```

**Note**: Update with actual entities from spec

### Table Definitions

#### Table: [table_name]

**Purpose**: [What this table stores]

```sql
CREATE TABLE [table_name] (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    [field] [TYPE] [CONSTRAINTS],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_[table]_[field] ON [table]([field]);

-- Constraints
ALTER TABLE [table] ADD CONSTRAINT [constraint_name] CHECK ([condition]);
```

**Indexes**:
- Primary: `id`
- Secondary: `[frequently_queried_field]`
- Rationale: [Why these indexes - query patterns]

**Growth Estimates**:
- Initial: [N rows]
- 1 year: [N rows]
- Storage: [MB/GB estimate]

### Migration Strategy

**Approach**: Sequential numbered migrations (001_initial.sql, 002_add_feature.sql)

**Migration Structure**:
```sql
-- Up Migration
-- [What this migration does]

-- Down Migration  
-- [How to rollback]
```

**Testing**: All migrations tested on production data copy before deployment

---

## 3. API Contracts

### REST API Design

**Base URL**: `/api/v1`

**Authentication**: [Bearer token / Session cookie / etc.]

**Content Type**: `application/json`

**Versioning**: URL versioning (`/api/v1`, `/api/v2`)

### Endpoint: [METHOD] /path

**Purpose**: [What this endpoint does]

**Authentication**: [Required / Optional / Not required]

**Request**:
```json
{
  "field": "value",
  "nested": {
    "field": "value"
  }
}
```

**Request Validation**:
- `field`: [Type, required/optional, constraints]
- `nested.field`: [Type, required/optional, constraints]

**Response (200 OK)**:
```json
{
  "data": {
    "id": "uuid",
    "field": "value"
  },
  "meta": {
    "timestamp": "2026-01-11T10:30:00Z"
  }
}
```

**Error Responses**:

**400 Bad Request** - Invalid input:
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Invalid input data",
  "fields": {
    "field": "Error message"
  },
  "request_id": "uuid"
}
```

**401 Unauthorized** - Missing authentication:
```json
{
  "error": "UNAUTHORIZED",
  "message": "Authentication required",
  "request_id": "uuid"
}
```

**Rate Limiting**: [N requests per minute per IP/user]

---

## 4. Authentication & Authorization

### Authentication Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant API as API Server
    participant Auth as Auth Service
    participant DB as Database
    
    C->>API: Request with credentials
    API->>Auth: Validate
    Auth->>DB: Check credentials
    DB-->>Auth: User data
    Auth-->>API: Token
    API-->>C: Success + token
```

### Session/Token Management

**Token Format**: [JWT / Opaque token / etc.]

**Storage**: [Database / Redis / etc.]

**Lifetime**: [Duration]

**Refresh Strategy**: [How tokens are refreshed]

### Authorization Rules

**Public Endpoints**:
- [List endpoints that don't require auth]

**Authenticated Endpoints**:
- [List endpoints requiring auth]

**Role-Based Access** (if applicable):
- Role: [role_name] - Can access: [endpoints]

---

## 5. Error Handling Strategy

### Error Categories

| Status Code | Category | User Message | Logging |
|-------------|----------|--------------|---------|
| 400 | Bad Request | Explain what's wrong with input | WARN |
| 401 | Unauthorized | "Please log in" | INFO |
| 403 | Forbidden | "Access denied" | WARN |
| 404 | Not Found | "Resource not found" | INFO |
| 409 | Conflict | "Resource already exists" | WARN |
| 429 | Rate Limit | "Too many requests" | WARN |
| 500 | Server Error | "Something went wrong" | ERROR |
| 503 | Unavailable | "Service temporarily unavailable" | ERROR |

### Error Response Format

**Standard Format**:
```json
{
  "error": "ERROR_CODE",
  "message": "User-friendly message",
  "details": {},
  "request_id": "uuid",
  "timestamp": "2026-01-11T10:30:00Z"
}
```

### Logging Strategy

**Log Levels**:
- `ERROR`: Server errors, data corruption, security issues
- `WARN`: Rate limits, validation failures, retries
- `INFO`: Successful operations, state changes
- `DEBUG`: Detailed flow (dev/staging only)

**Log Context** (every log):
- `request_id`: UUID per request
- `user_id`: When authenticated
- `endpoint`: API route
- `method`: HTTP method
- `status_code`: Response status
- `duration_ms`: Request duration

**Never Log**:
- Passwords
- Tokens
- Credit card numbers
- Full request bodies with PII

---

## 6. Security Considerations

### Threat Model

| Threat | Mitigation |
|--------|------------|
| SQL Injection | Parameterized queries only |
| XSS | Input sanitization, CSP headers |
| CSRF | SameSite cookies, CSRF tokens |
| Brute Force | Rate limiting, account lockout |
| Data Breach | Encryption at rest, hashed passwords |

### Security Measures

**Password Security**:
- Hashing: [Algorithm, cost factor]
- Requirements: [Length, complexity]
- Storage: Never plain text

**Data Encryption**:
- In Transit: TLS 1.3+
- At Rest: [Encryption method for sensitive fields]

**API Security**:
- HTTPS only (no HTTP)
- CORS configuration
- Request validation
- Rate limiting

**Session Security**:
- Secure cookies (HttpOnly, Secure, SameSite)
- Token rotation
- Expiration enforced

### Compliance

**Requirements**: [GDPR / HIPAA / PCI-DSS / etc. if applicable]

**Data Retention**: [Policy]

**User Data Export**: [How users can export their data]

**Right to Deletion**: [How users can delete their data]

---

## 7. Performance Strategy

### Performance Targets

From spec:
- [Target from spec with specific metric]
- [Another target]

### Optimization Approaches

**Database**:
- Indexing strategy: [Which fields, why]
- Query optimization: [N+1 prevention, query analysis]
- Connection pooling: [Max connections]

**Caching**:
- Cache layer: [Redis / In-memory / CDN]
- Cache keys: [Format and namespacing]
- TTL strategy: [Different TTLs for different data]
- Cache invalidation: [How and when]

**API**:
- Response compression: [gzip / brotli]
- Pagination: [Strategy for large result sets]
- Partial responses: [Field selection if needed]

### Monitoring & Metrics

**Application Metrics**:
- Request rate (requests/second)
- Latency (p50, p95, p99)
- Error rate (%)
- Cache hit rate (%)

**Database Metrics**:
- Query time (p95, p99)
- Connection pool usage
- Slow query log

**Business Metrics**:
- Active users
- Feature usage
- Conversion rates

**Alerting Thresholds**:
- Error rate > 1% → Alert
- p95 latency > [target] → Alert
- Database connections > 80% → Alert

---

## 8. Deployment Architecture

### Environments

| Environment | Purpose | Database | External Services |
|-------------|---------|----------|-------------------|
| Development | Local dev | Local/Docker | Mocked |
| Staging | Pre-production | Managed DB | Test mode |
| Production | Live system | Managed DB | Production |

### Infrastructure Diagram

```mermaid
graph TB
    Internet((Internet))
    LB[Load Balancer]
    API1[API Server 1]
    API2[API Server 2]
    Cache[(Cache)]
    DB[(Database Primary)]
    DBR[(Database Replica)]
    Backup[(Backups)]
    
    Internet --> LB
    LB --> API1
    LB --> API2
    API1 --> Cache
    API2 --> Cache
    API1 --> DB
    API2 --> DB
    DB --> DBR
    DB --> Backup
```

### Deployment Strategy

**Approach**: [Blue-green / Rolling / Canary]

**Steps**:
1. Run database migrations
2. Deploy to staging
3. Run smoke tests
4. Deploy to production (rolling)
5. Monitor error rates
6. Rollback if errors > 1%

**Rollback Plan**:
- Database migrations are reversible
- Previous version kept for 24 hours
- Rollback script: `./deploy/rollback.sh`

### Scaling Strategy

**Vertical Scaling** (until):
- [Resource limit reached]

**Horizontal Scaling** (when):
- CPU > 70% sustained
- Memory > 80%
- Request queue depth > 100

**Auto-scaling Rules**:
- Min instances: [N]
- Max instances: [N]
- Scale up: CPU > 70% for 5 min
- Scale down: CPU < 30% for 10 min

---

## 9. Testing Strategy

### Test Pyramid

```
    ┌─────────────┐
    │     E2E     │  <- 10% (Critical paths)
    ├─────────────┤
    │ Integration │  <- 20% (API contracts)
    ├─────────────┤
    │    Unit     │  <- 70% (Business logic)
    └─────────────┘
```

### Test Categories

**Unit Tests**:
- All business logic functions
- Coverage target: 80%+
- Run on every commit

**Integration Tests**:
- API endpoints
- Database queries
- External service mocks
- Run before deployment

**End-to-End Tests**:
- Critical user flows only
- Run in staging before production

---

## 10. Open Questions & Decisions

### Questions for Review

- [ ] [Question about specific design choice]
- [ ] [Question about technology selection]
- [ ] [Question about scaling approach]

### Design Decisions Log

| Decision | Options | Chosen | Rationale | Date |
|----------|---------|--------|-----------|------|
| [Topic] | A, B, C | [Choice] | [Why] | [Date] |

---

## 11. Future Considerations

### Not in MVP, Consider Later

- [Feature or optimization to add later]
- [Another future enhancement]

### Technical Debt Acknowledged

- [Shortcut taken with plan to address]
- [Another known limitation]

---

**Last Updated**: [CURRENT_DATE]

**Review Status**: [ ] Pending [ ] Approved [ ] Changes Requested
EOF

# Replace placeholders
sed -i.bak "s/\[FEATURE_NAME\]/$FEATURE_NAME/g" "$DESIGN_PATH"
sed -i.bak "s/\[CURRENT_DATE\]/$CURRENT_DATE/g" "$DESIGN_PATH"
sed -i.bak "s/\[SPEC_FILENAME\]/$(basename "$SPEC_PATH")/g" "$DESIGN_PATH"
sed -i.bak "s/\[RESEARCH_FILENAME\]/$(basename "$SPEC_PATH" .md)-research.md/g" "$DESIGN_PATH"

# Remove backup file
rm "${DESIGN_PATH}.bak"

echo -e "${GREEN}✅ System design document created${NC}"
echo ""
echo -e "${BLUE}📄 File: $DESIGN_PATH${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. AI will populate design sections based on spec"
echo "  2. AI will ask architecture questions"
echo "  3. AI will validate against agents.md"
echo "  4. Review and approve design"
echo ""

# Output path for AI
echo "$DESIGN_PATH"
