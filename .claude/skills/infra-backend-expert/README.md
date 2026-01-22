# Infrastructure & Backend Expert Skill

**Skill Name**: `infra-backend-expert`

**Purpose**: Implement TeamFlow's serverless infrastructure and backend with production-grade code

---

## What This Skill Does

This skill provides a **Senior Infrastructure & Backend Engineer** persona that:

1. **Implements serverless infrastructure** using CDKTF (Terraform CDK)
2. **Builds AWS Lambda functions** following hexagonal architecture
3. **Designs and implements DynamoDB** single-table access patterns
4. **Ensures multi-tenant security** at every layer
5. **Translates EPICS/STORIES/TASKS** into technical implementation

---

## When to Use This Skill

Invoke this skill when you need to:

### Infrastructure Tasks
- Create or modify CDKTF stacks (DynamoDB, Lambda, API Gateway, Cognito, S3)
- Deploy AWS resources
- Configure IAM roles and policies
- Set up Lambda layers
- Debug infrastructure issues

### Backend Development
- Implement Lambda functions (API handlers)
- Create domain entities and use cases (hexagonal architecture)
- Build DynamoDB repository adapters
- Define DynamoDB access patterns
- Implement multi-tenant data isolation

### Implementation Guidance
- Translate stories from EPICS into code
- Review access patterns for correctness
- Debug Lambda/DynamoDB issues
- Optimize performance (cold starts, query efficiency)
- Ensure security best practices

---

## How to Use This Skill

### Basic Invocation

```bash
claude /infra-backend-expert
```

Then ask your question or describe the task.

### Example Usage

**Creating Infrastructure**:
```
/infra-backend-expert

I need to implement Story 2.1 from EPIC_2_CORE_INFRASTRUCTURE.
Create the DynamoDB table stack with GSIs.
```

**Implementing Features**:
```
/infra-backend-expert

Implement the "Create Project" feature:
1. Domain entity
2. Repository (DynamoDB)
3. Use case
4. Lambda handler
5. CDKTF deployment

Follow hexagonal architecture and ensure organizationId filtering.
```

**Debugging**:
```
/infra-backend-expert

Lambda function is timing out when querying projects.
Function: teamflow-list-projects-dev
Error: Task timed out after 3.00 seconds

Help me debug and optimize.
```

**Reviewing Access Patterns**:
```
/infra-backend-expert

Review this DynamoDB access pattern for listing tasks assigned to a user:

GSI2: PK = USER#{userId}, SK begins_with TASK#

Is this correct? What's the query pattern?
```

---

## What This Skill Provides

### 1. Code Examples

The skill includes extensive production-grade code examples for:
- Lambda handler structure (hexagonal pattern)
- DynamoDB repository implementations
- CDKTF stack definitions
- Domain entities and use cases
- Multi-tenant security patterns
- Error handling patterns

### 2. Access Pattern Guidance

Complete DynamoDB single-table design patterns:
- Organization hierarchy (ORG#, PROJECT#, TASK#)
- Entity lookups by ID (GSI1)
- User relationships (GSI2)
- Query examples with code

### 3. Architecture Implementation

How to implement:
- Hexagonal architecture (domain, ports, use cases, adapters)
- Lambda layers for shared business logic
- API Gateway integration with Cognito
- Multi-tenant security validation (3 layers)

### 4. Testing Strategies

- Unit tests (domain & use cases with mocks)
- Integration tests (DynamoDB Local)
- Lambda handler tests
- Multi-tenant security tests

### 5. CDKTF Infrastructure

Complete stack implementations:
- DatabaseStack (DynamoDB + GSIs)
- LambdaStack (functions + layers + IAM)
- ApiStack (API Gateway + Cognito authorizer)
- Deployment patterns

---

## Skill Expertise Areas

1. **AWS Lambda** - Function structure, cold starts, layers, optimization
2. **DynamoDB** - Single-table design, access patterns, GSIs, queries
3. **CDKTF** - Terraform CDK with TypeScript, stack organization
4. **Hexagonal Architecture** - Domain, ports, adapters, use cases
5. **Multi-Tenant Security** - organizationId filtering at all layers
6. **API Gateway** - REST API, Cognito authorizer, proxy integration
7. **TypeScript** - Strict typing, error handling, best practices
8. **Testing** - Unit, integration, handler testing strategies

---

## Skill Behavior

### What the Skill WILL Do

✅ Implement architecture decisions in production-grade code
✅ Translate EPICS/STORIES into technical implementation
✅ Ensure multi-tenant security (organizationId everywhere)
✅ Follow hexagonal architecture patterns strictly
✅ Optimize for AWS free tier and performance
✅ Provide complete, working code examples
✅ Debug infrastructure and Lambda issues
✅ Review code for security and best practices

### What the Skill WON'T Do

❌ Make architectural decisions (that's software-architect's role)
❌ Define product features (that's product-owner's role)
❌ Break down stories into tasks (that's project-manager's role)
❌ Write frontend code (that's outside its scope)

---

## Key Patterns & Examples

The skill provides detailed examples for:

### Lambda Handler Pattern
```typescript
// Thin wrapper calling use case from layer
export const handler: APIGatewayProxyHandler = async (event, context) => {
  // 1. Extract context (userId, organizationId from JWT)
  // 2. Parse and validate request
  // 3. Execute use case
  // 4. Return formatted response
};
```

### DynamoDB Access Pattern
```typescript
// Organization projects
PK = ORG#{orgId}, SK = PROJECT#{projectId}

// Query all projects in org
QueryCommand({
  KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
  ExpressionAttributeValues: {
    ':pk': `ORG#${organizationId}`,
    ':sk': 'PROJECT#',
  },
})
```

### Hexagonal Architecture
```typescript
Domain Entity → Use Case → Repository Port → Repository Adapter → DynamoDB
         ↑                                                    ↓
         └─────────────── Lambda Handler ─────────────────────┘
```

### Multi-Tenant Security
```typescript
// Layer 1: API Gateway (Cognito authorizer)
// Layer 2: Lambda middleware (extract organizationId from JWT)
// Layer 3: Use case (validate access)
// Layer 4: Repository (filter by organizationId in queries)
```

---

## Integration with Other Skills

### Works With

**software-architect**:
- Architect defines WHAT and WHY
- This skill implements HOW

**project-manager**:
- PM defines stories and tasks
- This skill translates to code

**product-owner**:
- PO defines features
- This skill implements backend logic

### Complements

- Frontend skills (will implement backend APIs they consume)
- DevOps skills (will deploy infrastructure it creates)
- Testing skills (will verify implementations)

---

## File Locations Referenced

The skill knows about and references:

**Project Management**:
- `.claude/skills/project-manager/epics/` - EPIC files with stories
- `.claude/skills/project-manager/sprints/` - Sprint planning

**Architecture Documentation**:
- `research/TECHNICAL_ARCHITECTURE_SERVERLESS.md` - Complete architecture spec
- `research/PRODUCT_OVERVIEW.md` - Product features

**Code Locations**:
- `backend/functions/` - Lambda function handlers
- `backend/layers/business-logic/` - Shared business logic layer
- `infrastructure/stacks/` - CDKTF stack definitions

---

## Technical Level

**Expertise Level**: Senior/Expert

This skill operates at the **highest technical level**:
- Production-grade code (not prototypes)
- Security-first mindset
- Performance optimization
- Best practices enforcement
- Complete implementations (no TODOs or placeholders)

---

## Example Workflows

### Workflow 1: Implementing a Story

1. User: `/infra-backend-expert Implement Story 2.3: Create Lambda layer for business logic`
2. Skill reads story from EPIC file
3. Skill creates layer structure with proper nodejs/node_modules convention
4. Skill implements domain entities, ports, use cases, adapters
5. Skill creates CDKTF code for Lambda layer deployment
6. Skill provides testing instructions
7. Skill confirms acceptance criteria met

### Workflow 2: Debugging Production Issue

1. User: `/infra-backend-expert Lambda timeout on list-projects endpoint`
2. Skill asks for CloudWatch logs
3. Skill analyzes query pattern
4. Skill identifies inefficient Scan instead of Query
5. Skill provides corrected repository code
6. Skill explains optimization

### Workflow 3: Adding New Feature

1. User: `/infra-backend-expert Add task comments feature with full backend`
2. Skill defines DynamoDB access pattern
3. Skill creates Comment domain entity
4. Skill implements CommentRepository (DynamoDB adapter)
5. Skill creates use cases (CreateComment, ListComments)
6. Skill implements Lambda handlers
7. Skill adds CDKTF infrastructure
8. Skill provides API Gateway configuration
9. Skill includes test examples

---

## Quality Standards

When this skill generates code, expect:

**Code Quality**:
- TypeScript strict mode
- No `any` types
- Comprehensive error handling
- Proper logging
- JSDoc comments for complex logic

**Security**:
- organizationId in every query
- Input validation
- Output sanitization
- Least-privilege IAM
- No hardcoded secrets

**Performance**:
- Clients initialized outside handler
- arm64 Lambda architecture
- Optimized queries (Query over Scan)
- Minimal bundle sizes
- Connection reuse

**Testing**:
- Unit test examples
- Integration test patterns
- Multi-tenant security tests
- Edge case coverage

---

## Limitations

This skill focuses on **backend infrastructure only**:
- Does NOT implement frontend (Angular) code
- Does NOT make architecture decisions (defers to software-architect)
- Does NOT define features (defers to product-owner)
- Does NOT create project plans (defers to project-manager)

---

## Getting Started

1. **Read the skill file**: `.claude/skills/infra-backend-expert/SKILL.md`
2. **Review code examples**: See sections on Lambda, DynamoDB, CDKTF
3. **Check architecture**: Read `research/TECHNICAL_ARCHITECTURE_SERVERLESS.md`
4. **Invoke the skill**: `/infra-backend-expert`
5. **Ask technical questions**: Get implementation guidance

---

## Feedback & Improvements

If you find this skill needs updates:
1. Update the SKILL.md file with new patterns
2. Add more code examples
3. Document new anti-patterns discovered
4. Refine based on actual implementation experience

---

**Last Updated**: 2026-01-22
