# CDKTF Change Management Guide

**Last Updated:** 2026-01-23

## Overview

Guide for managing infrastructure changes with CDKTF (Terraform CDK for TypeScript). Covers common scenarios during early development stages including updates, renames, additions, and deletions.

---

## CDKTF Workflow

**Standard workflow for infrastructure changes:**

```bash
1. Edit main.ts              # Change infrastructure code
2. npm run build             # Compile TypeScript → JavaScript
3. cdktf synth               # Generate Terraform JSON
4. cdktf diff                # Preview changes (CRITICAL!)
5. cdktf deploy              # Apply changes to AWS
```

**Golden Rule:** Always run `cdktf diff` before `cdktf deploy` to preview changes and avoid unintended resource destruction.

---

## Scenario A: Update Existing Resource Properties

**Example: Increase Lambda memory**

```typescript
// Before
new LambdaFunction(this, "hello-lambda", {
  memorySize: 128,  // Current
});

// After
new LambdaFunction(this, "hello-lambda", {
  memorySize: 256,  // Updated
});
```

**Diff output:**
```diff
~ aws_lambda_function.hello-lambda
  ~ memory_size: 128 → 256

Plan: 0 to add, 1 to change, 0 to destroy.
```

**Result:** In-place update, no downtime

---

## Scenario B: Rename Resource ID (Dangerous)

**Example: Rename CDKTF resource ID**

```typescript
// Before
new LambdaFunction(this, "hello-lambda", {  // ID
  functionName: "teamflow-hello",
});

// After
new LambdaFunction(this, "greeting-lambda", {  // New ID
  functionName: "teamflow-hello",
});
```

**Diff output:**
```diff
- aws_lambda_function.hello-lambda (destroy)
+ aws_lambda_function.greeting-lambda (create)

Plan: 1 to add, 0 to change, 1 to destroy.
```

**Result:** ⚠️ Destroys old resource, creates new one → **Downtime**

**Why:** Terraform tracks resources by their ID (first parameter). Changing ID = different resource.

**Safe Alternative - Don't rename IDs:**
- Use descriptive IDs from the start
- If absolutely necessary, use Terraform state move:
  ```bash
  cdktf terraform -- state mv \
    'aws_lambda_function.hello-lambda' \
    'aws_lambda_function.greeting-lambda'
  ```

---

## Scenario C: Add New Resources

**Example: Add second Lambda function**

```typescript
class TeamFlowStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    // Existing Lambda (unchanged)
    new LambdaFunction(this, "hello-lambda", { ... });

    // New Lambda
    new LambdaFunction(this, "goodbye-lambda", {
      functionName: "teamflow-goodbye",
      handler: "goodbye.handler",
      role: lambdaRole.arn,  // Reuse existing role
      // ...
    });
  }
}
```

**Diff output:**
```diff
+ aws_lambda_function.goodbye-lambda (create)

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Result:** Creates new resource, existing resources untouched, no downtime

---

## Scenario D: Delete Resources

**Example: Remove Lambda function**

```typescript
// Delete code:
// new LambdaFunction(this, "goodbye-lambda", { ... });
```

**Diff output:**
```diff
- aws_lambda_function.goodbye-lambda (destroy)

Plan: 0 to add, 0 to change, 1 to destroy.
```

**Result:** Deletes resource from AWS

---

## Scenario E: Update Lambda Code

**Most common scenario during development**

**Workflow:**

```bash
# 1. Edit handler code
# src/backend/src/handlers/hello.ts
return {
  statusCode: 200,
  body: JSON.stringify({
    message: 'Hello from TeamFlow Lambda v2!',  // Updated
    timestamp: new Date().toISOString(),
  }),
};

# 2. Rebuild backend
cd src/backend
npm run build

# 3. Redeploy infrastructure
cd ../infrastructure
cdktf diff
```

**Diff output:**
```diff
~ aws_lambda_function.hello-lambda
  ~ source_code_hash: "abc123..." → "xyz789..."

Plan: 0 to add, 1 to change, 0 to destroy.
```

**What happens:**
1. CDKTF re-zips `dist/handlers/`
2. Detects code change via `sourceCodeHash`
3. Uploads new zip to AWS
4. Lambda performs atomic update → **No downtime**

```bash
# 4. Deploy
cdktf deploy
```

---

## Change Impact Reference

| **Change Type** | **Effect** | **Downtime?** |
|-----------------|------------|---------------|
| Increase memory | In-place update | ❌ No |
| Change timeout | In-place update | ❌ No |
| Add environment variable | In-place update | ❌ No |
| Update code (source_code_hash) | In-place update | ❌ No |
| Add new Lambda | Create | ❌ No |
| **Change handler name** | Replace (destroy + create) | ✅ Yes |
| **Change runtime** | Replace | ✅ Yes |
| **Change function name** | Replace | ✅ Yes |
| **Change architecture** | Replace | ✅ Yes |
| **Rename resource ID** | Replace | ✅ Yes |
| **Delete Lambda** | Destroy | ✅ Yes |

---

## How Terraform Tracks Changes

**Terraform State File:**
```
src/infrastructure/terraform.teamflow-dev.tfstate
```

**State file contents (simplified):**
```json
{
  "resources": [
    {
      "type": "aws_lambda_function",
      "name": "hello-lambda",
      "instances": [{
        "attributes": {
          "function_name": "teamflow-hello",
          "memory_size": 128,
          "arn": "arn:aws:lambda:us-east-1:123:function:teamflow-hello"
        }
      }]
    }
  ]
}
```

**How it works:**
1. `cdktf synth` - Generates desired state (Terraform JSON)
2. `cdktf diff` - Compares desired state vs current state (tfstate)
3. `cdktf deploy` - Applies changes, updates tfstate

**Example:**
- Current state (tfstate): `memory_size: 128`
- Desired state (main.ts): `memorySize: 256`
- Diff shows: `memory_size: 128 → 256`
- Deploy updates AWS and tfstate to 256

---

## Understanding CDKTF Deployment Speed

### CDKTF IS Smart About Changes

**Important:** Terraform/CDKTF DOES intelligently detect what changed and only updates those specific resources.

**Example when only Lambda code changed:**
```bash
cdktf diff
```

**Output:**
```diff
~ aws_lambda_function.hello-lambda
  ~ source_code_hash: "abc123..." → "xyz789..."

Plan: 0 to add, 1 to change, 0 to destroy.
```

**What Terraform does:**
- Only calls `aws lambda update-function-code` API
- Does NOT touch IAM roles, policies, or other resources
- Only updates what actually changed

### Then Why Does CDKTF Feel Slow?

The slowness comes from **CDKTF/Terraform workflow overhead**, not AWS API calls.

**CDKTF Workflow Time Breakdown:**

```bash
# Infrastructure TypeScript Compilation (OVERHEAD)
npm run build                    # 2-5 seconds
# Compiles main.ts even though you didn't change it
# Only Lambda code changed, not infrastructure!

# Generate Terraform JSON (OVERHEAD)
cdktf synth                      # 5-10 seconds
# Re-generates ALL Terraform JSON files
# Even though only sourceCodeHash changed

# Calculate State Diff (OVERHEAD)
cdktf diff                       # 3-5 seconds
# Compares entire desired state vs current state
# Reads tfstate, compares all resources

# Apply Changes (TERRAFORM OVERHEAD + AWS WORK)
cdktf deploy                     # 15-30 seconds
# - Terraform state locking
# - State reconciliation
# - AWS Lambda API call (1-2 seconds) ← actual work
# - Terraform state update

# TOTAL: 30-60 seconds (only 1-2s is actual AWS work)
```

### Direct AWS CLI Comparison

```bash
# Build Lambda code
cd src/backend
npm run build                    # 2-5 seconds

# Direct AWS API call
aws lambda update-function-code \
  --function-name teamflow-hello \
  --zip-file fileb://dist.zip \
  --profile teamflow-developer   # 1-2 seconds

# TOTAL: 5-10 seconds (same AWS work, no CDKTF overhead)
```

### Time Breakdown Comparison

| Approach | Infra TypeScript Build | CDKTF Synth | State Diff | Terraform Overhead | AWS API Call | Total |
|----------|------------------------|-------------|------------|-------------------|--------------|-------|
| **CDKTF** | 2-5s | 5-10s | 3-5s | 10-15s | 1-2s | **30-60s** |
| **Direct CLI** | ❌ Skip | ❌ Skip | ❌ Skip | ❌ Skip | 1-2s | **5-10s** |

### Why Can't CDKTF Skip These Steps?

**Technical reasons:**

1. **Infrastructure code must be compiled** - CDKTF doesn't know if you changed `main.ts` until it compiles it
2. **Synth must regenerate full JSON** - Terraform requires complete desired state, not just diffs
3. **State reconciliation is required** - Terraform's core design (safety over speed)
4. **No watch mode** - CDKTF doesn't have a daemon watching for file changes

### Could CDKTF Be Smarter?

Theoretically yes, but would require:
- File watching to detect backend vs infrastructure changes
- Incremental synth (generate only changed resources)
- Partial state diffs (not standard Terraform behavior)

**SAM solved this** by building a specialized tool for serverless (not general IaC), so they could add `sam sync` as a fast path for code-only updates.

### Deployment Strategy Comparison

| Scenario | Best Approach | Speed | Safety |
|----------|--------------|-------|--------|
| **Code changes only** | Direct AWS CLI script | 5-10s | Medium (bypasses state) |
| **Infrastructure changes** | Full CDKTF deploy | 30-60s | High (full state tracking) |
| **Both code + infra** | Full CDKTF deploy | 30-60s | High (required for resources) |
| **Development iteration** | Direct AWS CLI script | 5-10s | Medium (fast feedback) |
| **Production deploy** | Full CDKTF deploy | 30-60s | High (proper state management) |

### Fast Update Script for Development

**Create `scripts/update-lambda.sh`:**

```bash
#!/bin/bash
set -euo pipefail

# Configuration
FUNCTION_NAME="teamflow-hello"
AWS_PROFILE="teamflow-developer"
BACKEND_DIR="src/backend"
HANDLERS_DIR="dist/handlers"

# Build TypeScript
echo "Building Lambda code..."
cd "${BACKEND_DIR}"
npm run build

# Create deployment package
echo "Creating deployment package..."
cd "${HANDLERS_DIR}"
zip -r /tmp/lambda-code.zip .

# Update Lambda directly
echo "Updating Lambda function..."
aws lambda update-function-code \
  --function-name "${FUNCTION_NAME}" \
  --zip-file fileb:///tmp/lambda-code.zip \
  --profile "${AWS_PROFILE}"

echo "✅ Lambda updated successfully!"
```

**Usage:**
```bash
chmod +x scripts/update-lambda.sh

# Edit Lambda code
vim src/backend/src/handlers/hello.ts

# Fast update (5-10 seconds)
./scripts/update-lambda.sh

# Test
aws lambda invoke \
  --function-name teamflow-hello \
  --profile teamflow-developer \
  response.json
```

### When to Use Each Approach

**Use CDKTF deploy when:**
- Changing infrastructure (IAM roles, memory, timeout, environment variables)
- Adding/removing resources
- Production deployments
- You need full state tracking and safety guarantees

**Use direct AWS CLI when:**
- Only Lambda handler code changed
- Rapid development iteration
- Testing code changes quickly
- You're confident infrastructure hasn't changed

**Key Insight:** The direct AWS CLI script does exactly what `sam sync` does - bypass CloudFormation/Terraform for code-only updates during development.

---

## Best Practices for Early Development

### 1. Always Preview Changes First

```bash
# ✅ Good workflow
cdktf diff      # Review changes
cdktf deploy    # Apply if safe

# ❌ Bad workflow
cdktf deploy    # No preview, risky
```

### 2. Use Descriptive Resource IDs

```typescript
// ✅ Good - describes purpose
new LambdaFunction(this, "create-project-lambda", { ... });

// ❌ Bad - vague, might want to rename later
new LambdaFunction(this, "lambda1", { ... });
```

### 3. Keep AWS Resource Names Consistent with IDs

```typescript
new LambdaFunction(this, "create-project-lambda", {
  functionName: "teamflow-create-project",  // Matches ID
  // ...
});
```

### 4. Test Changes in Separate Stack

```typescript
// Development stack
new TeamFlowStack(app, "teamflow-dev");

// Production stack (deploy after testing dev)
new TeamFlowStack(app, "teamflow-prod");
```

**Deploy separately:**
```bash
cdktf deploy teamflow-dev   # Test here first
cdktf deploy teamflow-prod  # Deploy to prod after verification
```

### 5. Version Control Infrastructure Code

```bash
git add src/infrastructure/main.ts
git commit -m "Increase Lambda memory to 256MB"
git push
```

---

## Quick Reference Commands

```bash
# Preview changes (always run first!)
cdktf diff

# Apply changes
cdktf deploy

# Deploy specific stack
cdktf deploy <stack-name>

# Destroy all resources
cdktf destroy

# View Terraform state
cat terraform.teamflow-dev.tfstate

# Manually sync state (if AWS changed outside Terraform)
cdktf terraform -- refresh

# Move resource in state (advanced)
cdktf terraform -- state mv \
  'aws_lambda_function.old-name' \
  'aws_lambda_function.new-name'
```

---

## Common Pitfalls

### Pitfall 1: Skipping `cdktf diff`

**Problem:** Deploy without reviewing changes → unexpected resource deletion

**Solution:** Always run `cdktf diff` before `cdktf deploy`

### Pitfall 2: Renaming Resource IDs

**Problem:** Changing resource ID causes destroy + create

**Solution:** Use descriptive IDs from the start, avoid renaming

### Pitfall 3: Changing Immutable Properties

**Problem:** Properties like `functionName`, `runtime`, `architecture` trigger replacement

**Solution:** Check AWS docs for immutable properties before changing

### Pitfall 4: Manual AWS Changes

**Problem:** Changing resources in AWS Console creates state drift

**Solution:** Always make changes via CDKTF, run `cdktf terraform -- refresh` if drift occurs

---

## Example: Complete Change Workflow

**Goal:** Update Lambda code and increase memory

```bash
# 1. Edit backend code
vim src/backend/src/handlers/hello.ts
# Change message to "Hello v2!"

# 2. Rebuild backend
cd src/backend
npm run build

# 3. Edit infrastructure
cd ../infrastructure
vim main.ts
# Change memorySize: 128 → 256

# 4. Compile infrastructure
npm run build

# 5. Preview changes
cdktf diff
# Expected: memory_size change + source_code_hash change

# 6. Apply changes
cdktf deploy
# Type 'yes' when prompted

# 7. Verify
aws lambda invoke \
  --function-name teamflow-hello \
  --profile teamflow-developer \
  response.json

cat response.json
# Should see "Hello v2!" message
```

---

## Summary

- **Always run `cdktf diff` before deploying** to preview changes
- **Avoid renaming resource IDs** - causes destroy + recreate
- **Use descriptive IDs from the start** to avoid future renames
- **Test in dev stack first** before deploying to production
- **Track infrastructure changes in git** for version control
- **Understand immutable properties** to avoid unexpected replacements
- **Terraform state tracks current AWS state** - don't modify manually
- **Most code updates are safe** (no downtime) via sourceCodeHash changes

---

## References

- CDKTF Documentation: https://developer.hashicorp.com/terraform/cdktf
- Terraform State: https://developer.hashicorp.com/terraform/language/state
- AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/
