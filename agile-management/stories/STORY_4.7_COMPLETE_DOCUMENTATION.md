# Story 4.7: Create Complete Documentation Package

**Story ID**: EPIC4-7  
**Epic**: EPIC-4 (Cloud + Local Integration)  
**Sprint**: SPRINT-3  
**Status**: 📋 TODO  
**Story Type**: Documentation

---

## User Story

```
As a backend developer,
I want comprehensive documentation for the local backend setup and development,
so that I can get up and running quickly and solve problems independently.
```

---

## Requirements

### Documentation Files

1. **Full Stack Setup Guide** - Complete instructions for local backend + frontend
2. **Backend Configuration Reference** - All `.env` variables explained
3. **Troubleshooting Guide** - Common issues and solutions
4. **API Endpoints Reference** - All available endpoints documented
5. **Development Workflows** - When to use which setup
6. **Local Backend README** - Quick reference in the local-dev folder

### Scope

This story covers documentation for the **complete local environment**:
- Frontend configuration (Angular)
- Backend server (Express)
- Mock database
- Configuration system
- Troubleshooting

---

## Acceptance Criteria

- [ ] `SETUP_LOCAL_FULL_STACK.md` created with step-by-step guide
- [ ] `BACKEND_CONFIGURATION_REFERENCE.md` created with all variables
- [ ] `BACKEND_TROUBLESHOOTING.md` created with common issues
- [ ] `API_ENDPOINTS_REFERENCE.md` created documenting all endpoints
- [ ] `LOCAL_DEVELOPMENT_WORKFLOWS.md` created showing when to use what
- [ ] `src/backend/local-dev/README.md` created as quick reference
- [ ] Documentation tested with new developer
- [ ] All files use consistent style and formatting
- [ ] Examples are concrete (not abstract)
- [ ] Code samples are functional

---

## Definition of Done

- [ ] All documentation files created
- [ ] Tested with new developer
- [ ] Setup time <30 minutes for full stack
- [ ] Ready for EPIC completion

---

## Technical Tasks

### Task 1: Create full stack setup guide

**Location**: `docs/SETUP_LOCAL_FULL_STACK.md`

**Content**:
```markdown
# Complete Setup: Local Angular + Local Express Backend

**Setup Time**: ~20-30 minutes  
**Difficulty**: ⭐⭐ Moderate  
**For**: Backend developers and full-stack development

---

## What You'll Get

After following these steps:
- Angular dev server on **http://localhost:4200**
- Express backend on **http://localhost:3000**
- Mock database with sample data
- Ready to develop complete features end-to-end

---

## Prerequisites

Before starting:
- Node.js 18+ (`node --version`)
- npm (`npm --version`)
- Git installed
- TeamFlow repository cloned

---

## Part 1: Frontend Setup (5 minutes)

### Step 1: Install Frontend Dependencies

```bash
cd src/frontend
npm install
```

### Step 2: Create Frontend `.env` File

```bash
cat > .env << EOF
API_URL=http://localhost:3000
ENVIRONMENT=local
EOF
```

### Step 3: Start Angular Dev Server

```bash
ng serve

# Wait for:
# ✔ Compiled successfully
# [development server] Accepting connections on http://localhost:4200
```

Keep this running in a terminal.

---

## Part 2: Backend Setup (15-20 minutes)

Open a **new terminal** while frontend is running.

### Step 1: Navigate to Backend

```bash
cd src/backend/local-dev
```

### Step 2: Install Backend Dependencies

```bash
npm install

# Installs: express, cors, dotenv, uuid, ts-node-dev, etc.
# Takes 30-60 seconds
```

### Step 3: Create Backend `.env` File

```bash
cat > .env << EOF
PORT=3000
NODE_ENV=development
FRONTEND_URL=http://localhost:4200
LOG_LEVEL=debug
DATABASE_TYPE=in-memory
API_VERSION=v1
ENABLE_AUTH=false
ENABLE_RATE_LIMITING=false
EOF
```

### Step 4: Start Backend Server

```bash
npm run dev

# Wait for:
# ✅ Configuration Loaded:
#    Port: 3000
#    ...
# 🚀 Local Backend Server Started
# 📡 http://localhost:3000
```

Keep this running in another terminal.

---

## Part 3: Verify Everything Works (5 minutes)

### Check 1: Frontend Loads

1. Open **http://localhost:4200** in browser
2. Angular app should load (you'll see the app UI)

### Check 2: Backend Responds

1. Open **http://localhost:3000/health** in browser
2. Should see: `{"status":"ok","timestamp":"2026-01-25T..."}`

### Check 3: Frontend Can Call Backend

1. Open DevTools (F12) → Console tab
2. Should see logs:
   ```
   ✅ API Service initialized
   📡 API Endpoint: http://localhost:3000
   🌍 Environment: local
   ```

### Check 4: Test API Call

If your app has a test component or API button:
1. Click "Test API" or similar
2. In DevTools Network tab, should see:
   - Request to `http://localhost:3000/api/...`
   - Response with status 200

---

## Success Checklist

- [ ] Frontend running on http://localhost:4200
- [ ] Backend running on http://localhost:3000
- [ ] Both `/health` and `/api/home` endpoints respond
- [ ] Frontend console shows API Service initialized
- [ ] API calls reach backend (see in Network tab)
- [ ] No CORS errors in console

**All checked? You're ready to develop!**

---

## Now You Can...

### Develop Frontend Features
- Edit Angular components in `src/frontend/src/app/`
- Changes auto-reload in browser (hot reload)
- Use API Service to call local backend

### Develop Backend Endpoints
- Edit Express routes in `src/backend/local-dev/src/routes/`
- Add new endpoints in routes
- Change mock database behavior
- Server auto-restarts on changes (ts-node-dev)

### Test End-to-End
- Make changes in frontend and backend
- See them work together immediately
- No AWS deployment needed

---

## Stopping the Servers

### Stop Frontend
```bash
# In frontend terminal: Ctrl+C
# Angular dev server will shut down
```

### Stop Backend
```bash
# In backend terminal: Ctrl+C
# Express server will shut down gracefully
```

---

## Restarting After Stopping

### Restart Frontend
```bash
cd src/frontend
ng serve
```

### Restart Backend
```bash
cd src/backend/local-dev
npm run dev
```

---

## Quick Reference

| Task | Command | Port |
|------|---------|------|
| Start Frontend | `cd src/frontend && ng serve` | 4200 |
| Start Backend | `cd src/backend/local-dev && npm run dev` | 3000 |
| Frontend logs | Open browser DevTools (F12) | - |
| Backend logs | See terminal output | - |

---

## Troubleshooting

### Port Already in Use

```bash
# If port 4200 (frontend) in use:
ng serve --port 4201

# If port 3000 (backend) in use:
# Edit src/backend/local-dev/.env
# Change PORT=3001
# Restart backend
```

### CORS Error

If you see: "Access to XMLHttpRequest... blocked by CORS policy"

1. Verify `FRONTEND_URL` in backend `.env` is correct
2. Should be: `FRONTEND_URL=http://localhost:4200`
3. Restart backend server
4. Refresh browser

### Backend Not Starting

```bash
# Check Node/npm versions
node --version  # Should be 18+
npm --version

# Clear node_modules and reinstall
cd src/backend/local-dev
rm -rf node_modules
npm install
npm run dev
```

### No Response from API

1. Verify backend is running (see "🚀 Local Backend Server Started")
2. Check frontend `.env` has `API_URL=http://localhost:3000`
3. Try accessing endpoint directly: `curl http://localhost:3000/health`
4. Check browser Network tab for actual request

---

## Next Steps

1. Explore the codebase:
   - Frontend: `src/frontend/src/app/`
   - Backend: `src/backend/local-dev/src/`

2. Check out routes:
   - Frontend routes: `src/frontend/src/app/app.routes.ts`
   - Backend routes: `src/backend/local-dev/src/routes/`

3. Understand the flow:
   - Frontend makes request via API Service
   - Request goes to Express server
   - Express queries mock database
   - Response returned to frontend

4. Make a change:
   - Edit a component or route
   - See auto-reload in action
   - Test with API Service

---

## Common Commands

```bash
# Frontend commands
cd src/frontend
ng serve              # Start dev server
ng build              # Production build
npm test              # Run tests
npm run lint          # Check code

# Backend commands
cd src/backend/local-dev
npm run dev           # Start dev server
npm run build         # Compile TypeScript
npm run lint          # Check code
npm test              # Run tests (if available)
```

---

## Useful Documentation

- **Frontend Only Setup**: See [SETUP_LOCAL_FRONTEND_ONLY.md](./SETUP_LOCAL_FRONTEND_ONLY.md)
- **API Reference**: See [API_ENDPOINTS_REFERENCE.md](./API_ENDPOINTS_REFERENCE.md)
- **Configuration**: See [BACKEND_CONFIGURATION_REFERENCE.md](./BACKEND_CONFIGURATION_REFERENCE.md)
- **Troubleshooting**: See [BACKEND_TROUBLESHOOTING.md](./BACKEND_TROUBLESHOOTING.md)
- **Workflows**: See [LOCAL_DEVELOPMENT_WORKFLOWS.md](./LOCAL_DEVELOPMENT_WORKFLOWS.md)

---

**Last Updated**: 2026-01-25
```

**What to do**:
1. Create file: `docs/SETUP_LOCAL_FULL_STACK.md`
2. Copy content above
3. Save

---

### Task 2: Create API endpoints reference

**Location**: `docs/API_ENDPOINTS_REFERENCE.md`

**Content** (excerpt, create full version with all endpoints):
```markdown
# API Endpoints Reference

**Base URL**: `http://localhost:3000` (local) or `https://api.example.com/dev` (cloud)

---

## Health Check

### GET /health
Get server health status.

**Response**:
```json
{
  "status": "ok",
  "timestamp": "2026-01-25T10:30:00.000Z"
}
```

**Status Code**: 200

---

## Home

### GET /api/home
Get API home information.

**Response**:
```json
{
  "message": "hello from local backend",
  "source": "local",
  "timestamp": "2026-01-25T10:30:00.000Z"
}
```

**Status Code**: 200

---

## Projects

### GET /api/projects
Get all projects.

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "project-1",
      "name": "Website Redesign",
      "description": "Update website",
      "createdAt": "2026-01-25T...",
      "updatedAt": "2026-01-25T..."
    }
  ],
  "count": 1
}
```

### POST /api/projects
Create new project.

**Request Body**:
```json
{
  "name": "My Project",
  "description": "Optional description"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "project-1",
    "name": "My Project",
    "description": "Optional description",
    "createdAt": "2026-01-25T...",
    "updatedAt": "2026-01-25T..."
  }
}
```

### GET /api/projects/:id
Get single project.

### PUT /api/projects/:id
Update project.

### DELETE /api/projects/:id
Delete project.

---

## Tasks

### GET /api/tasks
Get all tasks.

### GET /api/projects/:projectId/tasks
Get tasks in project.

### POST /api/projects/:projectId/tasks
Create task in project.

**Request Body**:
```json
{
  "title": "Task Title",
  "description": "Optional",
  "status": "todo",
  "priority": "high",
  "assigneeId": "optional-user-id"
}
```

### GET /api/tasks/:id
Get single task.

### PUT /api/tasks/:id
Update task.

### DELETE /api/tasks/:id
Delete task.

---

[Full documentation would continue with all endpoints...]
```

**What to do**:
1. Create file: `docs/API_ENDPOINTS_REFERENCE.md`
2. Create detailed documentation for all endpoints
3. Include request/response examples
4. Include status codes and error responses
5. Save

---

### Task 3-6: Create remaining documentation files

Similar to above, create:

1. **`docs/BACKEND_CONFIGURATION_REFERENCE.md`**
   - Explain each `.env` variable
   - Valid values and ranges
   - Examples for different scenarios

2. **`docs/BACKEND_TROUBLESHOOTING.md`**
   - Common backend errors
   - How to debug
   - Where to look for logs

3. **`docs/LOCAL_DEVELOPMENT_WORKFLOWS.md`**
   - When to use frontend-only setup
   - When to use full-stack
   - Tips for efficient development

4. **`src/backend/local-dev/README.md`**
   - Quick reference for local backend
   - How to start/stop server
   - Common commands

---

## Verification Steps

### Step 1: All files exist

```bash
ls -la docs/SETUP_LOCAL_FULL_STACK.md
ls -la docs/API_ENDPOINTS_REFERENCE.md
ls -la docs/BACKEND_CONFIGURATION_REFERENCE.md
ls -la docs/BACKEND_TROUBLESHOOTING.md
ls -la docs/LOCAL_DEVELOPMENT_WORKFLOWS.md
ls -la src/backend/local-dev/README.md
```

### Step 2: Test with new developer

Have someone unfamiliar with the project:
1. Follow SETUP_LOCAL_FULL_STACK.md
2. Time how long it takes
3. Note any confusing sections
4. Ask what would have helped

### Step 3: Verify completeness

Checklist for each file:
- [ ] Clear title and purpose
- [ ] Step-by-step instructions
- [ ] Concrete examples (not abstract)
- [ ] Expected outputs shown
- [ ] Troubleshooting for that topic
- [ ] Links to related documents

---

## Notes

**Key Points**:
- Write for newcomers (not just experts)
- Show expected output after each step
- Include concrete examples (commands, URLs, responses)
- Keep formatting consistent
- Link between documents

**Future Enhancements**:
- Add screenshots or GIFs
- Add video walkthrough
- Add automated tests for setup
- Keep updated as code changes

**Dependencies**:
- Requires STORY 4.1-4.6 to be complete
- All features must be working

**Estimated Time**: 5-7 hours

---

## Completion Checklist

- [ ] `SETUP_LOCAL_FULL_STACK.md` created
- [ ] `API_ENDPOINTS_REFERENCE.md` created
- [ ] `BACKEND_CONFIGURATION_REFERENCE.md` created
- [ ] `BACKEND_TROUBLESHOOTING.md` created
- [ ] `LOCAL_DEVELOPMENT_WORKFLOWS.md` created
- [ ] `src/backend/local-dev/README.md` created
- [ ] All files tested with new developer
- [ ] Cross-references between files working
- [ ] Setup time <30 minutes verified
- [ ] Ready for EPIC completion

---

**Last Updated**: 2026-01-25
