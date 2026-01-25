# Epic 3: Initial RESTful API - First Functional Endpoint

**Status**: 🎯 Planning  
**Epic Owner**: Product Owner  
**Start Date**: January 24, 2026  
**Target Completion**: Sprint 2 (2 weeks)

**📋 Technical Specification**: [Epic 3 Technical Overview](../docs/EPIC_3_TECHNICAL_OVERVIEW.md)

---

## Epic Overview

Create the first working API endpoint that allows the frontend to communicate with a backend service. This proves the frontend and backend can work together and establishes the foundation for all future features.

### Business Value

**Why This Matters**:
- **Proves Product Works**: Frontend is currently a static dashboard. With a working API, we prove TeamFlow can actually do something functional
- **Unblocks Future Features**: Every feature (authentication, workspaces, projects, tasks, comments) depends on having working API endpoints
- **Foundation for Learning**: Developers learn the pattern for creating new endpoints that will be repeated dozens of times
- **MVP Requirement**: The app must have at least one working feature - a simple endpoint proves the system works end-to-end

**Target Users Impacted**:
- **Development Team**: Need working example to follow for future features
- **Early Adopters**: Can verify that TeamFlow is a real application with backend, not just frontend mockups
- **Future: All Users** (Sarah, Mike, Linda): This foundation enables all features they'll eventually use

### Success Criteria

This epic is successful when:
- ✅ API endpoint is accessible from the internet (public URL)
- ✅ Endpoint responds correctly to browser requests
- ✅ Frontend can call the endpoint and receive response
- ✅ Response is in expected format (JSON with message)
- ✅ Team understands the pattern for creating future endpoints

### Product Vision Alignment

**Simplicity**: Start with the simplest possible API - one endpoint that returns a message. Build complexity incrementally.

**User-Centric**: Every new endpoint solves a real user problem. We don't build for technical reasons alone.

---

## Epic Requirements & Goals

### What We Need (Product Requirements)

**API Endpoint**: 
- One public API endpoint accessible from the internet
- Endpoint path: `/api/home`
- Method: GET
- Response: JSON object with a welcome message

**Expected Response**:
```json
{
  "message": "hello world"
}
```

**Functionality**:
- Endpoint should respond consistently and reliably
- Response should be fast (under 2 seconds)
- Should work from any browser or API client
- Should be accessible 24/7

### Why We're Starting Simple

- **No Auth Yet**: Authentication will be a separate epic - keep this focused
- **No Database Yet**: This endpoint doesn't need to store or retrieve data from a database
- **No Complex Logic**: Just prove the connection works between frontend and backend
- **Foundation First**: Once this works, we'll add more endpoints following the same pattern

### Future Endpoints (Not in this Epic)

These will be built in future epics:
- Authentication endpoints (login, register, logout)
- Workspace management endpoints
- Project management endpoints
- Task management endpoints
- Comments endpoints

---

## Context & Dependencies

### Prerequisites
- ✅ Epic 1: Development Environment Setup (completed)
- ✅ Epic 2: UI Foundation - Dashboard Layout (completed)
- ✅ Backend project structure initialized
- ✅ CDKTF project initialized with AWS provider

---

## Definition of Done

Epic 3 is complete when:

**Infrastructure**:
- [ ] API Gateway created and deployed via CDKTF
- [ ] CORS configured for browser requests
- [ ] API has public HTTPS URL
- [ ] CloudWatch logging enabled

**Backend**:
- [ ] Lambda function deployed and responding
- [ ] Endpoint returns valid JSON response
- [ ] Error handling implemented (500 errors logged)
- [ ] Response includes meaningful data (not just "OK")

**Integration**:
- [ ] Frontend successfully calls API endpoint
- [ ] Response displayed in browser console or UI
- What We Can See**:
- [ ] Public URL exists that we can visit in a browser or call with a tool like curl/Postman
- [ ] URL responds with JSON: `{"message": "hello world"}`
- [ ] Response is consistent every time we call it

**What We Can Test**:
- [ ] Frontend application can successfully call the endpoint and receive data
- [ ] No errors when calling from the browser
- [ ] Response time is acceptable (under 2-3 seconds)

**What the Team Knows**:
- [ ] Where the API endpoint URL is documented
- [How We Measure Success

After this epic, we should be able to:

1. **Visit the API**: Open the URL in a browser and see `{"message": "hello world"}`
2. **Call from Frontend**: Click a button in the app that fetches from the API and displays the response
3. **Document It**: Show the team where the endpoint lives and how to add more
4. **Replicate It**: Create a second endpoint using the same pattern (to prove we learned it)cepts

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| CDKTF deployment fails | Low | High | Test `cdktf synth` before full deploy; consult CDKTF docs |
| Lambda cold starts too slow | Low | Medium | Accept for MVP; optimize memory and dependencies later |
| CORS issues block frontend | Medium | High | Configure CORS broadly for dev (`*`); restrict in production |
| CloudWatch logs fill up | Low | Low | Set log retention to 7 days for dev environment |

---

## Notes for Project Manager

When breaking this epic into stories:

1. **Keep stories independent**: Each story should be completable without waiting for others
2. **Verify working at each step**: Don't wait until end to test - verify API works after topic 2
3.AWS account is configured and ready
- Team can deploy code to AWS
- The endpoint can be made publicly accessible

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Endpoint takes longer to create than expected | Medium | Medium | Break work into smaller stories; test early and often |
| CORS issues prevent frontend from calling API | Medium | High | Test API calls from browser immediately after endpoint works |
| Endpoint is not publicly accessible | Low | High | Verify URL works from different networks (mobile, external) |

---

## Notes for Project Manager & Software Architect

**Product Owner gives you the WHAT, you figure out the HOW:**

**WHAT we need** (from this epic):
- A public API endpoint at `/api/home`
- GET method that returns `{"message": "hello world"}`
- Accessible from the internet

**HOW you build it** (you decide):
- What infrastructure tool to use (CDKTF, Terraform, AWS CloudFormation, etc.)
- What Lambda configuration to use (memory, timeout, etc.)
- How to set up API Gateway (REST vs HTTP API, stages, etc.)
- How to configure CORS and security
- How to make it public and accessible
- How to test and verify it works

**Your job**: Take these requirements and design the best technical solution. Document your decisions so the team can replicate the pattern.

**📋 See Technical Specification**: [Epic 3 Technical Overview](../docs/EPIC_3_TECHNICAL_OVERVIEW.md) - Contains detailed AWS resources, CDKTF configuration, code structure, deployment steps, and testing strategy.

---

## Summary

This epic establishes the **first connection between frontend and backend**, proving TeamFlow can function as a real application. While simple (just returning "hello world"), it creates the foundation and pattern for all future API endpoints (authentication, workspaces, projects, tasks, comments).

**Key Deliverable**: One working public endpoint (`GET /api/home`) that returns `{"message": "hello world"}` and can be called from the Angular frontend.

**Next Epic**: After this works, Epic 4 will add authentication endpoints and user management.