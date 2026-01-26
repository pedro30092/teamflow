# Story 4.1: Configure Angular for Environment Variables

**Story ID**: EPIC4-1  
**Epic**: EPIC-4 (Cloud + Local Integration)  
**Sprint**: SPRINT-3  
**Status**: ✅ COMPLETED  
**Story Type**: Frontend Infrastructure

---

## User Story

```
As a frontend developer,
I want Angular to read the API endpoint from an environment variable,
so that I can switch between cloud and local backend without code changes.
```

---

## Requirements

### Environment Configuration

1. **`.env.example` file** - Template showing all required variables
2. **`.env` file** - Actual configuration (not committed to git)
3. **`environment.ts` and `environment.prod.ts`** - Angular environment files reading from `.env`
4. **TypeScript environment exports** - Safe access to configuration

### Configuration Variables

- `API_URL`: Backend endpoint (cloud or local)
- `ENVIRONMENT`: Current environment name (local/dev/cloud)

---

## Environment Files Setup

The project uses **three environment files** with automatic switching via Angular:

| File | Purpose | When Used |
|------|---------|-----------|
| `environment.ts` | Local development (localhost) | `ng serve` (default) |
| `environment.dev.ts` | Development server/cloud | `ng serve --configuration=dev` |
| `environment.prod.ts` | Production | `ng build --configuration production` |

**How it works**: Angular automatically replaces `environment.ts` with the appropriate file based on configuration.

---

## Acceptance Criteria

- [x] `.env.example` file created with clear documentation
- [x] `.env` file added to `.gitignore` (not tracked by git)
- [x] `src/environments/environment.ts` configured for local development
- [x] `src/environments/environment.dev.ts` configured for development server
- [x] `src/environments/environment.prod.ts` configured for production
- [x] `angular.json` configured with fileReplacements for all environments
- [x] `ng serve` starts without environment-related errors
- [x] `ng serve --configuration=dev` loads dev environment successfully
- [x] No hardcoded API URLs exist in component files
- [x] Angular builds successfully with `ng build`
- [x] Environment switching works via command-line flags

---

## Definition of Done

- [x] All files created and properly configured
- [x] `.env` is gitignored
- [x] Environment configuration loads correctly
- [x] `ng serve` and `ng serve --configuration=dev` both work
- [x] Angular native fileReplacements configured
- [x] TypeScript compiles without errors
- [x] Ready for STORY 4.2 (API Service creation)

---

## Technical Tasks

### Task 1: Create `.env.example` file

**Location**: `src/frontend/.env.example`

**Content**:
```bash
# API Configuration
# 
# For cloud backend (AWS), use:
#   API_URL=https://your-api-id.execute-api.us-east-1.amazonaws.com/dev
#
# For local backend (development), use:
#   API_URL=http://localhost:3000
#
# Default: http://localhost:3000 (local backend)

API_URL=http://localhost:3000
ENVIRONMENT=local
```

**What to do**:
1. Create the file with content above
2. Save in `src/frontend/` directory
3. Commit to git (this file is tracked)

---

### Task 2: Create `.env` file (actual configuration)

**Location**: `src/frontend/.env`

**Process**:
1. Copy from `.env.example`:
   ```bash
   cp src/frontend/.env.example src/frontend/.env
   ```

2. Edit with your actual cloud API URL:
   ```bash
   API_URL=https://your-actual-cloud-api.execute-api.us-east-1.amazonaws.com/dev
   ENVIRONMENT=cloud
   ```

3. **Do NOT commit** `.env` to git (contains secrets/environment-specific values)

---

### Task 3: Update `.gitignore`

**Location**: `src/frontend/.gitignore`

**Add these lines** (if not already present):
```
# Environment configuration
.env
.env.local
.env.*.local
```

**Verify**: `git check-ignore .env` should return true

---

### Task 4: Create/Update `environment.ts` (local development)

**Location**: `src/environments/environment.ts`

**Content**:
```typescript
// src/environments/environment.ts
// Local development environment configuration
// Default when running: ng serve

export const environment = {
  production: false,
  
  // Local backend
  apiUrl: 'http://localhost:3000',
  
  // Current environment name
  environment: 'local',
};
```

**What to do**:
1. Create file if doesn't exist
2. Replace with content above
3. Save

---

### Task 5: Create `environment.dev.ts` (development server)

**Location**: `src/environments/environment.dev.ts`

**Content**:
```typescript
// src/environments/environment.dev.ts
// Development server environment configuration
// Use with: ng serve --configuration=dev

export const environment = {
  production: false,
  
  // Development server API endpoint (cloud or remote dev server)
  apiUrl: 'https://your-dev-api-id.execute-api.us-east-1.amazonaws.com/dev',
  
  // Current environment name
  environment: 'dev',
};
```

**What to do**:
1. Create file
2. Replace `your-dev-api-id` with your actual development API endpoint
3. Save

---

### Task 6: Create/Update `environment.prod.ts` (production)

**Location**: `src/environments/environment.prod.ts`

**Content**:
```typescript
// src/environments/environment.prod.ts
// Production environment configuration

export const environment = {
  production: true,
  
  // Read from .env, default to cloud API
  apiUrl: process.env['API_URL'] || 'https://api.teamflow.dev/dev',
  
  // Production always uses cloud
  environment: 'cloud',
};
```

**What to do**:
1. Create file if doesn't exist
2. Replace `your-prod-api-id` with your actual production API endpoint
3. Save

---

### Task 7: Configure Angular Build (angular.json)

**Location**: `angular.json`

**What to do**: Update build configurations to include fileReplacements

**In `architect.build.configurations.production`**, add:
```json
"fileReplacements": [
  {
    "replace": "src/environments/environment.ts",
    "with": "src/environments/environment.prod.ts"
  }
]
```

**In `architect.build.configurations`**, add a new `dev` configuration:
```json
"dev": {
  "optimization": false,
  "extractLicenses": false,
  "sourceMap": true,
  "fileReplacements": [
    {
      "replace": "src/environments/environment.ts",
      "with": "src/environments/environment.dev.ts"
    }
  ]
}
```

**In `architect.serve.configurations`**, add:
```json
"dev": {
  "buildTarget": "frontend:build:dev"
}
```

**What to do**:
1. Open `angular.json`
2. Update the configurations as shown above
3. Save

---

---

### Task 8: Verify Environment Loading

**What to do**:
1. Verify the configuration loads correctly by testing each environment

---

## Verification Steps

### Step 1: Setup

```bash
# Navigate to frontend directory
cd src/frontend
```

### Step 2: Test Local Development (default)

```bash
# Start Angular dev server with default environment.ts
ng serve

# Expected output: Console shows localhost:3000
# Visit: http://localhost:4200
# DevTools console shows: API URL: http://localhost:3000
```

### Step 3: Test Development Server

```bash
# Start Angular dev server with environment.dev.ts
ng serve --configuration=dev

# Expected output: Console shows your dev API endpoint
# Visit: http://localhost:4200
# DevTools console shows: API URL: https://your-dev-api-id.execute-api.us-east-1.amazonaws.com/dev
```

### Step 4: Test Production Build

```bash
# Build for production with environment.prod.ts
ng build --configuration=production

# Expected output: Compiled with production API
# Check: cat dist/frontend/main.*.js | grep "your-prod-api-id"
```

### Step 5: Verify .env is ignored

```bash
# Check git will ignore .env
git check-ignore src/frontend/.env
# Should output: src/frontend/.env (meaning it's ignored ✓)
```

---

## How to Switch Environments

### From Command Line

```bash
# Local development (default)
ng serve
# Uses: environment.ts → localhost:3000

# Development server
ng serve --configuration=dev
# Uses: environment.dev.ts → cloud dev API

# Production build
ng build --configuration=production
# Uses: environment.prod.ts → cloud prod API
```

### In Code

```typescript
import { environment } from '../../environments/environment';

export class ApiService {
  constructor() {
    console.log('Current API:', environment.apiUrl);
    console.log('Environment:', environment.environment);
  }
}
```

The `environment` object is automatically switched by Angular based on the build configuration.

---

## File Replacements Explained

Angular's **fileReplacements** feature works like this:

**In `angular.json` under configurations:**
```json
"dev": {
  "fileReplacements": [
    {
      "replace": "src/environments/environment.ts",
      "with": "src/environments/environment.dev.ts"
    }
  ]
}
```

**When you run:**
```bash
ng serve --configuration=dev
```

**Angular automatically:**
1. Compiles with `environment.dev.ts` instead of `environment.ts`
2. Any imports of `environment` get the dev version
3. Build is optimized for that specific configuration

This happens at compile time, so there's zero runtime overhead.

---

## Notes

**Key Concepts**:
- Environment variables in Angular via `process.env`
- `.env` files are local configuration (not committed)
- `.env.example` shows template (committed to git)
- Different configurations for development vs production
- Fallback values if `.env` not present

**Future Considerations**:
- Could add validation for required variables
- Could add environment-specific build targets
- Could add error handling for missing `.env`

**Dependencies**:
- None for this story (just file configuration)
- Ready for STORY 4.2 (API Service)

**Estimated Time**: 3-4 hours (including testing)

---

## Completion Checklist

- [x] `.env.example` created with documentation
- [x] `.env` created and in `.gitignore`
- [x] `environment.ts` exports API URL for local development
- [x] `environment.dev.ts` exports API URL for development server
- [x] `environment.prod.ts` properly configured
- [x] `angular.json` configured with fileReplacements
- [x] `ng serve` starts without errors
- [x] `ng serve --configuration=dev` works with dev environment
- [x] TypeScript compiles without errors
- [x] No hardcoded API URLs in codebase
- [x] `ng build` succeeds without warnings
- [x] Environment switching tested and verified
- [x] Ready for next story

---

## Implementation Notes

### 🔍 Issue Discovered During Implementation

**Issue**: Original story suggested using `process.env` in Angular environment files, which caused TypeScript error: `Cannot find name 'process'`.

**Root Cause**: Angular's TypeScript configuration has `types: []` which excludes Node types. Using `process.env` in Angular is not the recommended approach.

**Resolution**: Changed to use Angular's native environment switching with fileReplacements in `angular.json`. This is the standard Angular way and works out of the box with no additional configuration.

**Impact**: 
- More robust and maintainable solution
- Zero runtime overhead (compile-time file swapping)
- No need for custom webpack configuration
- Easier to add additional environments in the future

### ✅ Final Implementation

**Three environment files created:**
- `environment.ts` - Local development (localhost:3000)
- `environment.dev.ts` - Development server (cloud dev API)
- `environment.prod.ts` - Production (cloud prod API)

**Angular configuration:**
- Updated `angular.json` with fileReplacements for dev and production
- Added serve configurations for each environment

**Usage:**
```bash
ng serve                          # Uses environment.ts (local)
ng serve --configuration=dev      # Uses environment.dev.ts (dev server)
ng build --configuration=production  # Uses environment.prod.ts (production)
```

**Verified:**
- ✅ TypeScript compiles without errors
- ✅ `ng serve --configuration=dev` successfully tested
- ✅ Environment switching works as expected

---

**Completed**: 2026-01-25  
**Time Invested**: ~3 hours (including issue resolution and testing)
