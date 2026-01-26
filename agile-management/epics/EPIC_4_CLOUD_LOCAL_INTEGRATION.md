# Epic 4: Local Frontend + Cloud Backend Integration & Local Development Environment

**Status**: 🎯 Planning  
**Epic Owner**: Product Owner  
**Start Date**: January 25, 2026  
**Target Completion**: Sprint 3 (2 weeks)

---

## Epic Overview

Enable developers to work efficiently with a local Angular frontend connected to the cloud backend, AND establish a full local development environment where both frontend and backend can run locally for testing and debugging. This removes friction from development workflow and enables faster iteration.

### Business Value

**Why This Matters**:
- **Developer Productivity**: Developers spend less time waiting for cloud deployments; local development is 10x faster
- **Cost Savings**: Reduces unnecessary cloud deployments and iteration cycles, lowering AWS costs
- **Debugging Capability**: Developers can debug and test locally before pushing to cloud, reducing bugs in production
- **Offline Development**: Work continues during AWS outages or network issues; team not blocked
- **Learning Environment**: New developers can set up full environment locally; lowers onboarding time
- **Parallel Development**: Multiple developers can work simultaneously without affecting each other's cloud environment
- **Testing Freedom**: Developers can test, break things, and recover locally without fear; accelerates feature development

**Target Users Impacted**:
- **Development Team**: Can iterate 10x faster with local setup; debugging and testing is instant
- **Product Owner**: Faster feature delivery means we can validate with users sooner
- **Future Early Adopters**: Working with a team that can move fast and respond to feedback

### Success Criteria

This epic is successful when:
- ✅ Developer can start local Angular app with `npm start` (or similar)
- ✅ Local Angular can call cloud API without manual configuration
- ✅ API response appears in local app instantly
- ✅ Developer can start local backend with single command
- ✅ Local backend responds to requests correctly
- ✅ Developer can switch between local and cloud backends with environment variable
- ✅ Full setup takes <30 minutes for new developer (with documentation)
- ✅ Both configurations work reliably every time

### Product Vision Alignment

**Simplicity**: Setup should be straightforward with clear documentation. No magic or mysterious scripts.

**Efficiency**: Developers should feel their work is fast and responsive. Slow feedback loops hurt productivity and morale.

---

## Epic Goals

### Goal 1: Local Angular ↔ Cloud Backend Integration
Enable Angular running locally to communicate with the production/staging API deployed on AWS.

**What We Need**:
- Angular app configured to hit cloud API endpoint
- Seamless setup (one environment variable or config file)
- No CORS issues or connection problems
- Works from `localhost:4200` without errors

**User Value**: Developers can see their UI changes immediately while using real backend data

### Goal 2: Full Local Development Environment
Enable developers to run entire stack locally (backend + frontend) for isolated testing and debugging.

**What We Need**:
- Local backend running on `localhost:3000` (or similar)
- Local database (or mock) with sample data
- Local Angular connecting to local backend
- Single command to start everything
- Documentation for setup and troubleshooting

**User Value**: Developers can test complete features locally, debug issues quickly, and break things without affecting others

### Goal 3: Environment Configuration Management
Simple way to switch between cloud and local backend without code changes.

**What We Need**:
- `.env` file or configuration file specifying API endpoint
- Angular app respects environment configuration
- Backend honors local vs cloud database settings
- Clear documentation of what each setting does

**User Value**: Developers can work in local environment, then deploy to cloud with confidence

---

## Context & Dependencies

### Prerequisites
- ✅ Epic 1: Development Environment Setup (completed)
- ✅ Epic 2: UI Foundation - Dashboard Layout (completed)
- ✅ Epic 3: Initial RESTful API - First Functional Endpoint (completed)
- ✅ Backend project structure and code exists
- ✅ CDKTF infrastructure code exists and deploys successfully
- ✅ Angular frontend exists and runs locally

### What This Epic Depends On
- Cloud API must be deployed and accessible (from Epic 3)
- Backend code must be available locally in repository

---

## Solution Architecture

### Part 1: Local Angular + Cloud Backend

**How It Works**:
1. Developer runs `ng serve` locally (Angular on localhost:4200)
2. Angular is configured to call cloud API URL (e.g., `https://api.teamflow.dev/api/home`)
3. API Gateway handles CORS, allows localhost requests
4. Developer sees data from cloud in local Angular app
5. Changes to Angular code are instant (hot reload)
6. No local backend needed for this setup

**Configuration**:
```
Frontend .env file:
  API_URL=https://your-cloud-api-url.execute-api.us-east-1.amazonaws.com/dev
  
Angular environment:
  export const environment = {
    production: false,
    apiUrl: process.env['API_URL']
  }
```

**Benefit**: Fastest setup for frontend-only work. No backend infrastructure needed locally.

### Part 2: Full Local Development Environment

**How It Works**:
1. Developer installs local backend (Node.js + Express/Fastify)
2. Developer starts local database (DynamoDB local or mock)
3. Developer starts local backend with `npm run start:local`
4. Developer configures Angular to use local API
5. Developer starts Angular with `ng serve --configuration=local`
6. Full stack runs locally; developer can debug end-to-end
7. Changes to backend are picked up via hot reload or restart

**Configuration**:
```
Backend environment:
  NODE_ENV=local
  DATABASE_TYPE=dynamodb-local  # or mock
  PORT=3000
  
Frontend .env:
  API_URL=http://localhost:3000
  ENVIRONMENT=local
```

**Benefit**: Complete control and visibility. Test features fully before cloud deployment.

### Part 3: Environment Switching

**Process**:
1. For cloud work: Set `API_URL=https://cloud-api-url`
2. For local work: Set `API_URL=http://localhost:3000`
3. Single variable controls which backend is used
4. No code changes needed

---

## User Personas & Their Workflows

### Persona 1: Frontend Developer (Quick Iteration)
**Name**: Alex - Works on Angular UI and components

**Workflow**:
1. Sets `API_URL` to cloud API (from Epic 3)
2. Runs `ng serve`
3. Makes changes to Angular templates, styles, components
4. Changes appear instantly (hot reload)
5. Calls cloud API to see real data
6. No need to run backend locally

**Time from setup to first change**: 5 minutes

---

### Persona 2: Backend Developer (Isolated Testing)
**Name**: Jordan - Works on API endpoints and business logic

**Workflow**:
1. Runs `npm run start:local` (starts backend + local database)
2. Runs `ng serve --configuration=local` (starts Angular pointing to local backend)
3. Makes changes to API logic or database code
4. Backend restarts automatically
5. Tests changes in Angular UI
6. No risk of affecting cloud environment or other developers
7. When ready, deploys to cloud

**Time from setup to first change**: 15-20 minutes

---

### Persona 3: Full-Stack Developer (Complete Testing)
**Name**: Sam - Works on features spanning frontend and backend

**Workflow**:
1. Runs full local stack (both backend and frontend commands)
2. Makes changes to Angular and backend simultaneously
3. Tests complete feature locally before pushing to cloud
4. Debugs issues end-to-end in local environment
5. When confident, deploys both to cloud
6. Verifies in cloud environment

**Time from setup to first change**: 20-30 minutes

---

## Definition of Done

Epic 4 is complete when:

### Setup & Documentation
- [ ] `.env.example` file created with required variables
- [ ] Setup guide created for local Angular + cloud backend
- [ ] Setup guide created for full local development environment
- [ ] Troubleshooting guide addresses common issues
- [ ] New developer can follow guide and have working setup in <30 minutes

### Local Angular + Cloud Backend
- [ ] Angular app reads API_URL from environment configuration
- [ ] API_URL can be set via `.env` file or environment variable
- [ ] Angular running on `localhost:4200` successfully calls cloud API
- [ ] No CORS errors or connection issues
- [ ] API response displays correctly in Angular app
- [ ] Hot reload works (changes appear instantly)
- [ ] Works from different network (not just local machine)

### Local Backend Setup
- [ ] Local backend (Node.js + framework) runs with single command
- [ ] Listens on `localhost:3000` (or documented port)
- [ ] Returns valid JSON responses
- [ ] Hot reload works (changes picked up without restart) or restart is quick
- [ ] Local database (mock or DynamoDB local) initialized with sample data
- [ ] Sample data includes test projects, tasks, users for manual testing
- [ ] Backend can be torn down and restarted cleanly

### Local Frontend + Local Backend Integration
- [ ] Angular running on `localhost:4200` successfully calls local backend on `localhost:3000`
- [ ] No CORS issues
- [ ] API response displays in Angular app
- [ ] Full user workflow works end-to-end (e.g., create project → see it displayed)

### Environment Configuration
- [ ] Single `.env` file controls which backend is used (cloud vs local)
- [ ] No code changes needed to switch environments
- [ ] Configuration is documented and examples provided
- [ ] Environment variables are respected by both frontend and backend

### What We Can See
- [ ] Local Angular loads and runs without errors
- [ ] Calling cloud API from local Angular works and data displays
- [ ] Running local backend command starts server successfully
- [ ] Accessing local backend in browser/Postman returns data
- [ ] Local frontend connects to local backend without errors
- [ ] Setup documentation is clear and tested with new developer

### What We Can Test
- [ ] Frontend-only development workflow (change Angular code, see it instantly)
- [ ] Backend-only development workflow (change backend, see results in local Angular)
- [ ] Full-stack development workflow (change both simultaneously, test completely)
- [ ] Switching from local to cloud backend (change one variable, no code changes)
- [ ] New developer can follow setup guide and have working environment in <30 minutes

### What the Team Knows
- [ ] Where setup documentation lives and is easy to find
- [ ] How to configure for cloud backend
- [ ] How to configure for local backend
- [ ] How to troubleshoot common issues
- [ ] Where sample data is seeded and how to add more
- [ ] How to switch environments quickly

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| CORS blocks local frontend from cloud API | Medium | High | Configure API Gateway CORS to allow `localhost:4200` in dev environment |
| Local backend setup is complex | Medium | High | Create automated setup script; test with new developer; document all steps |
| Hot reload doesn't work locally | Low | Medium | Choose framework with good hot reload; document manual restart if needed |
| Database sync between local and cloud | Low | Medium | Use DynamoDB local that mirrors production schema; seed sample data |
| Developers forget to switch `API_URL` | Low | Low | Add startup script that displays current endpoint; warning messages in UI |
| Local setup takes >30 minutes | Medium | Medium | Test setup with new developer; automate what's possible; simplify instructions |

---

## What's NOT in This Epic

### Out of Scope (Future Epics):
- ❌ Hot reload for backend code (can do manual restart for now)
- ❌ Database migrations tools (simplified approach for MVP)
- ❌ Docker containerization (future optimization)
- ❌ GitHub Actions CI/CD (separate epic)
- ❌ Production environment setup (future)
- ❌ Staging environment (future - comes after production)

### Why Minimal:
Keep this epic focused: **make local development easy and fast**. Everything else can be added later.

---

## User Stories

This epic has been broken into the following user stories:

### Completed Stories
- **Story 4.1**: Deploy Home Endpoint Lambda to AWS ✅
- **Story 4.2**: Backend Build System with TypeScript ✅
- **Story 4.3**: Lambda Dependencies Layer ✅
- **Story 4.4**: Create Local Express Backend Server ✅

### Current Story
- **Story 4.5**: Local Development Environment Documentation 📋
  - Document local Express server usage in `src/backend/README.md`
  - Add LOCAL SERVER section with quick start, scripts, configuration
  - Document hot reload workflow and architecture decisions
  - Include troubleshooting for common issues

### Deferred/Simplified
- **Story 4.5 (Original)**: Mock Database - **Not required** (deferred to future story when database is implemented)
- **Story 4.6**: Configuration System - **Merged into 4.5** (basic .env is sufficient, documented in README)
- **Story 4.7**: Complete Documentation - **Merged into 4.5** (consolidated into backend README per project conventions)

See individual story files in `agile-management/stories/` for detailed task breakdowns.

---

## Success Metrics

After this epic, we measure success by:

1. **Time to First Change**
   - New developer setup time: Target <30 minutes
   - Frontend developer (cloud API): Target <5 minutes
   - Backend developer (local): Target <20 minutes

2. **Developer Experience**
   - Setup guide is clear and complete (0 ambiguity)
   - Troubleshooting covers 90% of issues
   - Hot reload works (or documented workaround)

3. **Reliability**
   - Setup works consistently (tested 3+ times with different developers)
   - No environment-specific bugs (what works locally works in cloud)

4. **Adoption**
   - 100% of development team using local environment for feature work
   - Reduced cloud deployment frequency (developers testing locally first)

---

## Notes for Project Manager

**Breaking this into Stories**:

1. **Story 1: Configure Angular for Environment** (Frontend focus)
   - Setup environment files in Angular
   - Read `API_URL` from `.env` or `environment.ts`
   - Verify cloud API calls work from local Angular

2. **Story 2: Implement Local Backend Server** (Backend focus)
   - Create simple local server (Express/Fastify/Hono)
   - Listen on `localhost:3000`
   - Return dummy responses to match API contract
   - Test with Postman/curl

3. **Story 3: Local Database Setup** (Backend focus)
   - Choose local database solution (DynamoDB local, mock, SQLite)
   - Seed with sample data (test projects, tasks, users)
   - Backend reads from local database

4. **Story 4: Local Frontend + Backend Integration** (Full-stack focus)
   - Configure Angular to call local backend
   - Test complete flow (local frontend → local backend → local database)
   - Verify no CORS issues

5. **Story 5: Environment Configuration** (DevOps focus)
   - Create `.env.example` file
   - Document all variables (what each does, valid values)
   - Test switching between cloud and local

6. **Story 6: Setup Documentation** (Documentation focus)
   - Write clear setup guide for different personas
   - Include step-by-step instructions
   - Include troubleshooting section
   - Test with new developer

7. **Story 7: Automation Scripts** (DevOps focus - optional)
   - Create setup script (optional, can be manual for MVP)
   - Create startup scripts (optional)
   - Create teardown scripts (optional)

---

## Notes for Software Architect

**Product Owner gives you the WHAT, you figure out the HOW:**

**WHAT we need** (from this epic):
- Local Angular that can call cloud API without setup friction
- Local backend that developers can run with one command
- Simple way to switch between cloud and local backend
- Complete documentation for setup

**HOW you build it** (you decide):
- Choose backend framework for local server (Express, Fastify, Hono, etc.)
- Choose local database approach (DynamoDB local, mock, in-memory, SQLite, etc.)
- How to handle environment configuration (`.env` files, environment variables, config files)
- How to implement hot reload (or acceptable alternative)
- How to seed and manage sample data
- How to structure documentation

**Your job**: Take these requirements and design the most practical, easy-to-use solution. Make setup as simple as possible.

---

## Summary

This epic removes barriers to efficient development by enabling:

1. **Quick frontend iteration** (local Angular + cloud backend)
2. **Isolated testing** (full local stack)
3. **Easy environment switching** (one configuration)

**Key Deliverables**:
- Local Angular configured to call cloud API
- Local backend server with database
- Environment configuration system
- Complete setup documentation

**Result**: Development team can iterate 10x faster with full visibility and control. New developers can be productive in <30 minutes.

**Next Epic**: After this, we'll add real authentication endpoints and user management (future).
