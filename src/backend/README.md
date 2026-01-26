# Backend Structure

This doc stays concise. The detailed Lambda Layers guide is here:
- `.github/references/lambda-layers-cdktf-pattern.md`

## Folder layout (summary)
```
src/backend/
├── package.json, tsconfig.json
├── src/functions/           # Handlers (no node_modules inside)
├── layers/
│   └── dependencies/nodejs/ # Shared deps layer (AWS SDK, etc.)
├── local-dev/               # Local Express server for development
└── dist/                    # Compiled output
```

## Using the dependencies layer
Run the helper script to install/update deps and check size:
```
cd src/backend/layers/dependencies
./build.sh
```
CDKTF packages `src/backend/layers/dependencies/nodejs/` as the shared dependencies layer.

## Notes
- Keep handlers dependency-free; imports resolve from `/opt/nodejs/node_modules` at runtime.
- For steps, examples, and troubleshooting, use the canonical guide above.

---

## LOCAL SERVER

### Overview

The **local Express server** (`src/backend/local-dev/`) allows you to develop and test Lambda handlers locally without AWS deployment. It invokes compiled Lambda handlers with mock API Gateway events, matching the production execution model.

**Architecture**:
```
HTTP Request → Express Server → Mock API Gateway Event → Lambda Handler → Response
```

**Key Benefits**:
- 🚀 Fast iteration (no AWS deployment cycle)
- ✅ Same handler code runs locally and on AWS
- 🔄 Hot reload support (changes reflected immediately)
- 🎯 Test API Gateway event structure locally

---

### Quick Start

**Prerequisites**: Backend compiled (`npm run build` in `src/backend/`)

```bash
# Navigate to local server directory
cd src/backend/local-dev

# Install dependencies (first time only)
npm install

# Create .env file from template
cp .env.example .env

# Start the server (builds backend first, then starts)
npm run dev
```

**Expected output**:
```
✅ Configuration loaded:
   Port: 3000
   Environment: development
   Frontend URL: http://localhost:4200

🚀 Local Backend Server Started
📡 http://localhost:3000
✅ CORS enabled for http://localhost:4200

⚡ Lambda handler integration active

Try this endpoint:
  - http://localhost:3000/api/home (invokes Lambda handler)

Press Ctrl+C to stop
```

**Test it**: `curl http://localhost:3000/api/home`

---

### Available Scripts

| Script | Command | Description |
|--------|---------|-------------|
| **dev** | `npm run dev` | Build backend once → start server |
| **dev:watch** | `npm run dev:watch` | Watch backend for changes + auto-reload server |
| **build** | `npm run build` | Compile local-dev TypeScript |
| **build:backend** | `npm run build:backend` | Compile backend handlers (`../npm run build`) |
| **watch:backend** | `npm run watch:backend` | Watch backend handlers for changes |
| **dev:server** | `npm run dev:server` | Start server only (no backend build) |
| **start** | `npm run start` | Production start (compiled server) |

**Most common**:
- **First time**: `npm run dev` (builds backend, starts server)
- **Active development**: `npm run dev:watch` (auto-rebuild + reload)
- **Quick restart**: `npm run dev:server` (backend already built)

---

### Configuration

**Location**: `src/backend/local-dev/.env`

**Required variables**:
```bash
# Server
PORT=3000                           # Server port
NODE_ENV=development                # Environment (development/production)

# CORS
FRONTEND_URL=http://localhost:4200  # Angular frontend URL

# Logging
LOG_LEVEL=debug                     # Verbosity: error/warn/info/debug
```

**Usage**:
1. Copy `.env.example` → `.env`: `cp .env.example .env`
2. Edit `.env` with your values
3. Restart server to apply changes

**Note**: `.env` is git-ignored (never commit it)

---

### Hot Reload Workflow

**With `npm run dev:watch`**:

1. **Start watching**:
   ```bash
   cd src/backend/local-dev
   npm run dev:watch
   ```

2. **Edit Lambda handler**:
   ```typescript
   // src/backend/src/functions/home/get-home.ts
   export const handler = async (event, context) => {
     return {
       statusCode: 200,
       body: JSON.stringify({ message: 'Updated message!' }), // ← Change this
     };
   };
   ```

3. **Save file** → Backend watch recompiles → Express cache-busts import → **Changes live!**

4. **Test**: `curl http://localhost:3000/api/home` (see updated response)

**How it works**:
- `watch:backend` monitors `src/functions/` and recompiles to `dist/` on changes
- `dev:server` uses `ts-node-dev` to reload Express on local-dev changes
- Handler routes use `require.cache` deletion to reload compiled handlers on each request

**No restart needed** for handler changes when using `dev:watch`!

---

### Architecture Details

**Express wraps Lambda handlers**:
```typescript
// routes/handlers.ts
router.get('/api/home', async (req, res) => {
  // 1. Resolve compiled handler path
  const handlerPath = path.resolve(__dirname, '../../../dist/functions/home/get-home.js');
  
  // 2. Bust require cache (hot reload)
  delete require.cache[require.resolve(handlerPath)];
  
  // 3. Load handler
  const { handler: homeHandler } = require(handlerPath);
  
  // 4. Create mock API Gateway event
  const event = createMockAPIGatewayEvent(req);
  
  // 5. Invoke Lambda handler
  const lambdaResponse = await invokeLambdaHandler(homeHandler, event);
  
  // 6. Return response
  res.status(lambdaResponse.statusCode).send(lambdaResponse.body);
});
```

**Mock API Gateway event** (`utils/lambda-invoker.ts`):
- Translates Express `Request` → API Gateway `APIGatewayProxyEvent`
- Includes headers, query params, path, method
- Mock request context (accountId, requestId, etc.)
- Matches production Lambda event structure

**Same code, different runtime**:
- **Production**: API Gateway → Lambda → Handler
- **Local**: Express → Mock Event → Handler
- Handler code identical in both environments

---

### Endpoints

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/api/home` | `functions/home/get-home.js` | Home endpoint (returns welcome message) |

**Adding new endpoints**:
1. Create handler in `src/backend/src/functions/` (e.g., `projects/list-projects.ts`)
2. Build: `npm run build` in `src/backend/`
3. Add route in `local-dev/src/routes/handlers.ts`:
   ```typescript
   router.get('/api/projects', async (req, res) => {
     const handlerPath = path.resolve(__dirname, '../../../dist/functions/projects/list-projects.js');
     delete require.cache[require.resolve(handlerPath)];
     const { handler } = require(handlerPath);
     const event = createMockAPIGatewayEvent(req);
     const response = await invokeLambdaHandler(handler, event);
     res.status(response.statusCode).send(response.body);
   });
   ```
4. Restart server

---

### Troubleshooting

#### Port Already in Use

**Error**: `EADDRINUSE: address already in use :::3000`

**Fix**:
```bash
# Option 1: Change port in .env
echo "PORT=3001" >> .env

# Option 2: Kill process using port
lsof -ti:3000 | xargs kill -9
```

#### Module Not Found

**Error**: `Cannot find module '../../../dist/functions/home/get-home.js'`

**Fix**: Backend not compiled yet
```bash
# From backend root
cd src/backend
npm run build

# Or from local-dev
npm run build:backend
```

#### Handler Error

**Error**: `[Handler] Error invoking Lambda: ...`

**Debug**:
1. Check server logs (full error in terminal)
2. Test handler directly: `node -e "require('./dist/functions/home/get-home.js').handler({}, {})"`
3. Verify handler exports: `export const handler = async (event, context) => { ... }`
4. Check handler TypeScript errors: `npm run build` in backend

#### CORS Error in Browser

**Error**: `Access to fetch at 'http://localhost:3000' from origin 'http://localhost:4200' has been blocked by CORS policy`

**Fix**: Verify `FRONTEND_URL` in `.env` matches Angular dev server
```bash
# .env
FRONTEND_URL=http://localhost:4200  # Must match Angular port
```

Restart server after changing `.env`.

#### Changes Not Reflected

**Issue**: Edited handler but response unchanged

**Fix**:
1. **Using `dev:watch`?** Should auto-reload
2. **Using `dev`?** Restart server: Ctrl+C → `npm run dev`
3. **Check compilation**: Verify `dist/functions/` has updated files
4. **Hard refresh browser**: Ctrl+Shift+R (might be cached)

---

### When to Use Local Server

**✅ Use local server when**:
- Developing new backend features
- Testing API endpoints
- Debugging handler logic
- Integrating with local Angular frontend
- Iterating quickly without AWS

**❌ Don't use local server when**:
- Testing Lambda layer imports (needs AWS runtime)
- Testing DynamoDB integration (needs real/LocalStack DB)
- Testing Cognito authorizer (needs real user pool)
- Performance testing (different from Lambda cold starts)
- Production-like environment needed

**Local server is for fast development iteration. Always test on AWS before shipping.**

---

### Next Steps

- **Add database**: Story 5.x will integrate local/mock database
- **Add authentication**: JWT middleware for protected routes
- **Add more endpoints**: Follow pattern in `routes/handlers.ts`
- **API versioning**: Add `/v1/` prefix to routes

For advanced patterns (hexagonal architecture, use cases, repositories), see:
- `research/TECHNICAL_ARCHITECTURE_SERVERLESS.md`
- `research/DEVELOPMENT_ROADMAP_SERVERLESS.md`
