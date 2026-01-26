# Epic 4 - Story Breakdown & Implementation Plan

**Epic**: EPIC-4 (Local Frontend + Cloud Backend Integration & Local Development Environment)  
**Sprint**: SPRINT-3  
**Status**: 📋 Planning  
**Total Stories**: 6  
**Estimated Duration**: 2 weeks

---

## Story Decomposition Overview

```
EPIC-4: Cloud + Local Integration
│
├─ STORY 4.1: Configure API URL Environment Variable (Frontend)
│   └─ Estimated: 3-4 hours | Difficulty: Easy
│
├─ STORY 4.2: Create API Service in Angular (Frontend)
│   └─ Estimated: 4-5 hours | Difficulty: Easy
│
├─ STORY 4.3: Document & Test Local Angular + Cloud Backend (Documentation)
│   └─ Estimated: 2-3 hours | Difficulty: Easy
│
├─ STORY 4.4: Create Local Express.js Backend Server (Backend)
│   └─ Estimated: 6-8 hours | Difficulty: Medium
│
├─ STORY 4.5: Implement Mock Database with Sample Data (Backend)
│   └─ Estimated: 4-6 hours | Difficulty: Medium
│
├─ STORY 4.6: Create Environment Configuration System (Backend + DevOps)
│   └─ Estimated: 3-4 hours | Difficulty: Easy-Medium
│
└─ STORY 4.7: Create Complete Setup Documentation & Troubleshooting Guide (Documentation)
    └─ Estimated: 5-7 hours | Difficulty: Medium

TOTAL ESTIMATED TIME: 27-37 hours ≈ 1 week for experienced dev
                                    ≈ 1.5-2 weeks for typical dev
```

---

## Story Sequencing & Dependencies

```
DAY 1-2:
  ✓ STORY 4.1 (API URL Config) 
    └─→ STORY 4.2 (API Service)
        └─→ STORY 4.3 (Test Local Angular + Cloud)

DAY 3-4:
  ✓ STORY 4.4 (Express Server)
    ├─→ STORY 4.5 (Mock Database)
    │   └─→ STORY 4.6 (Env Config)

DAY 5:
  ✓ STORY 4.7 (Documentation)
    └─→ Complete

PARALLEL (Optional):
  STORY 4.4-4.6 can start once STORY 4.1 is merged
  STORY 4.7 can start once STORY 4.4 is done
```

---

## Detailed Story Cards

### STORY 4.1: Configure Angular for Environment Variables

**Story ID**: EPIC4-1  
**Type**: Frontend Infrastructure  
**Difficulty**: Easy  
**Estimated Time**: 3-4 hours

**User Story**:
```
As a frontend developer,
I want Angular to read the API endpoint from an environment variable,
so that I can switch between cloud and local backend without code changes.
```

**Requirements**:

1. **Create `.env.example` file**
   - Shows required environment variables
   - Includes sample values
   - Commented explanations for each variable

2. **Update `.env.local` handling**
   - Angular loads `.env` file on startup
   - Variables available via `process.env`
   - Works in development mode

3. **Create environment configuration system**
   - `environment.ts` (development)
   - `environment.prod.ts` (production)
   - Both export API URL from `.env`

**Acceptance Criteria**:

- [ ] `.env.example` file created with `API_URL` and `ENVIRONMENT` variables
- [ ] `.env` file is in `.gitignore` (not committed)
- [ ] `environment.ts` reads `API_URL` from `process.env['API_URL']`
- [ ] Angular builds successfully with `ng build`
- [ ] When `ng serve` runs, `process.env` values are accessible
- [ ] `ng serve` shows current API URL in console on startup
- [ ] No hardcoded API URLs in component files

**Technical Tasks**:

1. Create `src/frontend/.env.example`:
   ```bash
   API_URL=https://your-cloud-api.execute-api.us-east-1.amazonaws.com/dev
   ENVIRONMENT=cloud
   ```

2. Create `src/frontend/.env`:
   - Copy from `.env.example`
   - Actual values for development

3. Update `angular.json` or use environment plugin:
   - Enable `.env` file reading
   - Pass variables to TypeScript

4. Update `src/environments/environment.ts`:
   ```typescript
   export const environment = {
     production: false,
     apiUrl: process.env['API_URL'] || 'http://localhost:3000',
     environment: process.env['ENVIRONMENT'] || 'local',
   };
   ```

5. Update `src/environments/environment.prod.ts`:
   ```typescript
   export const environment = {
     production: true,
     apiUrl: process.env['API_URL'] || 'https://api.teamflow.dev/dev',
     environment: 'cloud',
   };
   ```

**Verification**:

```bash
cd src/frontend

# Create .env file
cp .env.example .env

# Edit .env with your cloud API URL
nano .env

# Start Angular
ng serve

# In browser console, verify:
# - No errors loading environment
# - API URL is correct
```

**Definition of Done**:

- [ ] `.env.example` created and documented
- [ ] `.env` added to `.gitignore`
- [ ] Environment files properly configured
- [ ] `ng serve` works without errors
- [ ] API URL displayed in console on startup
- [ ] Ready for STORY 4.2 (API Service)

---

### STORY 4.2: Create API Service in Angular

**Story ID**: EPIC4-2  
**Type**: Frontend Infrastructure  
**Difficulty**: Easy  
**Estimated Time**: 4-5 hours  
**Depends On**: STORY 4.1

**User Story**:
```
As a frontend developer,
I want a centralized API service,
so that all API calls use the same endpoint configuration and error handling.
```

**Requirements**:

1. **Create API service with HttpClient**
   - Reads API URL from environment configuration
   - Provides generic GET, POST, PUT, DELETE methods
   - Handles errors consistently

2. **Implement HTTP interceptor**
   - Logs all API calls (for debugging)
   - Adds common headers if needed
   - Handles response errors

3. **Create types for API responses**
   - Generic response wrapper
   - Standard error response format
   - Specific response types per endpoint

**Acceptance Criteria**:

- [ ] `api.service.ts` created and injectable
- [ ] Service reads API URL from environment configuration
- [ ] Generic methods: `get<T>()`, `post<T>()`, `put<T>()`, `delete<T>()`
- [ ] HTTP client provided in app config
- [ ] CORS headers handled automatically
- [ ] API calls logged to console (development only)
- [ ] Service tested with cloud API (STORY 4.3 verification)

**Technical Tasks**:

1. Create `src/app/core/http/api.service.ts`:
   - Inject HttpClient
   - Inject environment config
   - Implement generic methods

2. Create `src/app/core/http/http.interceptor.ts` (optional for MVP):
   - Log requests/responses
   - Add headers if needed

3. Create `src/app/core/http/api.types.ts`:
   - Response wrapper interface
   - Error response interface
   - Home endpoint response type

4. Update `app.config.ts`:
   - Provide HttpClient
   - Configure interceptor (if created)

5. Example usage in component:
   ```typescript
   export class HomeComponent implements OnInit {
     constructor(private api: ApiService) {}
     
     ngOnInit() {
       this.api.get('/api/home').subscribe(
         response => console.log(response),
         error => console.error(error)
       );
     }
   }
   ```

**Verification**:

```bash
# In browser console:
# 1. Component makes API call
# 2. See request logged
# 3. See response logged
# 4. Data displays in component
```

**Definition of Done**:

- [ ] API service created and tested
- [ ] Generic methods work for all CRUD operations
- [ ] Service reads configuration from environment
- [ ] No hardcoded URLs in service
- [ ] Ready for STORY 4.3 (Integration testing)

---

### STORY 4.3: Document & Test Local Angular + Cloud Backend Setup

**Story ID**: EPIC4-3  
**Type**: Documentation + Testing  
**Difficulty**: Easy  
**Estimated Time**: 2-3 hours  
**Depends On**: STORY 4.1, 4.2

**User Story**:
```
As a new developer,
I want clear step-by-step instructions,
so that I can set up local Angular + cloud backend in <5 minutes.
```

**Requirements**:

1. **Create `SETUP_LOCAL_FRONTEND_CLOUD.md` document**
   - Step-by-step setup instructions
   - How to set API_URL environment variable
   - How to start local Angular
   - How to verify it works

2. **Include troubleshooting section**
   - CORS errors
   - API URL not loading
   - Network connectivity issues

3. **Test setup with new developer (if possible)**
   - Follow documentation exactly
   - Time how long it takes
   - Fix any ambiguities

**Acceptance Criteria**:

- [ ] Setup documentation created and readable
- [ ] Instructions work end-to-end (tested by author)
- [ ] Estimated setup time: <5 minutes
- [ ] Troubleshooting section covers 3+ common issues
- [ ] Screenshots or examples included (optional)
- [ ] Clear "what happens next" statement

**File Location**:
- Create: `docs/SETUP_LOCAL_FRONTEND_CLOUD.md`

**Documentation Template**:

```markdown
# Local Angular + Cloud Backend Setup

## Prerequisites
- Node.js 18+ installed
- `ng` CLI installed globally

## Step 1: Get Cloud API URL
[Instructions to get cloud API URL from AWS]

## Step 2: Create .env File
[Instructions to copy .env.example and update]

## Step 3: Start Angular
[Instructions to run `ng serve`]

## Step 4: Verify Connection
[Instructions to open browser and check]

## Troubleshooting
[Common issues and solutions]
```

**Verification**:

```bash
# Complete setup from scratch:
rm -rf src/frontend/node_modules
npm ci
cp .env.example .env
# Edit .env with actual API URL
ng serve
# Verify in browser
```

**Definition of Done**:

- [ ] Documentation complete and accurate
- [ ] Tested by following steps exactly
- [ ] Setup time < 5 minutes
- [ ] Ready for STORY 4.4 (Local backend)

---

### STORY 4.4: Create Local Express.js Backend Server

**Story ID**: EPIC4-4  
**Type**: Backend Infrastructure  
**Difficulty**: Medium  
**Estimated Time**: 6-8 hours

**User Story**:
```
As a backend developer,
I need a local Express.js server,
so that I can test API endpoints locally without deploying to AWS.
```

**Requirements**:

1. **Create Express.js project structure**
   - `src/backend/local-dev/` directory
   - Proper TypeScript configuration
   - Package.json with scripts

2. **Implement basic Express server**
   - Listen on `localhost:3000`
   - Health check endpoint: `GET /health`
   - Home endpoint: `GET /api/home`
   - CORS enabled for `localhost:4200`

3. **Add development tooling**
   - Hot reload with `ts-node-dev`
   - Console logging for requests
   - Error handling middleware

**Acceptance Criteria**:

- [ ] Express server starts with `npm run start:local`
- [ ] Server listens on `localhost:3000`
- [ ] Health check endpoint returns `{"status": "ok"}`
- [ ] `/api/home` returns `{"message": "hello world"}`
- [ ] CORS configured for Angular on `localhost:4200`
- [ ] Hot reload works (changes picked up without restart)
- [ ] All requests logged to console
- [ ] Proper error handling (500 errors logged)

**Technical Tasks**:

1. Create directory structure:
   ```
   src/backend/local-dev/
   ├── src/
   │   ├── index.ts        # Main server
   │   ├── config.ts       # Configuration
   │   └── routes/
   │       └── health.ts   # Health & home routes
   ├── package.json
   └── tsconfig.json
   ```

2. Create `src/backend/local-dev/src/index.ts`:
   - Express app setup
   - CORS configuration
   - Route imports
   - Error handlers
   - Server startup (port 3000)

3. Create `src/backend/local-dev/src/routes/health.ts`:
   - `GET /health` endpoint
   - `GET /api/home` endpoint

4. Create `src/backend/local-dev/package.json`:
   - Dependencies: express, cors, dotenv
   - Dev dependencies: @types/express, typescript, ts-node-dev
   - Scripts: `dev`, `build`, `start`, `start:local`

5. Create `src/backend/local-dev/tsconfig.json`:
   - Strict TypeScript config
   - Output to `dist/`

**Verification**:

```bash
cd src/backend/local-dev

# Install dependencies
npm install

# Start server
npm run start:local

# Test endpoints
curl http://localhost:3000/health
curl http://localhost:3000/api/home

# Verify output
# Should see startup logs and request logs
```

**Definition of Done**:

- [ ] Express server created and runs without errors
- [ ] All endpoints respond correctly
- [ ] CORS working (can call from Angular)
- [ ] Hot reload functional
- [ ] Ready for STORY 4.5 (Mock database)

---

### STORY 4.5: Implement Mock Database with Sample Data

**Story ID**: EPIC4-5  
**Type**: Backend Infrastructure  
**Difficulty**: Medium  
**Estimated Time**: 4-6 hours  
**Depends On**: STORY 4.4

**User Story**:
```
As a backend developer,
I want an in-memory mock database,
so that I can test API endpoints without external database dependencies.
```

**Requirements**:

1. **Create in-memory database class**
   - Store projects, tasks, users in JavaScript Map
   - Initialize with sample data on startup
   - Provide CRUD methods

2. **Implement database service**
   - Expose database instance globally
   - Provide type-safe methods
   - Sample data includes realistic entities

3. **Add project and task routes**
   - `GET /api/projects` - list all projects
   - `POST /api/projects` - create project
   - `GET /api/tasks` - list tasks for project
   - Basic validation on POST

**Acceptance Criteria**:

- [ ] Mock database class created and tested
- [ ] Sample data loads on startup (3+ projects, 5+ tasks)
- [ ] All CRUD methods work correctly
- [ ] `/api/projects` returns list of sample projects
- [ ] `/api/projects` accepts POST with name/description
- [ ] Response format matches Angular expectations
- [ ] No external dependencies (no real database)
- [ ] Data resets on server restart

**Technical Tasks**:

1. Create `src/backend/local-dev/src/database/in-memory-db.ts`:
   - `Database` class
   - Constructor with `seedData()`
   - Methods: `getProjects()`, `createProject()`, `getTasks()`, etc.
   - Store in Map objects

2. Create `src/backend/local-dev/src/database/seed-data.ts`:
   - Sample projects (Website Redesign, API Integration)
   - Sample tasks (Design, Development, Testing)
   - Sample users (test data)

3. Create `src/backend/local-dev/src/routes/projects.ts`:
   - GET /api/projects
   - POST /api/projects
   - Response wrappers: `{success: true, data: {...}}`

4. Create `src/backend/local-dev/src/routes/tasks.ts` (if time):
   - GET /api/tasks (with projectId filter)
   - POST /api/tasks

5. Update `src/backend/local-dev/src/index.ts`:
   - Import database initialization
   - Mount routes
   - Test data accessible in memory

**Verification**:

```bash
# Server running
npm run start:local

# Test endpoints
curl http://localhost:3000/api/projects
# Should return: {"success": true, "data": [...], "count": N}

curl -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name": "Test", "description": "A test"}'
# Should return: {"success": true, "data": {...}}

# Restart server
# Data should reset to original sample
```

**Definition of Done**:

- [ ] Mock database created and working
- [ ] Sample data loads automatically
- [ ] Project endpoints functional
- [ ] Ready for STORY 4.6 (Environment config)

---

### STORY 4.6: Create Environment Configuration System

**Story ID**: EPIC4-6  
**Type**: Backend Infrastructure + DevOps  
**Difficulty**: Easy-Medium  
**Estimated Time**: 3-4 hours

**User Story**:
```
As a developer,
I need environment configuration that separates cloud and local settings,
so that I can switch between backend environments without code changes.
```

**Requirements**:

1. **Create `.env.example` for backend**
   - Shows all required variables
   - Includes sample values
   - Comments explaining each

2. **Create configuration loader**
   - Reads from `.env` file
   - Validates required variables
   - Exports typed config object

3. **Support cloud vs local modes**
   - `NODE_ENV=local` for local development
   - `NODE_ENV=cloud` for connecting to AWS
   - Database endpoint configurable

**Acceptance Criteria**:

- [ ] `.env.example` created with all variables documented
- [ ] `.env` file in `.gitignore` (not committed)
- [ ] Configuration loader created (`src/config.ts`)
- [ ] Backend respects `NODE_ENV` setting
- [ ] For local mode: uses in-memory database
- [ ] For cloud mode: connects to AWS (future, not in MVP)
- [ ] Configuration validation on startup
- [ ] Friendly error messages if config invalid

**File Structure**:

```
src/backend/local-dev/
├── .env.example           # Template
├── .env                   # Actual (gitignored)
└── src/
    ├── config.ts          # Configuration loader
    └── index.ts           # Uses config
```

**Example `.env.example`**:

```bash
# Node Environment
NODE_ENV=local
PORT=3000

# Database
DATABASE_TYPE=mock
DATABASE_URL=local-in-memory

# API
API_CORS_ORIGIN=http://localhost:4200
API_ENVIRONMENT=local

# Logging
LOG_LEVEL=debug
```

**Example `src/config.ts`**:

```typescript
import dotenv from 'dotenv';

dotenv.config();

export const config = {
  node: {
    env: process.env.NODE_ENV || 'local',
    port: parseInt(process.env.PORT || '3000', 10),
  },
  database: {
    type: process.env.DATABASE_TYPE || 'mock',
    url: process.env.DATABASE_URL || 'local-in-memory',
  },
  api: {
    corsOrigin: process.env.API_CORS_ORIGIN || 'http://localhost:4200',
    environment: process.env.API_ENVIRONMENT || 'local',
  },
  logging: {
    level: process.env.LOG_LEVEL || 'info',
  },
};

export function validateConfig() {
  if (config.node.env !== 'local' && config.node.env !== 'cloud') {
    throw new Error(`Invalid NODE_ENV: ${config.node.env}. Must be 'local' or 'cloud'.`);
  }
}
```

**Verification**:

```bash
# Copy .env.example to .env
cp .env.example .env

# Verify config loads
npm run start:local

# Should see startup logs showing configuration
# No errors about missing variables
```

**Definition of Done**:

- [ ] Configuration system created and documented
- [ ] `.env.example` clear and complete
- [ ] Configuration validation working
- [ ] Server starts with proper config
- [ ] Ready for STORY 4.7 (Documentation)

---

### STORY 4.7: Create Complete Setup Documentation & Troubleshooting Guide

**Story ID**: EPIC4-7  
**Type**: Documentation  
**Difficulty**: Medium  
**Estimated Time**: 5-7 hours  
**Depends On**: All other stories

**User Story**:
```
As a new developer,
I want comprehensive setup documentation,
so that I can get a working local environment in <30 minutes.
```

**Requirements**:

1. **Create multi-part documentation**
   - Quick start (5 min setup)
   - Full local stack setup (20 min)
   - Environment variable reference
   - Troubleshooting guide

2. **Document for different personas**
   - Frontend developer (cloud only)
   - Backend developer (local stack)
   - Full-stack developer (both)

3. **Include troubleshooting section**
   - CORS errors
   - Port conflicts
   - Environment variable issues
   - Common mistakes

**Acceptance Criteria**:

- [ ] 3+ separate documentation files created
- [ ] Each doc tested by following exactly
- [ ] Estimated setup times accurate (<5 min for frontend, <20 min for full)
- [ ] Troubleshooting covers 8+ common issues
- [ ] Screenshots/examples where helpful
- [ ] Clear "next steps" after each setup
- [ ] All commands copy-paste ready

**Documentation Files to Create**:

1. **`SETUP_LOCAL_FRONTEND_ONLY.md`** (5 min setup)
   - For frontend developers
   - Just local Angular + cloud backend
   - Minimal steps

2. **`SETUP_LOCAL_FULL_STACK.md`** (20 min setup)
   - For backend/full-stack developers
   - Complete local stack
   - All services running locally

3. **`ENVIRONMENT_VARIABLE_REFERENCE.md`**
   - All variables explained
   - Valid values
   - Examples for cloud vs local

4. **`LOCAL_DEVELOPMENT_TROUBLESHOOTING.md`**
   - CORS errors (solutions)
   - Port already in use (solutions)
   - `.env` file issues (solutions)
   - API not connecting (solutions)
   - Database issues (solutions)
   - Network issues (solutions)
   - More...

5. **`LOCAL_DEVELOPMENT_WORKFLOWS.md`** (Optional)
   - Typical developer workflow examples
   - When to use which setup
   - How to switch between configurations

**Example Documentation Structure**:

```markdown
# SETUP_LOCAL_FRONTEND_ONLY.md

## Prerequisites
- Node.js 18+
- Angular CLI globally installed

## Step 1: Clone Repository
## Step 2: Get Cloud API URL
## Step 3: Create .env File
## Step 4: Start Angular
## Step 5: Verify Connection
## Next Steps
## Troubleshooting
```

**Verification Process**:

- [ ] Follow setup docs exactly (don't use memory)
- [ ] Time how long each step takes
- [ ] Note any confusing parts
- [ ] Fix any errors or ambiguities
- [ ] Have another person test if possible

**Definition of Done**:

- [ ] All documentation created and tested
- [ ] Setup times match estimates
- [ ] Troubleshooting comprehensive
- [ ] New developer can complete setup without help
- [ ] Epic 4 is complete and ready for developer use

---

## Sprint Planning Summary

### Week 1 (Days 1-5)

**Monday-Tuesday (Days 1-2)**: Frontend Configuration
- STORY 4.1: API URL environment variable (3-4 hrs)
- STORY 4.2: API service creation (4-5 hrs)
- STORY 4.3: Test & document (2-3 hrs)
- **Subtotal**: 9-12 hours
- **Outcome**: Local Angular + cloud backend working

**Wednesday-Thursday (Days 3-4)**: Local Backend Server
- STORY 4.4: Express.js server setup (6-8 hrs)
- STORY 4.5: Mock database (4-6 hrs)
- STORY 4.6: Environment configuration (3-4 hrs)
- **Subtotal**: 13-18 hours
- **Outcome**: Local backend server + mock database

**Friday (Day 5)**: Documentation
- STORY 4.7: Setup docs & troubleshooting (5-7 hrs)
- **Subtotal**: 5-7 hours
- **Outcome**: Complete documentation for new developers

**Total**: 27-37 hours (1-2 weeks for typical developer)

---

## Story Prioritization

**Must Have** (Critical for MVP):
1. ✅ STORY 4.1 - API URL configuration
2. ✅ STORY 4.2 - API service
3. ✅ STORY 4.3 - Local frontend + cloud backend working

**Should Have** (Important for full epic):
4. ✅ STORY 4.4 - Local Express.js backend
5. ✅ STORY 4.5 - Mock database
6. ✅ STORY 4.6 - Environment configuration

**Nice to Have** (Documentation, helps adoption):
7. ✅ STORY 4.7 - Complete documentation

---

## Success Criteria for Epic 4

After all 7 stories are complete:

**Technical Verification**:
- ✅ Local Angular on `localhost:4200` runs without errors
- ✅ Angular API calls reach cloud endpoint successfully
- ✅ Local backend on `localhost:3000` responds to requests
- ✅ Local frontend + local backend integration works
- ✅ Environment switching (`API_URL`) works without code changes
- ✅ No hardcoded API URLs in codebase
- ✅ Sample data loads on backend startup

**Process Verification**:
- ✅ New developer can complete setup in <30 minutes
- ✅ Documentation covers all common issues
- ✅ Setup tested by multiple developers
- ✅ Clear "next steps" guidance after each setup phase

**Adoption Criteria**:
- ✅ Development team uses local setup for feature work
- ✅ Cloud deployments reduced (developers test locally first)
- ✅ Faster iteration cycles observed
- ✅ Fewer "works on my machine" issues

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Setup more complex than expected | Break STORY 4.4 into smaller tasks, add more explicit steps |
| Hot reload doesn't work | Document manual restart; can be workaround for MVP |
| Environment variable config confusing | Add extra documentation with examples |
| CORS issues blocking testing | Test CORS setup early in STORY 4.3 |
| New developer struggle with setup | Include troubleshooting section, test with real new dev |

---

## Next Actions

1. **Stakeholder Review**: Review stories with team
2. **Story Refinement**: Adjust estimates based on feedback
3. **Begin STORY 4.1**: Start with API URL configuration this week
4. **Daily Standup**: Track progress, surface blockers daily
5. **Testing**: Verify each story works before moving to next

---

## Notes

- **Team**: Can be done by 1 developer or split across 2+ developers
- **Parallel Work**: Stories 4.4-4.6 can start once 4.1-4.2 merged
- **Documentation**: STORY 4.7 can be done in parallel, not blocked by others
- **Testing**: Each story should be tested independently before moving on
- **Documentation**: Each story should update documentation as needed

