# Story 3.2: Create API Gateway Infrastructure with CDKTF

**Story ID**: EPIC3-002
**Epic**: EPIC-3 (Initial RESTful API - First Functional Endpoint)
**Sprint**: SPRINT-2
**Status**: ✅ COMPLETED

---

## User Story

```
As an infrastructure and backend expert,
I need to create API Gateway infrastructure using CDKTF that exposes the Lambda function,
so that the /api/home endpoint is publicly accessible via HTTPS.
```

---

## Requirements

### CDKTF Stack Structure

```
src/infrastructure/
├── stacks/
│   └── api-stack.ts       # New API Gateway stack
├── main.ts                # Update to include ApiStack
├── cdktf.json
└── package.json
```

### AWS Resources to Create

1. **API Gateway REST API**
   - Name: `teamflow-api`
   - Type: REST API
   - Endpoint Type: Regional
   - Stage: `dev`

2. **API Gateway Resources**
   - Root: `/`
   - Resource: `/api`
   - Resource: `/api/home`

3. **API Gateway Method**
   - Resource: `/api/home`
   - HTTP Method: GET
   - Authorization: NONE

4. **API Gateway Integration**
   - Type: AWS_PROXY (Lambda Proxy Integration)
   - Integration HTTP Method: POST
   - Lambda Function: `teamflow-get-home`

5. **Lambda Permission**
   - Allow API Gateway to invoke Lambda function
   - Principal: `apigateway.amazonaws.com`

6. **API Gateway Deployment**
   - Stage Name: `dev`
   - Deploy automatically on changes

### CORS Configuration

```typescript
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

---

## Acceptance Criteria

- [ ] `ApiStack` class created in `src/infrastructure/stacks/api-stack.ts`
- [ ] Lambda dependencies layer created and packaged
- [ ] Lambda function packaged separately (no node_modules)
- [ ] Lambda function configured with layer attachment
- [ ] All 14 CDKTF resources defined (layer, Lambda, API Gateway, etc.)
- [ ] CORS configured for browser requests
- [ ] CloudWatch logging enabled for API Gateway
- [ ] Lambda permission created for API Gateway invocation
- [ ] API Gateway deployment configured with `dev` stage
- [ ] CDKTF synthesizes without errors (`cdktf synth`)
- [ ] Stack outputs defined: `api_endpoint_url`, `lambda_function_name`
- [ ] Code follows TypeScript standards
- [ ] Documentation includes deployment instructions

---

## Technical Details

### CDKTF Resources List

1. `DataArchiveFile` - Package dependencies layer
2. `LambdaLayerVersion` - Dependencies layer (AWS SDK)
3. `DataArchiveFile` - Package Lambda function
4. `IamRole` - Lambda execution role
5. `IamRolePolicyAttachment` - Attach AWSLambdaBasicExecutionRole
6. `LambdaFunction` - teamflow-get-home function (with layer attached)
7. `LambdaPermission` - Allow API Gateway invocation
8. `ApiGatewayRestApi` - teamflow-api
9. `ApiGatewayResource` - /api
10. `ApiGatewayResource` - /api/home
11. `ApiGatewayMethod` - GET method
12. `ApiGatewayIntegration` - Lambda proxy integration
13. `ApiGatewayDeployment` - Deploy to dev stage
14. `ApiGatewayStage` - dev stage configuration

### Stack Output Example

```typescript
new TerraformOutput(this, 'api_endpoint_url', {
  value: `https://${api.id}.execute-api.us-east-1.amazonaws.com/${stageName}/api/home`,
  description: 'GET /api/home endpoint URL',
});
```

### API Gateway Resource Structure

```
/
└── /api
    └── /home    [GET]
        └── Lambda Integration: teamflow-get-home
```

---

## Definition of Done

- CDKTF stack compiles without errors
- `cdktf synth` generates valid Terraform configuration
- All resources properly defined with correct dependencies
- Lambda function referenced correctly (ARN or name)
- API Gateway stage deployed to `dev`
- Outputs configured for endpoint URL and function name
- Code reviewed for best practices
- Ready for deployment in Story 3.3

---

## Notes

**Architecture Reference**:
- See `agile-management/docs/EPIC_3_TECHNICAL_OVERVIEW.md` section "CDKTF Stack Structure"
- Follow existing CDKTF patterns from infrastructure setup

**Dependencies**:
- Story 3.1 must be complete (Lambda function exists)
- CDKTF providers: `@cdktf/provider-aws`, `@cdktf/provider-archive`

**CDKTF Commands**:
```bash
cd src/infrastructure
cdktf synth          # Generate Terraform config
cdktf plan           # Preview changes (safe, read-only)
cdktf deploy         # Deploy to AWS (Story 3.3)
```

**Key Configuration Points**:
- Integration type must be `AWS_PROXY` (not AWS)
- Integration HTTP method must be `POST` (not GET) - this is correct for Lambda
- Lambda permission source ARN must match API Gateway ARN pattern
- Stage must be created and deployed for endpoint to work

**Cost Impact**: $0 (API Gateway free tier: 1M requests/month for 12 months)

**Estimated Time**: 3-4 hours

---

## Completion Notes

**Completed**: _To be filled upon completion_

**Actual Time**: _To be filled upon completion_

**Issues Encountered**: _To be filled upon completion_
