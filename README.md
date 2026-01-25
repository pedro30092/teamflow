# TeamFlow

**Multi-tenant SaaS project management platform built with serverless architecture**

TeamFlow is a learning project focused on mastering modern cloud-native patterns: AWS Lambda, DynamoDB single-table design, hexagonal architecture, CDKTF, and Angular with NgRx.

---

## Quick Start

**New to this project?** Follow these steps:

1. **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Set up your development environment (1-2 days)
2. **[research/DEVELOPMENT_ROADMAP_SERVERLESS.md](research/DEVELOPMENT_ROADMAP_SERVERLESS.md)** - Follow the development phases
3. **[research/TECHNICAL_ARCHITECTURE_SERVERLESS.md](research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)** - Reference the architecture

---

## Documentation

### Getting Started
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete environment setup instructions
  - Install tools (Node.js, AWS CLI, CDKTF, Angular CLI)
  - Configure AWS account and credentials
  - Initialize project structure

### Development
- **[research/DEVELOPMENT_ROADMAP_SERVERLESS.md](research/DEVELOPMENT_ROADMAP_SERVERLESS.md)** - Development phases and tech stack
  - **Source of truth** for versions and technologies
  - 7 phases from infrastructure to deployment
  - Learn-while-building approach

### Architecture
- **[research/TECHNICAL_ARCHITECTURE_SERVERLESS.md](research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)** - Complete technical architecture
  - Serverless patterns (Lambda, API Gateway, DynamoDB)
  - Hexagonal architecture with ports & adapters
  - Multi-tenant security patterns
  - DynamoDB single-table design

### Product
- **[research/PRODUCT_OVERVIEW.md](research/PRODUCT_OVERVIEW.md)** - Product vision and features
- **[research/MVP_OVERVIEW.md](research/MVP_OVERVIEW.md)** - MVP scope and success criteria
- **[research/MVP_DETAILED_PLAN.md](research/MVP_DETAILED_PLAN.md)** - Sprint-by-sprint plan

---

## Tech Stack

**Backend**: AWS Lambda (Node.js 24.x) + DynamoDB + API Gateway + Cognito
**Frontend**: Angular 18 + NgRx + Dexie
**Infrastructure**: CDKTF (Terraform CDK with TypeScript)
**Architecture**: Hexagonal (ports & adapters)

See [DEVELOPMENT_ROADMAP_SERVERLESS.md](research/DEVELOPMENT_ROADMAP_SERVERLESS.md) for exact versions.

---

## Project Structure

```
teamflow/
├── backend/              # Lambda functions and layers
│   ├── functions/        # Lambda handlers (thin wrappers)
│   └── layers/           # Business logic (hexagonal architecture)
├── infrastructure/       # CDKTF infrastructure code
│   └── stacks/           # CloudFormation stacks
├── frontend/             # Angular SPA
│   └── src/app/          # Feature modules
├── research/             # Architecture and planning docs
└── SETUP_GUIDE.md        # Development environment setup
```

---

## Current Status

**Phase**: Initial setup
**Next**: Complete SETUP_GUIDE.md and begin Phase 1 (Infrastructure + Authentication)

---

## Learning Goals

This project is designed to master:
- **DynamoDB single-table design** - Access patterns, GSIs, multi-tenant data modeling
- **AWS Lambda architecture** - Layers, cold starts, hexagonal architecture in serverless
- **CDKTF** - Type-safe infrastructure as code with TypeScript
- **Hexagonal architecture** - Clean separation of concerns (domain, ports, use cases, adapters)
- **Multi-tenant security** - Organization-level data isolation
- **Angular + NgRx** - Reactive state management with signals

---

## License

MIT - Learning project for educational purposes
