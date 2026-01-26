# Story 4.6: Create Configuration System for Backend

**Story ID**: EPIC4-6  
**Epic**: EPIC-4 (Cloud + Local Integration)  
**Sprint**: SPRINT-3  
**Status**: 📋 TODO  
**Story Type**: Backend Infrastructure

---

## User Story

```
As a developer,
I want a unified configuration system for the local backend,
so that I can easily switch between different environments without code changes.
```

---

## Requirements

### Configuration System

1. **Environment file (.env)** - Configuration values for local development
2. **Configuration module** - Loads and validates `.env` values
3. **Type-safe exports** - TypeScript config object with all settings
4. **Validation** - Ensure required values are present and valid
5. **Logging** - Show loaded configuration on startup

### Configuration Values

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `FRONTEND_URL` - Angular frontend URL for CORS
- `LOG_LEVEL` - Logging level (debug/info/warn/error)
- `DATABASE_TYPE` - Type of database (in-memory/local/cloud) - for future use

---

## Acceptance Criteria

- [ ] `.env` file loads successfully on startup
- [ ] Configuration values available in config object
- [ ] Missing required values show error message
- [ ] Invalid values (port out of range) show error
- [ ] Configuration logged to console on startup
- [ ] `.env` file is not tracked by git (.gitignore)
- [ ] `.env.example` template exists
- [ ] Can change configuration by editing `.env`
- [ ] Server respects configuration values
- [ ] Easy to add new configuration values

---

## Definition of Done

- [ ] Configuration system working
- [ ] `.env.example` template complete
- [ ] `.env` properly ignored by git
- [ ] Configuration validated on startup
- [ ] Ready for STORY 4.7 (Documentation)

---

## Technical Tasks

### Task 1: Update `.env.example` with all variables

**Location**: `src/backend/local-dev/.env.example`

**Content**:
```bash
# Local Backend Configuration
# 
# Copy this file to .env and fill in your values
# .env is not tracked by git

# ===== Server Configuration =====

# Port to listen on (default: 3000)
# Range: 1-65535
PORT=3000

# Node environment
# Options: development, production, test
NODE_ENV=development

# ===== CORS Configuration =====

# Angular frontend URL (for CORS)
# Used to allow requests from frontend
# Development: http://localhost:4200
# Production: https://your-domain.com
FRONTEND_URL=http://localhost:4200

# ===== Logging Configuration =====

# Log level
# Options: error, warn, info, debug
# Recommended: debug (development), info (production)
LOG_LEVEL=debug

# ===== Database Configuration (Future) =====

# Database type
# Options: in-memory, local, cloud
# For MVP: use in-memory (no external setup)
DATABASE_TYPE=in-memory

# ===== API Configuration =====

# API Version (for future versioning)
API_VERSION=v1

# ===== Feature Flags =====

# Enable authentication (future feature)
ENABLE_AUTH=false

# Enable rate limiting (future feature)
ENABLE_RATE_LIMITING=false
```

**What to do**:
1. Open `src/backend/local-dev/.env.example`
2. Replace with content above
3. Save

---

### Task 2: Update actual `.env` with example values

**Location**: `src/backend/local-dev/.env`

**Content**:
```bash
# Copy of .env.example with your local values
# Never commit this file to git!

PORT=3000
NODE_ENV=development
FRONTEND_URL=http://localhost:4200
LOG_LEVEL=debug
DATABASE_TYPE=in-memory
API_VERSION=v1
ENABLE_AUTH=false
ENABLE_RATE_LIMITING=false
```

**What to do**:
1. Open `src/backend/local-dev/.env`
2. Replace with content above
3. Save

---

### Task 3: Update configuration module

**Location**: `src/backend/local-dev/src/config.ts`

**Content**:
```typescript
import dotenv from 'dotenv';
import path from 'path';

// Load .env file
const envPath = path.join(__dirname, '../.env');
const result = dotenv.config({ path: envPath });

if (result.error && result.error.code !== 'ENOENT') {
  console.warn('⚠️  Warning loading .env file:', result.error.message);
}

/**
 * Validated configuration from environment variables
 * All values are validated and have sensible defaults
 */
export const config = {
  // ===== Server =====
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  
  // ===== CORS =====
  frontendUrl: process.env.FRONTEND_URL || 'http://localhost:4200',
  
  // ===== Logging =====
  logLevel: (process.env.LOG_LEVEL || 'info') as 'error' | 'warn' | 'info' | 'debug',
  
  // ===== Database =====
  databaseType: (process.env.DATABASE_TYPE || 'in-memory') as 'in-memory' | 'local' | 'cloud',
  
  // ===== API =====
  apiVersion: process.env.API_VERSION || 'v1',
  
  // ===== Feature Flags =====
  enableAuth: process.env.ENABLE_AUTH === 'true',
  enableRateLimiting: process.env.ENABLE_RATE_LIMITING === 'true',
  
  // ===== Computed =====
  isDevelopment: process.env.NODE_ENV === 'development',
  isProduction: process.env.NODE_ENV === 'production',
  isTest: process.env.NODE_ENV === 'test',
} as const;

/**
 * Type for configuration
 */
export type Config = typeof config;

/**
 * Validate configuration
 * Throws if configuration is invalid
 */
export function validateConfig(): void {
  const errors: string[] = [];
  
  // Validate PORT
  if (config.port < 1 || config.port > 65535) {
    errors.push(`PORT must be between 1 and 65535, got ${config.port}`);
  }
  
  // Validate NODE_ENV
  const validEnvs = ['development', 'production', 'test'];
  if (!validEnvs.includes(config.nodeEnv)) {
    errors.push(`NODE_ENV must be one of: ${validEnvs.join(', ')}, got ${config.nodeEnv}`);
  }
  
  // Validate FRONTEND_URL
  try {
    new URL(config.frontendUrl);
  } catch {
    errors.push(`FRONTEND_URL must be valid URL, got ${config.frontendUrl}`);
  }
  
  // Validate LOG_LEVEL
  const validLogLevels = ['error', 'warn', 'info', 'debug'];
  if (!validLogLevels.includes(config.logLevel)) {
    errors.push(`LOG_LEVEL must be one of: ${validLogLevels.join(', ')}, got ${config.logLevel}`);
  }
  
  // Validate DATABASE_TYPE
  const validDbTypes = ['in-memory', 'local', 'cloud'];
  if (!validDbTypes.includes(config.databaseType)) {
    errors.push(`DATABASE_TYPE must be one of: ${validDbTypes.join(', ')}, got ${config.databaseType}`);
  }
  
  // Report errors
  if (errors.length > 0) {
    console.error('❌ Configuration Errors:');
    errors.forEach(err => console.error(`   - ${err}`));
    throw new Error('Invalid configuration');
  }
}

/**
 * Log configuration on startup
 * Useful for debugging
 */
export function logConfig(): void {
  console.log('\n✅ Configuration Loaded:');
  console.log(`   Port:              ${config.port}`);
  console.log(`   Environment:       ${config.nodeEnv}`);
  console.log(`   Frontend URL:      ${config.frontendUrl}`);
  console.log(`   Log Level:         ${config.logLevel}`);
  console.log(`   Database Type:     ${config.databaseType}`);
  console.log(`   API Version:       ${config.apiVersion}`);
  console.log(`   Auth Enabled:      ${config.enableAuth ? '✅' : '❌'}`);
  console.log(`   Rate Limiting:     ${config.enableRateLimiting ? '✅' : '❌'}`);
  console.log('');
}

/**
 * Get configuration summary
 * Useful for API responses
 */
export function getConfigSummary() {
  return {
    environment: config.nodeEnv,
    apiVersion: config.apiVersion,
    features: {
      authentication: config.enableAuth,
      rateLimiting: config.enableRateLimiting,
    },
  };
}
```

**What to do**:
1. Open `src/backend/local-dev/src/config.ts`
2. Replace with content above
3. Save

---

### Task 4: Update Express app to use configuration

**Location**: `src/backend/local-dev/src/index.ts`

**Update imports**:
```typescript
import { config, validateConfig, logConfig } from './config';
```

**Update startup logic**:
```typescript
// Validate configuration
try {
  validateConfig();
  logConfig();
} catch (error) {
  console.error('❌ Configuration error:', error);
  process.exit(1);
}
```

**Complete updated file** (key changes):
```typescript
import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { config, validateConfig, logConfig } from './config';  // ← Updated
import healthRoutes from './routes/health';
import projectRoutes from './routes/projects';
import taskRoutes from './routes/tasks';

// Validate and log configuration  ← Updated
try {
  validateConfig();
  logConfig();
} catch (error) {
  console.error('❌ Configuration error:', error);
  process.exit(1);
}

// Create Express app
const app: Express = express();

// === MIDDLEWARE ===

// CORS - Allow requests from Angular frontend
app.use(cors({
  origin: config.frontendUrl,  // ← Uses config
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// JSON parser
app.use(express.json());

// Request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  
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
    message: config.isDevelopment ? error.message : 'An error occurred',  // ← Uses config
  });
});

// === START SERVER ===

const server = app.listen(config.port, () => {  // ← Uses config
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
2. Update imports
3. Update startup logic to call `logConfig()`
4. Ensure all code uses `config` object
5. Save

---

### Task 5: Verify `.gitignore` excludes `.env`

**Location**: `src/backend/local-dev/.gitignore` (or update root `.gitignore`)

**Content** (add if not present):
```
# Environment files (contain local secrets)
.env
.env.local
.env.*.local
.env.production.local

# Dependencies
node_modules/
npm-debug.log*

# Build outputs
dist/

# IDE
.vscode/
.idea/
*.swp
*.swo
```

**What to do**:
1. Create or update: `src/backend/local-dev/.gitignore`
2. Add `.env` to gitignore
3. Or update root `.gitignore` to include `src/backend/local-dev/.env`
4. Verify: `git check-ignore src/backend/local-dev/.env` should return true
5. Save

---

## Verification Steps

### Step 1: Configuration validation

```bash
cd src/backend/local-dev

# Start server
npm run dev

# Should see in output:
# ✅ Configuration Loaded:
#    Port:              3000
#    Environment:       development
#    Frontend URL:      http://localhost:4200
#    Log Level:         debug
#    Database Type:     in-memory
#    API Version:       v1
#    Auth Enabled:      ❌
#    Rate Limiting:     ❌
```

### Step 2: Test invalid configuration

```bash
# Stop server (Ctrl+C)

# Edit .env with invalid port
echo "PORT=99999" >> .env

# Start server again
npm run dev

# Should see error:
# ❌ Configuration Errors:
#    - PORT must be between 1 and 65535, got 99999
```

### Step 3: Test configuration change

```bash
# Fix port back to valid value
# Edit .env to PORT=3000

# Restart server
# Should work again
```

### Step 4: Verify `.env` not tracked by git

```bash
# Check if .env would be ignored
git check-ignore src/backend/local-dev/.env

# Should output path if properly ignored
```

### Step 5: Test new configuration

```bash
# Edit .env to change values
# For example: PORT=3001

# Restart server (npm run dev)

# Server should start on new port
# Check the "Port: 3001" in output
```

---

## Usage Examples

**In routes or modules**:
```typescript
import { config } from '../config';

// Use configuration
if (config.isDevelopment) {
  console.log('Development mode');
}

// Check features
if (config.enableAuth) {
  // Apply authentication
}

// Use port or frontend URL
console.log(`Server on port ${config.port}`);
console.log(`Frontend at ${config.frontendUrl}`);
```

---

## Notes

**Key Points**:
- Configuration loaded from `.env` on startup
- Full validation with helpful error messages
- Type-safe with TypeScript
- Easy to add new variables
- `.env` is not tracked by git (secrets safe)
- Configuration logged on startup (for debugging)

**Future Enhancements**:
- Support for `.env.production` file
- Encrypted values for secrets
- Configuration per environment (dev/prod/test)
- Remote configuration management
- Environment variable schema validation

**Dependencies**:
- dotenv package (already installed)
- Requires NODE_ENV variable set correctly

**Estimated Time**: 3-4 hours

---

## Completion Checklist

- [ ] `.env.example` template complete
- [ ] `.env` file with local values
- [ ] Configuration validation working
- [ ] Missing/invalid values show errors
- [ ] Configuration logged on startup
- [ ] `.env` properly gitignored
- [ ] Easy to add new variables
- [ ] Ready for STORY 4.7 (Documentation)

---

**Last Updated**: 2026-01-25
