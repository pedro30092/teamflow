# AWS Account Setup: IAM Users vs IAM Identity Center (SSO)

## Problem Overview
Understanding the difference between AWS IAM users and IAM Identity Center users, and configuring secure CLI access using SSO instead of access keys.

## AWS Account Access Hierarchy

### Three Access Levels
1. **Root Account** - Emergency use only, MFA required, never for development
2. **IAM Admin User** (`pedro-admin`) - Console management, IAM resource administration
3. **Identity Center User** (`pedrodevelopment`) - CLI/CDKTF development work (recommended)

## Key Technical Distinctions

### IAM User vs Identity Center User

| Aspect | IAM User | Identity Center User |
|--------|----------|---------------------|
| **Authentication** | Account ID + Username + Password | Email + Password (SSO portal) |
| **Credentials** | Permanent access keys (less secure) | Temporary credentials (more secure) |
| **Sign-in URL** | `https://[account-id].signin.aws.amazon.com` | `https://d-xxxxx.awsapps.com/start` |
| **CLI Setup** | `aws configure` | `aws configure sso` |
| **Best Use** | Console management | CLI/development |

### SSO Session vs Profile

- **SSO Session Name**: Reusable login portal (e.g., `teamflow`)
  - One session can serve multiple profiles
  - Login once, use across multiple accounts/roles

- **Profile Name**: CLI command identifier (e.g., `teamflow-developer`)
  - References specific account + role combination
  - Used with `--profile` flag in commands

## Configuration Steps

### 1. Get SSO Start URL
1. Sign in to AWS Console as IAM admin user (`pedro-admin`)
2. Navigate to: **IAM Identity Center** → **Dashboard**
3. Copy the **AWS access portal URL** (format: `https://d-xxxxxxxxxx.awsapps.com/start`)

### 2. Configure SSO Profile

```bash
# Configure SSO
aws configure sso

# Prompts:
# SSO session name: teamflow
# SSO start URL: https://d-xxxxxxxxxx.awsapps.com/start
# SSO region: us-east-1
# SSO registration scopes: [press Enter]
# [Browser opens - sign in with pedrodevelopment credentials]
# CLI default region: us-east-1
# CLI output format: json
# Profile name: teamflow-developer
```

### 3. Daily Usage

```bash
# Login to SSO (once per day or when credentials expire)
aws sso login --profile teamflow-developer

# Set environment variables
export AWS_PROFILE="teamflow-developer"
export AWS_PAGER=""

# Verify identity
aws sts get-caller-identity

# Use for development
aws lambda list-functions
cdktf deploy
```

## Configuration File Structure

Result in `~/.aws/config`:

```ini
[sso-session teamflow]
sso_start_url = https://d-xxxxxxxxxx.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access

[profile teamflow-developer]
sso_session = teamflow
sso_account_id = 123456789012
sso_role_name = DeveloperAccess
region = us-east-1
output = json
```

## Security Benefits of SSO

- ✅ No permanent access keys stored on local machine
- ✅ Temporary credentials expire automatically (typically 8 hours)
- ✅ Centralized access management
- ✅ Can enable MFA at SSO level
- ✅ Easier credential rotation

## Common Error: Wrong SSO Start URL

**Error**: `InvalidRequestException when calling RegisterClient`

**Cause**: Using IAM sign-in URL instead of Identity Center URL
- ❌ Wrong: `https://aws-pedro-personal-development.signin.aws.amazon.com`
- ✅ Correct: `https://d-xxxxxxxxxx.awsapps.com/start`

**Fix**: Get URL from IAM Identity Center Dashboard, not from IAM user sign-in page
