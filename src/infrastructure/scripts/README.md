# Infrastructure Deployment Scripts

Production-grade scripts for deploying and destroying TeamFlow infrastructure with CDKTF.

## Overview

- **`deploy.sh`** - Compiles, synthesizes, and deploys infrastructure to AWS
- **`destroy.sh`** - Safely tears down AWS resources with confirmation

## Quick Start

### Deploy Infrastructure

```bash
# From infrastructure directory
npm run deploy

# Or directly
./scripts/deploy.sh

# Deploy specific stack
./scripts/deploy.sh teamflow-api-dev
```

### Destroy Infrastructure

```bash
# From infrastructure directory
npm run destroy

# Or directly
./scripts/destroy.sh

# Destroy specific stack
./scripts/destroy.sh teamflow-api-dev
```

### Clean Build Artifacts

```bash
npm run clean
```

## Environment Variables

Both scripts respect the following environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `AWS_PROFILE` | `teamflow-developer` | AWS CLI profile to use |
| `AWS_REGION` | `us-east-1` | AWS region for deployment |
| `SKIP_CONFIRM` | `false` | Skip destruction confirmation (destroy.sh only) |

### Examples

```bash
# Deploy with different profile
AWS_PROFILE=production npm run deploy

# Deploy to different region
AWS_REGION=eu-west-1 npm run deploy

# Destroy without confirmation (automation only)
SKIP_CONFIRM=true npm run destroy
```

## What the Deploy Script Does

1. **Pre-flight Checks**
   - Verifies required tools (node, npm, cdktf, aws)
   - Validates AWS credentials
   - Checks project structure

2. **Build Infrastructure**
   - Installs dependencies (if needed)
   - Compiles TypeScript (`npm run build`)
   - Synthesizes CDKTF configuration (`cdktf synth`)

3. **Deploy to AWS**
   - Deploys infrastructure using `cdktf deploy`
   - Requires manual confirmation (for safety)

4. **Capture Outputs**
   - Saves deployment outputs to `tmp/deployment-outputs-<timestamp>.json`
   - Displays outputs to console (includes API endpoint URLs)

## What the Destroy Script Does

1. **Pre-flight Checks**
   - Verifies required tools
   - Validates AWS credentials

2. **Confirmation**
   - Displays resources that will be deleted
   - Requires typing 'destroy' to confirm
   - 3-second countdown before proceeding

3. **Destroy Infrastructure**
   - Tears down AWS resources using `cdktf destroy --auto-approve`
   - Note: Confirmation already happened, so auto-approve is safe here

4. **Cleanup**
   - Removes local `cdktf.out` directory
   - Keeps compiled files for next deployment

## Safety Features

### Deploy Script
- ✅ Validates AWS credentials before deployment
- ✅ Checks for required tools
- ✅ Requires manual confirmation for deployment
- ✅ Colored output for errors/warnings
- ✅ Exits on any error (`set -e`)

### Destroy Script
- ✅ Strong confirmation prompt (must type 'destroy')
- ✅ Shows exactly what will be deleted
- ✅ 3-second countdown before destruction
- ✅ Can be skipped with `SKIP_CONFIRM=true` (automation only)
- ✅ Validates AWS credentials

## Output Files

Deployment outputs are saved to the `tmp/` directory (gitignored):

```
tmp/
├── deployment-outputs-20260125-143022.json
├── deployment-outputs-20260125-150333.json
└── ...
```

Each file contains:
- Stack outputs (API endpoints, resource ARNs, etc.)
- Timestamp for tracking deployments

## Troubleshooting

### "cdktf: command not found"

Install CDKTF CLI globally:

```bash
npm install -g cdktf-cli@latest
```

### "AWS credentials not configured"

Configure AWS CLI with your profile:

```bash
aws configure --profile teamflow-developer
```

### "Deployment failed"

Check the error message and:
1. Verify AWS credentials have sufficient permissions
2. Check AWS service quotas (Lambda, API Gateway, etc.)
3. Review Terraform state for conflicts
4. Check CloudWatch logs for Lambda errors

### "Stack already exists"

If a stack exists from a previous deployment:
```bash
# Destroy old stack first
npm run destroy teamflow-api-dev

# Then deploy again
npm run deploy teamflow-api-dev
```

## Integration with CI/CD

These scripts are designed to be used in CI/CD pipelines (future Story 7.x):

```yaml
# GitHub Actions example
- name: Deploy Infrastructure
  env:
    AWS_PROFILE: production
    AWS_REGION: us-east-1
  run: |
    cd src/infrastructure
    npm run deploy
```

For CI/CD, consider:
- Using `--auto-approve` flag directly with `cdktf deploy` (bypass manual confirmation)
- Setting `SKIP_CONFIRM=true` for automated destruction
- Using AWS credentials from GitHub Secrets

## Best Practices

1. **Always test in dev first** - Deploy to dev stack before production
2. **Review changes** - Read CDKTF plan before confirming deployment
3. **Monitor deployments** - Check CloudWatch for errors after deployment
4. **Keep outputs** - Save deployment outputs for troubleshooting
5. **Use version control** - Commit infrastructure changes before deploying

## Architecture Alignment

These scripts follow TeamFlow's infrastructure patterns:
- ✅ Uses CDKTF (Terraform CDK with TypeScript)
- ✅ Free tier optimized (no VPC, on-demand DynamoDB)
- ✅ Serverless architecture (Lambda + API Gateway)
- ✅ Multi-tenant ready (organization-scoped resources)

## Related Documentation

- [Technical Architecture](../../../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)
- [Development Roadmap](../../../research/DEVELOPMENT_ROADMAP_SERVERLESS.md)
- [Story 3.4 - CDKTF Deployment Scripts](../../../agile-management/stories/STORY_3.4_CDKTF_DEPLOYMENT_SCRIPTS.md)
