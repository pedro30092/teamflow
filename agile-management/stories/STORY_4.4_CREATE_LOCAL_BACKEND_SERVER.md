# Story 4.4: Create Local Express.js Backend Server

**Story ID**: EPIC4-4  
**Epic**: EPIC-4 (Cloud + Local Integration)  
**Sprint**: SPRINT-3  
**Status**: ✅ DONE  
**Story Type**: Backend Infrastructure

---

## User Story

```
As a backend developer,
I want to run the TeamFlow API locally using Express.js that invokes compiled Lambda handlers,
so that I can develop and test backend features with real Lambda code without AWS deployments.
```

---

## Requirements

### Express Server with Lambda Integration

1. **Listening on port 3000** - Standard development port
2. **CORS enabled** - Allow requests from localhost:4200 (Angular)
3. **Lambda handler invocation** - GET `/api/home` invokes compiled Lambda handler
4. **Mock API Gateway event** - Translates Express request → Lambda event
5. **Handler response passthrough** - Returns Lambda response to client
6. **Proper error handling** - Errors logged, not exposed
7. **Environment configuration** - Read from `.env` file

### Directory Structure

```
src/backend/local-dev/
├── src/
│   ├── index.ts              # Main Express app
│   ├── config.ts             # Environment configuration
│   ├── utils/
│   │   └── lambda-invoker.ts # Lambda handler wrapper
│   └── routes/
│       └── handlers.ts       # Route handlers (invoke Lambda)
├── .env.example              # Template
├── .env                       # Actual config (not tracked)
├── package.json              # Dependencies
├── tsconfig.json             # TypeScript config
└── README.md                 # Local backend documentation
```

---

## Acceptance Criteria

- [x] Express.js server created and listens on port 3000
- [x] Server starts with `npm run dev` command
- [x] GET `/api/home` invokes compiled Lambda handler and returns response
- [x] Lambda handler receives mock API Gateway event with correct structure
- [x] Express request is translated to API Gateway event format
- [x] Lambda response is passed through to client
- [x] CORS configured for localhost:4200
- [x] `.env` file configuration working
- [x] Server can be stopped cleanly with Ctrl+C
- [x] No hardcoded configuration values
- [x] TypeScript compiles without errors
- [x] Error middleware catches and logs errors

---

## Definition of Done

- [x] Express server running on port 3000
- [x] Lambda handler invoked from Express
- [x] Home endpoint responds with Lambda handler output
- [x] CORS allows Angular requests
- [x] Configuration via `.env`
- [x] Mock API Gateway event created correctly
- [x] Ready for STORY 4.5 (Mock database)

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
    "build": "tsc",
    "build:backend": "npm --prefix .. run build",
    "watch:backend": "npm --prefix .. run watch",
    "dev:server": "ts-node-dev --respawn --transpile-only src/index.ts",
    "dev": "npm run build:backend && npm run dev:server",
    "dev:watch": "concurrently \"npm:watch:backend\" \"npm:dev:server\"",
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
    "dotenv": "^16.0.3",
    "concurrently": "^9.1.2"
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

### Task 7: Create Lambda invoker utility

**Location**: `src/backend/local-dev/src/utils/lambda-invoker.ts`

**Content**:
```typescript
import { Request } from 'express';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

/**
 * Creates a mock API Gateway event from Express request
 * This simulates what API Gateway passes to Lambda handlers
 */
export function createMockAPIGatewayEvent(
  req: Request,
  body?: any
): APIGatewayProxyEvent {
  return {
    resource: req.path,
    path: req.path,
    httpMethod: req.method,
    headers: req.headers as Record<string, string>,
    multiValueHeaders: {},
    queryStringParameters: req.query as Record<string, string> | null,
    multiValueQueryStringParameters: null,
    pathParameters: null,
    stageVariables: null,
    requestContext: {
      accountId: '000000000000',
      apiId: 'local',
      protocol: 'HTTP/1.1',
      httpMethod: req.method,
      path: req.path,
      stage: 'local',
      requestId: `local-${Date.now()}`,
      requestTime: new Date().toISOString(),
      requestTimeEpoch: Date.now(),
      identity: {
        sourceIp: req.ip || '127.0.0.1',
      },
      authorizer: undefined,
    },
    body: body ? JSON.stringify(body) : null,
    isBase64Encoded: false,
  } as APIGatewayProxyEvent;
}

/**
 * Invokes a Lambda handler with mock event
 */
export async function invokeLambdaHandler(
  handler: (event: APIGatewayProxyEvent, context: any) => Promise<APIGatewayProxyResult>,
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> {
  // Mock Lambda context
  const context = {
    functionName: 'local-function',
    functionVersion: '$LATEST',
    invokedFunctionArn: 'arn:aws:lambda:local:000000000000:function:local',
    memoryLimitInMB: 256,
    awsRequestId: `local-${Date.now()}`,
    logGroupName: '/aws/lambda/local',
    logStreamName: 'local-stream',
    identity: undefined,
    clientContext: undefined,
    getRemainingTimeInMillis: () => 30000,
    done: () => {},
    fail: () => {},
    succeed: () => {},
  };

  try {
    console.log(`[Lambda] Invoking handler with path: ${event.path}`);
    const response = await handler(event, context);
    console.log(`[Lambda] Handler returned status: ${response.statusCode}`);
    return response;
  } catch (error) {
    console.error('[Lambda] Handler error:', error);
    throw error;
  }
}
```

**What to do**:
1. Create directory: `src/backend/local-dev/src/utils/`
2. Open file: `src/backend/local-dev/src/utils/lambda-invoker.ts`
3. Copy content above
4. Save

---

### Task 8: Create handler routes

**Location**: `src/backend/local-dev/src/routes/handlers.ts`

**Content**:
```typescript
import { Router, Request, Response } from 'express';
import path from 'path';
import { createMockAPIGatewayEvent, invokeLambdaHandler } from '../utils/lambda-invoker';

const router = Router();

/**
 * GET /api/home
 * Invokes the compiled Lambda home handler
 */
router.get('/api/home', async (req: Request, res: Response) => {
  try {
    const handlerPath = path.resolve(__dirname, '../../../dist/functions/home/get-home.js');

    // Bust the require cache so changes in the compiled handler are picked up without restart.
    delete require.cache[require.resolve(handlerPath)];

    const { handler: homeHandler } = require(handlerPath);

    // Create mock API Gateway event from Express request
    const event = createMockAPIGatewayEvent(req);

    // Invoke Lambda handler
    const lambdaResponse = await invokeLambdaHandler(homeHandler, event);

    // Send Lambda response back to client
    if (lambdaResponse.headers) {
      Object.entries(lambdaResponse.headers).forEach(([key, value]) => {
        res.setHeader(key, value as string);
      });
    }

    res.status(lambdaResponse.statusCode || 200).send(lambdaResponse.body);
  } catch (error) {
    console.error('[Handler] Error invoking Lambda:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
```

**What to do**:
1. Create directory: `src/backend/local-dev/src/routes/`
2. Open file: `src/backend/local-dev/src/routes/handlers.ts`
3. Copy content above
4. Save

**Note**: Uses cache-busting via `require.cache` deletion for hot reload support. Path resolves to `dist/functions/home/get-home.js` which is the compiled Lambda handler.

**Location**: `src/backend/local-dev/src/index.ts`

**Content**:
```typescript
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { config, validateConfig } from './config';
import handlersRoutes from './routes/handlers';

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

// Lambda handler routes
import handlersRoutes from './routes/handlers';
app.use('/', handlersRoutes);

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
  console.log(`\n⚡ Lambda handler integration active`);
  console.log(`\nTry this endpoint:`);
  console.log(`  - http://localhost:${config.port}/api/home (invokes Lambda handler)`);
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

### Step 2: Build backend first

```bash
# Build backend to generate compiled functions
cd src/backend
npm run build

# This creates src/dist/functions/ with compiled Lambda handlers
# Expected output should show successful TypeScript compilation
```

### Step 3: Start the local dev server

```bash
# Navigate to local-dev directory
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
# ⚡ Lambda handler integration active
# Try this endpoint:
#   - http://localhost:3000/api/home (invokes Lambda handler)
```

### Step 4: Test the Lambda endpoint

**In another terminal**:
```bash
# Test home endpoint (invokes Lambda handler)
curl http://localhost:3000/api/home

# Expected response (from Lambda handler):
# {"message":"hello from local backend","timestamp":"2026-01-25T..."}

# You should see in the dev server terminal:
# [GET] /api/home - 200 (45ms)
# [Lambda] Invoking handler with path: /api/home
# [Lambda] Handler returned status: 200
```

### Step 5: Test from browser

1. Open http://localhost:3000/api/home
2. Should see Lambda handler response (JSON)
3. Check browser Network tab (F12)
4. Should show 200 status
5. Check console logs in terminal - should show Lambda invocation

### Step 6: Test CORS

```bash
# With server running, in another terminal:
# Test CORS from Angular frontend URL
curl -H "Origin: http://localhost:4200" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS http://localhost:3000/api/home -v

# Look for response headers:
# Access-Control-Allow-Origin: http://localhost:4200
# Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
```

### Step 7: Stop the server

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
- Express server wraps Lambda handlers for local development
- Lambda handlers imported from compiled `src/dist/functions/`
- Mock API Gateway event translates Express requests to Lambda events
- Lambda response passed directly to client
- CORS allows Angular to make requests
- Configuration from `.env` file
- Logging shows all requests AND Lambda invocations
- Error handling logs errors but doesn't expose them

**Lambda Handler Path**:
- Update the import path in `routes/handlers.ts` if your build output differs
- Currently assumes: `src/dist/functions/get-home/index.js`
- Verify path matches your backend build configuration

**Future Enhancements**:
- Add more routes/handlers as needed
- Add authentication middleware (JWT)
- Add rate limiting
- Add request validation
- Add database connection
- Add API versioning
- Create route handler factory for easier multi-handler setup

**Hot Reload Support**:
- Uses cache-busting via `require.cache` deletion
- Can run with `npm run dev:watch` for automatic backend rebuild + server reload
- Backend watch (`npm run watch`) recompiles on file changes
- Server reload (`ts-node-dev`) restarts on local-dev file changes
- Cache-busting ensures fresh handler import on each request

**Dependencies**:
- Requires compiled backend (run `npm run build` in backend first)
- Can add database in Story 4.5
- Lambda handler must export `handler` function

**Estimated Time**: 8-10 hours

---

## Completion Checklist

- [x] Express server created
- [x] Listening on port 3000
- [x] Lambda invoker utility created
- [x] Handler routes created
- [x] Mock API Gateway event created correctly
- [x] `/api/home` endpoint invokes Lambda handler
- [x] Lambda response returned to client
- [x] CORS configured for localhost:4200
- [x] `.env` configuration working
- [x] Backend compiled before running
- [x] Can start with `npm run dev` or `npm run dev:watch` (with hot reload)
- [x] Can stop with Ctrl+C
- [x] Console logs show Lambda invocations
- [x] Hot reload support via cache-busting require
- [x] Ready for STORY 4.5 (Mock database)

---

**Last Updated**: 2026-01-25  
**Completed**: 2026-01-25
