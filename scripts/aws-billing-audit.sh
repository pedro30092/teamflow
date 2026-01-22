#!/bin/bash

# Script: aws-billing-audit.sh
# Purpose: Automated AWS resource audit for billing analysis
# Usage: ./aws-billing-audit.sh [--profile PROFILE_NAME]
# Author: TeamFlow AWS CLI Expert
# Date: 2026-01-22

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
export AWS_PAGER=""
DEFAULT_PROFILE="teamflow-admin"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly OUTPUT_DIR="${PROJECT_ROOT}/tmp"
readonly TIMESTAMP=$(date +%Y%m%d-%H%M%S)
readonly REPORT_FILE="${OUTPUT_DIR}/aws-billing-report-${TIMESTAMP}.txt"

# Ensure tmp directory exists
mkdir -p "${OUTPUT_DIR}"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Counters
COST_RESOURCES=0
ZERO_COST_RESOURCES=0
TOTAL_ESTIMATED_COST=0

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_cost() {
    echo -e "${RED}[COST]${NC} $1"
}

# Report functions
report_header() {
    cat >> "$REPORT_FILE" <<EOF
================================================================================
AWS RESOURCE BILLING AUDIT REPORT
================================================================================
Date: $(date)
Profile: $AWS_PROFILE
Account: $AWS_ACCOUNT_ID
Region: $AWS_REGION
User: $AWS_USER_ARN

================================================================================
COST-GENERATING RESOURCES
================================================================================

EOF
}

report_section() {
    local section_name="$1"
    echo "" >> "$REPORT_FILE"
    echo "--- $section_name ---" >> "$REPORT_FILE"
}

report_line() {
    echo "$1" >> "$REPORT_FILE"
}

report_footer() {
    cat >> "$REPORT_FILE" <<EOF

================================================================================
RESOURCES CHECKED (NO ACTIVE RESOURCES)
================================================================================

$ZERO_COST_SUMMARY

================================================================================
COST SUMMARY
================================================================================

Total Cost-Generating Resources: $COST_RESOURCES
Estimated Monthly Cost: \$$TOTAL_ESTIMATED_COST - \$$(echo "$TOTAL_ESTIMATED_COST + 2" | bc)

================================================================================
RECOMMENDATIONS
================================================================================

$RECOMMENDATIONS

================================================================================
Report saved to: $REPORT_FILE
================================================================================
EOF
}

# Service check functions

check_identity() {
    log_info "Verifying AWS identity..."
    local identity
    identity=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --output json)

    AWS_ACCOUNT_ID=$(echo "$identity" | jq -r '.Account')
    AWS_USER_ARN=$(echo "$identity" | jq -r '.Arn')
    AWS_REGION=$(aws configure get region --profile "$AWS_PROFILE" || echo "us-east-1")

    log_info "Account: $AWS_ACCOUNT_ID"
    log_info "User: $AWS_USER_ARN"
    log_info "Region: $AWS_REGION"
}

check_lambda() {
    log_info "Checking Lambda functions..."
    local functions
    functions=$(aws lambda list-functions --profile "$AWS_PROFILE" --output json | jq -r '.Functions[]')

    if [[ -n "$functions" ]]; then
        local count
        count=$(echo "$functions" | jq -s 'length')
        log_cost "Found $count Lambda function(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "Lambda Functions"
        aws lambda list-functions --profile "$AWS_PROFILE" --output json | \
            jq -r '.Functions[] | "  • \(.FunctionName) - \(.Runtime) - \(.MemorySize)MB"' >> "$REPORT_FILE"
        report_line "  COST: Pay-per-invocation + GB-second of execution"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ Lambda Functions: NONE\n"
    fi
}

check_ec2() {
    log_info "Checking EC2 instances..."
    local instances
    instances=$(aws ec2 describe-instances --profile "$AWS_PROFILE" --output json | \
        jq -r '.Reservations[].Instances[] | select(.State.Name != "terminated")')

    if [[ -n "$instances" ]]; then
        local count
        count=$(echo "$instances" | jq -s 'length')
        log_cost "Found $count EC2 instance(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "EC2 Instances"
        aws ec2 describe-instances --profile "$AWS_PROFILE" --output json | \
            jq -r '.Reservations[].Instances[] | select(.State.Name != "terminated") |
                "  • \(.InstanceId) - \(.InstanceType) - \(.State.Name)"' >> "$REPORT_FILE"
        report_line "  COST: Hourly rate based on instance type"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ EC2 Instances: NONE\n"
    fi
}

check_elastic_ips() {
    log_info "Checking Elastic IPs..."
    local unassociated_ips
    unassociated_ips=$(aws ec2 describe-addresses --profile "$AWS_PROFILE" --output json | \
        jq -r '.Addresses[] | select(.InstanceId == null)')

    if [[ -n "$unassociated_ips" ]]; then
        local count
        count=$(echo "$unassociated_ips" | jq -s 'length')
        log_cost "Found $count unassociated Elastic IP(s) - GENERATING COST!"
        COST_RESOURCES=$((COST_RESOURCES + count))
        TOTAL_ESTIMATED_COST=$(echo "$TOTAL_ESTIMATED_COST + ($count * 3.60)" | bc)

        report_section "Elastic IPs (UNASSOCIATED - ⚠️ CREATING COSTS)"
        aws ec2 describe-addresses --profile "$AWS_PROFILE" --output json | \
            jq -r '.Addresses[] | select(.InstanceId == null) |
                "  • IP: \(.PublicIp) - Allocation: \(.AllocationId)\n  COST: ~$3.60/month (charged when not associated)\n  FIX: aws ec2 release-address --allocation-id \(.AllocationId) --profile '"$AWS_PROFILE"'"' >> "$REPORT_FILE"

        RECOMMENDATIONS="${RECOMMENDATIONS}
• Release unassociated Elastic IPs to save \$$(echo "$count * 3.60" | bc)/month"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ Unassociated Elastic IPs: NONE\n"
    fi
}

check_nat_gateways() {
    log_info "Checking NAT Gateways..."
    local nat_gateways
    nat_gateways=$(aws ec2 describe-nat-gateways --profile "$AWS_PROFILE" --output json | \
        jq -r '.NatGateways[] | select(.State == "available")')

    if [[ -n "$nat_gateways" ]]; then
        local count
        count=$(echo "$nat_gateways" | jq -s 'length')
        log_cost "Found $count NAT Gateway(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))
        TOTAL_ESTIMATED_COST=$(echo "$TOTAL_ESTIMATED_COST + ($count * 32)" | bc)

        report_section "NAT Gateways"
        aws ec2 describe-nat-gateways --profile "$AWS_PROFILE" --output json | \
            jq -r '.NatGateways[] | select(.State == "available") |
                "  • \(.NatGatewayId) - \(.State)\n  COST: ~$32/month + data processing"' >> "$REPORT_FILE"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ NAT Gateways: NONE\n"
    fi
}

check_ebs_volumes() {
    log_info "Checking EBS volumes..."
    local volumes
    volumes=$(aws ec2 describe-volumes --profile "$AWS_PROFILE" --output json | jq -r '.Volumes[]')

    if [[ -n "$volumes" ]]; then
        local count
        count=$(echo "$volumes" | jq -s 'length')
        log_cost "Found $count EBS volume(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "EBS Volumes"
        aws ec2 describe-volumes --profile "$AWS_PROFILE" --output json | \
            jq -r '.Volumes[] | "  • \(.VolumeId) - \(.Size)GB - \(.State) - \(.VolumeType)"' >> "$REPORT_FILE"
        report_line "  COST: GB-month of provisioned storage"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ EBS Volumes: NONE\n"
    fi
}

check_rds() {
    log_info "Checking RDS instances..."
    local instances
    instances=$(aws rds describe-db-instances --profile "$AWS_PROFILE" --output json 2>/dev/null | jq -r '.DBInstances[]' || echo "")

    if [[ -n "$instances" ]]; then
        local count
        count=$(echo "$instances" | jq -s 'length')
        log_cost "Found $count RDS instance(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "RDS Databases"
        aws rds describe-db-instances --profile "$AWS_PROFILE" --output json | \
            jq -r '.DBInstances[] | "  • \(.DBInstanceIdentifier) - \(.DBInstanceClass) - \(.DBInstanceStatus)"' >> "$REPORT_FILE"
        report_line "  COST: Hourly rate + storage"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ RDS Databases: NONE\n"
    fi
}

check_dynamodb() {
    log_info "Checking DynamoDB tables..."
    local tables
    tables=$(aws dynamodb list-tables --profile "$AWS_PROFILE" --output json | jq -r '.TableNames[]')

    if [[ -n "$tables" ]]; then
        local count
        count=$(echo "$tables" | wc -l)
        log_cost "Found $count DynamoDB table(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "DynamoDB Tables"
        echo "$tables" | while read -r table; do
            echo "  • $table" >> "$REPORT_FILE"
        done
        report_line "  COST: Provisioned/on-demand capacity + storage"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ DynamoDB Tables: NONE\n"
    fi
}

check_s3() {
    log_info "Checking S3 buckets..."
    local buckets
    buckets=$(aws s3 ls --profile "$AWS_PROFILE" 2>/dev/null | awk '{print $3}')

    if [[ -n "$buckets" ]]; then
        local count
        count=$(echo "$buckets" | wc -l)
        log_cost "Found $count S3 bucket(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "S3 Buckets"
        echo "$buckets" | while read -r bucket; do
            echo "  • $bucket" >> "$REPORT_FILE"
        done
        report_line "  COST: Storage + requests + data transfer"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ S3 Buckets: NONE\n"
    fi
}

check_api_gateway() {
    log_info "Checking API Gateways..."
    local apis
    apis=$(aws apigateway get-rest-apis --profile "$AWS_PROFILE" --output json 2>/dev/null | jq -r '.items[]' || echo "")

    if [[ -n "$apis" ]]; then
        local count
        count=$(echo "$apis" | jq -s 'length')
        log_cost "Found $count API Gateway(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "API Gateways"
        aws apigateway get-rest-apis --profile "$AWS_PROFILE" --output json | \
            jq -r '.items[] | "  • \(.name) - \(.id)"' >> "$REPORT_FILE"
        report_line "  COST: Per million API calls"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ API Gateways: NONE\n"
    fi
}

check_cognito() {
    log_info "Checking Cognito User Pools..."
    local pools
    pools=$(aws cognito-idp list-user-pools --max-results 10 --profile "$AWS_PROFILE" --output json 2>/dev/null | jq -r '.UserPools[]' || echo "")

    if [[ -n "$pools" ]]; then
        local count
        count=$(echo "$pools" | jq -s 'length')
        log_cost "Found $count Cognito User Pool(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "Cognito User Pools"
        aws cognito-idp list-user-pools --max-results 10 --profile "$AWS_PROFILE" --output json | \
            jq -r '.UserPools[] | "  • \(.Name) - \(.Id)"' >> "$REPORT_FILE"
        report_line "  COST: Per monthly active user (MAU)"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ Cognito User Pools: NONE\n"
    fi
}

check_sqs() {
    log_info "Checking SQS queues..."
    local queues
    queues=$(aws sqs list-queues --profile "$AWS_PROFILE" --output json 2>/dev/null | jq -r '.QueueUrls[]' || echo "")

    if [[ -n "$queues" ]]; then
        local count
        count=$(echo "$queues" | wc -l)
        log_warn "Found $count SQS queue(s) - minimal cost if unused"

        report_section "SQS Queues"
        echo "$queues" | while read -r queue; do
            local queue_name
            queue_name=$(basename "$queue")
            echo "  • $queue_name" >> "$REPORT_FILE"
            echo "    URL: $queue" >> "$REPORT_FILE"
        done
        report_line "  COST: Per million requests (minimal if unused)"

        RECOMMENDATIONS="${RECOMMENDATIONS}
• Review SQS queues - delete if unused"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ SQS Queues: NONE\n"
    fi
}

check_sns() {
    log_info "Checking SNS topics..."
    local topics
    topics=$(aws sns list-topics --profile "$AWS_PROFILE" --output json 2>/dev/null | jq -r '.Topics[].TopicArn' || echo "")

    if [[ -n "$topics" ]]; then
        local count
        count=$(echo "$topics" | wc -l)
        log_cost "Found $count SNS topic(s)"

        report_section "SNS Topics"
        echo "$topics" | while read -r topic; do
            echo "  • $topic" >> "$REPORT_FILE"
        done
        report_line "  COST: Per million publishes"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ SNS Topics: NONE\n"
    fi
}

check_cloudwatch_logs() {
    log_info "Checking CloudWatch Log Groups..."
    local log_groups
    log_groups=$(aws logs describe-log-groups --profile "$AWS_PROFILE" --output json 2>/dev/null | jq -r '.logGroups[]' || echo "")

    if [[ -n "$log_groups" ]]; then
        local count
        count=$(echo "$log_groups" | jq -s 'length')
        log_cost "Found $count CloudWatch Log Group(s)"

        report_section "CloudWatch Log Groups"
        aws logs describe-log-groups --profile "$AWS_PROFILE" --output json | \
            jq -r '.logGroups[] | "  • \(.logGroupName) - \(.storedBytes) bytes"' >> "$REPORT_FILE"
        report_line "  COST: GB-month of storage"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ CloudWatch Logs: NONE\n"
    fi
}

check_ecs() {
    log_info "Checking ECS clusters..."
    local clusters
    clusters=$(aws ecs list-clusters --profile "$AWS_PROFILE" --output json | jq -r '.clusterArns[]')

    if [[ -n "$clusters" ]]; then
        local count
        count=$(echo "$clusters" | wc -l)
        log_cost "Found $count ECS cluster(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "ECS Clusters"
        echo "$clusters" | while read -r cluster; do
            echo "  • $cluster" >> "$REPORT_FILE"
        done
        report_line "  COST: Based on Fargate tasks or EC2 instances"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ ECS Clusters: NONE\n"
    fi
}

check_eks() {
    log_info "Checking EKS clusters..."
    local clusters
    clusters=$(aws eks list-clusters --profile "$AWS_PROFILE" --output json | jq -r '.clusters[]')

    if [[ -n "$clusters" ]]; then
        local count
        count=$(echo "$clusters" | wc -l)
        log_cost "Found $count EKS cluster(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))
        TOTAL_ESTIMATED_COST=$(echo "$TOTAL_ESTIMATED_COST + ($count * 72)" | bc)

        report_section "EKS Clusters"
        echo "$clusters" | while read -r cluster; do
            echo "  • $cluster" >> "$REPORT_FILE"
        done
        report_line "  COST: $0.10/hour (~$72/month) per cluster + worker nodes"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ EKS Clusters: NONE\n"
    fi
}

check_elasticache() {
    log_info "Checking ElastiCache clusters..."
    local clusters
    clusters=$(aws elasticache describe-cache-clusters --profile "$AWS_PROFILE" --output json 2>/dev/null | jq -r '.CacheClusters[]' || echo "")

    if [[ -n "$clusters" ]]; then
        local count
        count=$(echo "$clusters" | jq -s 'length')
        log_cost "Found $count ElastiCache cluster(s)"
        COST_RESOURCES=$((COST_RESOURCES + count))

        report_section "ElastiCache Clusters"
        aws elasticache describe-cache-clusters --profile "$AWS_PROFILE" --output json | \
            jq -r '.CacheClusters[] | "  • \(.CacheClusterId) - \(.CacheNodeType) - \(.CacheClusterStatus)"' >> "$REPORT_FILE"
        report_line "  COST: Hourly rate based on node type"
    else
        ZERO_COST_SUMMARY="${ZERO_COST_SUMMARY}✓ ElastiCache: NONE\n"
    fi
}

# Main execution
main() {
    log_info "Starting AWS Billing Audit..."
    log_info "Report will be saved to: $REPORT_FILE"
    echo ""

    # Check identity
    check_identity
    echo ""

    # Initialize report
    report_header

    # Run all checks
    check_elastic_ips  # Check first as it's a common cost source
    check_nat_gateways
    check_ec2
    check_ebs_volumes
    check_rds
    check_elasticache
    check_lambda
    check_dynamodb
    check_s3
    check_api_gateway
    check_cognito
    check_sqs
    check_sns
    check_cloudwatch_logs
    check_ecs
    check_eks

    # Finalize report
    report_footer

    echo ""
    log_info "Audit complete!"
    log_info "Cost-generating resources found: $COST_RESOURCES"
    log_info "Estimated monthly cost: \$${TOTAL_ESTIMATED_COST} - \$$(echo "$TOTAL_ESTIMATED_COST + 2" | bc)"
    log_info "Full report saved to: $REPORT_FILE"
    echo ""

    # Display report
    cat "$REPORT_FILE"
}

# Parse arguments
AWS_PROFILE="$DEFAULT_PROFILE"
while [[ $# -gt 0 ]]; do
    case $1 in
        --profile)
            AWS_PROFILE="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [--profile PROFILE_NAME]"
            echo ""
            echo "Options:"
            echo "  --profile    AWS profile to use (default: teamflow-admin)"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

export AWS_PROFILE

# Global variables
ZERO_COST_SUMMARY=""
RECOMMENDATIONS="
• Set up AWS Budgets for proactive cost monitoring
• Review Cost Explorer monthly for unexpected charges
• Run this audit script regularly (weekly/monthly)"

# Run main function
main
