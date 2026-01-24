# Epic 1: Development Environment Setup

**Epic ID**: EPIC-1
**Type**: Technical Enablement
**Phase**: Prerequisites (Before Phase 1)
**Duration**: 1-2 days
**Status**: 📋 TODO

---

## Epic Overview

**Goal**: Get the local development environment ready for building TeamFlow

**Why This Matters**: Before writing any code, developers need all tools installed, AWS configured, and project structure initialized. This epic ensures everyone can build and deploy the application.

**Success Criteria**:
- [ ] All development tools installed (Node.js, AWS CLI, CDKTF, Angular CLI)
- [ ] AWS account configured with IAM credentials
- [ ] Project structure initialized (backend/, infrastructure/, frontend/)
- [ ] All verification checks in SETUP_GUIDE.md pass
- [ ] Developer can run: `cdktf synth`, `npm run build`, `ng serve`

**Reference**: SETUP_GUIDE.md

---

## Stories in This Epic

### Story 1.1: Install Development Tools
### Story 1.2: Configure AWS Account
### Story 1.3: Initialize Project Structure
### Story 1.4: Verify Development Environment

---

## Story 1.1: Install Development Tools

**Story ID**: EPIC1-001
**Type**: Technical Enablement
**Status**: 📋 TODO

**Story**:
```
As a developer,
I need Node.js 20.x, AWS CLI v2, CDKTF CLI, and Angular CLI installed,
so that I can build and deploy the application.
```

### Tasks

**Node.js Installation**:
- [ ] Install Node.js 20.x LTS using nvm (recommended)
  ```bash
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
  nvm install 20
  nvm use 20
  nvm alias default 20
  ```
- [ ] Verify Node.js version: `node --version` (should show v20.x.x)
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

- [ ] `node --version` returns v20.x.x
- [ ] `npm --version` returns 10.x.x
- [ ] `git --version` returns any recent version
- [ ] `aws --version` returns 2.x.x
- [ ] `cdktf --version` returns latest version
- [ ] `ng version` returns 18.x.x
- [ ] Git is configured with user name and email

### Dependencies

- None (this is the starting point)

### Definition of Done

- [ ] All commands above return expected versions
- [ ] Tools are accessible from terminal/command prompt
- [ ] VS Code (or chosen IDE) is configured
- [ ] Developer can proceed to Story 1.2

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
**Status**: 📋 TODO

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

- [ ] AWS account created and accessible
- [ ] Billing alarms configured and confirmed (check email)
- [ ] IAM user created with programmatic access
- [ ] Credentials CSV downloaded and stored securely
- [ ] AWS CLI configured: `aws sts get-caller-identity` returns account info
- [ ] Response includes: UserId, Account number, IAM user ARN

### Security Checklist

- [ ] MFA enabled on root account
- [ ] Root account not used for development
- [ ] IAM user credentials stored securely
- [ ] Billing alarms active to prevent surprise charges
- [ ] .gitignore includes AWS credential files

### Dependencies

- Story 1.1 complete (AWS CLI installed)

### Definition of Done

- [ ] AWS CLI authenticated successfully
- [ ] `aws sts get-caller-identity` returns correct account
- [ ] Billing alarms confirmed via email
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
**Status**: 📋 TODO

**Story**:
```
As a developer,
I need the project structure initialized (backend/, infrastructure/, frontend/),
so that I can organize code properly and start building.
```

### Tasks

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

- [ ] Directory structure matches expected layout
- [ ] Backend project initialized with TypeScript
- [ ] `npm run build` works in backend (creates dist/)
- [ ] Infrastructure project initialized with CDKTF
- [ ] `cdktf synth` works (creates cdktf.out/)
- [ ] Frontend project initialized with Angular
- [ ] `ng serve` starts dev server successfully
- [ ] .gitignore properly configured
- [ ] Initial commit created

### Dependencies

- Story 1.1 complete (Node.js, npm, CDKTF CLI, Angular CLI installed)
- Story 1.2 complete (AWS credentials configured)

### Definition of Done

- [ ] All three projects (backend, infrastructure, frontend) initialized
- [ ] All build commands work without errors
- [ ] Project structure committed to Git
- [ ] Developer can proceed to Story 1.4 (verification)

### Notes

- **Time Estimate**: 2-3 hours (including npm install times)
- **Disk Space**: ~500MB for node_modules across all projects
- **Common Issues**:
  - Angular CLI prompts: Answer Yes to standalone, Yes to routing, SCSS for styles
  - CDKTF init creates its own package.json, that's expected
  - If `cdktf synth` fails, check AWS credentials are configured

---

## Story 1.4: Verify Development Environment

**Story ID**: EPIC1-004
**Type**: Technical Enablement
**Status**: 📋 TODO

**Story**:
```
As a developer,
I need to verify all setup steps completed successfully,
so that I can confidently start Phase 1 development.
```

### Tasks

**Run Verification Checklist**:
- [ ] Navigate to project root: `cd ~/Personal/development/teamflow`
- [ ] Run core tools verification:
  ```bash
  node --version          # Should be v20.x.x
  npm --version           # Should be 10.x.x
  git --version           # Any recent version
  aws --version           # Should be 2.x.x
  ng version              # Should be 18.x.x
  cdktf --version         # Latest version
  ```
- [ ] Verify AWS authentication:
  ```bash
  aws sts get-caller-identity
  # Should return account info (UserId, Account, Arn)
  ```
- [ ] Verify CDKTF works:
  ```bash
  cd infrastructure && cdktf synth && cd ..
  # Should generate Terraform JSON without errors
  ```
- [ ] Verify backend builds:
  ```bash
  cd backend && npm run build && cd ..
  # Should compile TypeScript without errors
  # Should create dist/ folder
  ```
- [ ] Verify frontend runs:
  ```bash
  cd frontend && ng serve
  # Should start dev server on http://localhost:4200
  # Open browser and verify Angular welcome page appears
  # Press Ctrl+C to stop
  ```
- [ ] Verify Git status:
  ```bash
  git status
  # Should show clean working tree or only untracked files
  ```

**Check Project Structure**:
- [ ] Verify directory structure exists:
  ```bash
  ls -la
  # Should see: backend/, infrastructure/, frontend/, research/, .git/
  ```
- [ ] Verify backend structure:
  ```bash
  ls backend/
  # Should see: functions/, layers/, package.json, tsconfig.json, node_modules/, dist/
  ```
- [ ] Verify infrastructure structure:
  ```bash
  ls infrastructure/
  # Should see: stacks/, main.ts, cdktf.json, package.json, node_modules/, cdktf.out/
  ```
- [ ] Verify frontend structure:
  ```bash
  ls frontend/
  # Should see: src/, angular.json, package.json, node_modules/
  ```

**Document Environment Details**:
- [ ] Create `DEVELOPMENT_ENVIRONMENT.md` in project root:
  ```markdown
  # Development Environment Details

  **Last Verified**: [Date]
  **Developer**: [Your Name]

  ## Installed Versions
  - Node.js: [version from node --version]
  - npm: [version from npm --version]
  - AWS CLI: [version from aws --version]
  - Angular CLI: [version from ng version]
  - CDKTF: [version from cdktf --version]

  ## AWS Account
  - Account ID: [from aws sts get-caller-identity]
  - IAM User: [your IAM username]
  - Default Region: us-east-1

  ## Verification Status
  - [x] All tools installed
  - [x] AWS authenticated
  - [x] CDKTF synth works
  - [x] Backend builds
  - [x] Frontend runs
  - [x] Git initialized

  **Status**: ✅ Ready for Phase 1
  ```

**Bookmark Reference Documentation**:
- [ ] Save these URLs for quick reference:
  - AWS Lambda Docs: https://docs.aws.amazon.com/lambda/
  - DynamoDB Docs: https://docs.aws.amazon.com/dynamodb/
  - CDKTF Docs: https://developer.hashicorp.com/terraform/cdktf
  - AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/
  - Angular Docs: https://angular.dev
  - NgRx Docs: https://ngrx.io

**Final Commit**:
- [ ] Add environment documentation:
  ```bash
  git add DEVELOPMENT_ENVIRONMENT.md
  git commit -m "docs: add development environment verification"
  ```

### Acceptance Criteria

- [ ] All verification commands pass without errors
- [ ] CDKTF generates Terraform JSON successfully
- [ ] Backend compiles TypeScript successfully
- [ ] Frontend dev server starts and displays default page
- [ ] AWS credentials validated
- [ ] Git repository is clean
- [ ] DEVELOPMENT_ENVIRONMENT.md created and committed

### Success Indicators

**All Green?**:
✅ Node.js 20.x installed
✅ AWS CLI 2.x installed
✅ AWS credentials configured
✅ CDKTF synth works
✅ Backend builds
✅ Frontend runs
✅ Git initialized

**If All Green**: 🎉 Ready to start Phase 1!

**If Any Red**: Review SETUP_GUIDE.md troubleshooting section

### Dependencies

- Story 1.1 complete (tools installed)
- Story 1.2 complete (AWS configured)
- Story 1.3 complete (project structure initialized)

### Definition of Done

- [ ] All verification checks pass
- [ ] Environment documented
- [ ] Developer confirms readiness
- [ ] **EPIC 1 COMPLETE** ✅
- [ ] Ready to proceed to Epic 2 (Core Infrastructure)

### Notes

- **Time Estimate**: 30 minutes - 1 hour
- **Purpose**: Catch any setup issues before starting real development
- **Common Issues**:
  - AWS credentials expired: Re-run `aws configure`
  - CDKTF synth fails: Check AWS credentials
  - npm build fails: Clear node_modules and reinstall
  - Angular serve fails: Check port 4200 not in use

---

## Epic Completion Checklist

When all stories are done, verify:

- [ ] **Story 1.1**: ✅ Development tools installed and verified
- [ ] **Story 1.2**: ✅ AWS account configured with IAM credentials
- [ ] **Story 1.3**: ✅ Project structure initialized
- [ ] **Story 1.4**: ✅ All verification checks pass

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
