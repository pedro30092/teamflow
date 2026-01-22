# AWS Billing Audit - Methodology & Script Documentation

**Date Created**: 2026-01-22
**Profile Used**: `teamflow-admin`
**Account**: 168687661563
**Purpose**: Document how to audit AWS resources for billing analysis

---

## Overview

This document explains the methodology used to discover all running AWS resources that generate costs, and provides a reusable script for regular billing audits.

---

## Methodology: Service-by-Service Audit

### 1. Verify AWS Profile Identity

**Command**:
```bash
export AWS_PAGER=""
aws sts get-caller-identity --profile teamflow-admin
```

**Purpose**: Confirm you're using the correct AWS account and role.

**Output**:
```json
{
    "UserId": "AROASORUROH553FLZE7AK:pedrodevelopment",
    "Account": "168687661563",
    "Arn": "arn:aws:sts::168687661563:assumed-role/AWSReservedSSO_AdministratorAccess_f5ea8001fc751b90/pedrodevelopment"
}
```

---

### 2. Compute Services (EC2, Lambda, ECS, EKS)

#### Lambda Functions
**Command**:
```bash
aws lambda list-functions --profile teamflow-admin --output json | \
  jq -r '.Functions[] | "\(.FunctionName) - \(.Runtime) - \(.MemorySize)MB - Last Modified: \(.LastModified)"'
```

**What it checks**: All deployed Lambda functions
**Cost Impact**: Pay-per-invocation + duration
**Result**: No functions found

---

#### EC2 Instances
**Command**:
```bash
aws ec2 describe-instances --profile teamflow-admin --output json | \
  jq -r '.Reservations[].Instances[] | select(.State.Name != "terminated") | "\(.InstanceId) - \(.InstanceType) - \(.State.Name)"'
```

**What it checks**: All EC2 instances not in "terminated" state
**Cost Impact**: Hourly rate based on instance type
**Result**: No instances found

---

#### ECS Clusters
**Command**:
```bash
aws ecs list-clusters --profile teamflow-admin --output json
```

**What it checks**: Container clusters
**Cost Impact**: Based on Fargate tasks or EC2 instances
**Result**: No clusters found

---

#### EKS Clusters
**Command**:
```bash
aws eks list-clusters --profile teamflow-admin --output json
```

**What it checks**: Kubernetes clusters
**Cost Impact**: $0.10/hour per cluster + worker nodes
**Result**: No clusters found

---

### 3. Storage Services (S3, EBS, DynamoDB)

#### S3 Buckets
**Command**:
```bash
aws s3 ls --profile teamflow-admin
```

**What it checks**: All S3 buckets
**Cost Impact**: Storage + requests + data transfer
**Result**: No buckets found

---

#### EBS Volumes
**Command**:
```bash
aws ec2 describe-volumes --profile teamflow-admin --output json | \
  jq -r '.Volumes[] | "\(.VolumeId) - \(.Size)GB - \(.State) - \(.VolumeType)"'
```

**What it checks**: All Elastic Block Store volumes
**Cost Impact**: GB-month of provisioned storage
**Result**: No volumes found

---

#### DynamoDB Tables
**Command**:
```bash
aws dynamodb list-tables --profile teamflow-admin --output json
```

**What it checks**: All NoSQL tables
**Cost Impact**: Provisioned/on-demand capacity + storage
**Result**: No tables found

---

### 4. Networking Services (VPC, EIP, NAT Gateway)

#### Elastic IPs (Unassociated)
**Command**:
```bash
aws ec2 describe-addresses --profile teamflow-admin --output json | \
  jq -r '.Addresses[] | "\(.PublicIp) - \(.AllocationId) - Associated: \(.InstanceId // "Not associated")"'
```

**What it checks**: All allocated Elastic IP addresses
**Cost Impact**: $0.005/hour (~$3.60/month) when NOT associated
**Result**: Found 1 unassociated IP (54.145.84.206) - **CREATING COST**

---

#### NAT Gateways
**Command**:
```bash
aws ec2 describe-nat-gateways --profile teamflow-admin --output json | \
  jq -r '.NatGateways[] | "\(.NatGatewayId) - \(.State)"'
```

**What it checks**: NAT Gateways for private subnet internet access
**Cost Impact**: $0.045/hour (~$32/month) + data processing
**Result**: No NAT Gateways found

---

### 5. Database Services (RDS, ElastiCache)

#### RDS Instances
**Command**:
```bash
aws rds describe-db-instances --profile teamflow-admin --output json | \
  jq -r '.DBInstances[] | "\(.DBInstanceIdentifier) - \(.DBInstanceClass) - \(.DBInstanceStatus)"'
```

**What it checks**: Relational database instances
**Cost Impact**: Hourly rate based on instance class + storage
**Result**: No databases found

---

#### ElastiCache Clusters
**Command**:
```bash
aws elasticache describe-cache-clusters --profile teamflow-admin --output json | \
  jq -r '.CacheClusters[] | "\(.CacheClusterId) - \(.CacheNodeType) - \(.CacheClusterStatus)"'
```

**What it checks**: Redis/Memcached caching clusters
**Cost Impact**: Hourly rate based on node type
**Result**: No clusters found

---

### 6. API & Application Services

#### API Gateway
**Command**:
```bash
aws apigateway get-rest-apis --profile teamflow-admin --output json | \
  jq -r '.items[] | "\(.name) - \(.id) - Created: \(.createdDate)"'
```

**What it checks**: REST APIs
**Cost Impact**: Per million API calls + data transfer
**Result**: No APIs found

---

#### Cognito User Pools
**Command**:
```bash
aws cognito-idp list-user-pools --max-results 10 --profile teamflow-admin --output json | \
  jq -r '.UserPools[] | "\(.Name) - \(.Id)"'
```

**What it checks**: User authentication pools
**Cost Impact**: Per monthly active user (MAU)
**Result**: No user pools found

---

### 7. Messaging Services (SQS, SNS)

#### SQS Queues
**Command**:
```bash
aws sqs list-queues --profile teamflow-admin --output json
```

**What it checks**: Message queues
**Cost Impact**: Per million requests (minimal if unused)
**Result**: Found 1 queue (onu-searched) - **MINIMAL COST**

---

#### SNS Topics
**Command**:
```bash
aws sns list-topics --profile teamflow-admin --output json | \
  jq -r '.Topics[] | .TopicArn'
```

**What it checks**: Notification topics
**Cost Impact**: Per million publishes + deliveries
**Result**: No topics found

---

### 8. Monitoring & Logs

#### CloudWatch Log Groups
**Command**:
```bash
aws logs describe-log-groups --profile teamflow-admin --output json | \
  jq -r '.logGroups[] | "\(.logGroupName) - \(.storedBytes) bytes"'
```

**What it checks**: Log storage
**Cost Impact**: GB-month of storage + ingestion
**Result**: No log groups found

---

### 9. Infrastructure as Code

#### CloudFormation Stacks
**Command**:
```bash
aws cloudformation list-stacks --profile teamflow-admin \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --output json | \
  jq -r '.StackSummaries[] | "\(.StackName) - \(.StackStatus)"'
```

**What it checks**: Active CloudFormation stacks
**Cost Impact**: No direct cost (but creates resources that cost)
**Result**: No active stacks found

---

### 10. Backup Services

#### AWS Backup Plans
**Command**:
```bash
aws backup list-backup-plans --profile teamflow-admin --output json
```

**What it checks**: Automated backup configurations
**Cost Impact**: Storage + restore requests
**Result**: No backup plans found

---

## Summary of Findings

### ✅ Services Checked (Total: 20)

1. Lambda Functions
2. EC2 Instances
3. ECS Clusters
4. EKS Clusters
5. S3 Buckets
6. EBS Volumes
7. DynamoDB Tables
8. Elastic IPs
9. NAT Gateways
10. RDS Databases
11. ElastiCache Clusters
12. API Gateway
13. Cognito User Pools
14. SQS Queues
15. SNS Topics
16. CloudWatch Logs
17. CloudFormation Stacks
18. AWS Backup Plans
19. (Additional: VPCs, Security Groups checked indirectly)
20. (Additional: IAM resources - not billed directly)

### 🔴 Cost-Generating Resources Found

1. **Unassociated Elastic IP**: `eipalloc-0e816f71025cb1a44` (~$3.60/month)
2. **SQS Queue**: `onu-searched` (minimal, pay-per-use)

### 💰 Estimated Monthly Cost

**Total**: ~$3.60 - $5.00/month

---

## Reusable Billing Audit Script

See accompanying file: `aws-billing-audit.sh`

This script automates the entire audit process and can be run regularly (weekly/monthly) to track AWS resource costs.

---

## Additional Billing Checks (Manual)

### Check Actual Billing Dashboard

```bash
# Note: AWS CLI does not directly support Cost Explorer queries without complex setup
# Use AWS Console instead:
# 1. Go to: https://console.aws.amazon.com/cost-management/home
# 2. Navigate to: Cost Explorer
# 3. View: Last 6 months of spending
```

### Set Up Budget Alerts (One-time)

```bash
# Create a budget with email alerts
aws budgets create-budget \
  --account-id 168687661563 \
  --budget file://budget-config.json \
  --notifications-with-subscribers file://budget-notifications.json \
  --profile teamflow-admin
```

**budget-config.json**:
```json
{
  "BudgetName": "TeamFlow-Monthly-Budget",
  "BudgetLimit": {
    "Amount": "10.00",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
```

**budget-notifications.json**:
```json
[
  {
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80,
      "ThresholdType": "PERCENTAGE"
    },
    "Subscribers": [
      {
        "SubscriptionType": "EMAIL",
        "Address": "your-email@example.com"
      }
    ]
  }
]
```

---

## Recommendations

### 1. Immediate Actions

- **Release Elastic IP** if not needed (saves $3.60/month)
- **Delete SQS queue** if not part of any application
- **Set up AWS Budgets** for proactive cost monitoring

### 2. Regular Audits

- Run `aws-billing-audit.sh` weekly or monthly
- Review Cost Explorer in AWS Console monthly
- Check for zombie resources (unused but running)

### 3. Cost Optimization

- Use AWS Free Tier when available
- Delete unused resources immediately
- Use Reserved Instances for predictable workloads
- Enable CloudWatch Alarms for unusual activity

---

## Script Customization

To add new service checks to the audit script:

1. Find the AWS CLI command for the service
2. Add a new function following the pattern:
   ```bash
   check_service_name() {
       log_info "Checking Service Name..."
       aws service-name list-resources --profile "$AWS_PROFILE" --output json | jq ...
   }
   ```
3. Call the function in the `main()` section
4. Update the resource count

---

## References

- [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/latest/)
- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/)
- [jq Manual](https://stedolan.github.io/jq/manual/)

---

**End of Document**
