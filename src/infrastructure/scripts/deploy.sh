#!/bin/bash
#
# TeamFlow Infrastructure Deployment Script
#
# This script compiles TypeScript infrastructure code, synthesizes
# CDKTF configuration, and deploys to AWS.
#
# Usage:
#   ./scripts/deploy.sh [stack-name] [--skip-backend]
#
# Environment Variables:
#   AWS_PROFILE - AWS profile to use (default: teamflow-developer)
#   AWS_REGION  - AWS region (default: us-east-1)
#
# Examples:
#   ./scripts/deploy.sh                    # Deploy all stacks + backend
#   ./scripts/deploy.sh --skip-backend     # Infrastructure only
#   ./scripts/deploy.sh teamflow-api-dev   # Deploy specific stack
#   AWS_PROFILE=prod ./scripts/deploy.sh   # Use different profile
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

# Directories
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
readonly INFRA_DIR="${PROJECT_ROOT}/infrastructure"
readonly BACKEND_DIR="${PROJECT_ROOT}/backend"
readonly TMP_DIR="${PROJECT_ROOT}/tmp"
readonly TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Flags
SKIP_BACKEND=false
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
            --skip-backend)
                SKIP_BACKEND=true
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
    check_tool "node" || exit 1
    check_tool "npm" || exit 1
    check_tool "cdktf" || {
        log_error "cdktf CLI not found. Install with: npm install -g cdktf-cli@latest"
        exit 1
    }
    check_tool "aws" || {
        log_warning "AWS CLI not found. Deployment may fail if credentials aren't configured."
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
    
    # Ensure tmp directory exists
    mkdir -p "${TMP_DIR}"
    
    log_success "Pre-flight checks passed"
    echo ""
}

# ============================================================================
# Build Steps
# ============================================================================

build_backend() {
    if [[ "${SKIP_BACKEND}" == "true" ]]; then
        log_warning "Skipping backend build (--skip-backend flag set)"
        echo ""
        return 0
    fi
    
    log_info "Building backend code..."
    
    # Check if backend directory exists
    if [[ ! -d "${BACKEND_DIR}" ]]; then
        log_warning "Backend directory not found at ${BACKEND_DIR}"
        log_warning "Skipping backend build"
        echo ""
        return 0
    fi
    
    # Check if backend has package.json
    if [[ ! -f "${BACKEND_DIR}/package.json" ]]; then
        log_warning "Backend package.json not found"
        log_warning "Skipping backend build"
        echo ""
        return 0
    fi
    
    cd "${BACKEND_DIR}"
    
    # Install dependencies if node_modules is missing
    if [[ ! -d "node_modules" ]]; then
        log_info "Installing backend dependencies..."
        npm install
    fi
    
    # Build backend (functions + layers)
    log_info "Compiling backend TypeScript and building layers..."
    npm run build
    log_success "Backend built successfully"
    
    cd "${INFRA_DIR}"
    echo ""
}

build_infrastructure() {
    log_info "Building infrastructure code..."
    
    cd "${INFRA_DIR}"
    
    # Install dependencies if node_modules is missing
    if [[ ! -d "node_modules" ]]; then
        log_info "Installing dependencies..."
        npm install
    fi
    
    # Compile TypeScript
    log_info "Compiling TypeScript..."
    npm run build
    log_success "TypeScript compiled"
    
    # Synthesize CDKTF
    log_info "Synthesizing CDKTF configuration..."
    cdktf synth
    log_success "CDKTF configuration synthesized"
    
    echo ""
}

# ============================================================================
# Deployment
# ============================================================================

deploy_infrastructure() {
    cd "${INFRA_DIR}"
    
    log_info "Starting deployment to AWS..."
    log_info "Profile: ${AWS_PROFILE}"
    log_info "Region: ${AWS_REGION}"
    
    if [[ -n "${STACK_NAME}" ]]; then
        log_info "Stack: ${STACK_NAME}"
        echo ""
        
        # Deploy specific stack (inherits AWS_PROFILE and AWS_REGION from environment)
           cdktf deploy "${STACK_NAME}" --auto-approve
    else
        log_info "Deploying all stacks"
        echo ""
        
        # Deploy all stacks (inherits AWS_PROFILE and AWS_REGION from environment)
           cdktf deploy "*" --auto-approve
    fi
    
    log_success "Deployment completed"
    echo ""
}

# ============================================================================
# Capture Outputs
# ============================================================================

capture_outputs() {
    log_info "Capturing deployment outputs..."
    
    cd "${INFRA_DIR}"
    
    local output_file="${TMP_DIR}/deployment-outputs-${TIMESTAMP}.json"
    
    # Try to get outputs (may not exist for all stacks)
    if cdktf output > "${output_file}" 2>/dev/null; then
        log_success "Outputs saved to: ${output_file}"
        
        # Display outputs
        echo ""
        log_info "Deployment Outputs:"
        cat "${output_file}"
        echo ""
    else
        log_warning "No outputs found or unable to capture outputs"
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    echo ""
    log_info "=========================="
    log_info "TeamFlow Deployment Script"
    log_info "=========================="
    echo ""
    
    preflight_checks
    build_backend
    build_infrastructure
    deploy_infrastructure
    capture_outputs
    
    log_success "=========================="
    log_success "Deployment Complete!"
    log_success "=========================="
    echo ""
    
    if [[ -n "${STACK_NAME}" ]]; then
        log_info "Stack '${STACK_NAME}' is now live"
    else
        log_info "All stacks are now live"
    fi
    echo ""
}

# Run main with all arguments
main "$@"
