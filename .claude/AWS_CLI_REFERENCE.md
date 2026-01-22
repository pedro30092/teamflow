# AWS CLI Command Reference

Detailed command examples for AWS services. For conventions, see CLAUDE.md.

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

# Scan (use sparingly)
aws dynamodb scan --table-name TABLE_NAME --profile teamflow-admin

# Put item
aws dynamodb put-item \
    --table-name TABLE_NAME \
    --item '{"PK":{"S":"TEST"},"SK":{"S":"TEST"},"data":{"S":"value"}}' \
    --profile teamflow-admin

# Update item
aws dynamodb update-item \
    --table-name TABLE_NAME \
    --key '{"PK":{"S":"ORG#org-123"},"SK":{"S":"PROJECT#proj-456"}}' \
    --update-expression "SET #name = :name" \
    --expression-attribute-names '{"#name":"name"}' \
    --expression-attribute-values '{":name":{"S":"Updated Name"}}' \
    --profile teamflow-admin

# Delete item
aws dynamodb delete-item \
    --table-name TABLE_NAME \
    --key '{"PK":{"S":"TEST"},"SK":{"S":"TEST"}}' \
    --profile teamflow-admin
```

---

## API Gateway

```bash
# List REST APIs
aws apigateway get-rest-apis --profile teamflow-admin

# Get API details
aws apigateway get-rest-api --rest-api-id API_ID --profile teamflow-admin

# List resources (endpoints)
aws apigateway get-resources --rest-api-id API_ID --profile teamflow-admin

# Get method details
aws apigateway get-method \
    --rest-api-id API_ID \
    --resource-id RESOURCE_ID \
    --http-method POST \
    --profile teamflow-admin

# Test invoke endpoint
aws apigateway test-invoke-method \
    --rest-api-id API_ID \
    --resource-id RESOURCE_ID \
    --http-method POST \
    --body '{"key":"value"}' \
    --profile teamflow-admin

# Get deployment stages
aws apigateway get-stages --rest-api-id API_ID --profile teamflow-admin
```

---

## S3

```bash
# List buckets
aws s3 ls --profile teamflow-admin

# List objects in bucket
aws s3 ls s3://BUCKET_NAME --profile teamflow-admin

# Copy file to S3
aws s3 cp local-file.txt s3://BUCKET_NAME/ --profile teamflow-admin

# Download from S3
aws s3 cp s3://BUCKET_NAME/file.txt ./downloaded-file.txt --profile teamflow-admin

# Sync directory to S3
aws s3 sync ./local-dir s3://BUCKET_NAME/prefix --profile teamflow-admin

# Get bucket policy
aws s3api get-bucket-policy --bucket BUCKET_NAME --profile teamflow-admin
```

---

## EC2

```bash
# List instances (not terminated)
aws ec2 describe-instances --profile teamflow-admin \
    | jq -r '.Reservations[].Instances[] | select(.State.Name != "terminated") | "\(.InstanceId) - \(.InstanceType) - \(.State.Name)"'

# List Elastic IPs
aws ec2 describe-addresses --profile teamflow-admin

# Find unassociated Elastic IPs
aws ec2 describe-addresses --profile teamflow-admin \
    | jq -r '.Addresses[] | select(.InstanceId == null) | "\(.PublicIp) - \(.AllocationId)"'

# Release Elastic IP
aws ec2 release-address --allocation-id ALLOCATION_ID --profile teamflow-admin

# List NAT Gateways
aws ec2 describe-nat-gateways --profile teamflow-admin

# List EBS volumes
aws ec2 describe-volumes --profile teamflow-admin
```

---

## IAM

```bash
# List roles
aws iam list-roles --profile teamflow-admin

# Get role details
aws iam get-role --role-name ROLE_NAME --profile teamflow-admin

# List policies attached to role
aws iam list-attached-role-policies --role-name ROLE_NAME --profile teamflow-admin

# List users
aws iam list-users --profile teamflow-admin

# Get user details
aws iam get-user --user-name USERNAME --profile teamflow-admin
```

---

## Cognito

```bash
# List user pools
aws cognito-idp list-user-pools --max-results 10 --profile teamflow-admin

# Describe user pool
aws cognito-idp describe-user-pool --user-pool-id USER_POOL_ID --profile teamflow-admin

# List users in pool
aws cognito-idp list-users --user-pool-id USER_POOL_ID --profile teamflow-admin

# Get user details
aws cognito-idp admin-get-user \
    --user-pool-id USER_POOL_ID \
    --username USERNAME \
    --profile teamflow-admin
```

---

## CloudWatch Logs

```bash
# List log groups
aws logs describe-log-groups --profile teamflow-admin

# Tail logs (live follow)
aws logs tail /aws/lambda/FUNCTION_NAME --follow --profile teamflow-admin

# Get logs since specific time
aws logs tail /aws/lambda/FUNCTION_NAME --since 30m --profile teamflow-admin

# Filter logs
aws logs filter-log-events \
    --log-group-name /aws/lambda/FUNCTION_NAME \
    --filter-pattern "ERROR" \
    --start-time $(date -d '1 hour ago' +%s)000 \
    --profile teamflow-admin
```

---

## SQS

```bash
# List queues
aws sqs list-queues --profile teamflow-admin

# Get queue URL
aws sqs get-queue-url --queue-name QUEUE_NAME --profile teamflow-admin

# Send message
aws sqs send-message \
    --queue-url QUEUE_URL \
    --message-body "message content" \
    --profile teamflow-admin

# Receive messages
aws sqs receive-message --queue-url QUEUE_URL --profile teamflow-admin

# Delete queue
aws sqs delete-queue --queue-url QUEUE_URL --profile teamflow-admin
```

---

## SNS

```bash
# List topics
aws sns list-topics --profile teamflow-admin

# Create topic
aws sns create-topic --name TOPIC_NAME --profile teamflow-admin

# Publish message
aws sns publish \
    --topic-arn TOPIC_ARN \
    --message "message content" \
    --profile teamflow-admin
```

---

## RDS

```bash
# List database instances
aws rds describe-db-instances --profile teamflow-admin

# Get instance details
aws rds describe-db-instances \
    --db-instance-identifier INSTANCE_ID \
    --profile teamflow-admin
```

---

## ECS

```bash
# List clusters
aws ecs list-clusters --profile teamflow-admin

# Describe cluster
aws ecs describe-clusters --clusters CLUSTER_NAME --profile teamflow-admin

# List services
aws ecs list-services --cluster CLUSTER_NAME --profile teamflow-admin
```

---

## EKS

```bash
# List clusters
aws eks list-clusters --profile teamflow-admin

# Describe cluster
aws eks describe-cluster --name CLUSTER_NAME --profile teamflow-admin
```

---

## CloudFormation

```bash
# List stacks
aws cloudformation list-stacks --profile teamflow-admin

# Describe stack
aws cloudformation describe-stacks --stack-name STACK_NAME --profile teamflow-admin

# Get stack events
aws cloudformation describe-stack-events --stack-name STACK_NAME --profile teamflow-admin
```

---

## jq Processing Examples

```bash
# Extract specific field
aws lambda list-functions --profile teamflow-admin \
    | jq '.Functions[0].FunctionName'

# Get all function names
aws lambda list-functions --profile teamflow-admin \
    | jq -r '.Functions[].FunctionName'

# Multiple fields
aws lambda list-functions --profile teamflow-admin \
    | jq '.Functions[] | {name: .FunctionName, runtime: .Runtime, memory: .MemorySize}'

# Filter by condition
aws lambda list-functions --profile teamflow-admin \
    | jq '.Functions[] | select(.Runtime == "nodejs20.x")'

# Count resources
aws lambda list-functions --profile teamflow-admin \
    | jq '.Functions | length'

# Convert to CSV
aws lambda list-functions --profile teamflow-admin \
    | jq -r '.Functions[] | [.FunctionName, .Runtime, .MemorySize] | @csv'

# Group by runtime
aws lambda list-functions --profile teamflow-admin \
    | jq 'group_by(.Runtime) | map({runtime: .[0].Runtime, count: length})'
```

---

## Common Patterns

### Save and Process

```bash
# Save raw output
aws dynamodb describe-table --table-name MyTable --profile teamflow-admin \
    > tmp/table-info-$(date +%Y%m%d).json

# Process and save
aws lambda list-functions --profile teamflow-admin \
    | jq -r '.Functions[].FunctionName' \
    > tmp/function-names.txt
```

### Iterate Over Resources

```bash
# Process each Lambda function
aws lambda list-functions --profile teamflow-admin \
    | jq -r '.Functions[].FunctionName' \
    | while read -r function; do
        echo "Processing: $function"
        aws lambda get-function --function-name "$function" --profile teamflow-admin
    done
```

### Error Handling

```bash
# Check if resource exists
if aws lambda get-function --function-name "$FUNCTION_NAME" --profile teamflow-admin &>/dev/null; then
    echo "Function exists"
else
    echo "Function not found"
fi

# Capture errors
if ! OUTPUT=$(aws dynamodb describe-table --table-name "$TABLE_NAME" --profile teamflow-admin 2>&1); then
    echo "Error: $OUTPUT"
    exit 1
fi
```

---

## Best Practices

1. **Always set AWS_PAGER=""** - Prevents interactive paging
2. **Always specify profile** - Never rely on default
3. **Use jq for parsing** - More reliable than grep/awk
4. **Save to tmp/** - Keep outputs organized and gitignored
5. **Use timestamps** - Makes files easier to track
6. **Verify identity first** - Run `aws sts get-caller-identity`
7. **Handle errors** - Check command exit codes
8. **Be cautious with delete** - Double-check resource names

---

## Security Reminders

- Never hardcode credentials
- Never commit AWS outputs (use tmp/)
- Verify profile before destructive operations
- Be careful with IAM operations
- Sanitize logs before sharing
- Use read-only operations when possible

---

**Last Updated**: 2026-01-22
