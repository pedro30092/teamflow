# Lambda Layers & Functions - CDKTF Deployment Pattern

**Last Updated**: 2026-01-25  
**Status**: Tested & Working (Production Ready)

This document provides the complete pattern for deploying Lambda Layers and Lambda Functions using CDKTF with the Terraform Archive Provider.

---

## Overview

Lambda Layers allow you to:
- Share dependencies across multiple Lambda functions
- Reduce deployment package size (faster cold starts)
- Separate dependency management from function code updates
- Package code as zip files automatically via Terraform

This pattern uses the **Archive Provider** to automatically zip source directories during deployment.

---

## Architecture

```
src/backend/
├── functions/
│   └── home/
│       └── get-home.ts          # Handler code (compiled to dist/)
│
├── layers/
│   └── dependencies/
│       └── nodejs/
│           ├── package.json     # npm dependencies
│           └── node_modules/    # Installed packages (in dist for deploy)
│
└── dist/
    ├── functions/
    │   ├── home/
    │   │   └── get-home.js      # Compiled handler
    │   └── home.zip             # Auto-zipped by Archive Provider
    │
    └── layers/
        ├── dependencies.zip     # Auto-zipped by Archive Provider
        └── dependencies/nodejs/ # Source with node_modules
```

---

## Prerequisites: Archive Provider Setup

### Step 1: Add Archive Provider to cdktf.json

Edit `/src/infrastructure/cdktf.json`:

```json
{
  "language": "typescript",
  "app": "npx ts-node main.ts",
  "terraformProviders": [
    "aws@~> 5.0",
    "hashicorp/archive@~> 2.7"
  ],
  "terraformModules": []
}
```

### Step 2: Generate Local Archive Provider Bindings

```bash
cd ~/Personal/development/teamflow/src/infrastructure
cdktf provider add hashicorp/archive --force-local
```

This creates `./.gen/providers/archive/` with TypeScript bindings.

**Why local generation?**
- ✅ No deprecated packages
- ✅ No peer dependency conflicts  
- ✅ Future-proof with any CDKTF version
- ✅ Official Terraform archive provider

**Verify it worked:**
```bash
ls .gen/providers/archive/
# Shows: provider.ts, data-archive-file/, index.ts, etc.
```

---

## CDKTF Stack Implementation

### Imports

```typescript
import { Construct } from "constructs";
import { TerraformStack, TerraformOutput } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { LambdaFunction } from "@cdktf/provider-aws/lib/lambda-function";
import { LambdaLayerVersion } from "@cdktf/provider-aws/lib/lambda-layer-version";
import { LambdaPermission } from "@cdktf/provider-aws/lib/lambda-permission";
import { IamRole } from "@cdktf/provider-aws/lib/iam-role";
import { IamRolePolicyAttachment } from "@cdktf/provider-aws/lib/iam-role-policy-attachment";

// Import from generated local bindings (NOT deprecated packages)
import { ArchiveProvider } from "../.gen/providers/archive/provider";
import { DataArchiveFile } from "../.gen/providers/archive/data-archive-file";

import * as path from "path";
```

### Initialize Providers

```typescript
export class ApiStack extends TerraformStack {
  constructor(scope: Construct, id: string, config: ApiStackConfig) {
    super(scope, id);

    // AWS Provider
    new AwsProvider(this, "aws", {
      region: config.awsRegion,
      profile: config.awsProfile,
    });

    // Archive Provider (required for DataArchiveFile)
    new ArchiveProvider(this, "archive", {});
```

**Important**: Instantiating `ArchiveProvider` is mandatory if you use `DataArchiveFile`. CDKTF validates that resources have matching provider constructs.

### Create Lambda Layer

```typescript
// Step 1: Archive dependencies directory into zip
const dependenciesArchive = new DataArchiveFile(this, "dependencies-archive", {
  type: "zip",
  sourceDir: path.resolve(__dirname, "../../backend/layers/dependencies/nodejs"),
  outputPath: path.resolve(__dirname, "../../dist/layers/dependencies.zip"),
});

// Step 2: Create Lambda layer from archived zip
const dependenciesLayer = new LambdaLayerVersion(this, "dependencies-layer", {
  layerName: `teamflow-dependencies-${config.environment}`,
  filename: dependenciesArchive.outputPath,  // ✅ Use output path
  compatibleRuntimes: ["nodejs24.x"],
  description: "Shared dependencies (AWS SDK, utilities)",
});
```

**Key properties**:
- `sourceDir`: Source directory with `nodejs/node_modules/`
- `outputPath`: Where to write the zip file
- `filename`: Must use `outputPath` (the zip file, not source directory)
- `compatibleRuntimes`: Node.js runtimes this layer supports

### Create Lambda Function

```typescript
// Step 1: Archive function code into zip
const lambdaFunctionArchive = new DataArchiveFile(this, "lambda-function-archive", {
  type: "zip",
  sourceDir: path.resolve(__dirname, "../../backend/dist/functions/home"),
  outputPath: path.resolve(__dirname, "../../dist/functions/home.zip"),
});

// Step 2: Create IAM role for Lambda
const lambdaRole = new IamRole(this, "lambda-role", {
  name: `teamflow-lambda-role-${config.environment}`,
  assumeRolePolicy: JSON.stringify({
    Version: "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: { Service: "lambda.amazonaws.com" },
        Action: "sts:AssumeRole",
      },
    ],
  }),
});

// Step 3: Attach basic execution policy
new IamRolePolicyAttachment(this, "lambda-basic-execution", {
  role: lambdaRole.name,
  policyArn: "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
});

// Step 4: Create Lambda function with layer
const lambdaFunction = new LambdaFunction(this, "get-home-function", {
  functionName: `teamflow-get-home-${config.environment}`,
  runtime: "nodejs24.x",
  architectures: ["arm64"],  // Graviton2: cheaper, faster cold starts
  handler: "get-home.handler",
  role: lambdaRole.arn,
  
  // Code packaging
  filename: lambdaFunctionArchive.outputPath,  // ✅ Use archived zip
  sourceCodeHash: lambdaFunctionArchive.outputBase64Sha256,  // ✅ For redeployments
  
  // Performance
  timeout: 30,
  memorySize: 256,
  
  // Attach layer
  layers: [dependenciesLayer.arn],
  
  // Configuration
  environment: {
    variables: {
      ENVIRONMENT: config.environment,
    },
  },
});
```

**Critical properties**:
- `filename`: Must point to **zip file** (via `DataArchiveFile.outputPath`), not directory
- `sourceCodeHash`: Use `outputBase64Sha256` (camelCase, not `outputBase64sha256`)
- `layers`: Array of layer ARNs to attach
- `architectures`: Use `["arm64"]` for 20% cost savings

---

## Build & Deploy Process

### 1. Prepare Dependencies

```bash
# Install layer dependencies
cd ~/Personal/development/teamflow/src/backend/layers/dependencies/nodejs
npm install --production  # production-only, no devDependencies
```

### 2. Compile Function Code

```bash
cd ~/Personal/development/teamflow/src/backend
npm run build  # TypeScript → dist/functions/
```

### 3. Build Infrastructure

```bash
cd ~/Personal/development/teamflow/src/infrastructure
npm install  # Install CDKTF dependencies
npm run build  # Compile TypeScript stack code
```

### 4. Synthesize Configuration

```bash
cdktf synth  # Generate Terraform JSON
```

### 5. Deploy to AWS

```bash
cdktf deploy --auto-approve
```

**What happens during deploy**:
1. Archive Provider zips `layers/dependencies/nodejs/` → `dist/layers/dependencies.zip`
2. Lambda layer created from zip (~6 seconds)
3. Archive Provider zips `dist/functions/home/` → `dist/functions/home.zip`
4. Lambda function created with layer attached (~5-10 seconds)
5. IAM role and permissions configured
6. Total deployment: ~60-90 seconds

---

## Runtime Behavior

When Lambda executes your function:

1. **Layer extraction**: Layer contents extracted to `/opt/nodejs/`
2. **NODE_PATH**: Node.js automatically includes `/opt/nodejs/node_modules`
3. **Module resolution**: `require('@aws-sdk/client-dynamodb')` resolves from layer
4. **Function code**: Your compiled handler runs with layer dependencies available

Example function:
```typescript
// Handler has access to layer dependencies
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";

export const handler = async (event: any) => {
  const client = new DynamoDBClient({});  // ✅ From layer
  // ... handler code
};
```

---

## Layer Size Management

### Size Limits
- **Per Layer**: 50 MB zipped (250 MB unzipped)
- **Per Function**: Max 5 layers total
- **Total Code**: 250 MB unzipped (all layers + function code)

### Check Layer Size

```bash
# After zipping
ls -lh src/infrastructure/../../dist/layers/dependencies.zip

# If too large, check what's in there
unzip -l dist/layers/dependencies.zip | head -30
```

### Reduce Layer Size

```bash
# 1. Production-only dependencies
cd src/backend/layers/dependencies/nodejs
npm install --production  # Remove devDependencies

# 2. Remove unused packages
npm uninstall @types/node  # If not needed
npm prune --production     # Clean up

# 3. Use bundling (webpack/esbuild) for production
# Future optimization: bundle AWS SDK and utilities together
```

---

## Multiple Layers Pattern

For complex projects, use separate layers:

```typescript
// Layer 1: External dependencies
const dependenciesLayer = new LambdaLayerVersion(this, "dependencies", {
  layerName: `teamflow-dependencies-${config.environment}`,
  filename: depArchive.outputPath,
  compatibleRuntimes: ["nodejs24.x"],
});

// Layer 2: Business logic (domain, use-cases, adapters)
const businessLogicLayer = new LambdaLayerVersion(this, "business-logic", {
  layerName: `teamflow-business-logic-${config.environment}`,
  filename: bizArchive.outputPath,
  compatibleRuntimes: ["nodejs24.x"],
});

// Attach both to function (order matters: listed first = higher priority)
const lambdaFunction = new LambdaFunction(this, "function", {
  // ... config
  layers: [
    businessLogicLayer.arn,    // Loaded first
    dependenciesLayer.arn,     // Loaded second
  ],
});
```

---

## Updating Layers

When dependencies change:

### Process
```bash
# 1. Update package.json
cd src/backend/layers/dependencies/nodejs
npm install --production  # Or: npm uninstall <package>

# 2. Rebuild infrastructure
cd src/infrastructure
npm run build
cdktf synth

# 3. Deploy
cdktf deploy --auto-approve
```

### Automatic Versioning
- CDKTF detects file changes via `DataArchiveFile` hash
- New layer version created automatically
- Old versions preserved (immutable)
- Functions using old versions continue working

Lambda layer versions:
```
arn:aws:lambda:us-east-1:ACCOUNT:layer:teamflow-dependencies:1
arn:aws:lambda:us-east-1:ACCOUNT:layer:teamflow-dependencies:2  (new version)
arn:aws:lambda:us-east-1:ACCOUNT:layer:teamflow-dependencies:3  (newer version)
```

---

## Common Mistakes

### ❌ Mistake 1: Wrong import (deprecated prebuilt package)

```typescript
// WRONG - deprecated, peer dependency conflicts
import { DataArchiveFile } from "@cdktf/provider-archive";
```

**✅ Correct - use locally generated bindings**:
```typescript
import { DataArchiveFile } from "../.gen/providers/archive/data-archive-file";
```

**Why**: Prebuilt bindings locked to CDKTF <0.14.0, conflicts with CDKTF 0.21.0

---

### ❌ Mistake 2: Forgetting ArchiveProvider

```typescript
// If you DON'T instantiate...
// new ArchiveProvider(this, "archive", {});

// ...you get error:
// "Found resources without a matching provider construct. Please make sure 
//  to add provider constructs [e.g. new ArchiveProvider(...)] to your stack"
```

**✅ Always instantiate**:
```typescript
new ArchiveProvider(this, "archive", {});
```

---

### ❌ Mistake 3: Wrong sourceCodeHash property

```typescript
// WRONG - lowercase 'sha'
sourceCodeHash: lambdaFunctionArchive.outputBase64sha256;

// CORRECT - camelCase
sourceCodeHash: lambdaFunctionArchive.outputBase64Sha256;
```

---

### ❌ Mistake 4: Pointing to directory instead of zip

```typescript
// WRONG - directory path
filename: path.resolve(__dirname, "../../backend/dist/functions/home"),

// CORRECT - zip file from DataArchiveFile
filename: lambdaFunctionArchive.outputPath,
```

**Error**: `Error: reading ZIP file (path): is a directory`

---

### ❌ Mistake 5: Including node_modules in function code

```
// WRONG - function archives with node_modules
dist/functions/home/
├── get-home.js
└── node_modules/  # ❌ Don't include!
    └── aws-sdk/

// CORRECT - only compiled handler
dist/functions/home/
└── get-home.js  # ✅ Dependencies come from layer
```

**Why**: Duplicates dependencies, increases package size, slower cold starts

---

## Troubleshooting

### Problem: "is a directory" error

**Error output**:
```
Error: reading ZIP file (assets/lambda-asset/...): 
read assets/lambda-asset/...: is a directory
```

**Cause**: `filename` points to directory, not zip file

**Solution**: 
```typescript
// Use DataArchiveFile output, not source directory
filename: lambdaFunctionArchive.outputPath,  // ✅ This is the zip
```

---

### Problem: Module not found from layer

**Error**:
```
Cannot find module '@aws-sdk/client-dynamodb'
```

**Cause**: Layer not properly attached or wrong structure

**Solution**:
```bash
# Verify layer structure
unzip -l dist/layers/dependencies.zip | grep node_modules
# Should show: nodejs/node_modules/@aws-sdk/...

# Check function has layer attached
aws lambda get-function-configuration \
  --function-name teamflow-get-home-dev \
  | grep -A 5 Layers
```

---

### Problem: Layer exceeds 50 MB

**Cause**: Too many dependencies or devDependencies included

**Solutions**:
```bash
# 1. Remove devDependencies
npm install --production

# 2. Find large packages
npm ls --depth=0  # See top-level dependencies

# 3. Remove unused packages
npm uninstall @types/node  # If not runtime-needed

# 4. Check size
du -sh node_modules  # See directory size
```

---

### Problem: Cold starts are slow

**Causes**: Large layer, too much code, insufficient memory

**Solutions**:
```typescript
// 1. Increase memory (faster CPU, faster code execution)
memorySize: 512,  // Was 256

// 2. Use arm64 (20% faster than x86_64)
architectures: ["arm64"],

// 3. Reduce dependencies in layer
npm uninstall unnecessary-package
```

---

## Testing Locally

### With Environment Variables

```bash
# Set layer path
export NODE_PATH="./src/backend/layers/dependencies/nodejs/node_modules:$NODE_PATH"

# Run handler
node -r ts-node/register src/backend/functions/home/get-home.ts
```

### With AWS SAM

```bash
# Test with local Lambda runtime
sam local invoke GetHomeFunction \
  --event events/api-gateway-event.json \
  --env-vars env.json
```

---

## Performance Optimization

### Cold Start Timeline
- **Layer extraction**: ~200-500ms (Terraform handles zipping)
- **Function initialization**: ~500ms-1s
- **First request**: 1-2 seconds total

### Optimization Strategies
1. **Use arm64**: 20% faster cold starts
2. **Reduce memory usage**: Smaller deployments
3. **Minimize dependencies**: Fewer files to load
4. **Use Lambda SnapStart** (future): When available for Node.js

---

## References

- AWS Lambda Layers: https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
- Terraform Archive Provider: https://registry.terraform.io/providers/hashicorp/archive/latest/docs
- CDKTF Documentation: https://developer.hashicorp.com/terraform/cdktf
- Node.js Module Resolution: https://nodejs.org/api/modules.html

---

## Document Metadata

- **Created**: 2026-01-25
- **Last Updated**: 2026-01-25
- **Status**: Tested & Production Ready
- **Related**: `src/infrastructure/stacks/api-stack.ts` (Implementation)
- **Tested With**: CDKTF 0.21.0, Terraform 1.7+, Node.js 24.x

