# Epic 3: Technical Overview - First RESTful API Endpoint

**Document Type**: Architecture Specification  
**Created**: January 24, 2026  
**Epic Reference**: [EPIC_3_RESTFUL_API.md](../epics/EPIC_3_RESTFUL_API.md) ← Product requirements  
**Architecture Reference**: [TECHNICAL_ARCHITECTURE_SERVERLESS.md](../../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)

---

## Purpose

This document translates **Epic 3's product requirements** into **technical specifications**, defining what AWS resources and code structures must be implemented to deliver a working `/api/home` endpoint.

**Document Flow**:
1. **Product Owner** creates Epic (WHAT we need) → [EPIC_3_RESTFUL_API.md](../epics/EPIC_3_RESTFUL_API.md)
2. **Software Architect** creates Technical Overview (HOW we build it) → This document
3. **Project Manager** breaks into stories → Coming next
4. **Infrastructure Expert** implements → CDKTF code + Lambda function

---

## Product Requirements Summary

**What the Product Owner wants:**
- Public API endpoint: `GET /api/home`
- Response: `{"message": "hello world"}`
- Accessible from internet
- No authentication, no database
- Response time: under 2 seconds

---

## Technical Architecture Overview

### Architecture Pattern

Following TeamFlow's **hexagonal architecture** (ports & adapters) with **serverless** compute:

```
Frontend (Angular)
    |
    | HTTPS Request
    ↓
CloudFront (CDN) → API Gateway (REST API)
                       |
                       | Lambda Proxy Integration
                       ↓
                   Lambda Function: get-home
                       |
                       | Handler executes
                       ↓
                   Return JSON Response
```

### Why This Architecture?

- **API Gateway**: Handles HTTP routing, CORS, rate limiting, SSL/TLS termination
- **Lambda**: Serverless compute - pay per request, auto-scales, no server management
- **Hexagonal Pattern**: Business logic isolated from AWS SDK, easy to test and change
- **CDKTF**: Infrastructure as Code - version controlled, repeatable deployments

---

## AWS Resources Required

### 1. Lambda Function: `get-home`

**Purpose**: Execute business logic and return response

**Configuration**:
```typescript
FunctionName: teamflow-get-home
Runtime: nodejs20.x
Architecture: arm64 (Graviton2 - 20% cheaper, faster)
Memory: 512 MB (balance cost vs cold start)
Timeout: 30 seconds (API Gateway max)
Handler: index.handler
Environment Variables:
  - NODE_ENV: production
  - LOG_LEVEL: info
```

**IAM Role**: 
- AWS managed policy: `AWSLambdaBasicExecutionRole`
- Permissions: CloudWatch Logs (write)

**Code Structure** (Hexagonal):
```
functions/home/
  └── index.ts          # Thin handler - calls use case
```

**Handler Pattern** (Thin Wrapper):
```typescript
// functions/home/index.ts
import { APIGatewayProxyHandler } from 'aws-lambda';

export const handler: APIGatewayProxyHandler = async (event) => {
  try {
    // No use case needed for hello world - but structure for future
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*', // CORS
      },
      body: JSON.stringify({
        message: 'hello world',
      }),
    };
  } catch (error) {
    console.error('Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal Server Error' }),
    };
  }
};
```

---

### 2. API Gateway REST API

**Purpose**: Expose Lambda function as HTTP endpoint

**Configuration**:
```typescript
API Name: teamflow-api
Type: REST API (not HTTP API)
Endpoint Type: Regional
Stage: dev
```

**Resource Structure**:
```
/
└── /api
    └── /home    [GET]
        └── Lambda Integration: get-home
```

**Method: GET /api/home**:
- Authorization: NONE (no auth for this epic)
- Request Validation: None (simple endpoint)
- Integration Type: AWS_PROXY (Lambda Proxy Integration)
- Integration HTTP Method: POST (always POST for Lambda)
- Lambda Function: arn:aws:lambda:us-east-1:xxx:function:teamflow-get-home

**CORS Configuration**:
```typescript
Access-Control-Allow-Origin: * (dev) / specific domain (prod)
Access-Control-Allow-Methods: GET, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

**Stage Configuration**:
```typescript
Stage Name: dev
Throttling: 100 requests/second burst
Logging: CloudWatch Logs enabled
Log Level: INFO
Metrics: Enabled
```

**Output**:
- API Endpoint URL: `https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/api/home`

---

### 3. CloudWatch Logs

**Purpose**: Capture Lambda execution logs and API Gateway access logs

**Lambda Log Group**:
```
Log Group: /aws/lambda/teamflow-get-home
Retention: 7 days (dev), 30 days (prod)
```

**API Gateway Log Group**:
```
Log Group: API-Gateway-Execution-Logs_{api-id}/dev
Retention: 7 days (dev)
```

---

### 4. IAM Roles & Policies

**Lambda Execution Role**: `teamflow-lambda-execution-role`
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

**Attached Policies**:
- `AWSLambdaBasicExecutionRole` (managed by AWS)
  - Allows: `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents`

**API Gateway Lambda Permission**:
```
Allow API Gateway to invoke: teamflow-get-home
Principal: apigateway.amazonaws.com
SourceArn: arn:aws:execute-api:us-east-1:xxx:{api-id}/*/*/api/home
```

---

## CDKTF Stack Structure

### Recommended Stack Organization

```
infrastructure/
├── stacks/
│   └── api-stack.ts       # API Gateway + Lambda + IAM
├── main.ts                # Entry point
└── cdktf.json
```

### Stack: `ApiStack`

**Resources to Define**:
1. IAM Role for Lambda (`IamRole`)
2. IAM Policy Attachment (`IamRolePolicyAttachment`)
3. Lambda Function (`LambdaFunction`)
4. Lambda Permission for API Gateway (`LambdaPermission`)
5. API Gateway REST API (`ApiGatewayRestApi`)
6. API Gateway Resource `/api` (`ApiGatewayResource`)
7. API Gateway Resource `/api/home` (`ApiGatewayResource`)
8. API Gateway Method `GET` (`ApiGatewayMethod`)
9. API Gateway Integration (`ApiGatewayIntegration`)
10. API Gateway Deployment (`ApiGatewayDeployment`)
11. CloudWatch Log Groups (optional, auto-created)

**CDKTF Outputs**:
```typescript
new TerraformOutput(this, 'api_endpoint_url', {
  value: `https://${api.id}.execute-api.us-east-1.amazonaws.com/${stage.stageName}/api/home`,
  description: 'GET /api/home endpoint URL',
});

new TerraformOutput(this, 'lambda_function_name', {
  value: lambdaFunction.functionName,
  description: 'Lambda function name for logs',
});
```

---

## Code Structure (Following Hexagonal Architecture)

### Current Structure (Simple)

Since this is a simple "hello world" endpoint, we don't need full hexagonal architecture yet. However, we establish the **foundation** for future endpoints.

```
src/
├── backend/
│   ├── functions/
│   │   └── home/
│   │       └── index.ts        # Lambda handler
│   └── package.json
│
└── infrastructure/
    ├── stacks/
    │   └── api-stack.ts        # CDKTF stack
    ├── main.ts
    └── package.json
```

### Future Structure (With Use Cases)

For reference, when we add authentication/database endpoints:

```
src/backend/
├── functions/
│   └── home/
│       └── index.ts            # Thin handler
├── layers/
│   └── business-logic/
│       └── nodejs/node_modules/@teamflow/core/
│           ├── use-cases/      # Business logic
│           ├── adapters/       # AWS SDK calls
│           └── ports/          # Interfaces
```

**For now**: Keep it simple. One Lambda function, one handler, no layers yet.

---

## Deployment Steps (High-Level)

### Step 1: Build Lambda Function
```bash
cd src/backend/functions/home
npm install
npm run build
# Output: dist/index.js
```

### Step 2: Package Lambda
```bash
cd dist
zip -r ../../get-home.zip .
# Output: src/backend/functions/get-home.zip
```

### Step 3: Deploy Infrastructure with CDKTF
```bash
cd src/infrastructure
cdktf plan      # Preview changes
cdktf deploy    # Deploy to AWS
```

### Step 4: Test Endpoint
```bash
# Get URL from CDKTF output
curl https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/api/home

# Expected response:
# {"message":"hello world"}
```

### Step 5: Verify CloudWatch Logs
```bash
aws logs tail /aws/lambda/teamflow-get-home --follow
```

---

## Testing Strategy

### 1. Unit Testing (Lambda Handler)

Test handler logic without AWS:
```typescript
// functions/home/index.test.ts
import { handler } from './index';

describe('GET /api/home handler', () => {
  it('returns hello world message', async () => {
    const event = { /* mock API Gateway event */ };
    const result = await handler(event, {}, () => {});
    
    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body)).toEqual({ message: 'hello world' });
  });
});
```

### 2. Integration Testing (Local)

Use AWS SAM or LocalStack to test Lambda locally:
```bash
sam local invoke GetHomeFunction
```

### 3. End-to-End Testing (Deployed)

After deployment:
```bash
# Test with curl
curl https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/api/home

# Test with Postman
# Test from frontend (browser)
```

### 4. CORS Testing

Test from browser console:
```javascript
fetch('https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/api/home')
  .then(r => r.json())
  .then(data => console.log(data));
```

Should NOT show CORS errors.

---

## Cost Estimation

### Free Tier Coverage

**Lambda**:
- Free Tier: 1M requests/month + 400K GB-seconds
- Expected: ~100 requests/day = 3K/month
- **Cost: $0** (well within free tier)

**API Gateway**:
- Free Tier: 1M requests/month (first 12 months)
- Expected: ~100 requests/day = 3K/month
- **Cost: $0** (within free tier)

**CloudWatch Logs**:
- Free Tier: 5GB ingestion, 5GB storage
- Expected: <100MB/month
- **Cost: $0** (within free tier)

**Total Monthly Cost: $0-1** (essentially free for MVP testing)

---

## Monitoring & Observability

### CloudWatch Metrics (Auto-Generated)

**Lambda Metrics**:
- Invocations
- Duration
- Errors
- Throttles
- Cold Starts

**API Gateway Metrics**:
- Count (requests)
- Latency
- 4XXError
- 5XXError

### CloudWatch Alarms (Future)

After MVP launch, add alarms:
- Lambda Error Rate > 5%
- API Gateway 5XX Errors > 10
- Lambda Duration > 5 seconds (cold start issues)

---

## Security Considerations

### Current (MVP)

**Authentication**: None (public endpoint)
**Authorization**: None
**CORS**: Allow all origins (`*`) for dev
**Secrets**: None needed

### Future (Production)

**Authentication**: Cognito User Pool Authorizer
**Authorization**: Role-based (Owner, Member)
**CORS**: Restrict to specific domain
**Rate Limiting**: API Gateway throttling
**Secrets**: AWS Secrets Manager for sensitive data

---

## Success Validation Checklist

After deployment, verify:

- [ ] Lambda function exists in AWS Console
- [ ] Lambda function has correct IAM role
- [ ] API Gateway exists with `/api/home` resource
- [ ] API Gateway method is `GET`
- [ ] API Gateway integration points to Lambda
- [ ] API Gateway stage is deployed (`dev`)
- [ ] API endpoint URL is publicly accessible
- [ ] Calling URL returns `{"message":"hello world"}`
- [ ] No CORS errors in browser console
- [ ] CloudWatch logs show invocations
- [ ] No 4XX or 5XX errors
- [ ] Response time < 2 seconds

---

## Troubleshooting Guide

### Issue: Lambda not triggered

**Check**:
- Lambda permission allows API Gateway invocation
- API Gateway integration is `AWS_PROXY`
- Integration HTTP method is `POST` (not GET)

### Issue: CORS errors in browser

**Check**:
- Lambda returns `Access-Control-Allow-Origin: *` header
- API Gateway has OPTIONS method configured
- Response headers are correctly formatted

### Issue: 500 Internal Server Error

**Check**:
- Lambda CloudWatch logs for errors
- Lambda function has correct handler name
- Lambda function code is valid

### Issue: 403 Forbidden

**Check**:
- API Gateway method authorization is NONE
- API Gateway stage is deployed
- URL is correct (includes stage name)

---

## Next Steps (After Epic 3)

Once this endpoint works:

1. **Epic 4**: Add authentication endpoints
   - POST /api/auth/register
   - POST /api/auth/login
   - GET /api/auth/me

2. **Add DynamoDB**: For user storage

3. **Add Lambda Layers**: For shared business logic

4. **Add Cognito**: For authentication

5. **Refactor**: Extract use cases when logic becomes complex

---

## References

- **Epic Document**: `agile-management/epics/EPIC_3_RESTFUL_API.md`
- **Architecture**: `research/TECHNICAL_ARCHITECTURE_SERVERLESS.md`
- **Setup Guide**: `SETUP_GUIDE.md`
- **AWS Lambda Docs**: https://docs.aws.amazon.com/lambda/
- **API Gateway Docs**: https://docs.aws.amazon.com/apigateway/
- **CDKTF Docs**: https://developer.hashicorp.com/terraform/cdktf

---

## Summary

**Big Picture**:
- 1 Lambda function (`get-home`)
- 1 API Gateway REST API with `/api/home` endpoint
- 2 CloudWatch Log Groups (Lambda + API Gateway)
- 1 IAM Role for Lambda execution
- Total resources: ~6 AWS resources
- Total cost: $0 (free tier)
- Deployment time: ~10 minutes
- Foundation for all future endpoints

**Outcome**: A working, public API endpoint that proves frontend and backend can communicate.

