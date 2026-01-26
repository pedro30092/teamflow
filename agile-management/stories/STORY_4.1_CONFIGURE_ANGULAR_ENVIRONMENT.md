# Story 4.1: Configure Angular for Environment Variables

**Story ID**: EPIC4-1  
**Epic**: EPIC-4 (Cloud + Local Integration)  
**Sprint**: SPRINT-3  
**Status**: 📋 TODO  
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
- `ENVIRONMENT`: Current environment name (cloud/local)

---

## Acceptance Criteria

- [ ] `.env.example` file created with clear documentation
- [ ] `.env` file added to `.gitignore` (not tracked by git)
- [ ] `src/environments/environment.ts` reads `API_URL` from `process.env`
- [ ] `src/environments/environment.prod.ts` configured for production
- [ ] `ng serve` starts without environment-related errors
- [ ] Console log on startup shows current API URL
- [ ] No hardcoded API URLs exist in component files
- [ ] Angular builds successfully with `ng build`
- [ ] `.env` changes are picked up on `ng serve` restart

---

## Definition of Done

- [ ] All files created and properly configured
- [ ] `.env` is gitignored
- [ ] Environment configuration loads correctly
- [ ] `ng serve` shows API URL in startup logs
- [ ] Ready for STORY 4.2 (API Service creation)

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

### Task 4: Create/Update `environment.ts` (development)

**Location**: `src/environments/environment.ts`

**Content**:
```typescript
// src/environments/environment.ts
// Development environment configuration

export const environment = {
  production: false,
  
  // Read from .env file, default to local backend
  apiUrl: process.env['API_URL'] || 'http://localhost:3000',
  
  // Current environment name
  environment: process.env['ENVIRONMENT'] || 'local',
};
```

**What to do**:
1. Create file if doesn't exist
2. Replace with content above
3. Save

---

### Task 5: Create/Update `environment.prod.ts` (production)

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
2. Replace with content above
3. Save

---

### Task 6: Verify Environment Loading

**What to do**:
1. Create a simple test component or just verify via console

**Example component** (for testing, can be removed):
```typescript
// Create src/app/debug/environment-debug.component.ts

import { Component } from '@angular/core';
import { environment } from '../../environments/environment';

@Component({
  selector: 'app-environment-debug',
  standalone: true,
  template: `
    <div class="debug-info">
      <h3>Environment Configuration</h3>
      <p><strong>API URL:</strong> {{ apiUrl }}</p>
      <p><strong>Environment:</strong> {{ env }}</p>
    </div>
  `,
  styles: [`
    .debug-info {
      background: #f0f0f0;
      padding: 10px;
      margin: 10px;
      border-radius: 4px;
      font-family: monospace;
    }
  `]
})
export class EnvironmentDebugComponent {
  apiUrl = environment.apiUrl;
  env = environment.environment;

  constructor() {
    console.log('🔧 Environment loaded:', { 
      apiUrl: this.apiUrl, 
      environment: this.env 
    });
  }
}
```

---

## Verification Steps

### Step 1: Setup

```bash
# Navigate to frontend directory
cd src/frontend

# Copy .env.example to .env
cp .env.example .env

# Edit .env with your cloud API URL (or leave as local)
# nano .env
```

### Step 2: Verify .env is ignored

```bash
# Check git will ignore .env
git check-ignore src/frontend/.env
# Should output: src/frontend/.env (meaning it's ignored ✓)
```

### Step 3: Start Angular and check logs

```bash
# Start Angular dev server
ng serve

# Watch console output for startup message
# Should see something like:
# ✔ Browser application bundle generated successfully.
# [development server] Accepting connections on http://localhost:4200
```

### Step 4: Check in browser console

```javascript
// Open browser (http://localhost:4200)
// Open DevTools Console (F12)
// You should see environment loaded

// Type in console:
import { environment } from './src/environments/environment.js';
environment.apiUrl
// Should return: http://localhost:3000 (or your cloud URL)
```

### Step 5: Verify no hardcoded URLs

```bash
# Search for hardcoded API URLs in code
grep -r "localhost:3000" src/frontend/src --exclude-dir=node_modules
grep -r "execute-api.us-east-1.amazonaws.com" src/frontend/src --exclude-dir=node_modules

# Should return NO results (only .env.example should match)
```

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

- [ ] `.env.example` created with documentation
- [ ] `.env` created and in `.gitignore`
- [ ] `environment.ts` exports API URL from process.env
- [ ] `environment.prod.ts` properly configured
- [ ] `ng serve` starts without errors
- [ ] Console shows API URL on startup
- [ ] No hardcoded API URLs in codebase
- [ ] `ng build` succeeds without warnings
- [ ] Can see configuration in browser DevTools
- [ ] Ready for next story

---

**Last Updated**: 2026-01-25
