# Lambda Dependencies Layer

This layer contains shared dependencies for all Lambda functions.

## Structure

```
layers/dependencies/
└── nodejs/
    ├── package.json          # Shared dependencies
    └── node_modules/         # Installed by npm (gitignored)
```

## Why Lambda Layers?

**Advantages**:
- ✅ Reduces function deployment size (faster cold starts)
- ✅ Share dependencies across multiple functions
- ✅ Separate dependency updates from function code updates
- ✅ AWS best practice for production serverless apps

**Layer Location**: Lambda runtime mounts layers at `/opt/nodejs/node_modules`

## Build Process

```bash
# Install dependencies for the layer
cd src/backend/layers/dependencies/nodejs
npm install

# CDKTF will package the entire nodejs/ folder as a layer
```

## Usage in Functions

Functions can import from the layer:

```typescript
// No need to install in function's package.json
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient } from '@aws-sdk/lib-dynamodb';

// Layer dependencies are available at runtime via /opt/nodejs/node_modules
```

## Updating Dependencies

1. Update version in `layers/dependencies/nodejs/package.json`
2. Run `npm install` in the nodejs folder
3. Redeploy CDKTF stack (new layer version created)
4. Lambda functions automatically use new layer version

## Size Limits

- **Zipped**: 50 MB per layer (250 MB unzipped)
- **Total**: Max 5 layers per Lambda function
- **Current Size**: ~5 MB zipped (AWS SDK v3)

If layer exceeds 50 MB:
- Split into multiple layers (dependencies, business-logic)
- Remove unused dependencies
- Use tree-shaking via bundlers
