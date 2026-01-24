# AWS CLI Reference

Detailed command examples for AWS services used in TeamFlow.

**Profile**: `teamflow-admin`  
**Always set**: `export AWS_PAGER=""`

---

## Identity & Account

```bash
# Get current identity
aws sts get-caller-identity --profile teamflow-admin

# Output:
# {
#   "UserId": "...",
#   "Account": "168687661563",
#   "Arn": "arn:aws:sts::168687661563:assumed-role/..."
# }
```

---

## Lambda Functions

```bash
# List all functions
aws lambda list-functions --profile teamflow-admin

# Get function names only
aws lambda list-functions --profile teamflow-admin \
    | jq -r '.Functions[].FunctionName'

# Get function configuration
aws lambda get-function --function-name FUNCTION_NAME --profile teamflow-admin

# Invoke function
aws lambda invoke \
    --function-name FUNCTION_NAME \
    --payload '{"key":"value"}' \
    --profile teamflow-admin \
    tmp/response.json

# Update environment variables
aws lambda update-function-configuration \
    --function-name FUNCTION_NAME \
    --environment "Variables={KEY=VALUE}" \
    --profile teamflow-admin

# Get function logs (last 10 minutes)
aws logs tail /aws/lambda/FUNCTION_NAME --since 10m --profile teamflow-admin
```

---

## DynamoDB

```bash
# List tables
aws dynamodb list-tables --profile teamflow-admin

# Describe table
aws dynamodb describe-table --table-name TABLE_NAME --profile teamflow-admin

# Get item by primary key
aws dynamodb get-item \
    --table-name TABLE_NAME \
    --key '{"PK":{"S":"ORG#org-123"},"SK":{"S":"PROJECT#proj-456"}}' \
    --profile teamflow-admin

# Query with KeyConditionExpression
aws dynamodb query \
    --table-name TABLE_NAME \
    --key-condition-expression "PK = :pk AND begins_with(SK, :sk)" \
    --expression-attribute-values '{":pk":{"S":"ORG#org-123"},":sk":{"S":"PROJECT#"}}' \
    --profile teamflow-admin

# Query using GSI
aws dynamodb query \
    --table-name TABLE_NAME \
    --index-name GSI1 \
    --key-condition-expression "GSI1PK = :gsi1pk" \
    --expression-attribute-values '{":gsi1pk":{"S":"PROJECT#proj-456"}}' \
    --profile teamflow-admin

# Scan (use sparingly - expensive)
aws dynamodb scan --table-name TABLE_NAME --limit 10 --profile teamflow-admin

# Put item
aws dynamodb put-item \
    --table-name TABLE_NAME \
    --item '{"PK":{"S":"TEST"},"SK":{"S":"TEST"},"data":{"S":"value"}}' \
    --profile teamflow-admin
```

---

## API Gateway

```bash
# List APIs
aws apigateway get-rest-apis --profile teamflow-admin

# Get API details
aws apigateway get-rest-api --rest-api-id API_ID --profile teamflow-admin

# List resources
aws apigateway get-resources --rest-api-id API_ID --profile teamflow-admin

# Test invoke
aws apigateway test-invoke-method \
    --rest-api-id API_ID \
    --resource-id RESOURCE_ID \
    --http-method GET \
    --profile teamflow-admin
```

---

## Cognito

```bash
# List user pools
aws cognito-idp list-user-pools --max-results 10 --profile teamflow-admin

# Describe user pool
aws cognito-idp describe-user-pool --user-pool-id POOL_ID --profile teamflow-admin

# List users
aws cognito-idp list-users --user-pool-id POOL_ID --profile teamflow-admin

# Get user
aws cognito-idp admin-get-user \
    --user-pool-id POOL_ID \
    --username user@example.com \
    --profile teamflow-admin

# Create user (admin)
aws cognito-idp admin-create-user \
    --user-pool-id POOL_ID \
    --username user@example.com \
    --user-attributes Name=email,Value=user@example.com Name=name,Value="John Doe" \
    --profile teamflow-admin
```

---

## S3

```bash
# List buckets
aws s3 ls --profile teamflow-admin

# List bucket contents
aws s3 ls s3://BUCKET_NAME/ --profile teamflow-admin

# Upload file
aws s3 cp local-file.txt s3://BUCKET_NAME/ --profile teamflow-admin

# Download file
aws s3 cp s3://BUCKET_NAME/file.txt ./local-file.txt --profile teamflow-admin

# Sync directory
aws s3 sync ./local-dir s3://BUCKET_NAME/remote-dir/ --profile teamflow-admin

# Generate presigned URL (1 hour expiry)
aws s3 presign s3://BUCKET_NAME/file.txt --expires-in 3600 --profile teamflow-admin
```

---

## CloudWatch Logs

```bash
# List log groups
aws logs describe-log-groups --profile teamflow-admin

# Tail logs (follow mode)
aws logs tail /aws/lambda/FUNCTION_NAME --follow --profile teamflow-admin

# Get logs since timestamp
aws logs tail /aws/lambda/FUNCTION_NAME --since 1h --profile teamflow-admin

# Filter logs
aws logs filter-log-events \
    --log-group-name /aws/lambda/FUNCTION_NAME \
    --filter-pattern "ERROR" \
    --profile teamflow-admin
```

---

## CloudWatch Metrics

```bash
# List metrics
aws cloudwatch list-metrics --namespace AWS/Lambda --profile teamflow-admin

# Get metric statistics
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Duration \
    --dimensions Name=FunctionName,Value=FUNCTION_NAME \
    --start-time 2026-01-24T00:00:00Z \
    --end-time 2026-01-24T23:59:59Z \
    --period 3600 \
    --statistics Average \
    --profile teamflow-admin
```

---

## IAM

```bash
# List users
aws iam list-users --profile teamflow-admin

# Get user details
aws iam get-user --user-name USERNAME --profile teamflow-admin

# List roles
aws iam list-roles --profile teamflow-admin

# Get role policy
aws iam get-role --role-name ROLE_NAME --profile teamflow-admin

# List attached policies
aws iam list-attached-role-policies --role-name ROLE_NAME --profile teamflow-admin
```

---

## Cost & Billing

```bash
# Get cost and usage (last 30 days)
aws ce get-cost-and-usage \
    --time-period Start=2026-01-01,End=2026-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --profile teamflow-admin

# Get cost by service
aws ce get-cost-and-usage \
    --time-period Start=2026-01-01,End=2026-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE \
    --profile teamflow-admin
```

---

## Common Workflows

### Deploy Lambda with New Code

```bash
# 1. Build code
cd backend
npm run build

# 2. Create deployment package
cd dist/functions/create-project
zip -r ../../../create-project.zip .

# 3. Update function
aws lambda update-function-code \
    --function-name teamflow-create-project-dev \
    --zip-file fileb://create-project.zip \
    --profile teamflow-admin

# 4. Check logs
aws logs tail /aws/lambda/teamflow-create-project-dev --since 1m --follow --profile teamflow-admin
```

### Debug DynamoDB Access Pattern

```bash
# 1. Query specific pattern
aws dynamodb query \
    --table-name teamflow-dev \
    --key-condition-expression "PK = :pk AND begins_with(SK, :sk)" \
    --expression-attribute-values '{":pk":{"S":"ORG#org-123"},":sk":{"S":"PROJECT#"}}' \
    --profile teamflow-admin \
    > tmp/projects-query-$(date +%Y%m%d-%H%M%S).json

# 2. Pretty print with jq
cat tmp/projects-query-*.json | jq '.Items'

# 3. Count results
cat tmp/projects-query-*.json | jq '.Count'
```

### Monitor Lambda Performance

```bash
# Get Duration metrics for last hour
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Duration \
    --dimensions Name=FunctionName,Value=teamflow-create-project-dev \
    --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
    --period 300 \
    --statistics Average,Maximum \
    --profile teamflow-admin \
    | jq '.Datapoints | sort_by(.Timestamp)'
```

---

## Remember

**Always**:
- Set `export AWS_PAGER=""`
- Use `--profile teamflow-admin`
- Save outputs to `tmp/` directory
- Use `jq` for JSON parsing

**Never**:
- Commit AWS outputs to git
- Hardcode credentials
- Run destructive commands without verification
