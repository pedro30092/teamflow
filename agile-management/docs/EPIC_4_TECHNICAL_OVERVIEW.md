# Epic 4: Technical Overview - Local Frontend + Cloud Backend Integration & Local Development Environment

**Document Type**: Architecture Specification  
**Epic Reference**: [EPIC_4_CLOUD_LOCAL_INTEGRATION.md](../epics/EPIC_4_CLOUD_LOCAL_INTEGRATION.md)  
**Architecture Reference**: [TECHNICAL_ARCHITECTURE_SERVERLESS.md](../../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)

---

## Purpose

Translate Epic 4 product requirements into technical specifications. This document defines:
- How to enable local Angular ↔ cloud backend communication
- How to set up a complete local development environment (backend + database + frontend)
- How to manage environment switching without code changes
- Specific tools, file structures, and configuration approaches

---

## Product Requirements Summary

**FROM EPIC 4**:
1. Local Angular app calls cloud API with minimal setup friction
2. Local backend (Node.js + database) runs with single command
3. Environment switching (cloud vs local) via `.env` file only
4. New developer can be productive in <30 minutes
5. Complete documentation and troubleshooting guide

---

## Part 1: Local Angular + Cloud Backend Integration

### How It Works

```
┌─────────────────────┐         ┌──────────────────────────┐
│   Local Angular     │         │   Cloud AWS              │
│  localhost:4200     │────────>│   API Gateway + Lambda   │
│  (ng serve)         │         │   https://api.xxx.../dev │
└─────────────────────┘         └──────────────────────────┘
```

### Required CDKTF Changes (API Gateway CORS)

**Update existing API Gateway CORS configuration** to allow localhost:

```typescript
// infrastructure/stacks/api-stack.ts
import * as apigateway from 'aws-cdk-lib/aws-apigateway';

const api = new apigateway.RestApi(this, 'teamflow-api', {
  restApiName: 'teamflow-api',
  description: 'TeamFlow serverless API',
});

// Add CORS configuration to the API
api.addGatewayResponse('DefaultCorsPreflightResponse', {
  type: apigateway.GatewayResponseType.DEFAULT_4XX,
  responseHeaders: {
    'Access-Control-Allow-Headers': 
      "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
    'Access-Control-Allow-Origin': "'*'",
    'Access-Control-Allow-Methods': "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
  },
});

api.addGatewayResponse('DefaultCorsPreflightResponse', {
  type: apigateway.GatewayResponseType.DEFAULT_4XX,
  responseHeaders: {
    'Access-Control-Allow-Headers': 
      "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
    'Access-Control-Allow-Origin': "'*'",
    'Access-Control-Allow-Methods': "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
  },
});

// Enable CORS on each method
const projectsResource = api.root.addResource('projects');
projectsResource.addMethod('OPTIONS', new apigateway.MockIntegration({
  integrationResponses: [{
    statusCode: '200',
    responseParameters: {
      'method.response.header.Access-Control-Allow-Headers': 
        "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
      'method.response.header.Access-Control-Allow-Origin': "'*'",
      'method.response.header.Access-Control-Allow-Methods': 
        "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    },
  }],
}), {
  methodResponses: [{
    statusCode: '200',
    responseParameters: {
      'method.response.header.Access-Control-Allow-Headers': true,
      'method.response.header.Access-Control-Allow-Origin': true,
      'method.response.header.Access-Control-Allow-Methods': true,
    },
  }],
});
```

**Note**: For MVP, allow all origins (`*`). In production, restrict to your domain.

### Angular Configuration

**File Structure**:
```
src/frontend/
├── src/
│   ├── environments/
│   │   ├── environment.ts           # Local development
│   │   └── environment.prod.ts      # Production
│   ├── app/
│   │   ├── core/
│   │   │   └── http/
│   │   │       └── api.service.ts   # API client
│   │   └── app.config.ts            # App configuration
│   └── main.ts
├── .env.example                     # Example config
├── .env                             # Actual config (gitignored)
├── angular.json
└── package.json
```

**`.env.example` file**:
```bash
# API Configuration
# For cloud API: https://your-api-id.execute-api.us-east-1.amazonaws.com/dev
# For local backend: http://localhost:3000

API_URL=https://your-cloud-api.execute-api.us-east-1.amazonaws.com/dev
ENVIRONMENT=cloud
```

**`.env` file** (actual config, add to `.gitignore`):
```bash
API_URL=https://your-cloud-api.execute-api.us-east-1.amazonaws.com/dev
ENVIRONMENT=cloud
```

**`environment.ts` (development environment)**:
```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: process.env['API_URL'] || 'http://localhost:3000',
  environment: process.env['ENVIRONMENT'] || 'local',
};
```

**`environment.prod.ts` (production)**:
```typescript
// src/environments/environment.prod.ts
export const environment = {
  production: true,
  apiUrl: process.env['API_URL'] || 'https://api.teamflow.dev/dev',
  environment: 'cloud',
};
```

**`api.service.ts` (HTTP client)**:
```typescript
// src/app/core/http/api.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {
    console.log(`API configured to: ${this.apiUrl}`);
    console.log(`Environment: ${environment.environment}`);
  }

  // Example endpoint
  getHome() {
    return this.http.get<{ message: string }>(`${this.apiUrl}/api/home`);
  }

  // Generic GET method for other endpoints
  get<T>(path: string) {
    return this.http.get<T>(`${this.apiUrl}${path}`);
  }

  // Generic POST method
  post<T>(path: string, data: any) {
    return this.http.post<T>(`${this.apiUrl}${path}`, data);
  }
}
```

**`app.config.ts` (provide HttpClient)**:
```typescript
// src/app/app.config.ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(),
    // ... other providers
  ],
};
```

### Usage Example in Component

```typescript
// Example component using the API service
import { Component, OnInit } from '@angular/core';
import { ApiService } from './core/http/api.service';

@Component({
  selector: 'app-home',
  template: `<div>{{ message }}</div>`,
})
export class HomeComponent implements OnInit {
  message: string = '';

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.api.getHome().subscribe(
      (response) => {
        this.message = response.message;
      },
      (error) => {
        console.error('API call failed:', error);
      }
    );
  }
}
```

### Running Local Angular + Cloud Backend

**Steps**:
1. Create `.env` file with cloud API URL
2. Run `ng serve`
3. Open `http://localhost:4200`
4. Angular calls cloud API automatically

**Verification**:
```bash
# Check browser console for API URL log
# API configured to: https://your-api-id.execute-api.us-east-1.amazonaws.com/dev

# Check network tab in DevTools
# Should see request to cloud API endpoint
```

---

## Part 2: Full Local Development Environment

### Architecture

```
┌──────────────────────────────────────────────────────────┐
│             LOCAL DEVELOPMENT ENVIRONMENT               │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────┐         ┌──────────────────┐     │
│  │  Angular App     │         │  Local Backend   │     │
│  │  localhost:4200  │────────>│  localhost:3000  │     │
│  │  (ng serve)      │         │  (Node.js)       │     │
│  └──────────────────┘         └────────┬─────────┘     │
│                                         │                │
│                              ┌──────────▼─────────┐     │
│                              │  Local Database    │     │
│                              │  (DynamoDB Local   │     │
│                              │   or Mock)         │     │
│                              └────────────────────┘     │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Local Backend Framework Choice

**Recommended**: Express.js (lightweight, familiar, fast to set up)

**Alternatives**: Fastify, Hono (both faster, but overkill for MVP)

**Use Express** because:
- Minimal setup
- Large ecosystem
- Team likely familiar with it
- Good enough performance for local development

### Backend Project Structure

```
src/backend/local-dev/
├── src/
│   ├── index.ts                    # Entry point
│   ├── config.ts                   # Configuration
│   ├── database/
│   │   ├── local-db.ts            # Local database setup
│   │   └── seed-data.ts           # Sample data
│   ├── routes/
│   │   ├── projects.ts
│   │   ├── tasks.ts
│   │   └── health.ts              # Health check
│   ├── middleware/
│   │   ├── cors.ts
│   │   └── logging.ts
│   └── types.ts                    # Shared types
├── package.json
└── tsconfig.json
```

### Local Backend Implementation

**`src/index.ts` (Main server)**:
```typescript
// src/backend/local-dev/src/index.ts
import express, { Express, Request, Response } from 'express';
import cors from 'cors';
import { initializeDatabase } from './database/local-db';
import { getProjects, createProject } from './routes/projects';

const app: Express = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

// Initialize database
initializeDatabase();

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    environment: 'local',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.get('/api/home', (req: Request, res: Response) => {
  res.json({
    message: 'hello world',
    source: 'local backend',
  });
});

app.get('/api/projects', getProjects);
app.post('/api/projects', createProject);

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
  });
});

// Error handler
app.use((err: any, req: Request, res: Response, next: any) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`\n✅ Local backend running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`\n⚙️  Environment: local`);
  console.log(`📁 Database: in-memory mock`);
  console.log(`\nPress Ctrl+C to stop\n`);
});
```

**`src/database/local-db.ts` (Mock database)**:
```typescript
// src/backend/local-dev/src/database/local-db.ts

// Simple in-memory database for local development
interface Project {
  id: string;
  name: string;
  description: string;
  createdAt: string;
}

interface Task {
  id: string;
  projectId: string;
  title: string;
  status: 'todo' | 'in_progress' | 'done';
  createdAt: string;
}

export class LocalDatabase {
  private projects: Map<string, Project> = new Map();
  private tasks: Map<string, Task> = new Map();

  constructor() {
    this.seedData();
  }

  private seedData() {
    // Add sample projects
    const project1: Project = {
      id: 'proj_1',
      name: 'Website Redesign',
      description: 'Q1 2026 website redesign',
      createdAt: new Date().toISOString(),
    };

    const project2: Project = {
      id: 'proj_2',
      name: 'API Integration',
      description: 'Integrate third-party APIs',
      createdAt: new Date().toISOString(),
    };

    this.projects.set(project1.id, project1);
    this.projects.set(project2.id, project2);

    // Add sample tasks
    const task1: Task = {
      id: 'task_1',
      projectId: 'proj_1',
      title: 'Create design mockups',
      status: 'in_progress',
      createdAt: new Date().toISOString(),
    };

    const task2: Task = {
      id: 'task_2',
      projectId: 'proj_1',
      title: 'Get client approval',
      status: 'todo',
      createdAt: new Date().toISOString(),
    };

    this.tasks.set(task1.id, task1);
    this.tasks.set(task2.id, task2);

    console.log('📦 Sample data loaded: 2 projects, 2 tasks');
  }

  // Projects
  getProjects(): Project[] {
    return Array.from(this.projects.values());
  }

  getProjectById(id: string): Project | undefined {
    return this.projects.get(id);
  }

  createProject(data: Omit<Project, 'id' | 'createdAt'>): Project {
    const project: Project = {
      ...data,
      id: `proj_${Date.now()}`,
      createdAt: new Date().toISOString(),
    };
    this.projects.set(project.id, project);
    return project;
  }

  // Tasks
  getTasksByProject(projectId: string): Task[] {
    return Array.from(this.tasks.values()).filter(
      (t) => t.projectId === projectId
    );
  }

  createTask(data: Omit<Task, 'id' | 'createdAt'>): Task {
    const task: Task = {
      ...data,
      id: `task_${Date.now()}`,
      createdAt: new Date().toISOString(),
    };
    this.tasks.set(task.id, task);
    return task;
  }
}

// Global database instance
let db: LocalDatabase;

export function initializeDatabase() {
  db = new LocalDatabase();
  return db;
}

export function getDatabase(): LocalDatabase {
  if (!db) {
    throw new Error('Database not initialized. Call initializeDatabase() first.');
  }
  return db;
}
```

**`src/routes/projects.ts` (Project routes)**:
```typescript
// src/backend/local-dev/src/routes/projects.ts
import { Request, Response } from 'express';
import { getDatabase } from '../database/local-db';

export const getProjects = (req: Request, res: Response) => {
  const db = getDatabase();
  const projects = db.getProjects();
  res.json({
    success: true,
    data: projects,
    count: projects.length,
  });
};

export const createProject = (req: Request, res: Response) => {
  const db = getDatabase();
  const { name, description } = req.body;

  if (!name) {
    return res.status(400).json({
      success: false,
      error: 'Project name is required',
    });
  }

  const project = db.createProject({
    name,
    description: description || '',
  });

  res.status(201).json({
    success: true,
    data: project,
  });
};
```

### Environment Configuration for Local Backend

**`.env` file for local backend**:
```bash
# Local Development Environment

# Node.js
NODE_ENV=local
PORT=3000

# Database
DATABASE_TYPE=mock
DATABASE_URL=local-in-memory

# Logging
LOG_LEVEL=debug

# API
API_CORS_ORIGIN=http://localhost:4200
```

**`src/config.ts` (Configuration loader)**:
```typescript
// src/backend/local-dev/src/config.ts
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
  },
  logging: {
    level: process.env.LOG_LEVEL || 'info',
  },
};

export function validateConfig() {
  if (config.node.env !== 'local') {
    console.warn('⚠️  NODE_ENV is not set to "local". Are you sure?');
  }
}
```

### Local Backend `package.json`

```json
{
  "name": "@teamflow/backend-local",
  "version": "1.0.0",
  "description": "Local development backend for TeamFlow",
  "main": "dist/index.js",
  "scripts": {
    "dev": "ts-node-dev --respawn src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "start:local": "npm run dev"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/node": "^20.x",
    "typescript": "^5.x",
    "ts-node-dev": "^2.0.0"
  }
}
```

### Running Local Backend

**Setup**:
```bash
# Install dependencies
cd src/backend/local-dev
npm install

# Create .env file
cp .env.example .env
```

**Start**:
```bash
# Start with auto-reload (development)
npm run start:local

# Or start built version
npm run build && npm start
```

**Verify**:
```bash
# Health check
curl http://localhost:3000/health

# Get projects
curl http://localhost:3000/api/projects

# Create project
curl -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Project", "description": "A test"}'
```

---

## Part 3: Environment Switching

### Configuration System

**Single source of truth**: `.env` file controls everything

**Frontend `.env`**:
```bash
# Switch between cloud and local backend
API_URL=http://localhost:3000          # For local development
# API_URL=https://api.xxx.../dev       # For cloud development

ENVIRONMENT=local
```

**Backend `.env`**:
```bash
# Backend configuration
NODE_ENV=local
PORT=3000
DATABASE_TYPE=mock
```

### How to Switch

**To use cloud backend**:
1. Edit `src/frontend/.env`
2. Change: `API_URL=https://your-cloud-api-url.execute-api.us-east-1.amazonaws.com/dev`
3. Restart `ng serve`
4. No code changes needed

**To use local backend**:
1. Run local backend: `cd src/backend/local-dev && npm run start:local`
2. Edit `src/frontend/.env`
3. Change: `API_URL=http://localhost:3000`
4. Restart `ng serve` (or it auto-reloads)
5. No code changes needed

**To display current endpoint in UI** (optional but helpful):
```typescript
// In any component
import { environment } from '../../environments/environment';

export class DashboardComponent {
  apiUrl = environment.apiUrl;
  environment = environment.environment;

  ngOnInit() {
    console.log(`Connected to: ${this.apiUrl} (${this.environment})`);
  }
}
```

Display in template:
```html
<div class="debug-info">
  API: {{ apiUrl }} ({{ environment }})
</div>
```

---

## CORS Configuration Details

### For Development (Current)

**Allow all origins** (from existing API Gateway):
```typescript
// api-stack.ts - CORS allowing all origins
'Access-Control-Allow-Origin': "'*'"
```

This allows:
- `http://localhost:4200` (local Angular)
- `http://localhost:3000` (local backend calling another endpoint)
- Any other origin (fine for dev/testing)

### For Production (Future)

Restrict CORS to specific domains:
```typescript
// Future production setup
'Access-Control-Allow-Origin': "'https://teamflow.dev'"
```

---

## File Structure Summary

```
teamflow/
├── src/
│   ├── frontend/
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── core/
│   │   │   │   │   └── http/
│   │   │   │   │       └── api.service.ts
│   │   │   │   └── app.config.ts
│   │   │   ├── environments/
│   │   │   │   ├── environment.ts
│   │   │   │   └── environment.prod.ts
│   │   │   └── main.ts
│   │   ├── .env.example              # ⬅️ CREATE
│   │   ├── .env                      # ⬅️ CREATE (add to .gitignore)
│   │   ├── angular.json
│   │   └── package.json
│   │
│   └── backend/
│       └── local-dev/                # ⬅️ CREATE
│           ├── src/
│           │   ├── index.ts
│           │   ├── config.ts
│           │   ├── database/
│           │   │   ├── local-db.ts
│           │   │   └── seed-data.ts
│           │   ├── routes/
│           │   │   ├── projects.ts
│           │   │   ├── tasks.ts
│           │   │   └── health.ts
│           │   ├── middleware/
│           │   │   ├── cors.ts
│           │   │   └── logging.ts
│           │   └── types.ts
│           ├── .env.example          # ⬅️ CREATE
│           ├── .env                  # ⬅️ CREATE (add to .gitignore)
│           ├── package.json
│           └── tsconfig.json
```

---

## Testing Strategy

### What to Test

**Test 1: Frontend + Cloud Backend**
- [ ] Start `ng serve` locally
- [ ] Set `API_URL` to cloud endpoint
- [ ] Browser: Open `http://localhost:4200`
- [ ] Console: Should show "API configured to: https://..."
- [ ] Call API: Data should display from cloud

**Test 2: Local Backend Solo**
- [ ] Start local backend: `npm run start:local`
- [ ] Browser: Visit `http://localhost:3000/health`
- [ ] Should see JSON: `{"status": "ok", ...}`
- [ ] Terminal: Should see startup logs and request logs

**Test 3: Frontend + Local Backend**
- [ ] Both services running
- [ ] Set `API_URL=http://localhost:3000`
- [ ] Browser: Open `http://localhost:4200`
- [ ] Console: Should show "API configured to: http://localhost:3000"
- [ ] Call API: Should get local data (sample projects, etc.)

**Test 4: Environment Switching**
- [ ] Change `API_URL` in `.env` to cloud endpoint
- [ ] Restart `ng serve`
- [ ] Verify cloud API is called
- [ ] Change `API_URL` back to local endpoint
- [ ] Restart `ng serve`
- [ ] Verify local API is called
- [ ] Confirm: **no code changes** needed

**Test 5: New Developer Setup**
- [ ] Give new developer `.env.example` file
- [ ] Have them follow setup guide
- [ ] Time how long setup takes (target: <30 minutes)
- [ ] Verify everything works without issues

### Tools for Testing

**Browser**:
- Open DevTools (F12)
- Network tab: Watch API calls
- Console: Watch logs and errors

**Curl**:
```bash
# Test cloud API
curl https://your-api.execute-api.us-east-1.amazonaws.com/dev/api/home

# Test local backend
curl http://localhost:3000/api/home
```

**Postman**:
- Import cloud API endpoints
- Create local environment with `localhost:3000`
- Switch between environments

---

## Deployment & CI/CD Implications

### What This Affects

**CI/CD Pipeline**:
- No changes to GitHub Actions
- Cloud deployment continues as before
- Local development is offline process

**Environment Variables**:
- Frontend `.env` is local only (not committed)
- `.env.example` shows what variables are needed
- Cloud deployment uses different environment configuration

**Secrets Management**:
- Local development uses no secrets
- Cloud deployment will use AWS Secrets Manager (future epic)

---

## Cost & Performance Implications

### Cost
- **No additional AWS costs**: Local development runs entirely on developer machine
- **Reduced costs**: Fewer cloud deployments (developers test locally first)

### Performance
- **Frontend**: Hot reload on `ng serve` is instant (<500ms)
- **Backend**: Restart with `ts-node-dev` is <2 seconds
- **Database**: In-memory mock is sub-millisecond
- **Network**: Local requests are <100ms vs 1-2 second cloud calls

**Result**: Developer iteration is 10-20x faster locally vs cloud

---

## Troubleshooting Guide

### Issue: `API_URL` not being read in Angular

**Symptom**: API endpoint shows wrong URL or undefined

**Solution**:
```bash
# 1. Verify .env file exists
ls -la src/frontend/.env

# 2. Check .env content
cat src/frontend/.env

# 3. Restart ng serve
# Kill terminal (Ctrl+C), run: ng serve

# 4. Check console in browser DevTools
# Should show API endpoint on load
```

### Issue: CORS error when calling cloud API

**Symptom**: Browser console shows "No 'Access-Control-Allow-Origin' header"

**Solution**:
- Cloud API already has CORS configured (from Epic 3)
- If error persists, verify API Gateway CORS is deployed
- Run: `cdktf deploy teamflow-api-dev`

### Issue: Local backend won't start

**Symptom**: Error on `npm run start:local`

**Solution**:
```bash
# 1. Check Node.js version
node --version  # Should be 18+

# 2. Clear node_modules
rm -rf node_modules package-lock.json
npm install

# 3. Check port 3000 is free
lsof -i :3000  # Kill process if needed

# 4. Check .env file
cat .env
```

### Issue: Angular can't reach local backend

**Symptom**: Network error in browser

**Solution**:
```bash
# 1. Verify backend is running
curl http://localhost:3000/health

# 2. Check .env has correct URL
cat src/frontend/.env
# Should be: API_URL=http://localhost:3000

# 3. Check no firewall blocking localhost

# 4. Restart ng serve
# Kill and restart: ng serve
```

### Issue: Changes to backend don't appear

**Symptom**: Code changes not reflected when calling API

**Solution**:
- `ts-node-dev` should auto-restart on file changes
- If not:
  ```bash
  # Restart manually
  Ctrl+C  # Stop backend
  npm run start:local  # Start again
  ```

### Issue: Sample data not showing

**Symptom**: Calls to `/api/projects` return empty array

**Solution**:
- Check local database initialization in `local-db.ts`
- Verify `seedData()` is being called in constructor
- Restart backend to reload sample data

---

## Security Notes

### Local Development Only

**These configurations are for LOCAL DEVELOPMENT ONLY**:
- ❌ CORS allowing all origins (`*`) - fine for local, will be restricted in production
- ❌ No authentication/authorization - add in future epic
- ❌ Sample data with no sensitive info - fine for local, production will have real data
- ❌ Logging all requests to console - fine for debug, will be restricted in production

### What's Missing (Future Epics)

- Authentication (JWT tokens) - Epic 5 or later
- Authorization (role-based access) - After authentication
- Input validation - Will be added to all endpoints
- Rate limiting - Production feature
- HTTPS in local - Use self-signed cert if needed (optional)

---

## API Contracts

### Endpoints Available Locally

Both local backend and cloud API should support the same endpoints:

**Health Check**:
```
GET /health
Response: {"status": "ok", "environment": "local|cloud", "timestamp": "..."}
```

**Home Endpoint** (from Epic 3):
```
GET /api/home
Response: {"message": "hello world", "source": "local backend|cloud"}
```

**List Projects** (new for local):
```
GET /api/projects
Response: {"success": true, "data": [...], "count": 2}
```

**Create Project**:
```
POST /api/projects
Body: {"name": "Project Name", "description": "..."}
Response: {"success": true, "data": {...}}
```

---

## Documentation Requirements

### Files to Create

1. **`SETUP_LOCAL_FRONTEND_CLOUD.md`**
   - Quick start for local Angular + cloud backend
   - 5 minute setup
   - Minimal steps

2. **`SETUP_LOCAL_FULL_STACK.md`**
   - Complete local environment setup
   - 20-30 minute setup
   - Includes local backend

3. **`ENVIRONMENT_CONFIGURATION.md`**
   - What each environment variable does
   - How to switch between environments
   - Troubleshooting

4. **`LOCAL_DEVELOPMENT_GUIDE.md`**
   - For each developer persona
   - Commands to use
   - Common workflows

---

## Success Criteria Validation

After implementing this technical specification, verify:

- [ ] Local Angular loads and runs on `localhost:4200`
- [ ] Angular app displays current API URL on load (console)
- [ ] `API_URL` environment variable controls backend endpoint
- [ ] Changing `API_URL` in `.env` switches between cloud and local without code changes
- [ ] Local backend starts with `npm run start:local`
- [ ] Local backend listens on `localhost:3000`
- [ ] `/health` endpoint returns success
- [ ] `/api/projects` returns sample data
- [ ] Local Angular + local backend integration works end-to-end
- [ ] No CORS errors in any configuration
- [ ] New developer can complete setup in <30 minutes following documentation

---

## Next Steps

1. **Implement Frontend Configuration** (Story 1)
   - Create environment files
   - Add API service
   - Update `.gitignore` for `.env`

2. **Create Local Backend** (Story 2-3)
   - Set up Express server
   - Initialize mock database with sample data
   - Create basic routes

3. **Integration Testing** (Story 4)
   - Test local frontend + cloud backend
   - Test local frontend + local backend
   - Test environment switching

4. **Documentation** (Story 6)
   - Create setup guides
   - Create troubleshooting guide
   - Test with new developer

5. **Automation** (Story 7, optional)
   - Create setup scripts (can be manual for MVP)
   - Create startup commands

---

## References

- **Epic Document**: [EPIC_4_CLOUD_LOCAL_INTEGRATION.md](../epics/EPIC_4_CLOUD_LOCAL_INTEGRATION.md)
- **Architecture**: [TECHNICAL_ARCHITECTURE_SERVERLESS.md](../../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)
- **CORS in API Gateway**: [AWS Documentation](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html)
- **Express.js**: [expressjs.com](https://expressjs.com/)
- **Environment Variables in Angular**: [Angular Docs](https://angular.io/guide/build#using-environment-specific-variables)
