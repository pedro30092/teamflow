# Epic 1: Development Environment Setup

**Epic ID**: EPIC-1
**Type**: Technical Enablement
**Phase**: Prerequisites (Before Phase 1)
**Duration**: 1-2 days
**Status**: ✅ DONE

---

## Epic Overview

**Goal**: Get the local development environment ready for building TeamFlow

**Why This Matters**: Before writing any code, developers need all tools installed, AWS configured, and project structure initialized. This epic ensures everyone can build and deploy the application.

**Success Criteria**:
- [x] All development tools installed (Node.js, AWS CLI, CDKTF, Angular CLI)
- [x] AWS account configured with IAM credentials
- [x] Project structure initialized (backend/, infrastructure/, frontend/)
- [x] All verification checks in SETUP_GUIDE.md pass
- [x] Developer can run: `cdktf synth`, `npm run build`, `ng serve`

**Reference**: SETUP_GUIDE.md

---

## Stories in This Epic

### Story 1.1: Install Development Tools
### Story 1.2: Configure AWS Account
### Story 1.3: Initialize Project Structure (Backend)
### Story 1.4: Initialize Infrastructure (CDKTF)
### Story 1.5: Initialize Frontend (Angular)

---

## Story 1.1: Install Development Tools

**Story ID**: EPIC1-001
**Type**: Technical Enablement
**Status**: ✅ DONE

**Story**:
```
As a developer,
I need Node.js 24.x, AWS CLI v2, CDKTF CLI, and Angular CLI installed,
so that I can build and deploy the application.
```

### Tasks

**Node.js Installation**:
- [ ] Install Node.js 24.x LTS using nvm (recommended)
  ```bash
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  nvm install 24
  nvm use 20
  nvm alias default 20
  ```
- [ ] Verify Node.js version: `node --version` (should show v24.x.x)
- [ ] Verify npm version: `npm --version` (should show 10.x.x)

**Git Configuration**:
- [ ] Configure Git user:
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```
- [ ] Verify: `git config --list`

**VS Code Setup** (Recommended):
- [ ] Install VS Code from https://code.visualstudio.com/
- [ ] Install recommended extensions:
  - [ ] ESLint
  - [ ] Prettier
  - [ ] TypeScript
  - [ ] Angular Language Service
  - [ ] HashiCorp Terraform (for CDKTF)
  - [ ] AWS Toolkit (optional)

**AWS CLI v2**:
- [ ] Install AWS CLI v2
  - macOS: `brew install awscli`
  - Linux: Download and install from AWS
  - Windows: Download installer from AWS website
- [ ] Verify: `aws --version` (should show aws-cli/2.x.x)

**CDKTF CLI**:
- [ ] Install globally: `npm install -g cdktf-cli@latest`
- [ ] Verify: `cdktf --version`

**Angular CLI**:
- [ ] Install globally: `npm install -g @angular/cli@18`
- [ ] Verify: `ng version` (should show Angular CLI 18.x)

**Optional Tools**:
- [ ] Install Docker (for DynamoDB Local testing later)
- [ ] Install API testing tool:
  - [ ] Postman (https://www.postman.com/downloads/)
  - [ ] Insomnia (https://insomnia.rest/download)
  - [ ] Thunder Client (VS Code extension)

### Acceptance Criteria

- [x] `node --version` returns v24.13.0
- [x] `npm --version` returns 11.6.2
- [x] `git --version` returns any recent version
- [x] `aws --version` returns aws-cli/2.33.5
- [x] `cdktf --version` returns 0.21.0
- [x] `ng version` returns Angular CLI 21.1.1
- [x] Git is configured with user name and email

### Dependencies

- None (this is the starting point)

### Definition of Done

- [x] All commands above return expected versions
- [x] Tools are accessible from terminal/command prompt
- [x] VS Code (or chosen IDE) is configured
- [x] Developer can proceed to Story 1.2

### Notes

- **Time Estimate**: 2-4 hours (depending on download speeds and familiarity)
- **Platform-Specific**: Some commands differ between macOS/Linux/Windows
- **Troubleshooting**: If npm permissions issues on macOS/Linux, run:
  ```bash
  sudo chown -R $USER ~/.npm
  ```

---

## Story 1.2: Configure AWS Account

**Story ID**: EPIC1-002
**Type**: Technical Enablement
**Status**: ✅ DONE

**Story**:
```
As a developer,
I need an AWS account with IAM credentials configured,
so that I can deploy infrastructure to AWS.
```

### Tasks

**Create AWS Account**:
- [ ] Go to https://aws.amazon.com/
- [ ] Click "Create an AWS Account"
- [ ] Follow registration process
- [ ] Note: Requires credit card for verification (free tier available)

**Set Up Billing Alarms** (CRITICAL):
- [ ] Log in to AWS Console
- [ ] Navigate to CloudWatch service
- [ ] Go to Alarms → Billing
- [ ] Create billing alarms:
  - [ ] $5 threshold
  - [ ] $10 threshold
  - [ ] $20 threshold
- [ ] Enter email for notifications
- [ ] Confirm email subscription (check inbox)

**Create IAM User for Development**:
- [ ] Go to IAM service in AWS Console
- [ ] Click Users → Add User
- [ ] Username: `teamflow-dev` (or your preferred name)
- [ ] Access type: ✅ **Programmatic access** (access key)
- [ ] Permissions: Attach **AdministratorAccess** policy
  - Note: For simplicity in development. Use least privilege in production.
- [ ] **Download credentials CSV** and save securely
  - ⚠️ CRITICAL: You cannot download this again!
  - Store in password manager or secure location
  - Never commit to Git

**Enable MFA** (Recommended):
- [ ] IAM → Users → Select root account
- [ ] Security credentials → Enable MFA
- [ ] Use authenticator app (Google Authenticator, Authy, etc.)

**Configure AWS CLI**:
- [ ] Run: `aws configure`
- [ ] Enter when prompted:
  - AWS Access Key ID: [from credentials CSV]
  - AWS Secret Access Key: [from credentials CSV]
  - Default region: `us-east-1`
  - Default output format: `json`
- [ ] Verify configuration: `aws sts get-caller-identity`
  - Should return JSON with UserId, Account, and Arn

### Acceptance Criteria

- [x] AWS account accessible with SSO
- [x] Billing alarms configured and confirmed (email)
- [x] AWS SSO profiles configured (`teamflow-developer`, `teamflow-admin`)
- [x] AWS CLI configured via SSO; `aws sts get-caller-identity` returns account info
- [x] Response includes Account number and SSO role ARN

### Security Checklist

- [x] MFA enabled on root account
- [x] Root account not used for development
- [x] SSO roles/credentials stored securely
- [x] Billing alarms active to prevent surprise charges
- [x] .gitignore includes AWS credential files

### Dependencies

- Story 1.1 complete (AWS CLI installed)

### Definition of Done

- [x] AWS CLI authenticated successfully via SSO profile
- [x] `aws sts get-caller-identity` returns correct account
- [x] Billing alarms confirmed via email
- [ ] Credentials documented in secure location (not in Git)
- [ ] Developer can proceed to Story 1.3

### Notes

- **Time Estimate**: 1-2 hours (including AWS account approval time)
- **Cost**: Free tier available (covers development needs)
- **Important**: NEVER commit AWS credentials to Git!
- **Troubleshooting**: If `aws configure` shows "Unable to locate credentials":
  - Re-run `aws configure`
  - Check credentials CSV for correct values
  - Verify credentials file: `cat ~/.aws/credentials`

---

## Story 1.3: Initialize Project Structure

**Story ID**: EPIC1-003
**Type**: Technical Enablement
**Status**: ✅ DONE

**Story**:
```
As a developer,
I need the project structure initialized (backend/, infrastructure/, frontend/),
so that I can organize code properly and start building.
```

### Tasks

**Completion Summary (Jan 2026)**: Backend scaffolded with TypeScript Lambda entrypoint and build setup; infrastructure and frontend initialization moved to Stories 1.4 and 1.5 respectively.

**Create Project Directories**:
- [ ] Navigate to project location: `cd ~/Personal/development/teamflow`
- [ ] Verify current structure:
  ```bash
  ls -la
  # Should see: research/, .git/, README.md, SETUP_GUIDE.md
  ```
- [ ] Create backend structure:
  ```bash
  mkdir -p backend/functions
  mkdir -p backend/layers/business-logic/nodejs/node_modules/@teamflow/core
  mkdir -p backend/layers/dependencies/nodejs/node_modules
  ```
- [ ] Create infrastructure structure:
  ```bash
  mkdir -p infrastructure/stacks
  ```
- [ ] Create frontend directory:
  ```bash
  mkdir -p frontend
  ```
- [ ] Verify structure:
  ```bash
  tree -L 2  # or: ls -R
  ```

**Initialize Backend Project**:
- [ ] Navigate to backend: `cd backend`
- [ ] Initialize npm: `npm init -y`
- [ ] Install TypeScript and types:
  ```bash
  npm install -D typescript @types/node @types/aws-lambda
  ```
- [ ] Install AWS SDK v3:
  ```bash
  npm install @aws-sdk/client-dynamodb @aws-sdk/lib-dynamodb
  ```
- [ ] Install development tools:
  ```bash
  npm install -D eslint prettier @typescript-eslint/eslint-plugin @typescript-eslint/parser
  ```
- [ ] Create `tsconfig.json` (see SETUP_GUIDE.md for content)
- [ ] Create `.eslintrc.js` (see SETUP_GUIDE.md for content)
- [ ] Update `package.json` scripts:
  ```json
  {
    "scripts": {
      "build": "tsc",
      "lint": "eslint . --ext .ts",
      "format": "prettier --write \"**/*.ts\"",
      "clean": "rm -rf dist"
    }
  }
  ```
- [ ] Create test function:
  ```bash
  mkdir -p functions/test
  cat > functions/test/hello.ts << 'EOF'
  export const handler = async () => {
    return {
      statusCode: 200,
      body: JSON.stringify({ message: 'Hello from Lambda!' }),
    };
  };
  EOF
  ```
- [ ] Test build: `npm run build`
- [ ] Verify: `ls dist/functions/test/` should show `hello.js`

**Initialize Infrastructure Project (CDKTF)**:
- [ ] Navigate to infrastructure: `cd ../infrastructure`
- [ ] Initialize CDKTF:
  ```bash
  cdktf init --template=typescript --local
  ```
- [ ] Install AWS providers:
  ```bash
  npm install @cdktf/provider-aws @cdktf/provider-archive
  ```
- [ ] Create stacks directory: `mkdir -p stacks`
- [ ] Create initial stack file: `stacks/database-stack.ts` (see SETUP_GUIDE.md)
- [ ] Update `main.ts` to use stack (see SETUP_GUIDE.md)
- [ ] Test CDKTF: `cdktf synth`
- [ ] Verify: `ls cdktf.out/` should show generated Terraform JSON

**Initialize Frontend Project (Angular)**:
- [ ] Navigate to frontend: `cd ../frontend`
- [ ] Create Angular app:
  ```bash
  ng new . --standalone --routing --style=scss --skip-git
  ```
- [ ] Install NgRx:
  ```bash
  npm install @ngrx/store @ngrx/effects @ngrx/store-devtools
  npm install @ngrx/schematics --save-dev
  ```
- [ ] Install Cognito SDK:
  ```bash
  npm install amazon-cognito-identity-js
  npm install -D @types/amazon-cognito-identity-js
  ```
- [ ] Install Dexie:
  ```bash
  npm install dexie
  ```
- [ ] Create feature folder structure:
  ```bash
  cd src/app
  mkdir -p core/auth/{services,guards,interceptors,models,store}
  mkdir -p core/http
  mkdir -p shared/{components,directives,pipes,models}
  mkdir -p features/{dashboard,organizations,projects,tasks}
  mkdir -p store
  ```
- [ ] Test Angular: `ng serve`
- [ ] Open browser: http://localhost:4200
- [ ] Verify: Should see default Angular welcome page

**Update .gitignore**:
- [ ] Verify `.gitignore` includes:
  ```
  # Node
  node_modules/

  # Build outputs
  dist/
  build/

  # Environment variables
  .env
  .env.local

  # AWS
  .aws/
  credentials
  *.pem

  # CDKTF
  .terraform/
  terraform.tfstate*
  cdktf.out/
  .gen/

  # Angular
  /.angular/
  /frontend/dist/
  /frontend/.angular/

  # IDE
  .vscode/
  .idea/
  ```

**Commit Initial Structure**:
- [ ] Navigate to project root: `cd ~/Personal/development/teamflow`
- [ ] Check status: `git status`
- [ ] Stage changes: `git add .`
- [ ] Commit:
  ```bash
  git commit -m "chore: initialize project structure (backend, infrastructure, frontend)"
  ```

### Acceptance Criteria

- [x] Directory structure matches expected layout
- [x] Backend project initialized with TypeScript
- [x] `npm run build` works in backend (creates dist/)
- [ ] Infrastructure project initialized with CDKTF (handled in Story 1.4)
- [ ] `cdktf synth` works (handled in Story 1.4)
- [ ] Frontend project initialized with Angular (handled in Story 1.5)
- [ ] `ng serve` starts dev server successfully (handled in Story 1.5)
- [x] .gitignore properly configured
- [x] Initial commit created

### Dependencies

- Story 1.1 complete (Node.js, npm, CDKTF CLI, Angular CLI installed)
- Story 1.2 complete (AWS credentials configured)

### Definition of Done

- [x] Backend initialized and builds without errors
- [ ] Infrastructure initialized (tracked in Story 1.4)
- [ ] Frontend initialized (tracked in Story 1.5)
- [x] Project structure committed to Git
- [x] Developer can proceed to Story 1.4

### Notes

- **Time Estimate**: 2-3 hours (including npm install times)
- **Disk Space**: ~500MB for node_modules across all projects
- **Common Issues**:
  - Angular CLI prompts: Answer Yes to standalone, Yes to routing, SCSS for styles
  - CDKTF init creates its own package.json, that's expected
  - If `cdktf synth` fails, check AWS credentials are configured

---

## Story 1.4: Initialize Infrastructure (CDKTF)

**Story ID**: EPIC1-004
**Type**: Technical Enablement
**Status**: ✅ DONE

**Story**:
```
As a developer,
I need the infrastructure project initialized with CDKTF and providers configured,
so that I can synthesize Terraform for our stacks.
```

### Tasks

**Completion Summary (Jan 2026)**:
- CDKTF TypeScript project initialized under `infrastructure/`.
- Providers installed: `@cdktf/provider-aws`, `@cdktf/provider-archive`.
- Initial stacks scaffolded and `cdktf synth` runs successfully.
- Infrastructure folder tracked in Git with generated outputs ignored.

### Acceptance Criteria

- [x] CDKTF project initialized with TypeScript template
- [x] Providers installed and imported
- [x] `cdktf synth` succeeds and produces outputs
- [x] Infrastructure folder tracked with `.gitignore` for generated files
- [x] Ready for stack authoring in subsequent epics

### Success Indicators

✅ CDKTF CLI 0.21.0 available
✅ AWS SSO profile works with `cdktf synth`
✅ Archive/AWS providers resolved
✅ Synth output present in `cdktf.out/`

### Dependencies

- Story 1.1 complete (tools installed)
- Story 1.2 complete (AWS configured)
- Story 1.3 complete (project structure initialized)

### Definition of Done

- [x] CDKTF initialized and synth completes
- [x] Providers installed and usable
- [x] Infrastructure repo state clean and committed
- [x] Ready to proceed to Epic 2 (Core Infrastructure)

### Notes

- **Time Estimate**: 30 minutes - 1 hour
- **Purpose**: Catch any setup issues before starting real development
- **Common Issues**:
  - AWS credentials expired: Re-run `aws configure`
  - CDKTF synth fails: Check AWS credentials
  - npm build fails: Clear node_modules and reinstall
  - Angular serve fails: Check port 4200 not in use

---

## Story 1.5: Initialize Frontend (Angular)

**Story ID**: EPIC1-005
**Type**: Technical Enablement
**Status**: ✅ DONE

**Story**:
```
As a developer,
I need the Angular workspace initialized and building successfully,
so that I can start implementing the frontend features.
```

### Tasks

**Completion Summary (Jan 2026)**:
- Angular 21 workspace created with standalone + routing + SCSS.
- Strict TypeScript configuration enabled; default app builds cleanly.
- `npm run build` succeeds; dist artifacts generated.

### Acceptance Criteria

- [x] Angular workspace initialized under `frontend/`
- [x] `npm run build` completes without errors
- [x] Angular CLI 21.1.1 available
- [x] Strict TS config enabled
- [x] Workspace committed to Git

### Definition of Done

- [x] Frontend scaffold created and builds
- [x] Workspace tracked in repo
- [x] Ready for feature development in future sprints

---

## Epic Completion Checklist

When all stories are done, verify:

- [x] **Story 1.1**: ✅ Development tools installed and verified
- [x] **Story 1.2**: ✅ AWS account configured with SSO profiles
- [x] **Story 1.3**: ✅ Backend project initialized
- [x] **Story 1.4**: ✅ Infrastructure project initialized
- [x] **Story 1.5**: ✅ Frontend project initialized

**Epic Status**:
- Change from 📋 TODO → ✅ DONE when all stories complete

**Next Epic**: EPIC_2_CORE_INFRASTRUCTURE.md

---

## Retrospective Notes

(To be filled after epic completion)

**What went well**:
-

**What didn't go well**:
-

**What we learned**:
-

**Improvements for next epic**:
-

**Time taken**: [Actual time spent]

---

**Last Updated**: 2026-01-22
