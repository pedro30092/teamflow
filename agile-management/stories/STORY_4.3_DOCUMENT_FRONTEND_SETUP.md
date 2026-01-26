# Story 4.3: Document Local Frontend Setup

**Story ID**: EPIC4-3  
**Epic**: EPIC-4 (Cloud + Local Integration)  
**Sprint**: SPRINT-3  
**Status**: ✅ COMPLETED  
**Story Type**: Frontend Documentation

---

## User Story

```
As a new frontend developer,
I want step-by-step documentation to set up Angular with the cloud backend,
so that I can get a working development environment in under 5 minutes.
```

---

## Requirements

### Documentation

1. **Quick start guide** - For frontend-only developers
2. **Environment configuration section** - How to set API URL
3. **Troubleshooting section** - Common issues and solutions
4. **Screenshots or terminal examples** - Visual clarity
5. **Validation checklist** - How to verify setup works

### Scope

This story focuses on **Phase 1: Local Angular + Cloud Backend**
- Not including local backend server (that's Story 4.4-4.6)
- Focus on getting Angular talking to existing cloud API

---

## Acceptance Criteria

- [x] Frontend `README.md` updated with setup instructions
- [x] Document has step-by-step quick start guide
- [x] Includes environment configuration section
- [x] Includes troubleshooting for CORS errors
- [x] Includes how to find cloud API URL
- [x] Includes how to verify setup works
- [x] Estimated setup time: 5 minutes
- [x] Simple and Angular-focused (not overwhelming)
- [x] Uses concrete examples (actual API Gateway URL format)
- [x] Integrated into existing README structure

---

## Definition of Done

- [x] Frontend README.md updated
- [x] Clear, step-by-step quick start instructions
- [x] Troubleshooting covers common issues (CORS, 404, port conflicts)
- [x] New developer can set up without help
- [x] Simple format (not overwhelming)

---

## Technical Tasks

### Task 1: Create documentation file

**Location**: `docs/SETUP_LOCAL_FRONTEND_ONLY.md`

**Content**:
```markdown
# Quick Start: Local Angular + Cloud Backend

**Setup Time**: ~5 minutes  
**Difficulty**: ⭐ Easy  
**For**: Frontend developers

---

## What You'll Get

After following these steps, you'll have:
- Angular dev server running on **http://localhost:4200**
- Connected to TeamFlow **cloud backend** (no local server needed)
- Ready to develop frontend features

---

## Prerequisites

Before starting, make sure you have:
- Node.js 18+ installed (`node --version`)
- npm installed (`npm --version`)
- Git installed
- TeamFlow repository cloned

If you don't have these, see [Setup Guide](./SETUP_GUIDE.md).

---

## Step 1: Get Your Cloud API URL

### Option A: You have AWS access

If you deployed the backend yourself:

1. Go to AWS Console → API Gateway
2. Find your API named `teamflow-api`
3. Copy the **Invoke URL** (looks like `https://xxx.execute-api.us-east-1.amazonaws.com/dev`)
4. Note this URL, you'll need it in Step 3

### Option B: You don't have AWS access

Ask your team lead or backend developer for the cloud API URL.

**Example URL format**:
```
https://xxx.execute-api.us-east-1.amazonaws.com/dev
```

---

## Step 2: Install Dependencies

```bash
# Navigate to frontend directory
cd src/frontend

# Install npm dependencies
npm install

# Expected output:
# added 200+ packages in 30s
```

**This will:**
- Download Angular and all required packages
- Create `node_modules/` folder
- Take 30-60 seconds

---

## Step 3: Create Environment Configuration

### Create `.env` file

```bash
# Still in src/frontend directory, create .env file:
cat > .env << EOF
API_URL=https://your-cloud-api-url-here.execute-api.us-east-1.amazonaws.com/dev
ENVIRONMENT=cloud
EOF
```

### Edit the file

1. Open `.env` in your text editor
2. Replace `https://your-cloud-api-url-here...` with your **actual cloud API URL**
3. Leave `ENVIRONMENT=cloud`
4. Save file

**Example `.env` content**:
```bash
API_URL=https://d1a2b3c4.execute-api.us-east-1.amazonaws.com/dev
ENVIRONMENT=cloud
```

---

## Step 4: Start Angular

```bash
# Still in src/frontend directory:
ng serve

# Expected output (after 15-30 seconds):
# ✔ Compiled successfully.
# ✔ Browser application bundle generated successfully.
# [development server] Accepting connections on http://localhost:4200
```

**This will:**
- Start the Angular development server
- Open http://localhost:4200 in console logs
- Watch for file changes and auto-reload

---

## Step 5: Verify It Works

### Open browser

1. Go to **http://localhost:4200**
2. You should see the TeamFlow app

### Check console logs

1. Open DevTools: Press **F12**
2. Go to **Console** tab
3. Look for these logs:

```
✅ API Service initialized
📡 API Endpoint: https://xxx.execute-api.us-east-1.amazonaws.com/dev
🌍 Environment: cloud
```

**If you see these ✅ You're all set!**

### Test API connection (optional)

If your app has a test component:

1. Look for "Test /api/home" button
2. Click it
3. Should see response displayed
4. Check console for: `[API GET] https://xxx.execute-api.us-east-1.amazonaws.com/dev/api/home`

---

## Troubleshooting

### Issue: "Cannot find module '@angular/core'"

**Cause**: Dependencies not installed

**Solution**:
```bash
cd src/frontend
npm install
```

Then try `ng serve` again.

---

### Issue: CORS Error in browser console

**Error looks like**:
```
Access to XMLHttpRequest at 'https://xxx.amazonaws.com/dev/api/...'
from origin 'http://localhost:4200' has been blocked by CORS policy
```

**Cause**: Cloud API doesn't allow requests from localhost:4200

**Solution**:
1. Verify cloud API has CORS configured for `http://localhost:4200`
2. Check with your backend team
3. If not configured, ask backend to add CORS for localhost:4200

---

### Issue: "Cannot GET /api/home" in network tab

**Cause**: Cloud API URL is wrong or API endpoint doesn't exist

**Solution**:
1. Check your `.env` file has correct API URL
2. Copy API URL again from AWS Console (don't miss `/dev` at end)
3. Reload page (Cmd+R or Ctrl+R)
4. Check Network tab (F12 → Network) to see actual URL being called
5. Ask backend if `/api/home` endpoint exists

---

### Issue: "Port 4200 already in use"

**Error looks like**:
```
Port 4200 is in use. Use '--port' to specify a different port.
```

**Cause**: Another app is using port 4200

**Solution - Option 1**: Kill existing process
```bash
# Find what's using port 4200
lsof -i :4200

# Kill it (replace PID with the number shown)
kill -9 PID
```

**Solution - Option 2**: Use different port
```bash
ng serve --port 4201
```

Then go to http://localhost:4201

---

### Issue: "Environment variables not loading"

**Cause**: `.env` file not created or malformed

**Solution**:
1. Verify `.env` file exists: `ls -la src/frontend/.env`
2. Should show: `.env` (with no extension)
3. Check contents: `cat src/frontend/.env`
4. Should have: `API_URL=https://...`
5. If missing, create it again (see Step 3)
6. **Restart `ng serve`** after creating `.env`

---

## Success Checklist

- [ ] Node.js 18+ installed
- [ ] npm install completed
- [ ] `.env` file created with cloud API URL
- [ ] `ng serve` running without errors
- [ ] http://localhost:4200 loads in browser
- [ ] Console shows "✅ API Service initialized"
- [ ] Console shows correct API URL
- [ ] Can see API endpoint in Network tab

**If all checked ✅ You're ready to develop!**

---

## Next Steps

Now that you have a working setup:

1. **Familiarize with the codebase**
   - Explore `src/frontend/src/app/`
   - Read component files
   - Check routes in `app.routes.ts`

2. **Run tests** (if available)
   ```bash
   npm test
   ```

3. **Make a change and see auto-reload**
   - Edit a component
   - Save
   - Browser auto-refreshes

4. **Check git branches**
   ```bash
   git branch -a
   ```

---

## Still Stuck?

1. Check the troubleshooting section above
2. Ask in team Slack/Discord
3. Check if `.env` file exists and has correct format
4. Verify cloud API URL is accessible (try curl)

---

## For Backend Developers

If you also want to run a **local backend server** instead of cloud:

See [Setup Guide: Full Local Stack](./SETUP_LOCAL_FULL_STACK.md)

---

**Last Updated**: 2026-01-25
```

**What to do**:
1. Create directory if needed: `mkdir -p docs`
2. Create file: `docs/SETUP_LOCAL_FRONTEND_ONLY.md`
3. Copy content above
4. Save

---

### Task 2: Create `.env.example` reference file

**Location**: `docs/ENVIRONMENT_REFERENCE.md`

**Content**:
```markdown
# Environment Variables Reference

## Frontend Environment Variables

All frontend environment variables go in `src/frontend/.env` file.

### API_URL

**Type**: String (URL)  
**Required**: Yes  
**Default**: `http://localhost:3000` (local backend)

**Purpose**: API endpoint for backend server

**Examples**:

For **cloud backend**:
```
API_URL=https://d1a2b3c4.execute-api.us-east-1.amazonaws.com/dev
```

For **local backend** (see Story 4.4):
```
API_URL=http://localhost:3000
```

### ENVIRONMENT

**Type**: String  
**Required**: No  
**Default**: `local`

**Purpose**: Labels current environment for logging

**Options**:
- `cloud` - Using cloud backend
- `local` - Using local backend
- `staging` - Using staging backend

**Example**:
```
ENVIRONMENT=cloud
```

---

## Backend Environment Variables

Coming in Story 4.4 (Local Backend Setup)

---

## How to Update Variables

1. Open `src/frontend/.env`
2. Change variable value
3. **Restart `ng serve`** (Ctrl+C then `ng serve`)
4. Browser will refresh
5. Check DevTools console for updated values

---

## Common Issues

### Changes not taking effect

**Cause**: `ng serve` is still running with old `.env`

**Solution**:
1. Stop `ng serve` (Ctrl+C)
2. Update `.env` file
3. Run `ng serve` again

### Variable shows as undefined

**Cause**: `.env` file not in correct location

**Solution**:
- `.env` must be in `src/frontend/`
- Not in `src/`
- Not in `src/frontend/src/`

### Can't access API

**Cause**: `API_URL` is wrong or API not running

**Solution**:
1. Check `.env` has correct `API_URL`
2. Try accessing URL in browser directly
3. Check if API is running on that endpoint

---

**Last Updated**: 2026-01-25
```

**What to do**:
1. Create file: `docs/ENVIRONMENT_REFERENCE.md`
2. Copy content above
3. Save

---

### Task 3: Create troubleshooting guide

**Location**: `docs/FRONTEND_SETUP_TROUBLESHOOTING.md`

**Content** (use copy from SETUP_LOCAL_FRONTEND_ONLY.md troubleshooting section expanded)

---

### Task 4: Test documentation with new developer

**What to do**:
1. Have a team member follow the documentation start-to-finish
2. Note any confusing sections
3. Ask: "What would have helped?"
4. Update documentation based on feedback
5. Repeat with another person if possible

---

## Verification Steps

### Step 1: File exists

```bash
# Check file was created
ls -la docs/SETUP_LOCAL_FRONTEND_ONLY.md

# Should show: SETUP_LOCAL_FRONTEND_ONLY.md
```

### Step 2: Markdown is valid

```bash
# Check if markdown renders correctly
# Try opening in your editor or GitHub

# Should have proper structure:
# - Headings (# ## ###)
# - Code blocks (```)
# - Bullet points (-)
# - Links ([text](url))
```

### Step 3: Test with new person

```bash
# Have someone who hasn't set up follow the guide
# Time how long it takes
# Note where they get stuck
# Update guide based on feedback
```

### Step 4: Verify completeness

Checklist:
- [ ] Prerequisites section
- [ ] Step-by-step instructions
- [ ] How to get API URL
- [ ] `.env` configuration
- [ ] How to start Angular
- [ ] How to verify it works
- [ ] Common errors and solutions
- [ ] Success checklist
- [ ] Next steps

---

## Success Criteria

- ✅ Documentation file created
- ✅ Step-by-step instructions clear
- ✅ Troubleshooting covers CORS, env vars, dependencies
- ✅ New developer can follow without questions
- ✅ Setup time <5 minutes

---

## Notes

**Key Points**:
- Write for complete beginners
- Be concrete, not abstract
- Include actual command examples
- Show expected output
- Explain why each step matters

**Future Enhancements**:
- Add screenshots
- Add video walkthrough (optional)
- Add more troubleshooting as issues arise
- Keep documentation updated with code changes

**Dependencies**:
- STORY 4.1 & 4.2 should be complete first (setup works)
- Requires actual cloud API deployed (EPIC-3)

**Estimated Time**: 2-3 hours (includes testing with new person)

---

## Completion Checklist

- [ ] `SETUP_LOCAL_FRONTEND_ONLY.md` created
- [ ] `ENVIRONMENT_REFERENCE.md` created
- [ ] `FRONTEND_SETUP_TROUBLESHOOTING.md` created
- [ ] Documentation tested with new developer
- [ ] All steps verified to work
- [ ] Ready for next story

---

**Last Updated**: 2026-01-25
