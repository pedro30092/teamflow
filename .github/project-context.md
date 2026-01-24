# TeamFlow Project Context

This document provides quick links to essential project information. Use this as your navigation guide when working with GitHub Copilot.

---

## Product Information

### What is TeamFlow?

TeamFlow is a **multi-tenant SaaS project management platform** built with serverless architecture on AWS.

**Target Users**: Teams of 5-200 people (small businesses, agencies, startups)

**Core Value**: Organize work without the complexity and cost of enterprise tools

**Full Details**: [research/PRODUCT_OVERVIEW.md](../research/PRODUCT_OVERVIEW.md)

### Key Features

**Base Platform** (MVP):
- User accounts and authentication
- Organization/workspace creation (multi-tenant)
- Team member invitations
- Projects and task boards
- Task assignment, status tracking, priorities
- Comments and collaboration

**Future Modules** (Post-MVP):
- Module 1: Team Calendar & Scheduling
- Module 2: Time Tracking & Reporting

### Pricing

**Model**: Freemium per-user subscription
- **Free**: $0 (3 users, 1 project)
- **Starter**: $10/user/month
- **Professional**: $25/user/month (+ Calendar)
- **Business**: $35/user/month (+ Calendar + Time Tracking)

---

## Technical Architecture

### Stack Overview

**Backend**:
- Runtime: Node.js 20.x LTS
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

### Architecture Deep Dive

**Complete Technical Details**: [research/TECHNICAL_ARCHITECTURE_SERVERLESS.md](../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)

**Key Sections**:
- High-level architecture diagram
- Technology stack with rationale
- Infrastructure architecture (Lambda, DynamoDB, API Gateway)
- Backend architecture (hexagonal architecture, Lambda layers)
- Frontend architecture (Angular + NgRx patterns)
- Database design (single-table DynamoDB)
- Authentication & authorization (Cognito)
- Cost optimization strategies

---

## Development

### Current Phase

**Phase**: Initial setup and infrastructure foundation

**Focus**: Setting up development environment, AWS configuration, and core infrastructure

### Development Roadmap

**Full Roadmap**: [research/DEVELOPMENT_ROADMAP_SERVERLESS.md](../research/DEVELOPMENT_ROADMAP_SERVERLESS.md)

**7 Phases** (14-15 weeks total):
1. **Infrastructure + Authentication** (2-3 weeks)
2. **Organizations** (2 weeks)
3. **Projects** (2 weeks)
4. **Tasks - Core** (2 weeks)
5. **Tasks - Workflow** (2 weeks)
6. **Collaboration** (2 weeks)
7. **Polish & Deployment** (2 weeks)

### MVP Details

**MVP Overview**: [research/MVP_OVERVIEW.md](../research/MVP_OVERVIEW.md)
**MVP Detailed Plan**: [research/MVP_DETAILED_PLAN.md](../research/MVP_DETAILED_PLAN.md)

**MVP Scope**: Base platform only (authentication, organizations, projects, tasks, comments)

**Timeline**: 3-4 months part-time development

**Success Criteria**:
- Users can create workspaces and invite teams
- Projects and tasks work with status tracking
- Comments enable collaboration
- Multi-tenant security validated

---

## Setup

### Getting Started

**Setup Guide**: [SETUP_GUIDE.md](../SETUP_GUIDE.md)

**Prerequisites** (1-2 days):
- Node.js 20.x LTS
- AWS CLI v2
- CDKTF CLI
- Angular CLI 18.x
- AWS account configured

**Verification**: Run the checklist in SETUP_GUIDE.md to confirm readiness

---

## Working with Copilot

### Main Instructions

**Primary Reference**: [.github/copilot-instructions.md](.github/copilot-instructions.md)

**Key Topics**:
- General principles (work in steps, skip certain directories)
- Temporary files convention (`tmp/` directory)
- AWS CLI operations (always use profile, save to tmp/)
- Project context and structure
- Best practices for code, security, performance

### Skills (Agents)

TeamFlow uses specialized "skills" to organize different types of work:

1. **[Product Owner](.github/skills/product-owner.md)**
   - Defines features and user needs
   - Creates user stories and acceptance criteria
   - Prioritizes based on business value

2. **[Project Manager](.github/skills/project-manager.md)**
   - Breaks down features into tasks
   - Organizes work using Agile/Scrum
   - Tracks progress and removes blockers

3. **[Software Architect](.github/skills/software-architect.md)**
   - Makes architectural decisions
   - Defines technical patterns and standards
   - Ensures alignment with architecture principles

4. **[Infrastructure & Backend Expert](.github/skills/infra-backend-expert.md)**
   - Implements serverless architecture
   - Writes production-grade code
   - Deploys infrastructure with CDKTF

### References

**Technical References**:
- [AWS CLI Reference](.github/references/aws-cli-reference.md) - Command examples for AWS services
- [Tmp Directory Convention](.github/references/tmp-directory-convention.md) - Where to save temporary files

---

## Quick Reference

### Common Questions

| Question | Answer |
|----------|--------|
| Where do I find product requirements? | [research/PRODUCT_OVERVIEW.md](../research/PRODUCT_OVERVIEW.md) |
| What's the technical architecture? | [research/TECHNICAL_ARCHITECTURE_SERVERLESS.md](../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md) |
| How do I break down work? | [.github/skills/project-manager.md](.github/skills/project-manager.md) |
| What coding patterns to use? | [.github/skills/infra-backend-expert.md](.github/skills/infra-backend-expert.md) |
| AWS CLI commands? | [.github/references/aws-cli-reference.md](.github/references/aws-cli-reference.md) |
| How do I set up my environment? | [SETUP_GUIDE.md](../SETUP_GUIDE.md) |

### File Organization

```
teamflow/
├── .github/                    # Copilot instructions and skills
│   ├── copilot-instructions.md # Main guidelines
│   ├── project-context.md      # This file
│   ├── skills/                 # Role-based agents
│   └── references/             # Technical references
├── research/                   # Product and architecture docs
│   ├── PRODUCT_OVERVIEW.md
│   ├── TECHNICAL_ARCHITECTURE_SERVERLESS.md
│   ├── DEVELOPMENT_ROADMAP_SERVERLESS.md
│   ├── MVP_OVERVIEW.md
│   └── MVP_DETAILED_PLAN.md
├── backend/                    # Lambda functions and layers
├── infrastructure/             # CDKTF infrastructure code
├── frontend/                   # Angular SPA
├── tmp/                        # Temporary files (gitignored)
├── README.md                   # Project README
└── SETUP_GUIDE.md              # Development environment setup
```

---

## Next Steps

1. **New to the project?** Start with [SETUP_GUIDE.md](../SETUP_GUIDE.md)
2. **Need product context?** Read [research/PRODUCT_OVERVIEW.md](../research/PRODUCT_OVERVIEW.md)
3. **Need technical details?** Check [research/TECHNICAL_ARCHITECTURE_SERVERLESS.md](../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)
4. **Ready to code?** Follow [research/DEVELOPMENT_ROADMAP_SERVERLESS.md](../research/DEVELOPMENT_ROADMAP_SERVERLESS.md)
5. **Working on a feature?** Reference the appropriate [skill](.github/skills/) for context

---

**Remember**: This project is about learning modern cloud-native patterns while building production-grade software. Take time to understand the architecture, and don't hesitate to reference the documentation.
