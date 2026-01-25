# Lambda Layers - CDKTF Pattern Reference

This document shows how to create and attach Lambda Layers using CDKTF.

## Overview

Lambda Layers allow you to:
- Share dependencies across multiple Lambda functions
- Reduce deployment package size (faster cold starts)
- Separate dependency management from function code updates

## Folder Structure

```
src/backend/
├── functions/
│   └── home/
│       └── get-home.ts          # Handler code only
├── layers/
│   └── dependencies/
│       └── nodejs/
│           ├── package.json     # Dependencies
│           └── node_modules/    # Installed packages (gitignored)
└── dist/
    ├── functions/
    │   └── home/
    │       └── get-home.js      # Compiled handler
    └── layers/
        └── dependencies/        # (Optional, if you compile layer)
```

## CDKTF Implementation

### Step 1: Package Dependencies Layer

```typescript
import { DataArchiveFile } from '@cdktf/provider-archive/lib/data-archive-file';
import { LambdaLayerVersion } from '@cdktf/provider-aws/lib/lambda-layer-version';

// Package the dependencies layer
const dependenciesLayerArchive = new DataArchiveFile(this, 'dependencies_layer_archive', {
  type: 'zip',
  sourceDir: path.resolve(__dirname, '../../backend/layers/dependencies/nodejs'),
  outputPath: path.resolve(__dirname, '../../backend/dist/layers/dependencies.zip'),
});

// Create Lambda layer
const dependenciesLayer = new LambdaLayerVersion(this, 'dependencies_layer', {
  layerName: 'teamflow-dependencies',
  compatibleRuntimes: ['nodejs20.x'],
  filename: dependenciesLayerArchive.outputPath,
  description: 'Shared dependencies (AWS SDK, etc.)',
});
```

### Step 2: Package Lambda Function

```typescript
import { DataArchiveFile } from '@cdktf/provider-archive/lib/data-archive-file';
import { LambdaFunction } from '@cdktf/provider-aws/lib/lambda-function';

// Package the function code (no node_modules)
const functionArchive = new DataArchiveFile(this, 'function_archive', {
  type: 'zip',
  sourceDir: path.resolve(__dirname, '../../backend/dist/functions/home'),
  outputPath: path.resolve(__dirname, '../../backend/dist/home-function.zip'),
});

// Create Lambda function with layer attached
const lambdaFunction = new LambdaFunction(this, 'get_home_lambda', {
  functionName: 'teamflow-get-home',
  runtime: 'nodejs20.x',
  architectures: ['arm64'],
  handler: 'get-home.handler',
  filename: functionArchive.outputPath,
  sourceCodeHash: functionArchive.outputBase64Sha256,
  
  // Attach the dependencies layer
  layers: [dependenciesLayer.arn],
  
  // Memory and timeout
  memorySize: 256,
  timeout: 30,
  
  // IAM role
  role: lambdaRole.arn,
  
  // Environment variables
  environment: {
    variables: {
      NODE_ENV: 'production',
    },
  },
  
  tags: {
    Environment: 'dev',
    ManagedBy: 'CDKTF',
  },
});
```

## Build Process

### 1. Install Layer Dependencies

```bash
cd src/backend/layers/dependencies/nodejs
npm install --production
```

### 2. Build Function Code

```bash
cd src/backend
npm run build  # TypeScript → dist/functions/
```

### 3. Deploy with CDKTF

```bash
cd src/infrastructure
cdktf deploy api-stack
```

CDKTF will:
1. Package `layers/dependencies/nodejs/` → `dependencies.zip`
2. Create Lambda layer from zip
3. Package `dist/functions/home/` → `home-function.zip`
4. Create Lambda function with layer attached

## Layer Runtime Behavior

When Lambda executes:
1. Layer contents extracted to `/opt/nodejs/node_modules`
2. Function code can import: `import { DynamoDBClient } from '@aws-sdk/client-dynamodb'`
3. Node.js automatically resolves from `/opt/nodejs/node_modules`

## Layer Size Limits

- **Per Layer**: 50 MB zipped (250 MB unzipped)
- **Total Layers**: Max 5 layers per function
- **Total Size**: 250 MB unzipped (all layers + function code)

Current sizes:
- AWS SDK v3: ~5 MB zipped
- Typical business logic layer: ~2-10 MB zipped

## Multiple Layers Pattern

For large projects, use multiple layers:

```typescript
// Layer 1: External dependencies (AWS SDK, date-fns, etc.)
const dependenciesLayer = new LambdaLayerVersion(this, 'dependencies', {
  layerName: 'teamflow-dependencies',
  sourceDir: '../../backend/layers/dependencies/nodejs',
});

// Layer 2: Shared business logic (domain, use-cases, adapters)
const businessLogicLayer = new LambdaLayerVersion(this, 'business_logic', {
  layerName: 'teamflow-business-logic',
  sourceDir: '../../backend/layers/business-logic/nodejs',
});

// Attach both layers to function
const lambdaFunction = new LambdaFunction(this, 'lambda', {
  functionName: 'teamflow-function',
  layers: [
    dependenciesLayer.arn,
    businessLogicLayer.arn,
  ],
  // ...
});
```

## Updating Layers

When dependencies change:

1. Update `layers/dependencies/nodejs/package.json`
2. Run `npm install` in nodejs folder
3. Redeploy CDKTF stack

CDKTF creates a new layer version automatically. Lambda functions get updated to use the new version.

## Layer Versioning

Lambda layers are immutable and versioned:
- `arn:aws:lambda:us-east-1:123456:layer:teamflow-dependencies:1`
- `arn:aws:lambda:us-east-1:123456:layer:teamflow-dependencies:2`

CDKTF automatically handles versioning. Each deployment creates a new version if layer content changes.

## Testing Locally

Test functions with layers:

```bash
# 1. Install dependencies in layer
cd src/backend/layers/dependencies/nodejs
npm install

# 2. Set NODE_PATH to include layer
export NODE_PATH="$PWD/src/backend/layers/dependencies/nodejs/node_modules:$NODE_PATH"

# 3. Run function locally
node -r ts-node/register src/backend/functions/home/get-home.ts
```

Or use AWS SAM for local testing:

```bash
sam local invoke GetHomeFunction --event events/api-gateway-event.json
```

## Troubleshooting

**Issue**: Function can't find module from layer

**Solution**: Ensure layer structure is correct:
```
nodejs/
└── node_modules/
    └── @aws-sdk/
        └── client-dynamodb/
```

**Issue**: Layer exceeds 50 MB

**Solution**:
- Run `npm install --production` (remove devDependencies)
- Split into multiple layers
- Remove unused dependencies
- Use bundler (webpack/esbuild) to tree-shake

**Issue**: Cold starts still slow

**Solution**:
- Reduce layer size (fewer dependencies)
- Use Provisioned Concurrency (costs extra)
- Consider Lambda SnapStart (when available for Node.js)

## References

- AWS Lambda Layers: https://docs.aws.amazon.com/lambda/latest/dg/chapter-layers.html
- CDKTF LambdaLayerVersion: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version
- Node.js Module Resolution: https://nodejs.org/api/modules.html#loading-from-node_modules-folders
