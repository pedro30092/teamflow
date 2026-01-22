# TeamFlow - Serverless Technical Architecture (AWS + TypeScript)

**Last Updated**: 2026-01-22
**Status**: Approved - Early Stage / Demo Phase
**Phase**: MVP - Free Tier Optimized
**Architecture Philosophy**: Learning-optimized with best practices (Hexagonal Architecture, Single-Table DynamoDB)

---

## Executive Summary

TeamFlow will be built as a **serverless multi-tenant SaaS application** on AWS, optimized for free tier usage during the demo/early stage. The architecture prioritizes **learning modern patterns** (hexagonal architecture, DynamoDB single-table design, serverless) while building a functional multi-tenant SaaS platform.

**Key Architectural Decisions**:
- **Backend**: API Gateway + AWS Lambda per endpoint (TypeScript/Node.js)
- **Database**: DynamoDB with single-table design (multi-tenant aware)
- **Frontend**: Angular SPA with NgRx state management (monolith with lazy-loading)
- **IaC**: CDKTF (Terraform CDK with TypeScript)
- **Architecture Pattern**: Hexagonal architecture (ports & adapters) for all business logic
- **Business Logic**: Lambda layers for shared code
- **CI/CD**: GitHub Actions
- **Auth**: AWS Cognito (to be designed)

**Learning Goals**:
- Master DynamoDB single-table design patterns
- Implement hexagonal architecture in serverless context
- Learn CDKTF for infrastructure as code
- Build production-grade multi-tenant SaaS architecture

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Technology Stack](#technology-stack)
3. [Infrastructure Architecture](#infrastructure-architecture)
4. [Backend Architecture](#backend-architecture)
5. [Frontend Architecture](#frontend-architecture)
6. [Database Design](#database-design)
7. [Authentication & Authorization](#authentication--authorization)
8. [Infrastructure as Code](#infrastructure-as-code)
9. [CI/CD Pipeline](#cicd-pipeline)
10. [Cost Optimization](#cost-optimization)
11. [Trade-offs & Risks](#trade-offs--risks)
12. [Migration Path](#migration-path)

---

## Architecture Overview

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │  Route 53 (DNS) │
                    └────────┬────────┘
                             │
        ┏━━━━━━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━━━━━━┓
        ▼                                          ▼
┌───────────────┐                        ┌─────────────────┐
│  CloudFront   │                        │  API Gateway    │
│     (CDN)     │                        │   (REST API)    │
└───────┬───────┘                        └────────┬────────┘
        │                                         │
        ▼                                         │
┌───────────────┐                                 │
│   S3 Bucket   │                        ┌────────▼────────┐
│ (Angular SPA) │                        │  Lambda         │
└───────────────┘                        │  Functions      │
                                         │  (TypeScript)   │
                                         └────────┬────────┘
                                                  │
                                    ┏━━━━━━━━━━━━━┻━━━━━━━━━━━━┓
                                    ▼                          ▼
                            ┌───────────────┐         ┌──────────────┐
                            │   DynamoDB    │         │   Cognito    │
                            │ (Multi-Tenant)│         │   (Auth)     │
                            └───────────────┘         └──────────────┘
                                    │
                                    ▼
                            ┌───────────────┐
                            │      S3       │
                            │ (File Storage)│
                            └───────────────┘

        ┌─────────────────────────────────────────────┐
        │  Observability Layer (Free Tier)            │
        │  - CloudWatch Logs                          │
        │  - CloudWatch Metrics                       │
        │  - X-Ray (optional)                         │
        └─────────────────────────────────────────────┘
```

---

## Technology Stack

### Backend

| Component | Technology | Version | Rationale |
|-----------|-----------|---------|-----------|
| **Runtime** | Node.js | 20.x LTS | Latest LTS, best Lambda performance |
| **Language** | TypeScript | 5.x | Type safety, better DX |
| **Compute** | AWS Lambda | - | Serverless, free tier generous (1M requests/month) |
| **API Gateway** | API Gateway REST | v2 | Standard REST API, WebSocket support future |
| **Database** | DynamoDB | - | Serverless, free tier 25GB + 25 RCU/WCU |
| **File Storage** | S3 | - | Object storage, 5GB free tier |
| **Authentication** | AWS Cognito | - | Managed auth, 50k MAU free |

### Frontend

| Component | Technology | Version | Rationale |
|-----------|-----------|---------|-----------|
| **Framework** | Angular | 18.x (TBD) | Modern, reactive, strong typing |
| **State Management** | NgRx | Latest | Reactive state with signals |
| **Local Storage** | Dexie.js | Latest | IndexedDB wrapper for offline capability |
| **HTTP Client** | Angular HttpClient | - | Built-in, interceptor support |
| **UI Components** | TBD | - | Material/PrimeNG/Custom (decision pending) |
| **Build Tool** | Angular CLI + esbuild | - | Fast builds, optimized bundles |

### Infrastructure & DevOps

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| **IaC** | CDKTF (Terraform CDK) | Type-safe Terraform with TypeScript, multi-cloud future |
| **CI/CD** | GitHub Actions | Free for public repos, 2000 min/month for private |
| **Monitoring** | CloudWatch | Free tier: 10 custom metrics, 5GB logs |
| **CDN** | CloudFront | 1TB transfer/month free tier |
| **DNS** | Route 53 | $0.50/month per hosted zone |

---

## Infrastructure Architecture

### AWS Service Usage & Free Tier Limits

| Service | Free Tier Limit | Expected Usage (MVP) | Cost After Free Tier |
|---------|-----------------|----------------------|----------------------|
| **Lambda** | 1M requests/month, 400,000 GB-seconds | ~100K requests/month | $0.20 per 1M requests |
| **API Gateway** | 1M API calls/month (12 months) | ~100K calls/month | $3.50 per 1M requests |
| **DynamoDB** | 25GB storage, 25 WCU/RCU | ~2GB, ~10 WCU/RCU | $1.25/GB-month, $0.25/WCU |
| **S3** | 5GB storage, 20K GET, 2K PUT | ~1GB, ~5K requests | $0.023/GB-month |
| **CloudFront** | 1TB transfer, 10M requests | ~10GB transfer | $0.085/GB after 1TB |
| **Cognito** | 50K MAU | ~100 users | $0.0055/MAU after 50K |
| **CloudWatch** | 10 metrics, 5GB logs | ~5 metrics, ~1GB logs | $0.30/metric, $0.50/GB |

**Estimated Monthly Cost (MVP)**: **$1-5/month** (mostly Route 53 + minimal overages)

### Infrastructure Components

#### 1. Networking (Minimal - Cost Optimized)

```typescript
// No VPC needed for serverless architecture
// Lambda runs in AWS-managed VPC
// DynamoDB is a managed service (no VPC)
// Only need VPC if adding RDS or ElastiCache later
```

**Decision**: Skip VPC for MVP to stay in free tier (NAT Gateway costs $32/month)

#### 2. Compute (Lambda)

**Lambda Configuration**:
- **Memory**: 512MB (balance between cost and cold start)
- **Timeout**: 30 seconds (API Gateway max)
- **Runtime**: Node.js 20.x
- **Architecture**: arm64 (Graviton2 - 20% cheaper, 19% faster)

**Cold Start Mitigation**:
- Keep functions small (<10MB zipped)
- Use Lambda layers for shared dependencies
- Consider provisioned concurrency for critical endpoints (costs extra)
- Use Lambda SnapStart (future - when available for Node.js)

#### 3. API Gateway Configuration

**Type**: REST API (not HTTP API)
- Better feature set (request validation, caching, API keys)
- Same free tier as HTTP API

**Features**:
- Request validation (JSON Schema)
- CORS configuration
- API keys for rate limiting
- Custom domain (post-MVP)
- Throttling (10,000 requests/second burst)

#### 4. Monitoring & Logging

**CloudWatch Logs**:
- 5GB free tier
- Structured JSON logging
- Log retention: 7 days (MVP), 30 days (production)

**CloudWatch Metrics**:
- Lambda duration, errors, invocations (free)
- Custom business metrics (10 free)

**X-Ray** (Optional):
- 100K traces/month free
- Enable for debugging only (not always-on)

---

## Backend Architecture

### Project Structure (Monorepo)

```
teamflow-backend/
├── functions/                     # Lambda handlers (thin wrappers)
│   ├── auth/
│   │   ├── login.ts               # Handler calls LoginUseCase from layer
│   │   ├── register.ts
│   │   └── refresh-token.ts
│   ├── organizations/
│   │   ├── create.ts
│   │   ├── list.ts
│   │   └── get.ts
│   ├── projects/
│   │   ├── create.ts
│   │   ├── list.ts
│   │   ├── get.ts
│   │   └── update.ts
│   └── tasks/
│       ├── create.ts
│       ├── list.ts
│       ├── update.ts
│       └── delete.ts
│
├── layers/                        # Lambda layers (business logic + dependencies)
│   ├── business-logic/            # Shared business logic layer
│   │   └── nodejs/
│   │       └── node_modules/
│   │           └── @teamflow/
│   │               └── core/
│   │                   ├── domain/                # Domain models
│   │                   │   ├── entities/
│   │                   │   │   ├── User.ts
│   │                   │   │   ├── Organization.ts
│   │                   │   │   ├── Project.ts
│   │                   │   │   └── Task.ts
│   │                   │   └── value-objects/
│   │                   ├── ports/                 # Hexagonal architecture ports
│   │                   │   ├── repositories/
│   │                   │   │   ├── IUserRepository.ts
│   │                   │   │   └── IProjectRepository.ts
│   │                   │   └── services/
│   │                   │       └── IAuthService.ts
│   │                   ├── use-cases/             # Application logic
│   │                   │   ├── auth/
│   │                   │   │   ├── LoginUseCase.ts
│   │                   │   │   └── RegisterUseCase.ts
│   │                   │   ├── projects/
│   │                   │   │   ├── CreateProjectUseCase.ts
│   │                   │   │   └── ListProjectsUseCase.ts
│   │                   │   └── tasks/
│   │                   ├── adapters/              # Hexagonal architecture adapters
│   │                   │   ├── dynamodb/
│   │                   │   │   ├── DynamoDBUserRepository.ts
│   │                   │   │   └── DynamoDBProjectRepository.ts
│   │                   │   └── cognito/
│   │                   │       └── CognitoAuthService.ts
│   │                   └── utils/
│   │                       ├── logger.ts
│   │                       ├── errors.ts
│   │                       └── validators.ts
│   │
│   └── dependencies/              # External npm dependencies layer
│       └── nodejs/
│           └── node_modules/      # aws-sdk, date-fns, etc.
│
├── infrastructure/                # CDKTF code
│   ├── stacks/
│   │   ├── api-stack.ts           # API Gateway + Lambdas + DynamoDB
│   │   ├── auth-stack.ts          # Cognito
│   │   ├── storage-stack.ts       # S3 buckets
│   │   └── frontend-stack.ts      # CloudFront + S3
│   ├── constructs/                # Reusable constructs (optional)
│   │   ├── lambda-with-layer.ts
│   │   └── api-endpoint.ts
│   ├── main.ts                    # CDKTF app entry point
│   ├── cdktf.json
│   └── package.json
│
├── package.json                   # Workspace root
├── tsconfig.json                  # Base TypeScript config
└── README.md
```

### Lambda Handler Pattern (Thin Wrapper)

```typescript
// functions/projects/create.ts
import { APIGatewayProxyHandler } from 'aws-lambda';
// Import from Lambda layer (available via /opt/nodejs/node_modules)
import { CreateProjectUseCase } from '@teamflow/core/use-cases/projects/CreateProjectUseCase';
import { DynamoDBProjectRepository } from '@teamflow/core/adapters/dynamodb/DynamoDBProjectRepository';
import { logger } from '@teamflow/core/utils/logger';
import { validateRequest } from '@teamflow/core/utils/validators';
import { CreateProjectDTO } from '@teamflow/core/domain/dtos/CreateProjectDTO';

// Initialize dependencies (outside handler for reuse)
const projectRepository = new DynamoDBProjectRepository();
const createProjectUseCase = new CreateProjectUseCase(projectRepository);

export const handler: APIGatewayProxyHandler = async (event, context) => {
  const requestId = context.requestId;
  logger.setContext({ requestId });

  try {
    // 1. Extract user context from authorizer
    const userId = event.requestContext.authorizer?.claims?.sub;
    const organizationId = event.requestContext.authorizer?.claims?.['custom:orgId'];

    if (!userId || !organizationId) {
      return {
        statusCode: 401,
        body: JSON.stringify({ error: 'Unauthorized' }),
      };
    }

    // 2. Parse and validate request
    const body = JSON.parse(event.body || '{}');
    const dto = validateRequest(CreateProjectDTO, body);

    // 3. Execute use case (business logic)
    const project = await createProjectUseCase.execute({
      ...dto,
      organizationId,
      createdBy: userId,
    });

    // 4. Return response
    return {
      statusCode: 201,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*', // Configure properly in production
      },
      body: JSON.stringify({
        success: true,
        data: project,
      }),
    };
  } catch (error) {
    logger.error('Failed to create project', { error });

    return {
      statusCode: error.statusCode || 500,
      body: JSON.stringify({
        success: false,
        error: error.message,
        code: error.code,
      }),
    };
  }
};
```

### Use Case Pattern (Business Logic)

```typescript
// layers/business-logic/nodejs/node_modules/@teamflow/core/use-cases/projects/CreateProjectUseCase.ts
import { IProjectRepository } from '../../ports/repositories/IProjectRepository';
import { Project } from '../../domain/entities/Project';
import { CreateProjectInput } from './types';

export class CreateProjectUseCase {
  constructor(private readonly projectRepository: IProjectRepository) {}

  async execute(input: CreateProjectInput): Promise<Project> {
    // Business logic here
    const project = Project.create({
      name: input.name,
      description: input.description,
      organizationId: input.organizationId,
      createdBy: input.createdBy,
    });

    // Validate organization exists (example)
    // Additional business rules...

    await this.projectRepository.save(project);

    return project;
  }
}
```

### Repository Pattern (DynamoDB Adapter)

```typescript
// layers/business-logic/nodejs/node_modules/@teamflow/core/adapters/dynamodb/DynamoDBProjectRepository.ts
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, PutCommand, QueryCommand } from '@aws-sdk/lib-dynamodb';
import { IProjectRepository } from '../../ports/repositories/IProjectRepository';
import { Project } from '../../domain/entities/Project';

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export class DynamoDBProjectRepository implements IProjectRepository {
  private readonly tableName = process.env.TABLE_NAME!;

  async save(project: Project): Promise<void> {
    await docClient.send(new PutCommand({
      TableName: this.tableName,
      Item: {
        PK: `ORG#${project.organizationId}`,
        SK: `PROJECT#${project.id}`,
        GSI1PK: `PROJECT#${project.id}`,
        GSI1SK: `PROJECT#${project.id}`,
        Type: 'Project',
        ...project.toJSON(),
        createdAt: new Date().toISOString(),
      },
    }));
  }

  async findByOrganization(organizationId: string): Promise<Project[]> {
    const result = await docClient.send(new QueryCommand({
      TableName: this.tableName,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
      ExpressionAttributeValues: {
        ':pk': `ORG#${organizationId}`,
        ':sk': 'PROJECT#',
      },
    }));

    return (result.Items || []).map(item => Project.fromJSON(item));
  }

  // ... other methods
}
```

### Building Lambda Layers with Business Logic

#### Layer Structure

Lambda layers must follow a specific directory structure:

```
layers/business-logic/
└── nodejs/
    └── node_modules/
        └── @teamflow/
            └── core/
                ├── domain/
                ├── ports/
                ├── use-cases/
                ├── adapters/
                ├── utils/
                └── package.json
```

**Why `nodejs/node_modules`?**
- Lambda looks for layers in `/opt/nodejs/node_modules`
- The `nodejs` folder is automatically added to NODE_PATH
- This allows imports: `import { X } from '@teamflow/core/...'`

#### Building the Business Logic Layer

```bash
# layers/business-logic/build.sh

#!/bin/bash
set -e

echo "Building business logic layer..."

# Clean previous build
rm -rf nodejs/node_modules/@teamflow

# Create directory structure
mkdir -p nodejs/node_modules/@teamflow/core

# Compile TypeScript
cd ../../  # Go to root
npx tsc --project layers/business-logic/tsconfig.json

# Copy compiled files
cp -r layers/business-logic/dist/* layers/business-logic/nodejs/node_modules/@teamflow/core/

# Copy package.json
cp layers/business-logic/package.json layers/business-logic/nodejs/node_modules/@teamflow/core/

echo "Business logic layer built successfully!"
```

#### Layer package.json

```json
{
  "name": "@teamflow/core",
  "version": "1.0.0",
  "main": "index.js",
  "types": "index.d.ts",
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.400.0",
    "@aws-sdk/lib-dynamodb": "^3.400.0"
  }
}
```

#### Layer Size Management

**50MB Zipped Limit** (250MB unzipped)

**Monitor layer size:**
```bash
cd layers/business-logic
zip -r ../business-logic.zip nodejs/
ls -lh ../business-logic.zip  # Check size
```

**If layer exceeds limit:**
1. Split into multiple layers by domain (auth-layer, projects-layer, tasks-layer)
2. Move AWS SDK to dependencies layer (already external in Lambda runtime)
3. Use webpack/esbuild to tree-shake unused code
4. Remove source maps in production builds

---

## Frontend Architecture

### Angular Project Structure

```
teamflow-frontend/
├── apps/
│   └── teamflow-app/              # Main Angular application
│       ├── src/
│       │   ├── app/
│       │   │   ├── core/          # Singleton services, guards, interceptors
│       │   │   │   ├── auth/
│       │   │   │   │   ├── guards/
│       │   │   │   │   │   └── auth.guard.ts
│       │   │   │   │   ├── interceptors/
│       │   │   │   │   │   └── auth.interceptor.ts
│       │   │   │   │   └── services/
│       │   │   │   │       └── auth.service.ts
│       │   │   │   ├── http/
│       │   │   │   │   └── api.service.ts
│       │   │   │   └── services/
│       │   │   │       └── local-storage.service.ts
│       │   │   │
│       │   │   ├── shared/        # Shared components, directives, pipes
│       │   │   │   ├── components/
│       │   │   │   ├── directives/
│       │   │   │   ├── pipes/
│       │   │   │   └── models/
│       │   │   │
│       │   │   ├── features/      # Feature modules (lazy loaded)
│       │   │   │   ├── auth/
│       │   │   │   │   ├── login/
│       │   │   │   │   ├── register/
│       │   │   │   │   └── auth.routes.ts
│       │   │   │   │
│       │   │   │   ├── dashboard/
│       │   │   │   │   ├── components/
│       │   │   │   │   ├── dashboard.component.ts
│       │   │   │   │   └── dashboard.routes.ts
│       │   │   │   │
│       │   │   │   ├── organizations/
│       │   │   │   │   ├── components/
│       │   │   │   │   ├── services/
│       │   │   │   │   ├── store/
│       │   │   │   │   │   ├── organization.actions.ts
│       │   │   │   │   │   ├── organization.reducer.ts
│       │   │   │   │   │   ├── organization.effects.ts
│       │   │   │   │   │   └── organization.selectors.ts
│       │   │   │   │   └── organizations.routes.ts
│       │   │   │   │
│       │   │   │   ├── projects/
│       │   │   │   │   ├── components/
│       │   │   │   │   ├── project-list/
│       │   │   │   │   ├── project-detail/
│       │   │   │   │   ├── store/
│       │   │   │   │   └── projects.routes.ts
│       │   │   │   │
│       │   │   │   └── tasks/
│       │   │   │       ├── components/
│       │   │   │       ├── task-board/
│       │   │   │       ├── task-detail/
│       │   │   │       ├── store/
│       │   │   │       └── tasks.routes.ts
│       │   │   │
│       │   │   ├── store/         # Root NgRx store
│       │   │   │   ├── app.state.ts
│       │   │   │   ├── app.reducer.ts
│       │   │   │   └── app.effects.ts
│       │   │   │
│       │   │   ├── app.component.ts
│       │   │   ├── app.config.ts
│       │   │   └── app.routes.ts
│       │   │
│       │   ├── assets/
│       │   ├── environments/
│       │   │   ├── environment.ts
│       │   │   └── environment.prod.ts
│       │   └── index.html
│       │
│       ├── project.json
│       └── tsconfig.app.json
│
├── libs/                          # Shared libraries (future module federation)
│   ├── calendar-module/           # Future: Federated module
│   └── time-tracking-module/      # Future: Federated module
│
├── package.json
├── angular.json
└── tsconfig.json
```

### Reactive Programming Patterns

#### Declarative Component with Signals

```typescript
// features/projects/project-list/project-list.component.ts
import { Component, inject, computed, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { Store } from '@ngrx/store';
import { ProjectActions } from '../store/project.actions';
import { selectProjects, selectProjectsLoading } from '../store/project.selectors';

@Component({
  selector: 'app-project-list',
  standalone: true,
  template: `
    <div class="project-list">
      <h2>Projects</h2>

      @if (loading()) {
        <app-spinner />
      } @else {
        <div class="projects-grid">
          @for (project of filteredProjects(); track project.id) {
            <app-project-card [project]="project" />
          } @empty {
            <p>No projects found</p>
          }
        </div>
      }

      <button (click)="createProject()">Create Project</button>
    </div>
  `,
})
export class ProjectListComponent {
  private store = inject(Store);

  // Convert Observables to Signals
  projects = toSignal(this.store.select(selectProjects), { initialValue: [] });
  loading = toSignal(this.store.select(selectProjectsLoading), { initialValue: false });

  // Local signal for search
  searchTerm = signal('');

  // Computed signal (derived state)
  filteredProjects = computed(() => {
    const term = this.searchTerm().toLowerCase();
    return this.projects().filter(p =>
      p.name.toLowerCase().includes(term)
    );
  });

  ngOnInit() {
    this.store.dispatch(ProjectActions.loadProjects());
  }

  createProject() {
    this.store.dispatch(ProjectActions.openCreateDialog());
  }
}
```

#### NgRx Store with Effects

```typescript
// features/projects/store/project.effects.ts
import { inject } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { ProjectService } from '../services/project.service';
import { ProjectActions } from './project.actions';
import { catchError, map, switchMap } from 'rxjs/operators';
import { of } from 'rxjs';

export const loadProjects = createEffect(
  (actions$ = inject(Actions), projectService = inject(ProjectService)) => {
    return actions$.pipe(
      ofType(ProjectActions.loadProjects),
      switchMap(() =>
        projectService.getProjects().pipe(
          map(projects => ProjectActions.loadProjectsSuccess({ projects })),
          catchError(error => of(ProjectActions.loadProjectsFailure({ error: error.message })))
        )
      )
    );
  },
  { functional: true }
);
```

### Local Storage with Dexie

```typescript
// core/services/local-storage.service.ts
import Dexie, { Table } from 'dexie';

export interface CachedProject {
  id: string;
  data: any;
  timestamp: number;
  organizationId: string;
}

export class AppDatabase extends Dexie {
  projects!: Table<CachedProject, string>;
  tasks!: Table<any, string>;

  constructor() {
    super('TeamFlowDB');
    this.version(1).stores({
      projects: 'id, organizationId, timestamp',
      tasks: 'id, projectId, organizationId, timestamp',
    });
  }
}

export const db = new AppDatabase();

@Injectable({ providedIn: 'root' })
export class LocalStorageService {
  async cacheProjects(organizationId: string, projects: any[]) {
    const timestamp = Date.now();
    await db.projects.bulkPut(
      projects.map(p => ({
        id: p.id,
        data: p,
        timestamp,
        organizationId,
      }))
    );
  }

  async getProjectsFromCache(organizationId: string): Promise<any[]> {
    const cached = await db.projects
      .where('organizationId')
      .equals(organizationId)
      .toArray();

    return cached.map(c => c.data);
  }

  async clearStaleCache(maxAge = 24 * 60 * 60 * 1000) {
    const cutoff = Date.now() - maxAge;
    await db.projects.where('timestamp').below(cutoff).delete();
  }
}
```

### Module Federation (Future Consideration)

**Current Decision**: **Angular monolith with lazy-loaded modules for MVP**

**Rationale**:
- Simpler to build and deploy
- Single build pipeline
- Easier debugging
- Team learning curve already high with other technologies

**Module Structure (MVP)**:
```
apps/teamflow-app/
├── features/
│   ├── core/           # Main workspace features
│   ├── projects/       # Lazy-loaded
│   ├── tasks/          # Lazy-loaded
│   ├── calendar/       # Lazy-loaded (Module 1 - future)
│   └── time-tracking/  # Lazy-loaded (Module 2 - future)
```

**Future Migration Path to Module Federation**:
When you need independent deployment (multiple teams, separate release cycles):
1. Extract calendar module as separate Angular app
2. Configure Module Federation with @angular-architects/module-federation
3. Update routing to load remote module
4. Deploy calendar app separately
5. Repeat for time-tracking module

**Migration Trigger**: When you have 2+ developers working on different modules simultaneously

---

## Database Design

### DynamoDB Single-Table Design

#### Table Structure

**Table Name**: `teamflow-main`

**Keys**:
- **PK** (Partition Key): String
- **SK** (Sort Key): String

**GSI1** (Global Secondary Index):
- **GSI1PK**: String
- **GSI1SK**: String

**GSI2** (for user lookups):
- **GSI2PK**: String (email)
- **GSI2SK**: String

#### Access Patterns

| Pattern | Keys | Example |
|---------|------|---------|
| Get organization | PK=ORG#{orgId}, SK=METADATA | PK=ORG#123, SK=METADATA |
| List projects in org | PK=ORG#{orgId}, SK begins_with PROJECT# | PK=ORG#123, SK=PROJECT#456 |
| Get project | GSI1PK=PROJECT#{projectId}, GSI1SK=PROJECT#{projectId} | Query GSI1 |
| List tasks in project | PK=PROJECT#{projectId}, SK begins_with TASK# | PK=PROJECT#456, SK=TASK#789 |
| Get task | GSI1PK=TASK#{taskId}, GSI1SK=TASK#{taskId} | Query GSI1 |
| Get user by email | GSI2PK={email}, GSI2SK=USER | Query GSI2 |
| List org members | PK=ORG#{orgId}, SK begins_with MEMBER# | PK=ORG#123, SK=MEMBER#USER#456 |

#### Item Examples

**Organization**:
```json
{
  "PK": "ORG#org_abc123",
  "SK": "METADATA",
  "GSI1PK": "ORG#org_abc123",
  "GSI1SK": "ORG#org_abc123",
  "Type": "Organization",
  "id": "org_abc123",
  "name": "Acme Corp",
  "ownerId": "user_xyz789",
  "createdAt": "2026-01-22T10:00:00Z"
}
```

**Project**:
```json
{
  "PK": "ORG#org_abc123",
  "SK": "PROJECT#proj_def456",
  "GSI1PK": "PROJECT#proj_def456",
  "GSI1SK": "PROJECT#proj_def456",
  "Type": "Project",
  "id": "proj_def456",
  "organizationId": "org_abc123",
  "name": "Website Redesign",
  "description": "Q1 2026 redesign project",
  "createdBy": "user_xyz789",
  "createdAt": "2026-01-22T11:00:00Z"
}
```

**Task**:
```json
{
  "PK": "PROJECT#proj_def456",
  "SK": "TASK#task_ghi789",
  "GSI1PK": "TASK#task_ghi789",
  "GSI1SK": "TASK#task_ghi789",
  "Type": "Task",
  "id": "task_ghi789",
  "projectId": "proj_def456",
  "organizationId": "org_abc123",
  "title": "Design homepage mockup",
  "description": "Create high-fidelity mockup",
  "assigneeId": "user_xyz789",
  "status": "in_progress",
  "priority": "high",
  "deadline": "2026-02-01T00:00:00Z",
  "createdAt": "2026-01-22T12:00:00Z"
}
```

**User**:
```json
{
  "PK": "USER#user_xyz789",
  "SK": "METADATA",
  "GSI2PK": "john@example.com",
  "GSI2SK": "USER",
  "Type": "User",
  "id": "user_xyz789",
  "email": "john@example.com",
  "name": "John Doe",
  "cognitoSub": "cognito-sub-uuid",
  "createdAt": "2026-01-22T09:00:00Z"
}
```

**Organization Member**:
```json
{
  "PK": "ORG#org_abc123",
  "SK": "MEMBER#user_xyz789",
  "GSI1PK": "USER#user_xyz789",
  "GSI1SK": "ORG#org_abc123",
  "Type": "OrganizationMember",
  "organizationId": "org_abc123",
  "userId": "user_xyz789",
  "role": "owner",
  "joinedAt": "2026-01-22T09:30:00Z"
}
```

#### Multi-Tenancy Enforcement

**Critical**: Every Lambda must validate `organizationId` matches user's organization

```typescript
// Example validation middleware
export async function validateOrganizationAccess(
  userId: string,
  organizationId: string
): Promise<boolean> {
  const membership = await docClient.send(new GetCommand({
    TableName: process.env.TABLE_NAME,
    Key: {
      PK: `ORG#${organizationId}`,
      SK: `MEMBER#${userId}`,
    },
  }));

  return !!membership.Item;
}
```

### Learning DynamoDB Single-Table Design

#### Essential Resources

**Books**:
1. **"The DynamoDB Book" by Alex DeBrie** (Most recommended)
   - Comprehensive single-table design guide
   - Multi-tenant patterns
   - Access pattern modeling

2. **"DynamoDB, explained" by Alex DeBrie** (Free online)
   - https://www.dynamodbguide.com/

**AWS Documentation**:
- **Best Practices**: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html
- **Single-Table Design**: https://aws.amazon.com/blogs/compute/creating-a-single-table-design-with-amazon-dynamodb/

**Videos**:
- **Rick Houlihan's re:Invent talks** (Search: "Advanced Design Patterns DynamoDB")
- **AWS re:Invent 2019: Data modeling with Amazon DynamoDB** (DAT403)

**Tools**:
- **NoSQL Workbench for DynamoDB** (Visual design tool)
- **DynamoDB Local** (Run DynamoDB locally for testing)

#### Key Concepts to Master

1. **Primary Key Design**
   - Partition Key (PK): Determines which partition stores the item
   - Sort Key (SK): Enables range queries and one-to-many relationships
   - Composite keys enable multiple access patterns

2. **Access Pattern First Design**
   - List ALL queries your app needs BEFORE designing schema
   - Design PK/SK to support queries efficiently
   - Avoid scans (expensive and slow)

3. **Global Secondary Indexes (GSI)**
   - Allows alternative access patterns
   - Has its own PK/SK (GSI1PK/GSI1SK)
   - Eventually consistent
   - Costs same as base table

4. **Item Collections**
   - Items with same PK are stored together
   - Enables efficient queries for hierarchical data
   - Example: All projects in an organization

5. **Overloading Keys**
   - Store different entity types in same table
   - Use Type attribute to distinguish
   - Example: PK=ORG#123, SK can be PROJECT#, MEMBER#, etc.

#### Design Process

```
1. Identify Entities
   - User, Organization, Project, Task, Comment

2. List Access Patterns
   - Get user by email
   - List all projects in organization
   - Get project by ID
   - List tasks in project
   - Get task by ID
   - List members of organization

3. Design Primary Keys
   - Base table: PK + SK for main access patterns
   - GSI1: Alternative access pattern (get by ID)
   - GSI2: Another access pattern (get user by email)

4. Create Item Examples
   - Write actual JSON for each entity
   - Verify keys support all access patterns

5. Test Queries
   - Write actual DynamoDB queries
   - Use NoSQL Workbench to visualize
   - Validate performance characteristics
```

#### Common Patterns in TeamFlow

**Pattern 1: Hierarchical Data (Organization → Projects)**
```typescript
// Store: PK=ORG#123, SK=PROJECT#456
// Query: All projects in org
const result = await dynamodb.query({
  KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
  ExpressionAttributeValues: {
    ':pk': 'ORG#123',
    ':sk': 'PROJECT#',
  },
});
```

**Pattern 2: Get Item by ID (using GSI)**
```typescript
// Store: GSI1PK=PROJECT#456, GSI1SK=PROJECT#456
// Query: Get project by ID (don't know orgId)
const result = await dynamodb.query({
  IndexName: 'GSI1',
  KeyConditionExpression: 'GSI1PK = :pk',
  ExpressionAttributeValues: {
    ':pk': 'PROJECT#456',
  },
});
```

**Pattern 3: Many-to-Many (User ↔ Organizations)**
```typescript
// Store membership: PK=ORG#123, SK=MEMBER#USER#456
// Store reverse: GSI1PK=USER#456, GSI1SK=ORG#123

// Query: Get orgs for user
const userOrgs = await dynamodb.query({
  IndexName: 'GSI1',
  KeyConditionExpression: 'GSI1PK = :pk AND begins_with(GSI1SK, :sk)',
  ExpressionAttributeValues: {
    ':pk': 'USER#456',
    ':sk': 'ORG#',
  },
});

// Query: Get members of org
const orgMembers = await dynamodb.query({
  KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
  ExpressionAttributeValues: {
    ':pk': 'ORG#123',
    ':sk': 'MEMBER#',
  },
});
```

#### Testing Strategy

1. **Use DynamoDB Local**
   ```bash
   docker run -p 8000:8000 amazon/dynamodb-local
   ```

2. **Create test data with multiple tenants**
   ```typescript
   // Always test with org1 and org2 to verify isolation
   await createTestOrganization('org1');
   await createTestOrganization('org2');
   ```

3. **Verify queries return correct data**
   ```typescript
   // Test: User in org1 should NOT see org2's projects
   const projects = await projectRepo.findByOrganization('org1');
   expect(projects).not.toContainItemFromOrg('org2');
   ```

#### Migration Strategy

If single-table design becomes problematic:
1. **Vertical split**: Move high-volume tables to separate DynamoDB tables
2. **Add RDS**: Use PostgreSQL for complex relational queries
3. **Hybrid approach**: DynamoDB for hot data, RDS for reports/analytics

---

## Authentication & Authorization

### AWS Cognito Setup

**User Pool Configuration**:
- **Sign-in**: Email
- **Required attributes**: email, name
- **Custom attributes**:
  - `custom:currentOrgId` (user's active organization)
- **Password policy**: 8+ chars, uppercase, lowercase, number
- **MFA**: Optional (Post-MVP: required for production)

**App Client**:
- **Auth flows**: USER_PASSWORD_AUTH, REFRESH_TOKEN_AUTH
- **Token expiration**:
  - ID Token: 1 hour
  - Access Token: 1 hour
  - Refresh Token: 30 days

### Authentication Flow

```
┌─────────┐                ┌─────────┐                ┌─────────┐
│ Angular │                │  Cognito│                │ Lambda  │
│   App   │                │         │                │         │
└────┬────┘                └────┬────┘                └────┬────┘
     │                          │                          │
     │  1. Login (email/pass)   │                          │
     ├─────────────────────────>│                          │
     │                          │                          │
     │  2. ID + Access Tokens   │                          │
     │<─────────────────────────┤                          │
     │                          │                          │
     │  3. API Request + Token  │                          │
     ├──────────────────────────┼─────────────────────────>│
     │                          │                          │
     │                          │  4. Validate Token       │
     │                          │<─────────────────────────┤
     │                          │                          │
     │                          │  5. User Claims          │
     │                          ├─────────────────────────>│
     │                          │                          │
     │  6. Response             │                          │
     │<─────────────────────────┼──────────────────────────┤
     │                          │                          │
```

### API Gateway Authorizer

**Type**: Cognito User Pool Authorizer

```typescript
// infrastructure/lib/stacks/ApiStack.ts (CDK)
const authorizer = new apigateway.CognitoUserPoolsAuthorizer(this, 'Authorizer', {
  cognitoUserPools: [userPool],
  identitySource: 'method.request.header.Authorization',
});

// Protect endpoints
projectsResource.addMethod('GET', projectsLambdaIntegration, {
  authorizer,
  authorizationType: apigateway.AuthorizationType.COGNITO,
});
```

### Frontend Auth Service

```typescript
// core/auth/services/auth.service.ts
import { Injectable, signal } from '@angular/core';
import { CognitoUserPool, CognitoUser, AuthenticationDetails } from 'amazon-cognito-identity-js';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private userPool: CognitoUserPool;
  private currentUser = signal<any>(null);
  private idToken = signal<string | null>(null);

  constructor() {
    this.userPool = new CognitoUserPool({
      UserPoolId: environment.cognito.userPoolId,
      ClientId: environment.cognito.clientId,
    });
  }

  login(email: string, password: string): Promise<any> {
    return new Promise((resolve, reject) => {
      const authDetails = new AuthenticationDetails({
        Username: email,
        Password: password,
      });

      const cognitoUser = new CognitoUser({
        Username: email,
        Pool: this.userPool,
      });

      cognitoUser.authenticateUser(authDetails, {
        onSuccess: (result) => {
          this.idToken.set(result.getIdToken().getJwtToken());
          this.currentUser.set(result.getIdToken().payload);
          resolve(result);
        },
        onFailure: (err) => {
          reject(err);
        },
      });
    });
  }

  getIdToken(): string | null {
    return this.idToken();
  }

  isAuthenticated(): boolean {
    return !!this.idToken();
  }

  logout() {
    const cognitoUser = this.userPool.getCurrentUser();
    if (cognitoUser) {
      cognitoUser.signOut();
    }
    this.idToken.set(null);
    this.currentUser.set(null);
  }
}
```

### Auth Interceptor

```typescript
// core/auth/interceptors/auth.interceptor.ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getIdToken();

  if (token) {
    req = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`,
      },
    });
  }

  return next(req);
};
```

---

## Infrastructure as Code

### CDKTF (Terraform CDK with TypeScript)

**Decision**: Use CDKTF (Terraform CDK with TypeScript)

**Rationale**:
- TypeScript-native (matches stack)
- Terraform state management (proven, mature)
- Multi-cloud future possibility
- Type-safe infrastructure
- Terraform ecosystem and providers
- Learning Terraform through familiar TypeScript syntax

**Trade-off**: CDKTF is less mature than plain Terraform or AWS CDK, but offers the best of both worlds for a TypeScript-first team.

### CDKTF Stack Example

```typescript
// infrastructure/stacks/api-stack.ts
import { Construct } from 'constructs';
import { TerraformStack, TerraformOutput } from 'cdktf';
import { AwsProvider } from '@cdktf/provider-aws/lib/provider';
import { DynamodbTable } from '@cdktf/provider-aws/lib/dynamodb-table';
import { LambdaFunction } from '@cdktf/provider-aws/lib/lambda-function';
import { LambdaLayerVersion } from '@cdktf/provider-aws/lib/lambda-layer-version';
import { IamRole } from '@cdktf/provider-aws/lib/iam-role';
import { IamRolePolicyAttachment } from '@cdktf/provider-aws/lib/iam-role-policy-attachment';
import { ApiGatewayRestApi } from '@cdktf/provider-aws/lib/api-gateway-rest-api';
import { ApiGatewayResource } from '@cdktf/provider-aws/lib/api-gateway-resource';
import { ApiGatewayMethod } from '@cdktf/provider-aws/lib/api-gateway-method';
import { ApiGatewayIntegration } from '@cdktf/provider-aws/lib/api-gateway-integration';
import { ApiGatewayDeployment } from '@cdktf/provider-aws/lib/api-gateway-deployment';
import { DataArchiveFile } from '@cdktf/provider-archive/lib/data-archive-file';
import { ArchiveProvider } from '@cdktf/provider-archive/lib/provider';

export class ApiStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    // AWS Provider
    new AwsProvider(this, 'aws', {
      region: 'us-east-1',
    });

    // Archive Provider (for Lambda zip files)
    new ArchiveProvider(this, 'archive');

    // DynamoDB Table
    const table = new DynamodbTable(this, 'teamflow_table', {
      name: 'teamflow-main',
      billingMode: 'PAY_PER_REQUEST', // Free tier: 25 RCU/WCU
      hashKey: 'PK',
      rangeKey: 'SK',

      attribute: [
        { name: 'PK', type: 'S' },
        { name: 'SK', type: 'S' },
        { name: 'GSI1PK', type: 'S' },
        { name: 'GSI1SK', type: 'S' },
        { name: 'GSI2PK', type: 'S' },
        { name: 'GSI2SK', type: 'S' },
      ],

      globalSecondaryIndex: [
        {
          name: 'GSI1',
          hashKey: 'GSI1PK',
          rangeKey: 'GSI1SK',
          projectionType: 'ALL',
        },
        {
          name: 'GSI2',
          hashKey: 'GSI2PK',
          rangeKey: 'GSI2SK',
          projectionType: 'ALL',
        },
      ],

      tags: {
        Environment: 'dev',
        Project: 'TeamFlow',
      },
    });

    // IAM Role for Lambda
    const lambdaRole = new IamRole(this, 'lambda_role', {
      name: 'teamflow-lambda-role',
      assumeRolePolicy: JSON.stringify({
        Version: '2012-10-17',
        Statement: [
          {
            Action: 'sts:AssumeRole',
            Effect: 'Allow',
            Principal: {
              Service: 'lambda.amazonaws.com',
            },
          },
        ],
      }),
    });

    // Attach basic Lambda execution policy
    new IamRolePolicyAttachment(this, 'lambda_basic_execution', {
      role: lambdaRole.name,
      policyArn: 'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole',
    });

    // Attach DynamoDB access policy
    new IamRolePolicyAttachment(this, 'lambda_dynamodb_access', {
      role: lambdaRole.name,
      policyArn: 'arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess',
    });

    // Lambda Layer - Business Logic
    const businessLogicArchive = new DataArchiveFile(this, 'business_logic_archive', {
      type: 'zip',
      sourceDir: './layers/business-logic',
      outputPath: './dist/layers/business-logic.zip',
    });

    const businessLogicLayer = new LambdaLayerVersion(this, 'business_logic_layer', {
      layerName: 'teamflow-business-logic',
      filename: businessLogicArchive.outputPath,
      compatibleRuntimes: ['nodejs20.x'],
      description: 'Shared business logic with hexagonal architecture',
    });

    // Lambda Layer - Dependencies
    const dependenciesArchive = new DataArchiveFile(this, 'dependencies_archive', {
      type: 'zip',
      sourceDir: './layers/dependencies',
      outputPath: './dist/layers/dependencies.zip',
    });

    const dependenciesLayer = new LambdaLayerVersion(this, 'dependencies_layer', {
      layerName: 'teamflow-dependencies',
      filename: dependenciesArchive.outputPath,
      compatibleRuntimes: ['nodejs20.x'],
      description: 'Shared npm dependencies',
    });

    // Create Project Lambda Function
    const createProjectArchive = new DataArchiveFile(this, 'create_project_archive', {
      type: 'zip',
      sourceDir: './dist/functions/projects',
      outputPath: './dist/functions/create-project.zip',
    });

    const createProjectLambda = new LambdaFunction(this, 'create_project_lambda', {
      functionName: 'teamflow-create-project',
      filename: createProjectArchive.outputPath,
      handler: 'create.handler',
      runtime: 'nodejs20.x',
      role: lambdaRole.arn,
      architectures: ['arm64'], // Graviton2 - cheaper & faster
      memorySize: 512,
      timeout: 30,
      layers: [businessLogicLayer.arn, dependenciesLayer.arn],

      environment: {
        variables: {
          TABLE_NAME: table.name,
          NODE_ENV: 'production',
        },
      },

      tags: {
        Environment: 'dev',
        Project: 'TeamFlow',
      },
    });

    // API Gateway
    const api = new ApiGatewayRestApi(this, 'api', {
      name: 'teamflow-api',
      description: 'TeamFlow serverless API',
    });

    // Projects resource
    const projectsResource = new ApiGatewayResource(this, 'projects_resource', {
      restApiId: api.id,
      parentId: api.rootResourceId,
      pathPart: 'projects',
    });

    // POST /projects method
    const createProjectMethod = new ApiGatewayMethod(this, 'create_project_method', {
      restApiId: api.id,
      resourceId: projectsResource.id,
      httpMethod: 'POST',
      authorization: 'NONE', // Will add Cognito authorizer later
    });

    // Lambda integration
    new ApiGatewayIntegration(this, 'create_project_integration', {
      restApiId: api.id,
      resourceId: projectsResource.id,
      httpMethod: createProjectMethod.httpMethod,
      integrationHttpMethod: 'POST',
      type: 'AWS_PROXY',
      uri: createProjectLambda.invokeArn,
    });

    // Deploy API
    const deployment = new ApiGatewayDeployment(this, 'api_deployment', {
      restApiId: api.id,
      stageName: 'prod',
      dependsOn: [createProjectMethod],
    });

    // Outputs
    new TerraformOutput(this, 'api_url', {
      value: `https://${api.id}.execute-api.us-east-1.amazonaws.com/${deployment.stageName}`,
      description: 'API Gateway URL',
    });

    new TerraformOutput(this, 'table_name', {
      value: table.name,
      description: 'DynamoDB table name',
    });
  }
}
```

### Multi-Environment Setup

```typescript
// infrastructure/main.ts
import { App } from 'cdktf';
import { ApiStack } from './stacks/api-stack';
import { FrontendStack } from './stacks/frontend-stack';

const app = new App();

// Dev environment
new ApiStack(app, 'teamflow-api-dev');

// Production environment (future)
// new ApiStack(app, 'teamflow-api-prod');

// Frontend stack
// new FrontendStack(app, 'teamflow-frontend-dev');

app.synth();
```

### CDKTF Project Structure

```
infrastructure/
├── stacks/
│   ├── api-stack.ts           # API Gateway + Lambda + DynamoDB
│   ├── auth-stack.ts          # Cognito User Pool
│   ├── frontend-stack.ts      # S3 + CloudFront
│   └── storage-stack.ts       # S3 for file uploads
├── constructs/                # Reusable constructs (optional)
│   ├── lambda-with-layer.ts
│   └── api-endpoint.ts
├── main.ts                    # CDKTF app entry point
├── cdktf.json                 # CDKTF configuration
└── package.json
```

---

## CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy-backend.yml
name: Deploy Backend

on:
  push:
    branches:
      - main
      - develop
    paths:
      - 'backend/**'
      - 'infrastructure/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci
        working-directory: ./backend

      - name: Run tests
        run: npm test
        working-directory: ./backend

      - name: Run linter
        run: npm run lint
        working-directory: ./backend

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci
        working-directory: ./backend

      - name: Build TypeScript
        run: npm run build
        working-directory: ./backend

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: backend-dist
          path: backend/dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: backend-dist
          path: backend/dist/

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Install CDK
        run: npm install -g aws-cdk

      - name: CDK Deploy
        run: cdk deploy TeamFlowApiDev --require-approval never
        working-directory: ./infrastructure
```

```yaml
# .github/workflows/deploy-frontend.yml
name: Deploy Frontend

on:
  push:
    branches:
      - main
    paths:
      - 'frontend/**'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci
        working-directory: ./frontend

      - name: Build Angular app
        run: npm run build:prod
        working-directory: ./frontend
        env:
          API_URL: ${{ secrets.API_URL }}
          COGNITO_USER_POOL_ID: ${{ secrets.COGNITO_USER_POOL_ID }}
          COGNITO_CLIENT_ID: ${{ secrets.COGNITO_CLIENT_ID }}

      - name: Deploy to S3
        run: |
          aws s3 sync dist/teamflow-app s3://${{ secrets.S3_BUCKET }} --delete
        working-directory: ./frontend

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"
```

---

## Cost Optimization

### Free Tier Maximization

| Service | Free Tier | Strategy |
|---------|-----------|----------|
| **Lambda** | 1M requests, 400K GB-seconds | Use arm64, keep memory low (512MB) |
| **API Gateway** | 1M calls (12 months) | After expiry, consider Lambda Function URLs |
| **DynamoDB** | 25GB, 25 RCU/WCU | Use on-demand pricing, add indexes sparingly |
| **S3** | 5GB, 20K GET, 2K PUT | Lifecycle policies, compress images |
| **CloudFront** | 1TB transfer | Enable compression, cache aggressively |
| **Cognito** | 50K MAU | Sufficient for MVP, grows with usage |
| **CloudWatch** | 10 metrics, 5GB logs | Reduce log retention to 7 days for dev |

### Cost Alarms

```typescript
// infrastructure/lib/constructs/BillingAlarm.ts
import * as cloudwatch from 'aws-cdk-lib/aws-cloudwatch';
import * as sns from 'aws-cdk-lib/aws-sns';
import * as subscriptions from 'aws-cdk-lib/aws-sns-subscriptions';

export class BillingAlarm extends Construct {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    const topic = new sns.Topic(this, 'BillingAlertTopic');
    topic.addSubscription(
      new subscriptions.EmailSubscription('your-email@example.com')
    );

    new cloudwatch.Alarm(this, 'BillingAlarm', {
      metric: new cloudwatch.Metric({
        namespace: 'AWS/Billing',
        metricName: 'EstimatedCharges',
        dimensionsMap: {
          Currency: 'USD',
        },
        statistic: 'Maximum',
        period: cdk.Duration.hours(6),
      }),
      threshold: 10, // Alert if bill exceeds $10
      evaluationPeriods: 1,
      comparisonOperator: cloudwatch.ComparisonOperator.GREATER_THAN_THRESHOLD,
    }).addAlarmAction(new cloudwatchActions.SnsAction(topic));
  }
}
```

---

## Trade-offs & Risks

### Architectural Trade-offs

| Decision | Pros | Cons | Mitigation |
|----------|------|------|------------|
| **Serverless (Lambda)** | Cost-efficient, auto-scaling, no server management | Cold starts, vendor lock-in, debugging harder | Accept cold starts for learning phase, use arm64, structured logging |
| **DynamoDB Single-Table** | Serverless, fast, free tier generous, learn advanced NoSQL | Complex queries, no joins, steep learning curve | Document ALL access patterns upfront, study single-table design patterns first |
| **API Gateway + Lambda per endpoint** | Clear separation, easy to understand, easy to secure | More cold starts, more IaC code | Accept for learning clarity, optimize later if needed |
| **Hexagonal architecture (all logic)** | Clean separation, highly testable, learn best practices | More boilerplate, slower initial development | Accept learning curve, builds good habits for future |
| **Business logic in Lambda layers** | Shared code across functions, learn layers | 50MB size limit, deployment complexity | Monitor layer size, split into multiple layers if needed |
| **CDKTF** | Type-safe Terraform, multi-cloud future | Less mature than CDK or plain Terraform | Use stable providers, consult Terraform docs when needed |
| **Angular monolith + NgRx** | Scalable, predictable state, learn reactive patterns | More code than simpler state management | Accept for learning reactive programming, ComponentStore for local state |

### Key Risks & Success Strategies

#### 1. **Lambda Cold Starts (Accepted Trade-off)**
- **Reality**: 1-3 second delays on first request
- **Success Strategy**:
  - Use arm64 architecture (19% faster cold starts)
  - Keep function code size small (<5MB per function)
  - Frontend: Show loading states, implement optimistic UI updates
  - Educate users this is a demo/early version
  - Document cold start behavior for future optimization

#### 2. **DynamoDB Single-Table Design Complexity**
- **Challenge**: Requires upfront planning, hard to change later
- **Success Strategy**:
  - **Study first**: Read "The DynamoDB Book" by Alex DeBrie
  - **Document all access patterns** before writing code (included in this doc)
  - **Start with examples**: Use the item examples in this document
  - **Test with real data**: Validate queries work before building features
  - **Join communities**: AWS re:Post, DynamoDB subreddit for help
  - **Iterate carefully**: Test changes in dev environment thoroughly

#### 3. **Lambda Layer 50MB Limit**
- **Challenge**: Business logic must fit in 50MB (unzipped: 250MB)
- **Success Strategy**:
  - Separate business logic layer from dependencies layer
  - Monitor layer sizes: `aws lambda get-layer-version`
  - Use tree-shaking: Only import what you need
  - Split into multiple layers if needed (max 5 layers per function)
  - Keep dependencies in separate layer to avoid rebuilding

#### 4. **Multi-Tenant Security (Critical)**
- **Risk**: organization_id filter missed = data leak between tenants
- **Success Strategy**:
  - **Centralized validation**: Create middleware that ALWAYS validates organizationId
  - **Code template**: Start every use case with organizationId validation
  - **Integration tests**: Test with multiple tenants (org1, org2) - verify isolation
  - **Code review checklist**: Every PR must verify organizationId checks
  - **Audit logging**: Log all authorization failures for security monitoring

#### 5. **Hexagonal Architecture Learning Curve**
- **Challenge**: More code, more abstractions to learn
- **Success Strategy**:
  - **Start with one feature**: Implement projects fully before moving to tasks
  - **Follow templates**: Use the examples in this document as templates
  - **Pair programming**: Explain ports/adapters to solidify understanding
  - **Refactor as you go**: If a pattern doesn't make sense, discuss and adjust
  - **Celebrate progress**: Acknowledge the learning - this builds strong foundations

#### 6. **CDKTF Maturity**
- **Challenge**: Less mature than AWS CDK or plain Terraform
- **Success Strategy**:
  - **Consult Terraform docs**: CDKTF generates Terraform, so Terraform docs apply
  - **Check provider versions**: Use stable AWS provider versions
  - **Terraform state management**: Use remote state (S3 + DynamoDB) from the start
  - **Community resources**: cdktf.dev documentation, GitHub discussions
  - **Fallback option**: Can always migrate to plain Terraform later (generated code)

#### 7. **Free Tier Limits**
- **Risk**: Unexpected costs during development
- **Success Strategy**:
  - **Billing alarms**: Set at $5, $10, $20 thresholds
  - **Daily monitoring**: Check AWS Cost Explorer every few days
  - **Cleanup scripts**: Automate deletion of test data
  - **Use LocalStack**: Test locally with LocalStack (Docker) before deploying
  - **Tag resources**: Tag everything with "Environment:dev" for cost tracking

---

## Migration Path

### Phase 1: MVP (Current)
- Serverless Lambda + API Gateway
- DynamoDB single-table
- Angular monolith (lazy-loaded modules)
- AWS Cognito auth
- Free tier optimized

### Phase 2: Scale (100-1000 users)
- Add provisioned concurrency for critical Lambdas
- DynamoDB auto-scaling or reserved capacity
- CloudFront optimization
- Monitoring and alerting improvements
- Add staging environment

### Phase 3: Growth (1000+ users)
**Potential Changes** (only if needed):
- Migrate to ECS Fargate (eliminate cold starts)
- Add RDS PostgreSQL for relational queries
- Redis for caching and rate limiting
- Separate API Gateway per domain (organizations, projects, tasks)
- Module federation for calendar/time-tracking modules

### Phase 4: Enterprise (10k+ users)
**Potential Changes** (only if needed):
- Microservices for independent teams
- Event-driven architecture (EventBridge, SQS)
- Multi-region deployment
- DDoS protection (AWS Shield)
- Compliance certifications (SOC2, ISO)

---

## Implementation Roadmap

### Phase 0: Learning & Setup (Week 1-2)

**Learn DynamoDB** (Priority 1):
1. Read first 5 chapters of "The DynamoDB Book"
2. Practice with NoSQL Workbench
3. Build a simple todo app with single-table design
4. Document 10 access patterns for TeamFlow

**Setup Development Environment**:
1. Install AWS CLI and configure credentials
2. Install CDKTF CLI: `npm install -g cdktf-cli`
3. Setup project structure (backend, infrastructure, frontend folders)
4. Initialize CDKTF project: `cdktf init --template=typescript`
5. Install LocalStack for local AWS testing (optional but recommended)

**Hexagonal Architecture Practice**:
1. Review hexagonal architecture examples
2. Build a simple CRUD feature with ports & adapters
3. Write tests for use cases (without database)
4. Understand dependency injection patterns

### Phase 1: Infrastructure Foundation (Week 3)

**CDKTF Setup**:
1. Create DynamoDB table with GSIs (use examples from this doc)
2. Create Lambda execution role with DynamoDB permissions
3. Deploy and test: `cdktf deploy teamflow-api-dev`
4. Verify table created in AWS Console

**Lambda Layer Setup**:
1. Create business-logic layer structure
2. Setup TypeScript compilation for layers
3. Build and deploy layer
4. Create a test Lambda that imports from layer

**Verification**:
- Can create items in DynamoDB
- Can query items by access patterns
- Lambda can import from layer successfully

### Phase 2: Authentication (Week 4)

**Cognito Setup** (using CDKTF):
1. Create User Pool
2. Create User Pool Client
3. Configure password policies
4. Add custom attributes (custom:currentOrgId)

**Auth Lambdas**:
1. Register endpoint (creates user + organization)
2. Login endpoint (returns JWT tokens)
3. Refresh token endpoint
4. Middleware for JWT validation

**Frontend Auth**:
1. Create AuthService with Cognito SDK
2. Login/Register components
3. Auth interceptor for API calls
4. Auth guard for protected routes

**Testing**:
- User can register
- User can login
- Token included in API calls
- Invalid tokens rejected

### Phase 3: Core Domain - Organizations & Projects (Week 5-6)

**Backend - Hexagonal Architecture**:

**Domain Layer** (in Lambda layer):
```
domain/
├── entities/
│   ├── Organization.ts
│   └── Project.ts
└── value-objects/
    └── ProjectStatus.ts
```

**Ports** (interfaces):
```
ports/
├── repositories/
│   ├── IOrganizationRepository.ts
│   └── IProjectRepository.ts
└── services/
    └── IAuthService.ts
```

**Use Cases**:
```
use-cases/
├── organizations/
│   ├── CreateOrganizationUseCase.ts
│   └── GetOrganizationUseCase.ts
└── projects/
    ├── CreateProjectUseCase.ts
    ├── ListProjectsUseCase.ts
    └── GetProjectUseCase.ts
```

**Adapters** (implementations):
```
adapters/
├── dynamodb/
│   ├── DynamoDBOrganizationRepository.ts
│   └── DynamoDBProjectRepository.ts
└── cognito/
    └── CognitoAuthService.ts
```

**Lambda Functions** (thin wrappers):
```
functions/
├── organizations/
│   ├── create.ts
│   └── get.ts
└── projects/
    ├── create.ts
    ├── list.ts
    └── get.ts
```

**CDKTF** (Infrastructure):
- Add API Gateway with /organizations and /projects resources
- Create Lambda functions for each endpoint
- Attach Cognito authorizer
- Deploy and test

**Frontend**:
- Organization store (NgRx)
- Project store (NgRx)
- Project list component
- Create project modal
- Routing and navigation

**Testing**:
- Create organization
- Create project in organization
- List projects (filtered by org)
- Multi-tenant isolation verified

### Phase 4: Tasks & Comments (Week 7-8)

Repeat Phase 3 pattern for:
- Task entity with CRUD operations
- Comment entity
- Task board UI (Kanban view)
- Drag-and-drop functionality

### Phase 5: Polish & Demo (Week 9-10)

**Frontend**:
- UI polish (styling, transitions)
- Loading states
- Error handling
- Offline support with Dexie

**Backend**:
- Logging and monitoring
- Error tracking
- Performance optimization

**Demo Preparation**:
- Sample data scripts
- Demo walkthrough
- Architecture presentation

---

## Open Questions / Next Steps

### Immediate Decisions Needed

- [ ] **TypeScript Version**: 5.3+ (latest stable)
- [ ] **Angular Version**: 18.x (with signals support)
- [ ] **Node.js Version**: 20.x LTS (Lambda runtime)
- [ ] **UI Component Library**: Material/PrimeNG/Custom?
- [ ] **Testing Framework**: Jest or Vitest?
- [ ] **E2E Testing**: Playwright or Cypress?

### Authentication Deep Dive (Next Session)

- Cognito vs. Auth0 vs. Custom
- Social login (Google/GitHub)?
- MFA requirements
- User invitation flow
- Organization switching UX

### Infrastructure Decisions

- AWS Region selection (us-east-1 for free tier maximization)
- Custom domain purchase
- SSL certificate strategy (ACM)
- Environment strategy (dev, staging, prod)

---

## Appendix

### Useful CDKTF Commands

```bash
# Install CDKTF globally
npm install -g cdktf-cli

# Initialize CDKTF in project
cdktf init --template=typescript --local

# Install AWS provider
npm install @cdktf/provider-aws @cdktf/provider-archive

# Synthesize Terraform configuration
cdktf synth

# Plan changes (like terraform plan)
cdktf plan

# Deploy stack
cdktf deploy teamflow-api-dev

# Destroy stack (careful!)
cdktf destroy teamflow-api-dev

# View outputs
cdktf output

# List stacks
cdktf list
```

### CDKTF Configuration (cdktf.json)

```json
{
  "language": "typescript",
  "app": "npx ts-node main.ts",
  "projectId": "teamflow-infrastructure",
  "sendCrashReports": "false",
  "terraformProviders": [
    "aws@~> 5.0",
    "archive@~> 2.0"
  ],
  "terraformModules": [],
  "context": {
    "excludeStackIdFromLogicalIds": "true"
  }
}
```

### Useful AWS CLI Commands

```bash
# Test Lambda function locally
aws lambda invoke --function-name createProject output.json

# View CloudWatch logs
aws logs tail /aws/lambda/createProject --follow

# DynamoDB scan (debugging only)
aws dynamodb scan --table-name teamflow-main --limit 10

# Get Cognito user
aws cognito-idp admin-get-user --user-pool-id us-east-1_xxx --username user@example.com
```

### TypeScript Configuration

```json
// tsconfig.json (backend)
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./packages",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "paths": {
      "@teamflow/shared/*": ["./packages/shared/*"]
    }
  },
  "include": ["packages/**/*"],
  "exclude": ["node_modules", "dist", "cdk.out"]
}
```

---

## Summary

This architecture is optimized for **learning and mastering modern cloud-native patterns** while building a functional multi-tenant SaaS application. The key technologies and patterns chosen reflect a deliberate focus on gaining deep expertise:

### Technologies Chosen
- **CDKTF**: Type-safe infrastructure with Terraform ecosystem
- **DynamoDB Single-Table**: Master advanced NoSQL design patterns
- **Lambda + Layers**: Serverless with shared business logic
- **Hexagonal Architecture**: Clean, testable, maintainable code structure
- **Angular + NgRx**: Reactive state management with signals
- **TypeScript**: End-to-end type safety

### Success Factors
1. **Study DynamoDB first** - Read "The DynamoDB Book" before coding
2. **Document access patterns** - All queries planned upfront
3. **Start small** - One feature fully implemented before moving on
4. **Test multi-tenancy** - Always test with multiple organizations
5. **Monitor costs** - Billing alarms and daily cost checks
6. **Embrace learning curve** - This architecture teaches best practices for future projects

### When to Reassess
- Lambda cold starts become unacceptable → Consider ECS Fargate
- DynamoDB queries become too complex → Consider adding RDS PostgreSQL
- Team velocity too slow → Simplify hexagonal architecture
- Costs exceed budget → Optimize or consider alternatives

This architecture will teach you patterns used by companies like Netflix, Amazon, and other cloud-native leaders. The complexity is intentional for learning, but all decisions are reversible if needed.

---

**Document Status**: ✅ Approved - Ready for Implementation
**Next Steps**:
1. Begin Phase 0: Learning & Setup
2. Create authentication design document
3. Setup GitHub repository structure

**Owner**: Software Architect
**Last Updated**: 2026-01-22
