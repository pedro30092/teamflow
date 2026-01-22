# TeamFlow - Development Environment Setup Guide

**Last Updated**: 2026-01-22

This guide walks you through setting up your development environment for TeamFlow. Complete these steps before starting Phase 1 of the development roadmap.

**Reference**: See [DEVELOPMENT_ROADMAP_SERVERLESS.md](research/DEVELOPMENT_ROADMAP_SERVERLESS.md) for the tech stack versions and development phases.

---

## Prerequisites Overview

**Time Required**: 1-2 days (depending on familiarity with tools)

**What You'll Set Up**:
- Development tools (Node.js, CLI tools, IDE)
- AWS account and credentials
- CDKTF infrastructure project
- Backend TypeScript project
- Angular frontend project

---

## Step 1: Install Core Development Tools

### 1.1 Node.js

**Install Node.js 20.x LTS** (see roadmap for exact version)

**macOS/Linux**:
```bash
# Using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
nvm alias default 20

# Verify
node --version  # Should show v20.x.x
npm --version   # Should show 10.x.x
```

**Windows**:
- Download from https://nodejs.org/
- Install LTS version
- Verify in CMD: `node --version`

### 1.2 Git

**Configure Git** (if not already done):
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify
git config --list
```

### 1.3 VS Code (Recommended)

**Install VS Code**: https://code.visualstudio.com/

**Recommended Extensions**:
- ESLint
- Prettier
- TypeScript
- Angular Language Service
- HashiCorp Terraform (for CDKTF)
- AWS Toolkit (optional)

### 1.4 AWS CLI v2

**Install AWS CLI**:

**macOS**:
```bash
brew install awscli
```

**Linux**:
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows**:
- Download from https://aws.amazon.com/cli/
- Run installer

**Verify**:
```bash
aws --version  # Should show aws-cli/2.x.x
```

### 1.5 API Testing Tool (Choose One)

- **Postman**: https://www.postman.com/downloads/
- **Insomnia**: https://insomnia.rest/download
- **Thunder Client** (VS Code extension)
- **cURL** (command line, already installed on macOS/Linux)

### 1.6 Optional Tools

**Docker** (for DynamoDB Local testing):
```bash
# macOS
brew install --cask docker

# Linux
sudo apt-get install docker.io

# Verify
docker --version
```

---

## Step 2: AWS Account Setup

### 2.1 Create AWS Account

1. Go to https://aws.amazon.com/
2. Click "Create an AWS Account"
3. Follow the registration process
4. **Important**: You'll need a credit card (for verification, free tier available)

### 2.2 Set Up Billing Alarms (Critical!)

**Before deploying anything, set up billing alarms**:

1. Log in to AWS Console
2. Go to **CloudWatch** service
3. Navigate to **Alarms** → **Billing**
4. Create alarms:
   - $5 threshold
   - $10 threshold
   - $20 threshold
5. Enter your email for notifications
6. Confirm email subscription

### 2.3 Create IAM User for Development

**Never use root account for development**:

1. Go to **IAM** service
2. Click **Users** → **Add User**
3. Username: `teamflow-dev` (or your name)
4. Access type: **Programmatic access** (access key)
5. Permissions: **AdministratorAccess** (for simplicity in dev)
   - *Note: In production, use least privilege*
6. **Download credentials CSV** (keep it safe!)

### 2.4 Enable MFA

1. IAM → Users → Select root account
2. Security credentials → Enable MFA
3. Use authenticator app (Google Authenticator, Authy, etc.)

### 2.5 Configure AWS CLI

```bash
aws configure

# Enter when prompted:
AWS Access Key ID: [from CSV]
AWS Secret Access Key: [from CSV]
Default region: us-east-1
Default output format: json
```

**Verify configuration**:
```bash
aws sts get-caller-identity

# Should return:
# {
#   "UserId": "AIDAXXXXXXXXXX",
#   "Account": "123456789012",
#   "Arn": "arn:aws:iam::123456789012:user/teamflow-dev"
# }
```

**Important**: Never commit AWS credentials to Git!

---

## Step 3: Project Structure Setup

### 3.1 Create Repository Structure

```bash
# Navigate to where you want the project
cd ~/projects  # or your preferred location

# Create main folder (if not exists)
mkdir -p teamflow
cd teamflow

# Create folder structure
mkdir -p backend/functions
mkdir -p backend/layers/business-logic/nodejs/node_modules/@teamflow/core
mkdir -p backend/layers/dependencies/nodejs/node_modules
mkdir -p infrastructure/stacks
mkdir -p frontend

# Verify structure
tree -L 2  # or ls -R
```

Expected structure:
```
teamflow/
├── backend/
│   ├── functions/
│   └── layers/
├── infrastructure/
│   └── stacks/
├── frontend/
└── research/ (already exists)
```

### 3.2 Initialize Git

```bash
cd teamflow

# If not already a git repo
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Node
node_modules/
npm-debug.log
yarn-error.log

# Build outputs
dist/
build/
*.js.map

# Environment variables
.env
.env.local
.env.*.local

# AWS
.aws/
*.pem
credentials

# CDKTF
.terraform/
terraform.tfstate*
cdktf.out/
.gen/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Angular
/.angular/
/frontend/dist/
/frontend/.angular/

# Logs
logs/
*.log
EOF

git add .gitignore
git commit -m "Initial commit: project structure"
```

---

## Step 4: Infrastructure Setup (CDKTF)

### 4.1 Install CDKTF CLI

```bash
npm install -g cdktf-cli@latest

# Verify
cdktf --version
```

### 4.2 Initialize CDKTF Project

```bash
cd infrastructure

# Initialize CDKTF
cdktf init --template=typescript --local

# This creates:
# - main.ts (entry point)
# - cdktf.json (config)
# - package.json
# - tsconfig.json
```

### 4.3 Install AWS Providers

```bash
cd infrastructure

npm install @cdktf/provider-aws @cdktf/provider-archive

# Verify package.json includes these dependencies
cat package.json
```

### 4.4 Create Stack Structure

```bash
cd infrastructure

# Create stacks folder
mkdir -p stacks

# Create initial stack file
cat > stacks/database-stack.ts << 'EOF'
import { Construct } from 'constructs';
import { TerraformStack } from 'cdktf';
import { AwsProvider } from '@cdktf/provider-aws/lib/provider';

export class DatabaseStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    new AwsProvider(this, 'aws', {
      region: 'us-east-1',
    });

    // DynamoDB table will be added here in Phase 1
  }
}
EOF

# Update main.ts to use the stack
cat > main.ts << 'EOF'
import { App } from 'cdktf';
import { DatabaseStack } from './stacks/database-stack';

const app = new App();
new DatabaseStack(app, 'teamflow-database-dev');
app.synth();
EOF
```

### 4.5 Test CDKTF

```bash
cd infrastructure

# Generate Terraform configuration
cdktf synth

# Should create cdktf.out/ folder with Terraform JSON
ls cdktf.out/

# Expected output: stacks/teamflow-database-dev/
```

**Success**: If `cdktf synth` completes without errors, CDKTF is ready!

---

## Step 5: Backend Setup

### 5.1 Initialize Backend Project

```bash
cd backend

# Initialize npm project
npm init -y

# Install TypeScript and types
npm install -D typescript @types/node @types/aws-lambda

# Install AWS SDK v3
npm install @aws-sdk/client-dynamodb @aws-sdk/lib-dynamodb

# Install development tools
npm install -D eslint prettier @typescript-eslint/eslint-plugin @typescript-eslint/parser
```

### 5.2 Configure TypeScript

Create `backend/tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "types": ["node"]
  },
  "include": ["functions/**/*", "layers/**/*"],
  "exclude": ["node_modules", "dist", "cdk.out"]
}
```

### 5.3 Configure ESLint

Create `backend/.eslintrc.js`:
```javascript
module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
  },
  env: {
    node: true,
    es6: true,
  },
  rules: {
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
  },
};
```

### 5.4 Add Build Scripts

Update `backend/package.json` scripts:
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

### 5.5 Test Backend Build

```bash
cd backend

# Create a test file
mkdir -p functions/test
cat > functions/test/hello.ts << 'EOF'
export const handler = async () => {
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello from Lambda!' }),
  };
};
EOF

# Build
npm run build

# Should create dist/ folder
ls dist/functions/test/
```

**Success**: If `npm run build` completes without errors, backend is ready!

---

## Step 6: Frontend Setup (Angular)

### 6.1 Install Angular CLI

```bash
npm install -g @angular/cli@18

# Verify (check roadmap for exact version)
ng version
```

### 6.2 Create Angular Project

```bash
cd teamflow/frontend

# Create Angular app (if not exists)
ng new . --standalone --routing --style=scss --skip-git

# If folder already exists and empty:
# Answer prompts:
# - Standalone: Yes
# - Routing: Yes
# - Style: SCSS
```

### 6.3 Install NgRx

```bash
cd frontend

npm install @ngrx/store @ngrx/effects @ngrx/store-devtools
npm install @ngrx/schematics --save-dev
```

### 6.4 Install Other Dependencies

```bash
cd frontend

# Cognito SDK
npm install amazon-cognito-identity-js
npm install -D @types/amazon-cognito-identity-js

# Dexie (IndexedDB)
npm install dexie
```

### 6.5 Create Feature Folder Structure

```bash
cd frontend/src/app

mkdir -p core/auth/{services,guards,interceptors,models,store}
mkdir -p core/http
mkdir -p shared/{components,directives,pipes,models}
mkdir -p features/{dashboard,organizations,projects,tasks}
mkdir -p store
```

Expected structure:
```
src/app/
├── core/
│   ├── auth/
│   │   ├── services/
│   │   ├── guards/
│   │   ├── interceptors/
│   │   ├── models/
│   │   └── store/
│   └── http/
├── shared/
│   ├── components/
│   ├── directives/
│   ├── pipes/
│   └── models/
├── features/
│   ├── dashboard/
│   ├── organizations/
│   ├── projects/
│   └── tasks/
└── store/
```

### 6.6 Test Frontend

```bash
cd frontend

# Start dev server
ng serve

# Open browser: http://localhost:4200
# Should see default Angular welcome page
```

**Success**: If Angular app runs without errors, frontend is ready!

---

## Step 7: Reference Materials

### 7.1 Documentation Bookmarks

Save these links:

**CDKTF**:
- Official docs: https://developer.hashicorp.com/terraform/cdktf
- AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/

**AWS**:
- Lambda: https://docs.aws.amazon.com/lambda/
- DynamoDB: https://docs.aws.amazon.com/dynamodb/
- API Gateway: https://docs.aws.amazon.com/apigateway/
- Cognito: https://docs.aws.amazon.com/cognito/

**Frontend**:
- Angular: https://angular.dev
- NgRx: https://ngrx.io
- RxJS: https://rxjs.dev

**DynamoDB Learning**:
- "The DynamoDB Book" by Alex DeBrie: https://www.dynamodbbook.com/

### 7.2 Local Reference Files

Keep these files open in VS Code:
- `research/TECHNICAL_ARCHITECTURE_SERVERLESS.md` (architecture reference)
- `research/DEVELOPMENT_ROADMAP_SERVERLESS.md` (feature roadmap)
- `research/PRODUCT_OVERVIEW.md` (product context)

---

## Step 8: Verification Checklist

Run these commands to verify everything is set up:

```bash
# Core tools
node --version          # Should be v20.x.x
npm --version           # Should be 10.x.x
git --version           # Any recent version
aws --version           # Should be 2.x.x
ng version              # Should be 18.x.x
cdktf --version         # Latest version

# AWS authentication
aws sts get-caller-identity  # Should return your account info

# CDKTF works
cd infrastructure && cdktf synth  # Should generate Terraform JSON

# Backend builds
cd backend && npm run build       # Should compile without errors

# Frontend runs
cd frontend && ng serve           # Should start dev server

# Git initialized
git status                        # Should show clean working tree
```

**All green?** You're ready to start Phase 1!

---

## Troubleshooting

### AWS CLI Not Authenticated

**Error**: `Unable to locate credentials`

**Solution**:
```bash
aws configure
# Re-enter credentials from IAM user CSV
```

### CDKTF Synth Fails

**Error**: `Provider not found`

**Solution**:
```bash
cd infrastructure
npm install @cdktf/provider-aws @cdktf/provider-archive
```

### Node Version Issues

**Error**: `Unsupported engine`

**Solution**:
```bash
nvm install 20
nvm use 20
nvm alias default 20
```

### Permission Denied (macOS/Linux)

**Error**: `EACCES: permission denied`

**Solution**:
```bash
# Fix npm permissions
sudo chown -R $USER ~/.npm
```

### Angular CLI Not Found

**Error**: `ng: command not found`

**Solution**:
```bash
npm install -g @angular/cli@18
# Restart terminal
```

---

## Next Steps

Once all verification checks pass:

1. **Commit your setup**:
   ```bash
   git add .
   git commit -m "chore: initial project setup complete"
   ```

2. **Review the tech stack** in `research/DEVELOPMENT_ROADMAP_SERVERLESS.md`

3. **Start Phase 1**: Infrastructure + Authentication
   - See `research/DEVELOPMENT_ROADMAP_SERVERLESS.md` for detailed tasks

4. **Keep references handy**:
   - TECHNICAL_ARCHITECTURE_SERVERLESS.md
   - "The DynamoDB Book"
   - AWS/CDKTF documentation

---

## Support

**Stuck?** Check these resources:
- Review error messages carefully (they're usually helpful)
- Consult AWS/CDKTF documentation
- Check GitHub issues for similar problems
- Review TECHNICAL_ARCHITECTURE_SERVERLESS.md for architecture guidance

**Ready to build!** 🚀
