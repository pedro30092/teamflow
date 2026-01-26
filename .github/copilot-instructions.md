# GitHub Copilot - TeamFlow Project Guidelines

**Last Updated**: 2026-01-24

---

## 🛑 ABSOLUTELY FORBIDDEN (Check Before Any Action)

**DO NOT create/modify/update without explicit user request**:
- Story files (agile-management/stories/)
- Summary or documentation files
- Any files outside the code being built
- Story status or completion
- Retrospectives or work notes

**Before creating ANY file**: Ask — "Did the user explicitly request this?"

---

This document provides guidelines for effectively working with GitHub Copilot on the TeamFlow project. These instructions help Copilot understand the project context, constraints, and best practices.

---

## General Principles

### 1. Work in Steps for Large Processes

**Rule**: When dealing with large, complex processes that involve multiple files or extensive documentation, always work in steps to maintain clarity and avoid overwhelming context.

**Why**: Breaking work into smaller steps:
- Prevents context confusion
- Allows for better focus on each subtask
- Makes it easier to review and iterate
- Reduces errors and improves quality

**Examples of When to Use Step-by-Step Approach**:

✅ **DO break into steps**:
- Creating multiple epic files (create one at a time)
- Generating extensive documentation (overview first, then details)
- Setting up complex infrastructure (one stack at a time)
- Implementing multiple features (one feature per step)
- Large refactoring tasks (one module at a time)

❌ **DON'T break into steps** (can do in one go):
- Single file edits
- Small bug fixes
- Simple feature additions
- Quick documentation updates

### Example: Creating Project Management System

**❌ Bad Approach** (all at once):
```
Create PROJECT_MANAGER_OVERVIEW.md with complete details,
plus all epic files (EPIC_1, EPIC_2, EPIC_3, EPIC_4, EPIC_5),
plus all sprint files, and update README.
```
*Problem*: This approach risks incomplete work and confusion.

**✅ Good Approach** (step-by-step):
```
Step 1: Create PROJECT_MANAGER_OVERVIEW.md with general structure
Step 2: Create EPIC_1_SETUP.md with detailed breakdown
Step 3: Create EPIC_2_CORE_INFRASTRUCTURE.md (next session)
Step 4: Create sprint templates (when needed)
```
*Benefit*: Each step is complete, reviewable, and maintains quality.

### 2. Directories to Always Skip

**CRITICAL RULE**: Copilot must NEVER read, review, or reference certain directories.

**What Copilot CANNOT do**:
- ❌ **NEVER read files** inside `learning/` directory or any subdirectory
- ❌ **NEVER reference** content from these directories in responses
- ❌ **NEVER use** ideas or concepts from these files

**What Copilot CAN do**:
- ✅ Acknowledge that these directories exist if asked
- ✅ Explain that they're excluded from Copilot's scope

**Rationale**: These directories contain personal notes, experimental concepts, or are not relevant to the current development phase. Reading this content can:
- Cause confusion about project requirements
- Mix personal ideas with actual project specifications
- Lead to incorrect assumptions about the codebase
- Waste context on irrelevant content

**Excluded Paths**:
```
learning/           # Skip entirely
learning/**/*       # All nested
```

### 3. Temporary Files Convention

**CRITICAL RULE**: All temporary files, dumps, reports, and sensitive data MUST go in `/tmp` at the project root.

**Path**: `/home/pedro/Personal/development/teamflow/tmp/`

**What Copilot MUST do**:
- ✅ **ALWAYS save** temporary files to `tmp/` directory
- ✅ **ALWAYS use** timestamped filenames (e.g., `report-20260124-180702.txt`)
- ✅ **ALWAYS create** `tmp/` directory if it doesn't exist (`mkdir -p tmp`)
- ✅ **Reference** the convention in `.github/references/tmp-directory-convention.md` for details

**What goes in `/tmp`**:
- AWS CLI outputs and billing reports
- Debug logs and diagnostics
- Any data that might contain credentials or account IDs
- Script-generated reports and data dumps

**Script pattern**:
```bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="${PROJECT_ROOT}/tmp"
mkdir -p "${TMP_DIR}"
OUTPUT_FILE="${TMP_DIR}/report-$(date +%Y%m%d-%H%M%S).txt"
```

**Why**: The `tmp/` directory is in `.gitignore`, preventing accidental commits of sensitive AWS data, credentials, or personal information.

### 4. AWS CLI Operations

**CRITICAL RULES**: When executing AWS CLI commands, Copilot must follow these conventions:

**Environment Setup**:
- ✅ **ALWAYS set** `export AWS_PAGER=""` (prevents interactive paging)
- ✅ **ALWAYS use** `--profile teamflow-developer` (or specified profile name)
- ✅ **NEVER** run AWS commands without specifying profile
- ✅ **ALWAYS save** outputs to `tmp/` directory

**Command Patterns**:
```bash
# Standard session setup
export AWS_PAGER=""
export AWS_PROFILE="teamflow-developer"

# Verify identity before operations
aws sts get-caller-identity --profile teamflow-developer

# Save outputs with timestamps
aws lambda list-functions --profile teamflow-developer \
    > tmp/lambda-list-$(date +%Y%m%d-%H%M%S).json
```

**Script Template**:
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
export AWS_PAGER=""
export AWS_PROFILE="teamflow-developer"
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly TMP_DIR="${PROJECT_ROOT}/tmp"
readonly TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Ensure tmp directory exists
mkdir -p "${TMP_DIR}"

# Your AWS operations here
aws sts get-caller-identity --profile teamflow-developer
```

**JSON Processing**:
- ✅ **ALWAYS use jq** for parsing AWS CLI JSON outputs
- ✅ Use `-r` flag for raw output (no quotes)
- ✅ Extract specific fields instead of returning entire JSON

**Example**:
```bash
# Get all Lambda function names
aws lambda list-functions --profile teamflow-developer \
    | jq -r '.Functions[].FunctionName'
```

**Security**:
- ❌ **NEVER** hardcode credentials
- ❌ **NEVER** commit AWS outputs (they go to `tmp/`)
- ❌ **NEVER** log sensitive data (tokens, keys, passwords)
- ✅ Verify profile before destructive operations

**Reference**: See `.github/references/aws-cli-reference.md` for detailed command examples for specific AWS services.

### 5. Communication Style

**Be clear and direct**:
- State what you're doing and why
- Provide context for technical decisions
- Explain trade-offs when relevant
- Ask clarifying questions when requirements are ambiguous

**Format responses**:
- Use markdown for structure
- Include code examples when helpful
- Provide file paths and line references
- Use clear section headings

### 6. Teaching Mode & Technical Teacher Agent

When user explicitly identifies as a **junior developer** or requests educational explanation of infrastructure/backend topics, use the **Technical Teacher Agent** (see `.github/agents/technical-teacher.agent.md`):

**Activation Phrases**:
- "As a junior developer, explain..."
- "Teach me about..."
- "As someone learning about..."
- "I want to understand how..."

**What Technical Teacher Agent Does**:
- ✅ Explains infrastructure, backend, and architecture topics
- ✅ Uses real AWS resource names, IDs, and ARNs
- ✅ Shows complete request/execution flows
- ✅ References actual TeamFlow code
- ✅ Explains trade-offs and design decisions
- ❌ Does NOT use analogies (pure technical explanation)

**Structure**:
1. **Technical Explanation** (what, how, why)
2. **Detailed Technical Walkthrough** (actual AWS resource interactions)
3. **Summary** (key takeaways + actionable understanding)

**Output**: Deep technical understanding—explains architecture with real resource names and complete flows.

---

## Project Context

### Overview
TeamFlow is a **multi-tenant SaaS project management platform** built with serverless architecture on AWS.

**Key Information**:
- **Product Details**: See [research/PRODUCT_OVERVIEW.md](../research/PRODUCT_OVERVIEW.md)
- **Technical Architecture**: See [research/TECHNICAL_ARCHITECTURE_SERVERLESS.md](../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)
- **Development Roadmap**: See [research/DEVELOPMENT_ROADMAP_SERVERLESS.md](../research/DEVELOPMENT_ROADMAP_SERVERLESS.md)
- **MVP Details**: See [research/MVP_OVERVIEW.md](../research/MVP_OVERVIEW.md) and [research/MVP_DETAILED_PLAN.md](../research/MVP_DETAILED_PLAN.md)

**Quick Summary**:
- **Target Users**: Teams of 5-200 people (small businesses, agencies, startups)
- **Core Features**: Project & task management with optional calendar and time tracking modules
- **Pricing**: Freemium model ($0-$35/user/month)

### Technology Stack

**Backend**:
- Runtime: Node.js 24.x LTS
- Language: TypeScript 5.x
- Compute: AWS Lambda (arm64)
- API: API Gateway (REST)
- Database: DynamoDB (single-table design)
- Auth: AWS Cognito
- Storage: S3 + CloudFront

**Frontend**:
- Framework: Angular 18.x
- State: NgRx with signals
- Local Storage: Dexie.js (IndexedDB)

**Infrastructure**:
- IaC: CDKTF (Terraform CDK with TypeScript)
- CI/CD: GitHub Actions
- Monitoring: CloudWatch

**Architecture Pattern**:
- Hexagonal architecture (ports & adapters)
- Lambda layers for shared business logic
- Multi-tenant data isolation

### Current Phase
**Phase**: Initial setup and infrastructure foundation
**Focus**: Setting up development environment, AWS configuration, and core infrastructure

---

## Working with Skills/Agents

TeamFlow uses specialized "skills" (similar to agent roles) to organize different types of work. These skills help Copilot understand the context and constraints for specific tasks.

### Available Skills

1. **Product Owner** (`.github/skills/product-owner.md`)
   - Defines features and user needs
   - Prioritizes work based on business value
   - Creates user stories and acceptance criteria

2. **Project Manager** (`.github/skills/project-manager.md`)
   - Breaks down features into tasks
   - Organizes work using Agile/Scrum methodology
   - Tracks progress and removes blockers

3. **Software Architect** (`.github/skills/software-architect.md`)
   - Makes architectural decisions
   - Defines technical patterns and standards
   - Ensures alignment with architecture principles

4. **Infrastructure & Backend Expert** (`.github/skills/infra-backend-expert.md`)
   - Implements serverless architecture
   - Writes production-grade code
   - Deploys infrastructure with CDKTF

### How to Use Skills

When working on specific tasks, reference the appropriate skill file for context:

```
For product-related questions: Check .github/skills/product-owner.md
For task breakdown: Check .github/skills/project-manager.md
For architecture decisions: Check .github/skills/software-architect.md
For implementation: Check .github/skills/infra-backend-expert.md
```

---

