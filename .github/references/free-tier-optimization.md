# Free Tier Optimization Guidelines

**Last Updated**: January 25, 2026  
**Purpose**: Default resource configurations to maximize AWS free tier usage  
**Applies To**: All AWS resource creation (Lambda, DynamoDB, API Gateway, etc.)

---

## Philosophy

**TeamFlow is optimized for cost-effectiveness during MVP and early growth stages.**

We default to **lightweight, free-tier-friendly configurations** unless performance requirements explicitly demand more resources. The principle is: **start small, scale when needed**.

---

## Core Principles

1. **Free Tier First**: Always check if configuration stays within AWS free tier limits
2. **Lightweight by Default**: Use minimum resources that meet performance requirements
3. **Monitor and Optimize**: Track usage and upgrade only when data shows bottlenecks
4. **Cost-Conscious Scaling**: Document why any resource needs more than default allocation

---

## AWS Lambda Configuration Defaults

### Standard Lambda Function (Simple endpoints, no heavy computation)

```typescript
FunctionName: teamflow-{function-name}
Runtime: nodejs20.x
Architecture: arm64              // Graviton2 - 20% cheaper + faster
Memory: 256 MB                   // ⭐ Default for most functions
Timeout: 30 seconds              // API Gateway max
```

**When to use 256 MB**:
- Simple CRUD operations
- API endpoints returning JSON
- Functions with minimal dependencies
- Functions that don't process large data sets
- Expected execution time: <1 second

**Free Tier Coverage**:
- 1M requests/month
- 400,000 GB-seconds/month
- At 256 MB: ~1.56M invocations at 1 second each

### Lambda Functions with Moderate Complexity

```typescript
Memory: 512 MB                   // Use when 256 MB is insufficient
```

**When to use 512 MB**:
- Database query aggregations
- Image/file processing (small files)
- External API calls with response processing
- Functions with multiple dependencies
- Expected execution time: 1-3 seconds

**Requires Justification**: Document in story/technical overview why 512 MB is needed

### Lambda Functions with Heavy Processing

```typescript
Memory: 1024 MB or higher        // Use only when clearly justified
```

**When to use 1024+ MB**:
- Large file processing (images, videos, PDFs)
- Complex data transformations
- Machine learning inference
- Batch processing jobs
- Expected execution time: >3 seconds

**Requires Architecture Review**: Must be approved by Software Architect

---

## API Gateway Configuration Defaults

### REST API (Default for TeamFlow)

```typescript
Type: REST API                   // Not HTTP API
Endpoint Type: Regional          // Not Edge-optimized (saves cost)
Throttling: 100 requests/sec     // Burst rate
Stage: dev                       // Start with single stage
```

**Free Tier Coverage**:
- 1M API calls/month (first 12 months)
- After free tier: $3.50 per million requests

**Why REST API over HTTP API**:
- Request validation (reduces Lambda invocations)
- Better caching options
- API keys for rate limiting
- Same free tier as HTTP API

---

## DynamoDB Configuration Defaults

### Billing Mode

```typescript
BillingMode: PAY_PER_REQUEST     // ⭐ Default (on-demand)
```

**Free Tier Coverage**:
- 25 GB storage
- 25 WCU (Write Capacity Units)
- 25 RCU (Read Capacity Units)

**Why On-Demand**:
- No cost when not in use
- Auto-scales with traffic
- Simpler than provisioned capacity
- Cheaper for MVP usage patterns

**When to Switch to Provisioned**:
- Predictable, steady traffic
- >1M requests/month
- Cost analysis shows savings

### Global Secondary Indexes (GSI)

```typescript
// Default: Maximum 2 GSIs per table
GSI1: Entity lookup by ID
GSI2: User lookup by email
```

**Principle**: Only create GSIs for documented access patterns
- Each GSI doubles your costs (read/write capacity)
- Avoid creating "nice to have" indexes
- Document access pattern before creating GSI

---

## CloudWatch Configuration Defaults

### Log Retention

```typescript
// Development
LogRetention: 7 days             // ⭐ Default for dev/testing

// Production
LogRetention: 30 days            // Only when needed
```

**Free Tier Coverage**:
- 5 GB log ingestion/month
- 5 GB log storage/month

**Cost After Free Tier**:
- $0.50/GB ingestion
- $0.03/GB storage/month

### Metrics

```typescript
CustomMetrics: Maximum 10        // Free tier limit
```

**Principle**: Use default AWS metrics first, add custom metrics only when necessary

---

## S3 Configuration Defaults

### Storage Class

```typescript
StorageClass: STANDARD           // Default
```

**Free Tier Coverage** (first 12 months):
- 5 GB storage
- 20,000 GET requests
- 2,000 PUT requests

**Lifecycle Policies**:
- Move infrequently accessed objects to STANDARD_IA after 30 days
- Archive to GLACIER after 90 days (if applicable)

---

## Cognito Configuration Defaults

### User Pool

```typescript
MFA: Optional                    // Not required for MVP
PasswordPolicy: Medium strength  // 8+ chars, mixed case, number
```

**Free Tier Coverage**:
- 50,000 MAU (Monthly Active Users)

**Cost After Free Tier**:
- $0.0055 per MAU

---

## Performance vs. Cost Trade-offs

### When to Optimize for Performance Over Cost

**Acceptable cases for higher resource allocation**:
1. **User-facing critical path**: Login, dashboard load, primary workflows
2. **Data consistency**: Financial calculations, payment processing
3. **Security operations**: Authentication, authorization, encryption
4. **Measured bottleneck**: Performance testing shows resource constraint

**Not acceptable**:
- "Future-proofing" without data
- "It might be slow" without testing
- "Industry standard" without context
- "Best practice" without requirements

---

## Configuration Review Checklist

Before creating any AWS resource, verify:

- [ ] Configuration uses minimum resources that meet requirements
- [ ] Resource stays within AWS free tier (or justification documented)
- [ ] Lambda memory set to 256 MB (unless justified)
- [ ] DynamoDB on-demand billing mode
- [ ] CloudWatch log retention: 7 days (dev)
- [ ] No unnecessary GSIs created
- [ ] Timeout values are reasonable (not max "just in case")

---

## Upgrade Path

When free tier limits are exceeded:

1. **Monitor First**: Use CloudWatch to identify actual bottlenecks
2. **Measure Performance**: Get baseline metrics (p50, p95, p99 latency)
3. **Optimize Code**: Improve efficiency before adding resources
4. **Targeted Upgrades**: Only increase resources for proven bottlenecks
5. **Document Decision**: Update technical docs with reasoning

### Lambda Memory Upgrade Example

```
Observation: Function timeout at 256 MB after 5 seconds
Measurement: Cold start 2s, execution 3.5s
Analysis: Processing 10K records in memory
Decision: Upgrade to 512 MB
Result: Execution reduced to 1.5s
Cost Impact: +$X per month (acceptable)
```

---

## Cost Monitoring

### Billing Alarms (Required)

Set up CloudWatch billing alarms:
- Alert at $5/month
- Alert at $10/month
- Alert at $20/month

### Weekly Review

Check AWS Cost Explorer every week:
- Which services cost the most?
- Any unexpected spikes?
- Are we still in free tier?

---

## Examples

### ✅ Good: Cost-Optimized Lambda

```typescript
new LambdaFunction(this, 'get-home', {
  functionName: 'teamflow-get-home',
  runtime: 'nodejs20.x',
  architecture: ['arm64'],
  memorySize: 256,              // ✅ Default
  timeout: 30,
  handler: 'index.handler',
});
```

### ❌ Bad: Over-Provisioned Lambda

```typescript
new LambdaFunction(this, 'get-home', {
  functionName: 'teamflow-get-home',
  runtime: 'nodejs20.x',
  architecture: ['x86_64'],     // ❌ More expensive than arm64
  memorySize: 1024,             // ❌ 4x more than needed for simple endpoint
  timeout: 900,                 // ❌ Max timeout "just in case"
  handler: 'index.handler',
});
```

### ✅ Good: Minimal GSI Usage

```typescript
new DynamodbTable(this, 'main', {
  name: 'teamflow-main',
  billingMode: 'PAY_PER_REQUEST',
  hashKey: 'PK',
  rangeKey: 'SK',
  globalSecondaryIndex: [
    { name: 'GSI1', ... },      // ✅ Entity by ID
    { name: 'GSI2', ... },      // ✅ User by email
  ],
});
```

### ❌ Bad: Excessive GSI Creation

```typescript
new DynamodbTable(this, 'main', {
  name: 'teamflow-main',
  billingMode: 'PAY_PER_REQUEST',
  hashKey: 'PK',
  rangeKey: 'SK',
  globalSecondaryIndex: [
    { name: 'GSI1', ... },
    { name: 'GSI2', ... },
    { name: 'GSI3', ... },      // ❌ No documented access pattern
    { name: 'GSI4', ... },      // ❌ "Might need later"
    { name: 'GSI5', ... },      // ❌ Over-engineering
  ],
});
```

---

## References

- **AWS Free Tier**: https://aws.amazon.com/free/
- **Lambda Pricing**: https://aws.amazon.com/lambda/pricing/
- **DynamoDB Pricing**: https://aws.amazon.com/dynamodb/pricing/
- **API Gateway Pricing**: https://aws.amazon.com/api-gateway/pricing/
- **Architecture Doc**: `research/TECHNICAL_ARCHITECTURE_SERVERLESS.md`

---

## Summary

**Default to lean**: 256 MB Lambda, on-demand DynamoDB, 7-day logs, minimal GSIs

**Upgrade with data**: Only increase resources when performance testing shows clear need

**Monitor continuously**: Weekly cost reviews, billing alarms, usage tracking

**Document decisions**: Every deviation from defaults requires justification

**TeamFlow succeeds by being cost-effective** - we deliver value without burning money on over-provisioned infrastructure.
