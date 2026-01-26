# Story 4.5: Implement Mock Database with Sample Data

**Story ID**: EPIC4-5  
**Epic**: EPIC-4 (Cloud + Local Integration)  
**Sprint**: SPRINT-3  
**Status**: 📋 TODO  
**Story Type**: Backend Infrastructure

---

## User Story

```
As a backend developer,
I want an in-memory mock database with sample data,
so that I can test API endpoints without a real database.
```

---

## Requirements

### Mock Database

1. **In-memory storage** - JavaScript Map for projects and tasks
2. **Sample data** - At least 3 projects and 5+ tasks loaded on startup
3. **CRUD operations** - Create, Read, Update, Delete functionality
4. **Data persistence** - Data survives while server running (lost on restart)
5. **Type-safe** - Full TypeScript support

### Sample Data

**Projects**:
- "Website Redesign" - With description
- "Mobile App MVP" - With description
- "Documentation Portal" - With description

**Tasks per project**:
- 2-3 tasks per project (at least 5 total)
- Mix of statuses: todo, in_progress, done
- Some with assignees, some without

---

## Acceptance Criteria

- [ ] In-memory database module created
- [ ] Database loads sample data on startup
- [ ] Get all projects endpoint returns sample data
- [ ] Get single project endpoint works
- [ ] Create project endpoint works
- [ ] Update project endpoint works
- [ ] Delete project endpoint works
- [ ] Get all tasks endpoint works
- [ ] Create task endpoint works
- [ ] Update task endpoint works
- [ ] Delete task endpoint works
- [ ] Data is lost on server restart (expected for MVP)

---

## Definition of Done

- [ ] Mock database with sample projects and tasks
- [ ] CRUD endpoints working for projects and tasks
- [ ] Frontend can fetch and display data
- [ ] Ready for STORY 4.6 (Environment configuration)

---

## Technical Tasks

### Task 1: Create database module

**Location**: `src/backend/local-dev/src/database/in-memory-db.ts`

**Content**:
```typescript
/**
 * In-memory mock database for local development
 * Data is stored in memory and lost on server restart
 */

import { v4 as uuidv4 } from 'uuid';

/**
 * Project entity
 */
export interface Project {
  id: string;
  name: string;
  description?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * Task entity
 */
export interface Task {
  id: string;
  projectId: string;
  title: string;
  description?: string;
  status: 'todo' | 'in_progress' | 'done';
  priority?: 'low' | 'medium' | 'high';
  assigneeId?: string;
  createdAt: string;
  updatedAt: string;
}

/**
 * In-memory database
 */
class InMemoryDatabase {
  private projects: Map<string, Project> = new Map();
  private tasks: Map<string, Task> = new Map();

  constructor() {
    this.seed();
  }

  /**
   * Load sample data
   */
  private seed(): void {
    // Sample projects
    const project1: Project = {
      id: uuidv4(),
      name: 'Website Redesign',
      description: 'Redesign the main website with modern UI/UX',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const project2: Project = {
      id: uuidv4(),
      name: 'Mobile App MVP',
      description: 'Build minimum viable product for iOS and Android',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const project3: Project = {
      id: uuidv4(),
      name: 'Documentation Portal',
      description: 'Create comprehensive API and user documentation',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    // Store projects
    this.projects.set(project1.id, project1);
    this.projects.set(project2.id, project2);
    this.projects.set(project3.id, project3);

    // Sample tasks
    const tasks: Task[] = [
      // Website Redesign tasks
      {
        id: uuidv4(),
        projectId: project1.id,
        title: 'Design homepage mockup',
        description: 'Create high-fidelity mockup of homepage',
        status: 'in_progress',
        priority: 'high',
        assigneeId: 'user1',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
      {
        id: uuidv4(),
        projectId: project1.id,
        title: 'Implement responsive layout',
        description: 'Make website mobile-friendly',
        status: 'todo',
        priority: 'high',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },

      // Mobile App MVP tasks
      {
        id: uuidv4(),
        projectId: project2.id,
        title: 'Setup development environment',
        description: 'Install React Native and configure builds',
        status: 'done',
        priority: 'high',
        assigneeId: 'user2',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
      {
        id: uuidv4(),
        projectId: project2.id,
        title: 'Create authentication screen',
        description: 'Login and signup screens',
        status: 'in_progress',
        priority: 'high',
        assigneeId: 'user1',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
      {
        id: uuidv4(),
        projectId: project2.id,
        title: 'Build dashboard',
        description: 'Main app dashboard with task list',
        status: 'todo',
        priority: 'medium',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },

      // Documentation Portal tasks
      {
        id: uuidv4(),
        projectId: project3.id,
        title: 'Write API documentation',
        description: 'Document all API endpoints',
        status: 'in_progress',
        priority: 'high',
        assigneeId: 'user3',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      },
    ];

    // Store tasks
    tasks.forEach(task => {
      this.tasks.set(task.id, task);
    });

    console.log('📊 Sample data loaded:');
    console.log(`   ${this.projects.size} projects`);
    console.log(`   ${this.tasks.size} tasks`);
  }

  // === PROJECTS ===

  /**
   * Get all projects
   */
  getAllProjects(): Project[] {
    return Array.from(this.projects.values());
  }

  /**
   * Get single project by ID
   */
  getProjectById(id: string): Project | null {
    return this.projects.get(id) || null;
  }

  /**
   * Create new project
   */
  createProject(data: Omit<Project, 'id' | 'createdAt' | 'updatedAt'>): Project {
    const project: Project = {
      id: uuidv4(),
      ...data,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    this.projects.set(project.id, project);
    return project;
  }

  /**
   * Update project
   */
  updateProject(id: string, data: Partial<Omit<Project, 'id' | 'createdAt'>>): Project | null {
    const project = this.projects.get(id);
    if (!project) return null;

    const updated: Project = {
      ...project,
      ...data,
      updatedAt: new Date().toISOString(),
    };
    this.projects.set(id, updated);
    return updated;
  }

  /**
   * Delete project (and its tasks)
   */
  deleteProject(id: string): boolean {
    if (!this.projects.has(id)) return false;

    // Delete project
    this.projects.delete(id);

    // Delete associated tasks
    Array.from(this.tasks.values())
      .filter(task => task.projectId === id)
      .forEach(task => this.tasks.delete(task.id));

    return true;
  }

  // === TASKS ===

  /**
   * Get all tasks
   */
  getAllTasks(): Task[] {
    return Array.from(this.tasks.values());
  }

  /**
   * Get tasks by project
   */
  getTasksByProjectId(projectId: string): Task[] {
    return Array.from(this.tasks.values())
      .filter(task => task.projectId === projectId);
  }

  /**
   * Get single task by ID
   */
  getTaskById(id: string): Task | null {
    return this.tasks.get(id) || null;
  }

  /**
   * Create new task
   */
  createTask(data: Omit<Task, 'id' | 'createdAt' | 'updatedAt'>): Task {
    const task: Task = {
      id: uuidv4(),
      ...data,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    this.tasks.set(task.id, task);
    return task;
  }

  /**
   * Update task
   */
  updateTask(id: string, data: Partial<Omit<Task, 'id' | 'createdAt'>>): Task | null {
    const task = this.tasks.get(id);
    if (!task) return null;

    const updated: Task = {
      ...task,
      ...data,
      updatedAt: new Date().toISOString(),
    };
    this.tasks.set(id, updated);
    return updated;
  }

  /**
   * Delete task
   */
  deleteTask(id: string): boolean {
    if (!this.tasks.has(id)) return false;
    this.tasks.delete(id);
    return true;
  }

  // === DEBUGGING ===

  /**
   * Get database stats
   */
  getStats() {
    return {
      projects: this.projects.size,
      tasks: this.tasks.size,
      totalItems: this.projects.size + this.tasks.size,
    };
  }

  /**
   * Clear all data (for testing)
   */
  reset(): void {
    this.projects.clear();
    this.tasks.clear();
    console.log('🧹 Database reset');
  }
}

// Singleton instance
export const db = new InMemoryDatabase();
```

**What to do**:
1. Create directory: `mkdir -p src/backend/local-dev/src/database`
2. Create file: `src/backend/local-dev/src/database/in-memory-db.ts`
3. Copy content above
4. Save

---

### Task 2: Install UUID package

```bash
# Navigate to local backend directory
cd src/backend/local-dev

# Install uuid package
npm install uuid
npm install --save-dev @types/uuid

# Expected output:
# added 2 packages
```

**What to do**: Run the commands above

---

### Task 3: Create projects routes

**Location**: `src/backend/local-dev/src/routes/projects.ts`

**Content**:
```typescript
import { Router, Request, Response } from 'express';
import { db } from '../database/in-memory-db';

const router = Router();

/**
 * GET /api/projects
 * Get all projects
 */
router.get('/api/projects', (req: Request, res: Response) => {
  try {
    const projects = db.getAllProjects();
    res.json({
      success: true,
      data: projects,
      count: projects.length,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/projects/:id
 * Get single project
 */
router.get('/api/projects/:id', (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const project = db.getProjectById(id);

    if (!project) {
      return res.status(404).json({
        success: false,
        error: 'Project not found',
      });
    }

    res.json({
      success: true,
      data: project,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/projects
 * Create new project
 */
router.post('/api/projects', (req: Request, res: Response) => {
  try {
    const { name, description } = req.body;

    // Validation
    if (!name || typeof name !== 'string' || name.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'Project name is required',
      });
    }

    const project = db.createProject({
      name: name.trim(),
      description: description?.trim() || undefined,
    });

    res.status(201).json({
      success: true,
      data: project,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * PUT /api/projects/:id
 * Update project
 */
router.put('/api/projects/:id', (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { name, description } = req.body;

    // Check if project exists
    const project = db.getProjectById(id);
    if (!project) {
      return res.status(404).json({
        success: false,
        error: 'Project not found',
      });
    }

    // Update
    const updated = db.updateProject(id, {
      name: name || undefined,
      description: description || undefined,
    });

    res.json({
      success: true,
      data: updated,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * DELETE /api/projects/:id
 * Delete project
 */
router.delete('/api/projects/:id', (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const deleted = db.deleteProject(id);

    if (!deleted) {
      return res.status(404).json({
        success: false,
        error: 'Project not found',
      });
    }

    res.json({
      success: true,
      message: 'Project deleted',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

export default router;
```

**What to do**:
1. Create file: `src/backend/local-dev/src/routes/projects.ts`
2. Copy content above
3. Save

---

### Task 4: Create tasks routes

**Location**: `src/backend/local-dev/src/routes/tasks.ts`

**Content**:
```typescript
import { Router, Request, Response } from 'express';
import { db } from '../database/in-memory-db';

const router = Router();

/**
 * GET /api/tasks
 * Get all tasks
 */
router.get('/api/tasks', (req: Request, res: Response) => {
  try {
    const tasks = db.getAllTasks();
    res.json({
      success: true,
      data: tasks,
      count: tasks.length,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/projects/:projectId/tasks
 * Get tasks by project
 */
router.get('/api/projects/:projectId/tasks', (req: Request, res: Response) => {
  try {
    const { projectId } = req.params;

    // Verify project exists
    const project = db.getProjectById(projectId);
    if (!project) {
      return res.status(404).json({
        success: false,
        error: 'Project not found',
      });
    }

    const tasks = db.getTasksByProjectId(projectId);
    res.json({
      success: true,
      data: tasks,
      count: tasks.length,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * GET /api/tasks/:id
 * Get single task
 */
router.get('/api/tasks/:id', (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const task = db.getTaskById(id);

    if (!task) {
      return res.status(404).json({
        success: false,
        error: 'Task not found',
      });
    }

    res.json({
      success: true,
      data: task,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * POST /api/projects/:projectId/tasks
 * Create new task
 */
router.post('/api/projects/:projectId/tasks', (req: Request, res: Response) => {
  try {
    const { projectId } = req.params;
    const { title, description, status, priority, assigneeId } = req.body;

    // Verify project exists
    const project = db.getProjectById(projectId);
    if (!project) {
      return res.status(404).json({
        success: false,
        error: 'Project not found',
      });
    }

    // Validation
    if (!title || typeof title !== 'string' || title.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'Task title is required',
      });
    }

    const task = db.createTask({
      projectId,
      title: title.trim(),
      description: description?.trim() || undefined,
      status: status || 'todo',
      priority: priority || undefined,
      assigneeId: assigneeId || undefined,
    });

    res.status(201).json({
      success: true,
      data: task,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * PUT /api/tasks/:id
 * Update task
 */
router.put('/api/tasks/:id', (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { title, description, status, priority, assigneeId } = req.body;

    // Check if task exists
    const task = db.getTaskById(id);
    if (!task) {
      return res.status(404).json({
        success: false,
        error: 'Task not found',
      });
    }

    // Update
    const updated = db.updateTask(id, {
      title: title || undefined,
      description: description || undefined,
      status: status || undefined,
      priority: priority || undefined,
      assigneeId: assigneeId || undefined,
    });

    res.json({
      success: true,
      data: updated,
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * DELETE /api/tasks/:id
 * Delete task
 */
router.delete('/api/tasks/:id', (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const deleted = db.deleteTask(id);

    if (!deleted) {
      return res.status(404).json({
        success: false,
        error: 'Task not found',
      });
    }

    res.json({
      success: true,
      message: 'Task deleted',
    });
  } catch (error: any) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

export default router;
```

**What to do**:
1. Create file: `src/backend/local-dev/src/routes/tasks.ts`
2. Copy content above
3. Save

---

### Task 5: Update Express app to use new routes

**Update**: `src/backend/local-dev/src/index.ts`

Add these imports at the top:
```typescript
import projectRoutes from './routes/projects';
import taskRoutes from './routes/tasks';
```

Add this in the ROUTES section (after health routes):
```typescript
// Project routes
app.use('/', projectRoutes);

// Task routes
app.use('/', taskRoutes);
```

**Complete updated file**:
```typescript
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { config, validateConfig } from './config';
import healthRoutes from './routes/health';
import projectRoutes from './routes/projects';
import taskRoutes from './routes/tasks';

// Validate configuration
try {
  validateConfig();
} catch (error) {
  console.error('❌ Configuration error:', error);
  process.exit(1);
}

// Create Express app
const app: Express = express();

// === MIDDLEWARE ===

// CORS - Allow requests from Angular frontend
app.use(cors({
  origin: config.frontendUrl,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// JSON parser
app.use(express.json());

// Request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  
  // Log response when sent
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${req.method}] ${req.path} - ${res.statusCode} (${duration}ms)`);
  });
  
  next();
});

// === ROUTES ===

// Health check routes
app.use('/', healthRoutes);

// Project routes
app.use('/', projectRoutes);

// Task routes
app.use('/', taskRoutes);

// === ERROR HANDLING ===

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    method: req.method,
  });
});

// Global error handler
app.use((error: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('❌ Error:', error.message);
  
  res.status(500).json({
    error: 'Internal Server Error',
    message: config.isDevelopment ? error.message : 'An error occurred',
  });
});

// === START SERVER ===

const server = app.listen(config.port, () => {
  console.log(`\n🚀 Local Backend Server Started`);
  console.log(`📡 http://localhost:${config.port}`);
  console.log(`✅ CORS enabled for ${config.frontendUrl}`);
  console.log(`\nAvailable endpoints:`);
  console.log(`  Health:`);
  console.log(`    - GET http://localhost:${config.port}/health`);
  console.log(`    - GET http://localhost:${config.port}/api/home`);
  console.log(`  Projects:`);
  console.log(`    - GET http://localhost:${config.port}/api/projects`);
  console.log(`    - GET http://localhost:${config.port}/api/projects/{id}`);
  console.log(`    - POST http://localhost:${config.port}/api/projects`);
  console.log(`    - PUT http://localhost:${config.port}/api/projects/{id}`);
  console.log(`    - DELETE http://localhost:${config.port}/api/projects/{id}`);
  console.log(`  Tasks:`);
  console.log(`    - GET http://localhost:${config.port}/api/tasks`);
  console.log(`    - GET http://localhost:${config.port}/api/projects/{projectId}/tasks`);
  console.log(`    - GET http://localhost:${config.port}/api/tasks/{id}`);
  console.log(`    - POST http://localhost:${config.port}/api/projects/{projectId}/tasks`);
  console.log(`    - PUT http://localhost:${config.port}/api/tasks/{id}`);
  console.log(`    - DELETE http://localhost:${config.port}/api/tasks/{id}`);
  console.log(`\nPress Ctrl+C to stop\n`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down...');
  server.close(() => {
    console.log('✅ Server stopped');
    process.exit(0);
  });
});

export default app;
```

**What to do**:
1. Open `src/backend/local-dev/src/index.ts`
2. Add imports at top
3. Add route usage in ROUTES section
4. Save

---

## Verification Steps

### Step 1: Start server

```bash
cd src/backend/local-dev
npm run dev

# Should see sample data loaded:
# 📊 Sample data loaded:
#    3 projects
#    6 tasks
```

### Step 2: Test projects endpoint

```bash
# In another terminal
curl http://localhost:3000/api/projects | jq

# Should see:
# {
#   "success": true,
#   "data": [
#     { "id": "...", "name": "Website Redesign", ... },
#     { "id": "...", "name": "Mobile App MVP", ... },
#     { "id": "...", "name": "Documentation Portal", ... }
#   ],
#   "count": 3
# }
```

### Step 3: Test tasks endpoint

```bash
curl http://localhost:3000/api/tasks | jq

# Should show 6 tasks with mixed statuses
```

### Step 4: Test create project

```bash
curl -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"New Project","description":"Test"}' | jq

# Should return created project with new ID
```

### Step 5: Test from Angular

1. If you have the Angular app set up with API service
2. Start Angular on localhost:4200
3. Make API call to `GET /api/projects`
4. Should work without CORS errors

---

## Notes

**Key Points**:
- Mock database uses JavaScript Map (in-memory)
- Data is lost on server restart (acceptable for MVP)
- Sample data has realistic project/task structure
- Full CRUD operations for both projects and tasks
- Validation for required fields

**Future Enhancements**:
- Persist data to JSON file (survives restart)
- Add database file export/import
- Add filtering and search
- Add pagination
- Add authentication checks

**Dependencies**:
- uuid package (for generating unique IDs)
- Requires STORY 4.4 (Express server)

**Estimated Time**: 4-6 hours

---

## Completion Checklist

- [ ] In-memory database module created
- [ ] Sample data loaded on startup
- [ ] Projects routes (GET all, GET one, POST, PUT, DELETE)
- [ ] Tasks routes (GET all, GET by project, POST, PUT, DELETE)
- [ ] CORS allows Angular requests
- [ ] Frontend can fetch projects and tasks
- [ ] Ready for STORY 4.6 (Environment config)

---

**Last Updated**: 2026-01-25
