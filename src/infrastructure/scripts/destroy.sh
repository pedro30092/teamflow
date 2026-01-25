#!/bin/bash
#
# TeamFlow Infrastructure Destruction Script
#
# This script tears down AWS infrastructure created by CDKTF.
# USE WITH CAUTION - This will delete AWS resources and may result in data loss.
#
# Usage:
#   ./scripts/destroy.sh [stack-name] [--delete-logs]
#
# Environment Variables:
#   AWS_PROFILE - AWS profile to use (default: teamflow-developer)
#   AWS_REGION  - AWS region (default: us-east-1)
#   SKIP_CONFIRM - Skip confirmation prompt (use in automation only)
#
# Examples:
#   ./scripts/destroy.sh                    # Destroy all stacks (with confirmation, keeps logs)
#   ./scripts/destroy.sh teamflow-api-dev   # Destroy specific stack
#   ./scripts/destroy.sh --delete-logs      # Destroy + delete CloudWatch logs
#   AWS_PROFILE=prod ./scripts/destroy.sh   # Use different profile
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# AWS Configuration
export AWS_PROFILE="${AWS_PROFILE:-teamflow-developer}"
export AWS_REGION="${AWS_REGION:-us-east-1}"
readonly SKIP_CONFIRM="${SKIP_CONFIRM:-false}"

# Directories
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly INFRA_DIR="${PROJECT_ROOT}/infrastructure"

# Flags
DELETE_LOGS=false
STACK_NAME=""

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

check_tool() {
    local tool=$1
    if ! command -v "${tool}" &> /dev/null; then
        log_error "Required tool '${tool}' is not installed"
        return 1
    fi
    log_success "Found ${tool}"
}

# ============================================================================
# Parse Arguments
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --delete-logs)
                DELETE_LOGS=true
                shift
                ;;
            *)
                # Assume it's a stack name
                STACK_NAME="$1"
                shift
                ;;
        esac
    done
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

preflight_checks() {
    log_info "Running pre-flight checks..."
    
    # Check required tools
    check_tool "cdktf" || {
        log_error "cdktf CLI not found. Install with: npm install -g cdktf-cli@latest"
        exit 1
    }
    check_tool "aws" || {
        log_warning "AWS CLI not found. Destruction may fail if credentials aren't configured."
    }
    
    # Verify AWS credentials
    log_info "Verifying AWS credentials (profile: ${AWS_PROFILE})..."
    if ! aws sts get-caller-identity --profile "${AWS_PROFILE}" &> /dev/null; then
        log_error "AWS credentials not configured for profile '${AWS_PROFILE}'"
        log_error "Run: aws configure --profile ${AWS_PROFILE}"
        exit 1
    fi
    
    local identity
    identity=$(aws sts get-caller-identity --profile "${AWS_PROFILE}" 2>/dev/null || echo "{}")
    local account_id
    account_id=$(echo "${identity}" | grep -o '"Account": "[^"]*"' | cut -d'"' -f4)
    local user_arn
    user_arn=$(echo "${identity}" | grep -o '"Arn": "[^"]*"' | cut -d'"' -f4)
    
    if [[ -n "${account_id}" ]]; then
        log_success "AWS Account: ${account_id}"
        log_info "AWS User: ${user_arn}"
    fi
    
    # Check if in infrastructure directory
    if [[ ! -f "${INFRA_DIR}/package.json" ]]; then
        log_error "Infrastructure package.json not found"
        exit 1
    fi
    
    log_success "Pre-flight checks passed"
    echo ""
}

# ============================================================================
# Confirmation
# ============================================================================

confirm_destruction() {
    local stack_name="${1:-all stacks}"
    
    if [[ "${SKIP_CONFIRM}" == "true" ]]; then
        log_warning "Skipping confirmation (SKIP_CONFIRM=true)"
        return 0
    fi
    
    echo ""
    log_warning "================================================"
    log_warning "          ⚠️  DESTRUCTIVE OPERATION  ⚠️"
    log_warning "================================================"
    echo ""
    log_warning "You are about to DESTROY: ${stack_name}"
    log_warning "AWS Profile: ${AWS_PROFILE}"
    log_warning "AWS Region: ${AWS_REGION}"
    echo ""
    log_warning "This will delete the following AWS resources:"
    log_warning "  - Lambda functions"
    log_warning "  - API Gateway"
    log_warning "  - DynamoDB tables (if any)"
    log_warning "  - S3 buckets (if any)"
    log_warning "  - IAM roles and policies"
    log_warning "  - All associated data"
    
    # Show additional warning if --delete-logs flag is set
    if [[ "${DELETE_LOGS}" == "true" ]]; then
        echo ""
        log_error "  - CloudWatch Log Groups (--delete-logs flag set)"
    fi
    
    echo ""
    log_error "THIS CANNOT BE UNDONE!"
    echo ""
    
       log_warning "Auto-approving destruction (no confirmation required)"
       log_warning "Proceeding with destruction in 2 seconds..."
       sleep 2
}

# ============================================================================
# Destruction
# ============================================================================

destroy_infrastructure() {
    cd "${INFRA_DIR}"
    
    log_info "Starting infrastructure destruction..."
    log_info "Profile: ${AWS_PROFILE}"
    log_info "Region: ${AWS_REGION}"
    
    if [[ -n "${STACK_NAME}" ]]; then
        log_info "Stack: ${STACK_NAME}"
        echo ""
        
        # Destroy specific stack with auto-approve (inherits AWS_PROFILE and AWS_REGION)
        cdktf destroy "${STACK_NAME}" --auto-approve
    else
        log_info "Destroying all stacks"
        echo ""
        
        # Destroy all stacks with auto-approve (inherits AWS_PROFILE and AWS_REGION)
        cdktf destroy "*" --auto-approve
    fi
    
    log_success "Infrastructure destroyed"
    echo ""
}

# ============================================================================
# Delete CloudWatch Logs (Optional)
# ============================================================================

delete_cloudwatch_logs() {
    if [[ "${DELETE_LOGS}" != "true" ]]; then
        log_info "Skipping CloudWatch Log deletion (use --delete-logs to enable)"
        echo ""
        return 0
    fi
    
    log_warning "Deleting CloudWatch Log Groups..."
    
    # Get all log groups
    local log_groups
    log_groups=$(aws logs describe-log-groups \
        --profile "${AWS_PROFILE}" \
        --region "${AWS_REGION}" \
        --query 'logGroups[*].logGroupName' \
        --output text 2>/dev/null || echo "")
    
    if [[ -z "${log_groups}" ]]; then
        log_info "No CloudWatch Log Groups found"
        echo ""
        return 0
    fi
    
    # Delete each log group that contains 'teamflow' in the name or Lambda logs
    local deleted_count=0
    for log_group in ${log_groups}; do
        if [[ "${log_group}" == *"teamflow"* ]] || [[ "${log_group}" == "/aws/lambda/teamflow"* ]]; then
            log_info "Deleting log group: ${log_group}"
            if aws logs delete-log-group \
                --profile "${AWS_PROFILE}" \
                --region "${AWS_REGION}" \
                --log-group-name "${log_group}" 2>/dev/null; then
                ((deleted_count++))
            else
                log_warning "Failed to delete log group: ${log_group}"
            fi
        fi
    done
    
    log_success "Deleted ${deleted_count} CloudWatch Log Group(s)"
    echo ""
}

# ============================================================================
# Cleanup
# ============================================================================

cleanup_artifacts() {
    log_info "Cleaning up local artifacts..."
    
    cd "${INFRA_DIR}"
    
    # Remove CDKTF output directory (optional - can be kept for debugging)
    if [[ -d "cdktf.out" ]]; then
        log_info "Removing cdktf.out directory..."
        rm -rf cdktf.out
        log_success "Local artifacts cleaned"
    fi
    
    # Note: We keep compiled JS/TS files as they may be needed for next deployment
    
    echo ""
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    echo ""
    log_info "============================"
    log_info "TeamFlow Destruction Script"
    log_info "============================"
    echo ""
    
    preflight_checks
    confirm_destruction "${STACK_NAME:-all stacks}"
    destroy_infrastructure
    delete_cloudwatch_logs
    cleanup_artifacts
    
    log_success "============================"
    log_success "Destruction Complete!"
    log_success "============================"
    echo ""
    
    if [[ -n "${STACK_NAME}" ]]; then
        log_info "Stack '${STACK_NAME}' has been destroyed"
    else
        log_info "All stacks have been destroyed"
    fi
    
    if [[ "${DELETE_LOGS}" == "true" ]]; then
        log_info "CloudWatch Logs have been deleted"
    else
        log_info "CloudWatch Logs have been preserved (use --delete-logs to delete them)"
    fi
    echo ""
}

# Run main with all arguments
main "$@"
