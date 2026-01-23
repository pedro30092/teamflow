# Story 1.2: Configure AWS Account

**Story ID**: EPIC1-002
**Epic**: EPIC-1 (Development Environment Setup)
**Sprint**: SPRINT-0
**Status**: ✅ DONE

---

## User Story

```
As an infra-backend-expert,
I need an AWS account with SSO-based authentication configured,
so that I can deploy infrastructure using CDKTF with admin permissions
and perform day-to-day development operations with least-privilege permissions.
```

---

## Requirements

- Setup AWS CLI with SSO authentication (no root, no IAM users with access keys)
- Two profiles sharing same SSO session:
  - `teamflow-developer`: DeveloperAccess role with least-privilege permissions (day-to-day operations) - **DEFAULT PROFILE**
  - `teamflow-admin`: AdministratorAccess role (for infrastructure deployment only)

---

## Implementation Steps

### Step 1: Set Up IAM Identity Center (SSO)

1. Go to **IAM Identity Center** service in AWS Console
2. Enable IAM Identity Center
3. Create SSO user
4. Get SSO start URL from Dashboard

### Step 2: Create Permission Sets

1. Create `AdministratorAccess` permission set (predefined)
2. Create `DeveloperAccess` permission set (custom with DynamoDB, Lambda, CloudWatch, API Gateway, Cognito read/invoke permissions)
3. Assign both permission sets to your SSO user

### Step 3: Configure AWS CLI Profiles

```bash
export AWS_PAGER=""

# Configure developer profile FIRST (default for day-to-day work)
aws configure sso
# - SSO session: teamflow-sso
# - Profile name: teamflow-developer
# - Select DeveloperAccess role
# - Set as default client region: us-east-1

# Configure admin profile SECOND (only for infrastructure deployment)
aws configure sso
# - SSO session: teamflow-sso (SAME)
# - Profile name: teamflow-admin
# - Select AdministratorAccess role
```

---

## Verification

```bash
export AWS_PAGER=""

# Login once (use developer profile as default)
aws sso login --profile teamflow-developer

# Test both profiles (both work with single login)
aws sts get-caller-identity --profile teamflow-developer
aws sts get-caller-identity --profile teamflow-admin
```

---

## Acceptance Criteria

- [x] IAM Identity Center (SSO) enabled
- [x] SSO user created
- [x] Two permission sets created: `AdministratorAccess`, `LambdaDevelopmentUserAccess`
- [x] Both permission sets assigned to SSO user
- [x] Two AWS CLI profiles configured: `teamflow-admin`, `teamflow-developer`
- [x] Both profiles share same SSO session `teamflow`
- [x] `aws sts get-caller-identity --profile teamflow-admin` works
- [x] `aws sts get-caller-identity --profile teamflow-developer` works

---

## Definition of Done

- Both profiles authenticate successfully with single SSO login
- Ready to proceed to Story 1.3 (Initialize Project Structure)

**Completed**: 2026-01-22

---

**Last Updated**: 2026-01-22

