# Story 4.4: Create Local Express.js Backend Server

**Story ID**: EPIC4-4  
**Epic**: EPIC-4 (Cloud + Local Integration)  
**Sprint**: SPRINT-3  
**Status**: 📋 TODO  
**Story Type**: Backend Infrastructure

---

## User Story

```
As a backend developer,
I want to run the TeamFlow API locally using Express.js,
so that I can develop and test backend features without AWS deployments.
```

---

## Requirements

### Express Server

1. **Listening on port 3000** - Standard development port
2. **CORS enabled** - Allow requests from localhost:4200 (Angular)
3. **Health check endpoint** - GET `/health` to verify server running
4. **Home endpoint** - GET `/api/home` for basic test
5. **Proper error handling** - 500 errors logged, not exposed
6. **Environment configuration** - Read from `.env` file

### Directory Structure

```
src/backend/local-dev/
├── src/
│   ├── index.ts              # Main Express app
│   ├── config.ts             # Environment configuration
│   └── routes/
│       └── health.ts         # Health check routes
├── .env.example              # Template
├── .env                       # Actual config (not tracked)
├── package.json              # Dependencies
├── tsconfig.json             # TypeScript config
└── README.md                 # Local backend documentation
```

---

## Acceptance Criteria

- [ ] Express.js server created and listens on port 3000
- [ ] Server starts with `npm run dev` command
- [ ] GET `/health` returns `{ status: "ok" }`
- [ ] GET `/api/home` returns `{ message: "hello from local backend" }`
- [ ] CORS configured for localhost:4200
- [ ] `.env` file configuration working
- [ ] Server can be stopped cleanly with Ctrl+C
- [ ] No hardcoded configuration values
- [ ] TypeScript compiles without errors
- [ ] Error middleware catches and logs errors

---

## Definition of Done

- [ ] Express server running on port 3000
- [ ] Health check responds
- [ ] Home endpoint responds
- [ ] CORS allows Angular requests
- [ ] Configuration via `.env`
- [ ] Ready for STORY 4.5 (Mock database)

---

## Technical Tasks

### Task 1: Create project structure

```bash
# Create directories
mkdir -p src/backend/local-dev/src/routes
mkdir -p src/backend/local-dev/src/utils

# Create empty files (we'll fill them next)
touch src/backend/local-dev/src/index.ts
touch src/backend/local-dev/src/config.ts
touch src/backend/local-dev/src/routes/health.ts
touch src/backend/local-dev/package.json
touch src/backend/local-dev/tsconfig.json
touch src/backend/local-dev/.env.example
```

**What to do**: Run the commands above in your terminal

---

### Task 2: Create `package.json`

**Location**: `src/backend/local-dev/package.json`

**Content**:
```json
{
  "name": "teamflow-local-backend",
  "version": "1.0.0",
  "description": "Local development backend for TeamFlow",
  "main": "dist/index.js",
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "lint": "eslint src/**/*.ts",
    "test": "jest"
  },
  "keywords": [
    "teamflow",
    "local",
    "development",
    "backend"
  ],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.0.3"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/node": "^18.0.0",
    "typescript": "^5.0.0",
    "ts-node-dev": "^2.0.0"
  }
}
```

**What to do**:
1. Open file: `src/backend/local-dev/package.json`
2. Copy content above
3. Save

---

### Task 3: Create `tsconfig.json`

**Location**: `src/backend/local-dev/tsconfig.json`

**Content**:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "moduleResolution": "node"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**What to do**:
1. Open file: `src/backend/local-dev/tsconfig.json`
2. Copy content above
3. Save

---

### Task 4: Create `.env.example`

**Location**: `src/backend/local-dev/.env.example`

**Content**:
```bash
# Local Backend Configuration

# Server port (default: 3000)
PORT=3000

# Node environment (development, production, test)
NODE_ENV=development

# Angular frontend URL (for CORS)
FRONTEND_URL=http://localhost:4200

# Log level (error, warn, info, debug)
LOG_LEVEL=debug
```

**What to do**:
1. Open file: `src/backend/local-dev/.env.example`
2. Copy content above
3. Save

---

### Task 5: Create `.env` (actual configuration)

**Location**: `src/backend/local-dev/.env`

**Content** (same as `.env.example` for now):
```bash
PORT=3000
NODE_ENV=development
FRONTEND_URL=http://localhost:4200
LOG_LEVEL=debug
```

**What to do**:
1. Open file: `src/backend/local-dev/.env`
2. Copy content above
3. Save
4. **Add to `.gitignore`** (so `.env` is not committed)

```bash
# In .gitignore, add:
src/backend/local-dev/.env
```

---

### Task 6: Create `config.ts`

**Location**: `src/backend/local-dev/src/config.ts`

**Content**:
```typescript
import dotenv from 'dotenv';
import path from 'path';

// Load .env file
dotenv.config({ path: path.join(__dirname, '../.env') });

/**
 * Application configuration from environment variables
 */
export const config = {
  // Server
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  
  // CORS
  frontendUrl: process.env.FRONTEND_URL || 'http://localhost:4200',
  
  // Logging
  logLevel: process.env.LOG_LEVEL || 'info',
  
  // Computed
  isDevelopment: process.env.NODE_ENV === 'development',
  isProduction: process.env.NODE_ENV === 'production',
};

/**
 * Validate configuration
 */
export function validateConfig(): void {
  if (!config.port || config.port < 1 || config.port > 65535) {
    throw new Error('Invalid PORT in .env (must be 1-65535)');
  }
  
  if (!config.frontendUrl) {
    throw new Error('FRONTEND_URL not set in .env');
  }
  
  console.log('✅ Configuration loaded:');
  console.log(`   Port: ${config.port}`);
  console.log(`   Environment: ${config.nodeEnv}`);
  console.log(`   Frontend URL: ${config.frontendUrl}`);
}
```

**What to do**:
1. Open file: `src/backend/local-dev/src/config.ts`
2. Copy content above
3. Save

---

### Task 7: Create health routes

**Location**: `src/backend/local-dev/src/routes/health.ts`

**Content**:
```typescript
import { Router, Request, Response } from 'express';

const router = Router();

/**
 * GET /health
 * Simple health check endpoint
 */
router.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
});

/**
 * GET /api/home
 * Home endpoint - verify API is running
 */
router.get('/api/home', (req: Request, res: Response) => {
  res.json({
    message: 'hello from local backend',
    source: 'local',
    timestamp: new Date().toISOString(),
  });
});

export default router;
```

**What to do**:
1. Open file: `src/backend/local-dev/src/routes/health.ts`
2. Copy content above
3. Save

---

### Task 8: Create Express app

**Location**: `src/backend/local-dev/src/index.ts`

**Content**:
```typescript
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { config, validateConfig } from './config';
import healthRoutes from './routes/health';

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
  console.log(`\nTry these endpoints:`);
  console.log(`  - http://localhost:${config.port}/health`);
  console.log(`  - http://localhost:${config.port}/api/home`);
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
1. Open file: `src/backend/local-dev/src/index.ts`
2. Copy content above
3. Save

---

### Task 9: Install dependencies

```bash
# Navigate to local backend directory
cd src/backend/local-dev

# Install npm dependencies
npm install

# Expected output:
# added 100+ packages in 30s
```

**What to do**: Run the command above

---

## Verification Steps

### Step 1: Verify file structure

```bash
# Check all files created
ls -la src/backend/local-dev/

# Should show:
# - src/
# - package.json
# - tsconfig.json
# - .env.example
# - .env
# - node_modules/ (after npm install)
```

### Step 2: Start the server

```bash
# Make sure you're in src/backend/local-dev/
cd src/backend/local-dev

# Start with npm run dev
npm run dev

# Expected output:
# ✅ Configuration loaded:
#    Port: 3000
#    Environment: development
#    Frontend URL: http://localhost:4200
# 🚀 Local Backend Server Started
# 📡 http://localhost:3000
# ✅ CORS enabled for http://localhost:4200
# Try these endpoints:
#   - http://localhost:3000/health
#   - http://localhost:3000/api/home
```

### Step 3: Test endpoints

**In another terminal**:
```bash
# Test health endpoint
curl http://localhost:3000/health

# Expected response:
# {"status":"ok","timestamp":"2026-01-25T..."}

# Test home endpoint
curl http://localhost:3000/api/home

# Expected response:
# {"message":"hello from local backend","source":"local","timestamp":"2026-01-25T..."}
```

### Step 4: Test from browser

1. Open http://localhost:3000/health
2. Should see JSON response
3. Check browser Network tab (F12)
4. Should show 200 status

### Step 5: Test CORS

```bash
# With server running, in another terminal:
# Test CORS from Angular frontend URL
curl -H "Origin: http://localhost:4200" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS http://localhost:3000/health -v

# Look for response headers:
# Access-Control-Allow-Origin: http://localhost:4200
# Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
```

### Step 6: Stop the server

```bash
# Press Ctrl+C in the terminal running npm run dev

# Expected output:
# ^C
# 🛑 Shutting down...
# ✅ Server stopped
```

---

## Notes

**Key Points**:
- Express server handles HTTP requests
- CORS allows Angular to make requests
- Configuration from `.env` file
- Logging shows all requests
- Error handling logs errors but doesn't expose them

**Future Enhancements**:
- Add authentication middleware (JWT)
- Add rate limiting
- Add request validation
- Add database connection
- Add API versioning

**Dependencies**:
- None (standalone server for MVP)
- Can add database in Story 4.5

**Estimated Time**: 6-8 hours

---

## Completion Checklist

- [ ] Express server created
- [ ] Listening on port 3000
- [ ] Health check endpoint responds
- [ ] Home endpoint responds
- [ ] CORS configured for localhost:4200
- [ ] `.env` configuration working
- [ ] Can start with `npm run dev`
- [ ] Can stop with Ctrl+C
- [ ] Ready for STORY 4.5 (Mock database)

---

**Last Updated**: 2026-01-25
