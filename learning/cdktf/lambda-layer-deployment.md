# How to Deploy Lambda Layers & Functions with CDKTF & Archive Provider

**Document Purpose**: A personal walkthrough of how to properly deploy Lambda layers and Lambda functions using CDKTF with the archive provider. Use this whenever you need to repeat or understand the deployment process.

**Last Updated**: 2026-01-25
**Status**: Tested & Working in Production

---

## The Journey: From Problem to Solution

### The Problem We Had
We needed to package Lambda layer dependencies and Lambda function code as zip files for AWS deployment. Initially, we tried:
1. Manual zip creation (tedious, error-prone)
2. Pre-built `@cdktf/provider-archive` package (deprecated, peer dependency conflicts with CDKTF 0.21.0)

### The Solution We Chose
Generate local Terraform archive provider bindings using CDKTF's built-in provider generation. This gives us:
- ✅ No deprecated packages
- ✅ No peer dependency conflicts
- ✅ Full compatibility with CDKTF 0.21.0+
- ✅ Automatic zipping via `DataArchiveFile`
- ✅ Future-proof (works with any future CDKTF version)

---

## Step-by-Step: How We Did It

### Step 1: Add Archive Provider to cdktf.json

Edit `/src/infrastructure/cdktf.json`:

```json
{
  "language": "typescript",
  "app": "npx ts-node main.ts",
  "projectId": "ad9dccab-3c71-4883-b9b6-db9c63f6e5f9",
  "sendCrashReports": "false",
  "terraformProviders": [
    "aws@~> 5.0",
    "hashicorp/archive@~> 2.7"
  ],
  "terraformModules": [],
  "context": {}
}
```

**Why**: Tells CDKTF which Terraform providers to generate local bindings for.

---

### Step 2: Generate Local Archive Provider Bindings

Run this command:

```bash
cd ~/Personal/development/teamflow/src/infrastructure
cdktf provider add hashicorp/archive --force-local
```

**What happens**:
- CDKTF downloads the Terraform archive provider definition
- Generates TypeScript bindings in `./.gen/providers/archive/`
- Creates `provider.ts` and `data-archive-file/index.ts`

**Verify it worked**:
```bash
ls .gen/providers/archive/
# Should show: data-archive-file, provider.ts, index.ts, etc.
```

---

### Step 3: Import Archive Provider in Your Stack

In `/src/infrastructure/stacks/api-stack.ts`, add these imports:

```typescript
import { ArchiveProvider } from "../.gen/providers/archive/provider";
import { DataArchiveFile } from "../.gen/providers/archive/data-archive-file";
```

**Why**: Gives you access to the generated provider and data source classes.

---

### Step 4: Instantiate the Archive Provider

Inside your stack constructor, right after the AWS provider:

```typescript
// AWS Provider
new AwsProvider(this, "aws", {
  region: config.awsRegion,
  profile: config.awsProfile,
});

// Archive Provider (for zipping Lambda layers)
new ArchiveProvider(this, "archive", {});
```

**Why**: CDKTF validates that any resources using a provider have the provider instantiated in the stack.

---

### Step 5: Create Lambda Layer Using DataArchiveFile

This is the key pattern for layers:

```typescript
// Archive dependencies directory into zip using DataArchiveFile
const dependenciesArchive = new DataArchiveFile(this, "dependencies-archive", {
  type: "zip",
  sourceDir: path.resolve(__dirname, "../../backend/layers/dependencies/nodejs"),
  outputPath: path.resolve(__dirname, "../../dist/layers/dependencies.zip"),
});

// Dependencies layer (AWS SDK, shared packages) from archived zip
const dependenciesLayer = new LambdaLayerVersion(this, "dependencies-layer", {
  layerName: `teamflow-dependencies-${config.environment}`,
  filename: dependenciesArchive.outputPath,
  compatibleRuntimes: ["nodejs24.x"],
});
```

**Key points**:
- `sourceDir`: Path to your layer's source directory (the one with `nodejs/node_modules/`)
- `outputPath`: Where the zip file will be created
- `filename`: Use `dependenciesArchive.outputPath` to reference the zipped output
- `compatibleRuntimes`: Specify the Node.js runtime you're using

---

### Step 6: Create Lambda Function Using DataArchiveFile

Same pattern for Lambda functions:

```typescript
// Archive Lambda function directory into zip using DataArchiveFile
const lambdaFunctionArchive = new DataArchiveFile(this, "lambda-function-archive", {
  type: "zip",
  sourceDir: path.resolve(__dirname, "../../backend/dist/functions/home"),
  outputPath: path.resolve(__dirname, "../../dist/functions/home.zip"),
});

// Lambda Function
const lambdaFunction = new LambdaFunction(this, "get-home-function", {
  functionName: `teamflow-get-home-${config.environment}`,
  runtime: "nodejs24.x",
  architectures: ["arm64"],
  handler: "get-home.handler",
  role: lambdaRole.arn,
  filename: lambdaFunctionArchive.outputPath,
  sourceCodeHash: lambdaFunctionArchive.outputBase64Sha256,
  timeout: 30,
  memorySize: 256,
  layers: [dependenciesLayer.arn],
  environment: {
    variables: {
      ENVIRONMENT: config.environment,
    },
  },
});
```

**Critical property**: `sourceCodeHash: lambdaFunctionArchive.outputBase64Sha256`
- This ensures Lambda redeploys when your code changes
- Use `outputBase64Sha256` (camelCase, not `outputBase64sha256`)

---

### Step 7: Build and Deploy

Once your stack code is ready:

```bash
cd ~/Personal/development/teamflow/src/infrastructure

# 1. Install dependencies (no more peer dependency conflicts!)
npm install

# 2. Compile TypeScript to JavaScript
npm run build

# 3. Synthesize CDKTF to Terraform configuration
cdktf synth

# 4. Deploy to AWS
cdktf deploy --auto-approve
```

**Watch for**:
- Terraform will create the zip files automatically via `DataArchiveFile`
- Lambda layer gets created first (takes ~6 seconds)
- Lambda function creation follows
- API Gateway resources are wired up

---

## The Complete Pattern: Checklist

When deploying Lambda layers + functions in the future, follow this checklist:

- [ ] Add `hashicorp/archive@~> 2.7` to `cdktf.json` → `terraformProviders`
- [ ] Run `cdktf provider add hashicorp/archive --force-local`
- [ ] Import `ArchiveProvider` and `DataArchiveFile`
- [ ] Instantiate `new ArchiveProvider(this, "archive", {})`
- [ ] Wrap layer source in `DataArchiveFile` → point to output path
- [ ] Wrap function source in `DataArchiveFile` → point to output path
- [ ] Use `outputBase64Sha256` (not `outputBase64sha256`) for Lambda `sourceCodeHash`
- [ ] Build → Synth → Deploy

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Using deprecated prebuilt package
```typescript
// DON'T do this
import { DataArchiveFile } from "@cdktf/provider-archive"; // ❌ Deprecated
```

**Why**: Locked to CDKTF <0.14.0, causes peer dependency conflicts with CDKTF 0.21.0

**✅ Do this instead**:
```typescript
import { DataArchiveFile } from "../.gen/providers/archive/data-archive-file"; // ✅ Generated locally
```

---

### ❌ Mistake 2: Forgetting to instantiate the provider
```typescript
// If you DON'T have this...
new ArchiveProvider(this, "archive", {});

// ...you'll get this error:
// "Found resources without a matching provider construct. Please make sure to add 
//  provider constructs for the following providers: archive"
```

---

### ❌ Mistake 3: Wrong property name for source code hash
```typescript
// DON'T
sourceCodeHash: lambdaFunctionArchive.outputBase64sha256; // ❌ Wrong case!

// DO
sourceCodeHash: lambdaFunctionArchive.outputBase64Sha256; // ✅ Correct camelCase
```

---

### ❌ Mistake 4: Pointing to directory instead of zip
```typescript
// DON'T
filename: path.resolve(__dirname, "../../backend/dist/functions/home"), // ❌ Directory

// DO
filename: lambdaFunctionArchive.outputPath, // ✅ Use the DataArchiveFile output path
```

**Error you'd get**: `Error: reading ZIP file ... is a directory`

---

## Troubleshooting

### Problem: "Cannot find module '../.gen/providers/archive/data-archive-file'"

**Solution**: Make sure you ran `cdktf provider add hashicorp/archive --force-local`

```bash
cd src/infrastructure
cdktf provider add hashicorp/archive --force-local
```

---

### Problem: Build fails with TypeScript errors

**Solution**: Make sure imports are correct:

```typescript
// From .gen/providers/archive (local generation)
import { ArchiveProvider } from "../.gen/providers/archive/provider";
import { DataArchiveFile } from "../.gen/providers/archive/data-archive-file";

// NOT from @cdktf/provider-archive (deprecated)
```

---

### Problem: Deploy fails with "is a directory"

**Solution**: Make sure your `DataArchiveFile` has both `sourceDir` AND `outputPath`:

```typescript
const archive = new DataArchiveFile(this, "my-archive", {
  type: "zip",
  sourceDir: path.resolve(__dirname, "../../path/to/source"),  // ✅ Source
  outputPath: path.resolve(__dirname, "../../path/to/output.zip"), // ✅ Output
});

// Then use the output
const layer = new LambdaLayerVersion(this, "my-layer", {
  filename: archive.outputPath, // ✅ The zip file, not the source
  // ...
});
```

---

## Key Learnings

### Why Archive Provider?
- **Automatic**: Zips files when Terraform runs (no manual steps)
- **Declarative**: Define once, runs everywhere
- **Dependency tracked**: Re-zips when source files change
- **Terraform native**: Uses the official Terraform archive provider

### Why Local Generation?
- **No deprecated packages**: Prebuilt bindings are end-of-life
- **Future-proof**: Works with any CDKTF version ≥0.21.0
- **Clean dependencies**: No peer conflicts
- **Learning**: Understand how CDKTF generates provider bindings

### Performance Notes
- `DataArchiveFile` runs during `terraform apply` (not `cdktf synth`)
- Layer creation takes ~6 seconds
- Lambda function creation takes ~5-10 seconds
- Entire deploy typically takes 60-90 seconds

---

## Real Example: Our API Stack

Here's the actual working code from our deployment:

```typescript
import { Construct } from "constructs";
import { TerraformStack, TerraformOutput } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { LambdaFunction } from "@cdktf/provider-aws/lib/lambda-function";
import { LambdaLayerVersion } from "@cdktf/provider-aws/lib/lambda-layer-version";
import { LambdaPermission } from "@cdktf/provider-aws/lib/lambda-permission";
import { IamRole } from "@cdktf/provider-aws/lib/iam-role";
import { IamRolePolicyAttachment } from "@cdktf/provider-aws/lib/iam-role-policy-attachment";
import { ArchiveProvider } from "../.gen/providers/archive/provider";
import { DataArchiveFile } from "../.gen/providers/archive/data-archive-file";
import * as path from "path";

export class ApiStack extends TerraformStack {
  constructor(scope: Construct, id: string, config: any) {
    super(scope, id);

    // Providers
    new AwsProvider(this, "aws", {
      region: config.awsRegion,
      profile: config.awsProfile,
    });
    new ArchiveProvider(this, "archive", {});

    // Lambda Layer
    const dependenciesArchive = new DataArchiveFile(this, "dependencies-archive", {
      type: "zip",
      sourceDir: path.resolve(__dirname, "../../backend/layers/dependencies/nodejs"),
      outputPath: path.resolve(__dirname, "../../dist/layers/dependencies.zip"),
    });

    const dependenciesLayer = new LambdaLayerVersion(this, "dependencies-layer", {
      layerName: `teamflow-dependencies-${config.environment}`,
      filename: dependenciesArchive.outputPath,
      compatibleRuntimes: ["nodejs24.x"],
    });

    // Lambda Function
    const lambdaFunctionArchive = new DataArchiveFile(this, "lambda-function-archive", {
      type: "zip",
      sourceDir: path.resolve(__dirname, "../../backend/dist/functions/home"),
      outputPath: path.resolve(__dirname, "../../dist/functions/home.zip"),
    });

    const lambdaRole = new IamRole(this, "lambda-role", {
      name: `teamflow-lambda-role-${config.environment}`,
      assumeRolePolicy: JSON.stringify({
        Version: "2012-10-17",
        Statement: [{
          Effect: "Allow",
          Principal: { Service: "lambda.amazonaws.com" },
          Action: "sts:AssumeRole",
        }],
      }),
    });

    new IamRolePolicyAttachment(this, "lambda-basic-execution", {
      role: lambdaRole.name,
      policyArn: "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    });

    const lambdaFunction = new LambdaFunction(this, "get-home-function", {
      functionName: `teamflow-get-home-${config.environment}`,
      runtime: "nodejs24.x",
      architectures: ["arm64"],
      handler: "get-home.handler",
      role: lambdaRole.arn,
      filename: lambdaFunctionArchive.outputPath,
      sourceCodeHash: lambdaFunctionArchive.outputBase64Sha256,
      timeout: 30,
      memorySize: 256,
      layers: [dependenciesLayer.arn],
      environment: {
        variables: {
          ENVIRONMENT: config.environment,
        },
      },
    });

    // Outputs
    new TerraformOutput(this, "lambda_function_name", {
      value: lambdaFunction.functionName,
      description: "Lambda function name",
    });
  }
}
```

---

## Next Time: Just Follow This

When you deploy Lambda layers and functions again in the future:

1. Reference this guide (you're reading it!)
2. Follow the 7-step checklist above
3. Copy the pattern code
4. Deploy: `npm install && npm run build && cdktf synth && cdktf deploy --auto-approve`

**That's it!** 🚀

---

## Document Metadata

- **Created**: 2026-01-25
- **Topics**: Lambda Layers, Lambda Functions, CDKTF, Archive Provider, Terraform
- **Related Files**: 
  - `src/infrastructure/stacks/api-stack.ts` (Implementation)
  - `src/infrastructure/cdktf.json` (Configuration)
  - `.github/references/lambda-layers-cdktf-pattern.md` (Technical reference)
- **Worked Examples**: This entire project's infrastructure folder
