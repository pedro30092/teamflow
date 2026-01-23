# Story 1.3: Initialize Backend (Lambda Handler)

**Story ID**: EPIC1-003
**Epic**: EPIC-1 (Development Environment Setup)
**Sprint**: SPRINT-0
**Status**: ✅ DONE

---

## User Story

```
As a developer,
I need a minimal TypeScript Lambda handler project,
so that I can write and compile Lambda functions for AWS deployment.
```

---

## Requirements

Set up a TypeScript project for Lambda functions with:
- Node.js package management (npm)
- TypeScript compiler configuration
- Build scripts for compilation
- A simple "Hello World" Lambda handler

**Target Structure:**
```
src/backend/
├── package.json           # npm configuration
├── tsconfig.json          # TypeScript compiler config
├── .gitignore            # Ignore node_modules and dist
├── src/
│   └── handlers/
│       └── hello.ts      # Lambda handler (TypeScript)
└── dist/                 # Compiled JavaScript (generated)
    └── handlers/
        └── hello.js
```

---

## Tasks

### Step 1: Create Backend Directory Structure

```bash
cd /home/pedro/Personal/development/teamflow
mkdir -p src/backend/src/handlers
```

**Verify:**
```bash
tree src/backend -L 2
```

---

### Step 2: Initialize npm Package

```bash
cd src/backend
npm init
```

**Configuration:**
- `package name`: `teamflow-backend`
- `version`: `1.0.0`
- `description`: `TeamFlow Lambda functions`
- `entry point`: `dist/handlers/hello.js`
- `author`: Your name
- `license`: `MIT`

**Quick alternative:**
```bash
npm init -y
# Then manually edit package.json
```

---

### Step 3: Install TypeScript Dependencies

```bash
npm install --save-dev typescript @types/node @types/aws-lambda
```

**What each package provides:**
- `typescript` - TypeScript compiler (tsc)
- `@types/node` - Type definitions for Node.js runtime
- `@types/aws-lambda` - Type definitions for Lambda (Handler, Context, Event)

**Verify installation:**
```bash
npx tsc --version
```

---

### Step 4: Create TypeScript Configuration

```bash
npx tsc --init
```

Replace the generated `tsconfig.json` with this configuration:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**Key settings explained:**
- `target: ES2020` - Node.js 20.x supports ES2020
- `module: commonjs` - Lambda requires CommonJS modules
- `outDir: ./dist` - Compiled JavaScript output directory
- `rootDir: ./src` - TypeScript source directory
- `moduleResolution: node` - Standard Node.js module resolution

**Verify configuration:**
```bash
npx tsc --showConfig
```

---

### Step 5: Add Build Scripts

Edit `package.json` and add the `scripts` section:

```json
{
  "name": "teamflow-backend",
  "version": "1.0.0",
  "description": "TeamFlow Lambda functions",
  "main": "dist/handlers/hello.js",
  "scripts": {
    "build": "tsc",
    "watch": "tsc --watch",
    "clean": "rm -rf dist"
  },
  "devDependencies": {
    "@types/aws-lambda": "^8.10.145",
    "@types/node": "^22.10.5",
    "typescript": "^5.7.3"
  }
}
```

**Scripts explained:**
- `npm run build` - Compile TypeScript once
- `npm run watch` - Auto-recompile on file changes
- `npm run clean` - Delete compiled output

---

### Step 6: Create Lambda Handler

Create `src/backend/src/handlers/hello.ts`:

```typescript
import { Handler } from 'aws-lambda';

export const handler: Handler = async (event, context) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  console.log('Context:', JSON.stringify(context, null, 2));

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Hello from TeamFlow Lambda!',
      timestamp: new Date().toISOString(),
    }),
  };
};
```

**Handler components:**
- `Handler` type - Generic Lambda handler type from AWS SDK
- `event` - Incoming event data (trigger information)
- `context` - Lambda runtime context
- Return value - HTTP-style response (compatible with API Gateway)

---

### Step 7: Build and Verify

```bash
npm run build
```

**Expected output:**
- No compilation errors
- `dist/` directory created
- `dist/handlers/hello.js` generated

**Verify compilation:**
```bash
ls -la dist/handlers/
cat dist/handlers/hello.js
```

---

### Step 8: Ignore Compiled Code

Create `.gitignore` in `src/backend/`:

```bash
echo "node_modules/" >> .gitignore
echo "dist/" >> .gitignore
```

---

## Acceptance Criteria

- [x] `src/backend/` directory exists
- [x] `package.json` configured with proper scripts
- [x] `tsconfig.json` configured for Lambda/CommonJS
- [x] TypeScript dependencies installed
- [x] `hello.ts` Lambda handler created
- [x] `npm run build` compiles successfully
- [x] `dist/handlers/hello.js` exists
- [x] `.gitignore` excludes `node_modules/` and `dist/`

---

## Dependencies

- Story 1.1 complete (Node.js, npm, TypeScript installed)
- Story 1.2 complete (AWS CLI configured)

---

## Definition of Done

- [x] Backend TypeScript project initialized
- [x] Lambda handler compiles without errors
- [x] Build scripts functional
- [x] No VS Code TypeScript errors
- [x] Compiled JavaScript ready for Lambda deployment
- [x] Ready for Story 1.4 (Infrastructure/CDKTF)

---

## Troubleshooting

### VS Code Error: "Unknown compiler option 'exclude'"
**Solution:** False positive from VS Code language server. Run `npx tsc --showConfig` to verify config is valid. Reload VS Code window if needed.

### VS Code Error: "Cannot use export in CommonJS"
**Solution:** Ensure `tsconfig.json` includes:
```json
{
  "compilerOptions": {
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true
  }
}
```
Then reload TypeScript server: `Ctrl+Shift+P` → "TypeScript: Restart TS Server"

---

## Notes

**What We Built:**
- Minimal Lambda backend project
- TypeScript compilation to JavaScript
- Proper module configuration for AWS Lambda
- Build automation with npm scripts

**What's Next:**
- Story 1.4: Initialize Infrastructure (CDKTF) - Deploy this Lambda to AWS
- Story 1.5: Initialize Frontend (Angular)

**Future Enhancements (Later Stories):**
- Lambda layers for shared code
- Hexagonal architecture (domain, ports, adapters)
- DynamoDB integration
- API Gateway integration
- Unit and integration tests

---

**Last Updated**: 2026-01-23
