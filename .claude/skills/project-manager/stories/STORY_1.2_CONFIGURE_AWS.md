# Story 1.2: Configure AWS Account

**Story ID**: EPIC1-002
**Epic**: EPIC-1 (Development Environment Setup)
**Sprint**: SPRINT-0
**Status**: 📋 TODO

---

## User Story

```
As an infra-backend-expert,
I need an AWS account with IAM credentials configured,
so that I can deploy infrastructure using CDKTF and run serverless services.
```

---

## Requirements

### AWS Account Setup

1. **AWS Account** - Free tier eligible account
2. **IAM User** - Programmatic access with appropriate permissions
3. **AWS CLI** - Configured with credentials
4. **Billing Alarms** - Set up to prevent unexpected charges
5. **MFA** (Recommended) - Multi-factor authentication on root account

### Security Requirements

- Root account should not be used for day-to-day development
- IAM user with least-privilege permissions (AdministratorAccess for development)
- Credentials stored securely (NOT in Git)
- Billing alarms active to monitor costs

---

## Implementation Steps

### Step 1: Create AWS Account

1. Go to https://aws.amazon.com/
2. Click "Create an AWS Account"
3. Follow registration process (requires credit card for verification)
4. Confirm email and complete setup

### Step 2: Set Up Billing Alarms (CRITICAL)

1. Log in to AWS Console
2. Navigate to CloudWatch service
3. Go to **Alarms → Billing**
4. Create billing alarms at:
   - $5 threshold (warning)
   - $10 threshold (alert)
   - $20 threshold (critical)
5. Enter email for notifications
6. Confirm email subscription (check inbox)

### Step 3: Create IAM User for Development

1. Go to **IAM service** in AWS Console
2. Click **Users → Add User**
3. Configuration:
   - Username: `teamflow-dev` (or your preference)
   - Access type: ✅ **Programmatic access** (access key)
   - Permissions: Attach **AdministratorAccess** policy
     - Note: For simplicity in development. Use least privilege in production.
4. **CRITICAL**: Download credentials CSV and save securely
   - ⚠️ You cannot download this again!
   - Store in password manager or secure location
   - Never commit to Git

### Step 4: Enable MFA on Root Account

1. IAM → Users → Select root account
2. Security credentials → Enable MFA
3. Use authenticator app (Google Authenticator, Authy, 1Password, etc.)
4. Scan QR code and verify with two consecutive codes

### Step 5: Configure AWS CLI

Run the AWS CLI configuration wizard:

```bash
aws configure
```

When prompted, enter:
- **AWS Access Key ID**: [from credentials CSV]
- **AWS Secret Access Key**: [from credentials CSV]
- **Default region**: `us-east-1`
- **Default output format**: `json`

---

## Verification

Test AWS CLI authentication:

```bash
# Verify identity
aws sts get-caller-identity

# Expected output (JSON):
{
  "UserId": "AIDAXXXXXXXXXXXXXXXXX",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/teamflow-dev"
}
```

Verify credentials file:

```bash
cat ~/.aws/credentials
# Should show [default] profile with access key

cat ~/.aws/config
# Should show region = us-east-1
```

---

## Acceptance Criteria

- [ ] AWS account created and accessible
- [ ] Billing alarms configured at $5, $10, $20 thresholds
- [ ] Billing alarm email confirmed (check inbox)
- [ ] IAM user `teamflow-dev` (or similar) created with programmatic access
- [ ] IAM user has AdministratorAccess policy attached
- [ ] Credentials CSV downloaded and stored securely
- [ ] AWS CLI configured: `aws configure` completed
- [ ] `aws sts get-caller-identity` returns account info successfully
- [ ] Response includes: UserId, Account number, IAM user ARN
- [ ] MFA enabled on root account (recommended)

---

## Security Checklist

Before marking this story as done, verify:

- [ ] Root account NOT used for development
- [ ] MFA enabled on root account
- [ ] IAM user credentials stored in secure location (password manager)
- [ ] Credentials NOT committed to Git
- [ ] `.gitignore` includes AWS credential files
- [ ] Billing alarms active and confirmed via email
- [ ] AWS CLI config file (~/.aws/credentials) has correct permissions (not world-readable)

---

## Definition of Done

- AWS CLI authenticated successfully with IAM user
- `aws sts get-caller-identity` returns correct account and user ARN
- Billing alarms confirmed via email (check spam folder)
- Credentials documented in secure location (NOT in Git)
- Security checklist completed
- Ready to proceed to Story 1.3 (Initialize Project Structure)

---

## Technical Notes for infra-backend-expert

### Why These Permissions?

**AdministratorAccess** is used for development because:
- Simplifies setup (no permission debugging during development)
- MVP needs broad access (DynamoDB, Lambda, API Gateway, Cognito, S3, IAM, CloudWatch)
- Production should use least-privilege roles (e.g., separate roles for deployment vs runtime)

### AWS Free Tier Coverage

Story 1.2 setup is **100% free**:
- IAM: Free
- CloudWatch Billing Alarms: Free
- AWS CLI: Free

Subsequent stories will deploy resources (DynamoDB, Lambda, etc.) that fall under free tier limits.

### Credentials Storage Best Practices

**✅ Good**:
- Password manager (1Password, LastPass, Bitwarden)
- Encrypted file in secure location
- AWS Secrets Manager (for production)

**❌ Bad**:
- Plain text files in home directory
- Committed to Git
- Shared via email/Slack
- Hardcoded in code

### .gitignore for AWS Credentials

Ensure your project `.gitignore` includes:

```gitignore
# AWS Credentials
.aws/
credentials
*.pem
.env
.env.local
config.json

# CDKTF
.terraform/
terraform.tfstate*
cdktf.out/
.gen/
```

### Troubleshooting

**Issue**: `aws configure` shows "Unable to locate credentials"
- **Solution**: Re-run `aws configure` and carefully re-enter credentials from CSV

**Issue**: `aws sts get-caller-identity` returns "InvalidClientTokenId"
- **Solution**: Check credentials are correct in `~/.aws/credentials`
- Verify no extra spaces or newlines in credentials file

**Issue**: `aws sts get-caller-identity` returns "SignatureDoesNotMatch"
- **Solution**: Ensure no leading/trailing spaces in Access Key ID or Secret Access Key
- Re-run `aws configure` with credentials from CSV

**Issue**: Billing alarm not received
- **Solution**: Check spam folder
- Verify email in CloudWatch Alarms subscription
- Click confirmation link in email

---

## Dependencies

- **Story 1.1**: MUST be complete (AWS CLI v2 installed)
- No other dependencies

---

## Estimated Time

**Total**: 1-2 hours (including AWS account approval time)

**Breakdown**:
- AWS account creation: 15-30 minutes
- IAM user setup: 10 minutes
- Billing alarms: 10 minutes
- AWS CLI configuration: 5 minutes
- MFA setup: 10 minutes
- Verification: 5 minutes

---

## Completion Notes

**Completed**: [Date]
**Verified By**: infra-backend-expert
**Status**: [Update when done]

**IAM User Created**: [username]
**Account ID**: [12-digit account ID]
**Region**: us-east-1

**Verification Evidence**:
```bash
# Output of: aws sts get-caller-identity
[Paste JSON output here when complete]
```

---

**Last Updated**: 2026-01-22

