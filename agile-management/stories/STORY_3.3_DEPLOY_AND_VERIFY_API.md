# Story 3.3: Deploy and Verify API Endpoint

**Story ID**: EPIC3-003
**Epic**: EPIC-3 (Initial RESTful API - First Functional Endpoint)
**Sprint**: SPRINT-2
**Status**: ✅ Completed

---

## User Story

```
As an infrastructure and backend expert,
I need to deploy the API Gateway and Lambda function to AWS and verify it works,
so that the /api/home endpoint is publicly accessible and functional.
```

---

## Requirements

### Deployment Steps

1. **Deploy Infrastructure**
   - Run `cdktf deploy` to create all AWS resources
   - Confirm deployment when prompted
   - Capture API endpoint URL from outputs

2. **Verify Resources in AWS Console**
   - Lambda function exists: `teamflow-get-home`
   - API Gateway exists: `teamflow-api`
   - API Gateway stage deployed: `dev`

3. **Test Endpoint Publicly**
   - Test with curl/Postman
   - Test from browser
   - Test from frontend (if available)


### Testing Matrix

| Test Type | Method | Expected Result |
|-----------|--------|----------------|
| curl | `curl {endpoint}` | 200 + JSON response |
| Browser | Visit URL | JSON displayed |
| Postman | GET request | 200 + correct body |
| Frontend | `fetch()` call | 200 response |
| Error case | Invalid path | 404 or 403 |

---

## Acceptance Criteria

- [ ] `cdktf deploy` completes successfully
- [ ] No Terraform errors during deployment
- [ ] API endpoint URL captured from CDKTF outputs
- [ ] Lambda function visible in AWS Console
- [ ] API Gateway REST API visible in AWS Console
- [ ] API Gateway stage `dev` deployed
- [ ] Endpoint responds with 200 status code
- [ ] No 4XX or 5XX errors in normal operation
- [ ] Documentation updated with endpoint URL

---

## Technical Details

### Deployment Command

```bash
cd src/infrastructure
cdktf deploy
# When prompted, confirm with "yes"
# Capture output: api_endpoint_url
```

### Testing Commands

**1. Test with curl**:
```bash
curl https://q1b2x7xegh.execute-api.us-east-1.amazonaws.com/dev/api/home

# Expected output:
# {"message":"hello world"}
```

**2. Test CORS headers**:
```bash
curl -v https://q1b2x7xegh.execute-api.us-east-1.amazonaws.com/dev/api/home | grep "Access-Control"
```

**4. Test from browser console**:
```javascript
fetch('https://q1b2x7xegh.execute-api.us-east-1.amazonaws.com/dev/api/home')
  .then(r => r.json())
  .then(data => console.log(data));
```

### Success Validation Checklist (Simplified)

Use the checklist from technical overview:

- [ ] Lambda function exists in AWS Console
- [ ] Lambda function has correct IAM role
- [ ] API Gateway exists with `/api/home` resource
- [ ] API Gateway method is `GET`
- [ ] API Gateway integration points to Lambda
- [ ] API Gateway stage is deployed (`dev`)
- [ ] API endpoint URL is publicly accessible
- [ ] Request returns 200 (success)
- [ ] No 4XX or 5XX errors

---

## Definition of Done

- Infrastructure deployed successfully to AWS
- All resources exist and are correctly configured
- Endpoint tested and verified working from:
  - curl/terminal
  - Browser
  - Postman or similar tool
  - Frontend application (if available)
- CORS working correctly (no browser errors)
- CloudWatch logs capturing requests and responses
- No errors in Lambda execution
- API endpoint URL documented in project README or docs
- Team can replicate testing process
- Epic 3 successfully completed

---

## Troubleshooting Guide (Short)

If the endpoint does not return 200:
- Verify API Gateway stage is deployed (`dev`).
- Confirm integration is `AWS_PROXY` and points to the correct Lambda.
- Ensure method is `GET` and authorization is `NONE` for this endpoint.

---

## Notes

**Architecture Reference**:
- See `agile-management/docs/EPIC_3_TECHNICAL_OVERVIEW.md` section "Success Validation Checklist"
- Follow troubleshooting guide in technical overview

**Dependencies**:
- Story 3.1 complete (Lambda function created)
- Story 3.2 complete (CDKTF stack defined)
- AWS credentials configured
- CDKTF CLI installed

**Deployment Safety**:
- First deployment may take 2-3 minutes
- Lambda cold start on first request (1-2 seconds)
- Subsequent requests should be faster (<200ms)

**Documentation Tasks**:
- Add API endpoint URL to project README
- Document testing procedure
- Capture lessons learned for future endpoints

**Cost Monitoring**:
- Check AWS Cost Explorer after deployment
- Confirm all resources in free tier
- Set up billing alarm if not already done

**Estimated Time**: 2-3 hours (including testing and troubleshooting)

---

## Completion Notes

**Completed**: 2026-01-25

**Actual Time**: _To be filled upon completion_

**Deployed Endpoint URL**: https://q1b2x7xegh.execute-api.us-east-1.amazonaws.com/dev/api/home

**Issues Encountered**: None

**Lessons Learned**: A 200 response is sufficient for initial endpoint verification.
