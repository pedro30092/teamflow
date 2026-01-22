# TeamFlow - Serverless Development Roadmap

**Last Updated**: 2026-01-22
**Architecture**: Lambda + DynamoDB + CDKTF + Hexagonal Architecture + Angular + NgRx
**Aligned With**: MVP_OVERVIEW.md, MVP_DETAILED_PLAN.md, TECHNICAL_ARCHITECTURE_SERVERLESS.md

---

## Overview

This roadmap defines the **feature delivery phases** for TeamFlow's serverless MVP. It serves as the **source of truth** for the tech stack, versions, and development timeline.

**Philosophy**: Master DynamoDB, Lambda, hexagonal architecture, and CDKTF while building production-grade software.

**Development Approach**:
- Build features in phases (infrastructure → backend → frontend)
- Learn while building (reference documentation as needed)
- Test with multiple tenants from day one

**Setup**: Before starting Phase 1, complete the [SETUP_GUIDE.md](../SETUP_GUIDE.md)

---

## Development Phases

**Philosophy**: Learn while building. Master DynamoDB, hexagonal architecture, and CDKTF through practical implementation.

### Phase 1: Infrastructure + Authentication (2-3 weeks)
**Goal**: CDKTF infrastructure + Cognito auth + Hexagonal architecture foundation
**Learn**: CDKTF basics, Cognito setup, hexagonal architecture patterns, DynamoDB setup

### Phase 2: Organizations (2 weeks)
**Goal**: Multi-tenant foundation with organization management
**Learn**: DynamoDB single-table design, multi-tenant patterns, GSI usage

### Phase 3: Projects (2 weeks)
**Goal**: Project CRUD with DynamoDB access patterns
**Learn**: Complex DynamoDB queries, Lambda layers, repository pattern refinement

### Phase 4: Tasks - Core (2 weeks)
**Goal**: Task management system
**Learn**: Advanced DynamoDB access patterns, hierarchical data modeling

### Phase 5: Tasks - Workflow (2 weeks)
**Goal**: Status, assignments, priorities, Kanban board
**Learn**: Frontend state management with NgRx, drag-and-drop patterns

### Phase 6: Collaboration (2 weeks)
**Goal**: Comments and task discussions
**Learn**: Real-time data patterns, comment threading

### Phase 7: Polish & Deployment (2 weeks)
**Goal**: Production-ready MVP on AWS
**Learn**: CloudWatch monitoring, CI/CD with GitHub Actions, production deployment

**Total Duration**: 14-15 weeks (~3.5 months)

---

## Tech Stack & Versions (Source of Truth)

This section defines the exact technologies and versions used in TeamFlow. Update this when upgrading dependencies.

### Backend Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| **Node.js** | 20.x LTS | Lambda runtime |
| **TypeScript** | 5.x | Type-safe development |
| **AWS SDK v3** | Latest | AWS service clients |
| `@aws-sdk/client-dynamodb` | Latest | DynamoDB operations |
| `@aws-sdk/lib-dynamodb` | Latest | DynamoDB Document Client |

### Infrastructure Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| **CDKTF** | Latest | Infrastructure as Code |
| `@cdktf/provider-aws` | Latest | AWS resource definitions |
| `@cdktf/provider-archive` | Latest | Lambda packaging |

### Frontend Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| **Angular** | 18.x | Frontend framework |
| **TypeScript** | 5.x | Type-safe development |
| **NgRx** | Latest | State management |
| `@ngrx/store` | Latest | Global state |
| `@ngrx/effects` | Latest | Side effects |
| `@ngrx/store-devtools` | Latest | Dev tools |
| **Dexie** | Latest | IndexedDB wrapper |
| **amazon-cognito-identity-js** | Latest | Cognito authentication |

### Development Tools

| Tool | Version | Purpose |
|------|---------|---------|
| **AWS CLI** | v2 | AWS management |
| **Git** | Latest | Version control |
| **VS Code** | Latest | IDE (recommended) |
| **Angular CLI** | 18.x | Angular tooling |

### AWS Services (Versions managed by AWS)

| Service | Configuration |
|---------|--------------|
| **Lambda** | Node.js 20.x, arm64 architecture, 512MB memory |
| **API Gateway** | REST API |
| **DynamoDB** | Pay-per-request billing, 25 RCU/WCU free tier |
| **Cognito** | User Pool with email authentication |
| **S3** | Standard storage class |
| **CloudFront** | Standard distribution |
| **CloudWatch** | Logs and metrics |

---

## Prerequisites

**Before starting Phase 1, complete the development environment setup.**

**Setup Guide**: See [SETUP_GUIDE.md](../SETUP_GUIDE.md) for detailed instructions

**Quick Checklist**:
- [ ] Development tools installed (Node.js, CDKTF CLI, AWS CLI, Angular CLI)
- [ ] AWS account configured with IAM user and billing alarms
- [ ] Project structure created (backend/, infrastructure/, frontend/)
- [ ] CDKTF initialized and tested (`cdktf synth` works)
- [ ] Backend builds successfully (`npm run build`)
- [ ] Frontend runs successfully (`ng serve`)
- [ ] Git initialized with proper .gitignore

**Estimated Time**: 1-2 days

**Ready?** All checks passed? Proceed to Phase 1!

---

## Phase 1: Infrastructure + Authentication (2-3 weeks)

### Goal: Working infrastructure with full authentication

**You'll learn**: CDKTF, DynamoDB setup, Cognito, hexagonal architecture basics, Lambda layers

### Week 1: Infrastructure Foundation

**Tasks**:

1. **DynamoDB Table (CDKTF)**
   - [ ] Create `DatabaseStack` in CDKTF
   - [ ] Define table: `teamflow-main`
   - [ ] Primary keys: PK (string), SK (string)
   - [ ] Add GSI1: GSI1PK, GSI1SK (for entity lookups by ID)
   - [ ] Add GSI2: GSI2PK, GSI2SK (for user lookup by email)
   - [ ] Set billing mode: PAY_PER_REQUEST (free tier: 25 RCU/WCU)
   - [ ] Add tags: Environment=dev, Project=TeamFlow
   - [ ] Deploy: `cdktf deploy`
   - [ ] Verify table created in AWS Console

2. **IAM Roles (CDKTF)**
   - [ ] Create Lambda execution role
   - [ ] Attach policy: AWSLambdaBasicExecutionRole
   - [ ] Add DynamoDB permissions (read/write on teamflow-main)
   - [ ] Principle of least privilege

3. **Lambda Layers (CDKTF)**
   - [ ] Create layer structure:
     ```
     layers/
     ├── business-logic/
     │   └── nodejs/node_modules/@teamflow/core/
     └── dependencies/
         └── nodejs/node_modules/
     ```
   - [ ] Set up build script for business-logic layer
   - [ ] Deploy dependencies layer (aws-sdk, date-fns)
   - [ ] Deploy business-logic layer (initially empty structure)
   - [ ] Verify layers in AWS Console

4. **API Gateway (CDKTF)**
   - [ ] Create `ApiStack` in CDKTF
   - [ ] Define REST API Gateway: `teamflow-api`
   - [ ] Configure CORS (allow all origins for dev)
   - [ ] Set up API Gateway stage: `dev`
   - [ ] Configure throttling: 100 req/sec burst
   - [ ] Deploy: `cdktf deploy`
   - [ ] Test: `curl https://{api-id}.execute-api.us-east-1.amazonaws.com/dev`

5. **Health Check Lambda**
   - [ ] Create first Lambda function: `health-check`
   - [ ] Handler: Return `{ status: 'ok', timestamp: new Date() }`
   - [ ] Configure: Node.js 20.x, arm64, 512MB memory
   - [ ] Attach layers (business-logic, dependencies)
   - [ ] Create API Gateway route: `GET /health`
   - [ ] Lambda integration (proxy)
   - [ ] Deploy: `cdktf deploy`
   - [ ] Test: `curl https://{api-id}.execute-api.us-east-1.amazonaws.com/dev/health`

**Deliverable**: Working infrastructure with health check endpoint

**Learning Resources** (consult as you build):
- CDKTF documentation for resource syntax
- AWS DynamoDB single-table design guide
- Lambda layer structure requirements

### Week 2: Cognito + Initial Backend Structure

**Tasks**:

1. **Cognito User Pool (CDKTF)**
   - [ ] Create `AuthStack` in CDKTF
   - [ ] Define User Pool: `teamflow-users`
   - [ ] Email-based sign-in (username = email)
   - [ ] Password policy: 8+ chars, uppercase, lowercase, number
   - [ ] Custom attribute: `custom:currentOrgId` (string)
   - [ ] MFA: Optional (off for MVP)
   - [ ] Email verification required
   - [ ] Deploy: `cdktf deploy`

2. **Cognito User Pool Client**
   - [ ] Create app client for web app
   - [ ] Auth flows: USER_PASSWORD_AUTH, REFRESH_TOKEN_AUTH
   - [ ] Token expiration:
     - ID Token: 1 hour
     - Access Token: 1 hour
     - Refresh Token: 30 days
   - [ ] No client secret (public client for SPA)

3. **Cognito Authorizer (API Gateway)**
   - [ ] Add Cognito authorizer to API Gateway
   - [ ] Identity source: `Authorization` header
   - [ ] Token validation against User Pool
   - [ ] Deploy: `cdktf deploy`

4. **Test Cognito Integration**
   - [ ] Create test user manually in Cognito console
   - [ ] Test: Get JWT token via AWS CLI
   - [ ] Test: Call health endpoint with token
   - [ ] Verify: 401 without token, 200 with token

**Deliverable**: Cognito authentication working with API Gateway

### Week 3: Auth Backend (Hexagonal Architecture)

**You'll learn**: Hexagonal architecture (ports & adapters), domain-driven design basics, Lambda handler patterns

**Hexagonal Architecture Implementation**:

1. **Domain Layer (Lambda Layer)**
   - [ ] Create entity: `User.ts`
     ```typescript
     class User {
       id: string;
       email: string;
       name: string;
       cognitoSub: string;
       createdAt: Date;
     }
     ```
   - [ ] Create value object: `Email.ts` (validation)
   - [ ] Create entity: `Organization.ts` (basic, expanded later)

2. **Ports (Interfaces)**
   - [ ] Create `IUserRepository.ts`
     ```typescript
     interface IUserRepository {
       save(user: User): Promise<void>;
       findByEmail(email: string): Promise<User | null>;
       findByCognitoSub(sub: string): Promise<User | null>;
     }
     ```
   - [ ] Create `ICognitoService.ts`
     ```typescript
     interface ICognitoService {
       register(email: string, password: string, name: string): Promise<{sub: string}>;
       confirmSignUp(email: string, code: string): Promise<void>;
     }
     ```

3. **Use Cases**
   - [ ] `RegisterUseCase.ts`
     - Input: { email, password, name }
     - Steps:
       1. Validate email/password
       2. Call Cognito to create user
       3. Save user to DynamoDB
       4. Create default organization
     - Output: { userId, message: 'Check email for verification' }

   - [ ] `LoginUseCase.ts`
     - Input: { email, password }
     - Steps:
       1. User already in DynamoDB (via Cognito sub)
       2. Cognito handles auth, returns tokens
     - Output: { tokens, user }

   - [ ] `GetCurrentUserUseCase.ts`
     - Input: { cognitoSub }
     - Steps: Fetch user from DynamoDB by cognitoSub
     - Output: { user }

4. **Adapters**
   - [ ] `DynamoDBUserRepository.ts`
     - Implements `IUserRepository`
     - Access patterns:
       - Save: PK=USER#{userId}, SK=METADATA
       - FindByEmail: Query GSI2 where GSI2PK={email}
       - FindByCognitoSub: Query where PK contains cognitoSub

   - [ ] `CognitoAuthService.ts`
     - Implements `ICognitoService`
     - Wraps AWS Cognito SDK calls

5. **Lambda Handlers**
   - [ ] `functions/auth/register.ts`
     - Thin wrapper
     - Calls RegisterUseCase
     - Returns API Gateway response

   - [ ] `functions/auth/confirm.ts`
     - Confirm email verification

   - [ ] `functions/auth/me.ts`
     - Protected endpoint (Cognito authorizer)
     - Calls GetCurrentUserUseCase
     - Returns current user info

6. **Deploy Auth Lambdas (CDKTF)**
   - [ ] Update ApiStack with auth endpoints:
     - POST /auth/register (no auth)
     - POST /auth/confirm (no auth)
     - GET /auth/me (Cognito authorizer required)
   - [ ] Deploy: `cdktf deploy`
   - [ ] Test with Postman/cURL

**DynamoDB Access Patterns**:
- User by email: GSI2PK={email}, GSI2SK=USER
- User by cognitoSub: Store cognitoSub in user item, query by attribute

**Multi-Tenant Consideration**: When user registers, auto-create personal organization

### Week 4: Frontend Auth Module (Complete Auth Flow)

**You'll learn**: NgRx store patterns, Angular reactive forms, JWT token management, auth guards/interceptors

**Angular + NgRx Implementation**:

1. **Core Auth Module**
   - [ ] Create `core/auth/` folder structure:
     ```
     core/auth/
     ├── services/
     │   ├── auth.service.ts
     │   └── cognito.service.ts
     ├── guards/
     │   └── auth.guard.ts
     ├── interceptors/
     │   └── auth.interceptor.ts
     ├── models/
     │   └── user.model.ts
     └── store/
         ├── auth.actions.ts
         ├── auth.reducer.ts
         ├── auth.effects.ts
         └── auth.selectors.ts
     ```

2. **Cognito Service**
   - [ ] Install: `amazon-cognito-identity-js`
   - [ ] Implement CognitoService:
     ```typescript
     class CognitoService {
       register(email, password, name): Observable<void>
       confirmSignUp(email, code): Observable<void>
       login(email, password): Observable<CognitoTokens>
       getIdToken(): string | null
       refreshSession(): Observable<CognitoTokens>
     }
     ```

3. **NgRx Store**
   - [ ] Auth Actions:
     - `register`, `registerSuccess`, `registerFailure`
     - `confirmEmail`, `confirmEmailSuccess`, `confirmEmailFailure`
     - `login`, `loginSuccess`, `loginFailure`
     - `loadCurrentUser`, `loadCurrentUserSuccess`
     - `logout`

   - [ ] Auth State:
     ```typescript
     interface AuthState {
       user: User | null;
       tokens: {idToken: string, accessToken: string} | null;
       loading: boolean;
       error: string | null;
       isAuthenticated: boolean;
     }
     ```

   - [ ] Auth Effects:
     - Listen to `login` action → call CognitoService → dispatch success/failure
     - On `loginSuccess` → call API `/auth/me` → load user → store in state
     - Handle token refresh logic

4. **Auth Components**
   - [ ] Register page (standalone component):
     - Reactive form: email, password, confirm password, name
     - Validation (email format, password strength, match)
     - Submit → dispatch `register` action
     - Show success: "Check email for verification code"

   - [ ] Email confirmation page:
     - Input: verification code
     - Submit → dispatch `confirmEmail` action
     - Redirect to login on success

   - [ ] Login page:
     - Reactive form: email, password
     - Submit → dispatch `login` action
     - Redirect to dashboard on success
     - Show error messages

5. **Auth Guard**
   - [ ] Check `isAuthenticated` from store
   - [ ] If false → redirect to /login
   - [ ] Applied to all protected routes

6. **Auth Interceptor**
   - [ ] Add `Authorization: Bearer {idToken}` to all API calls
   - [ ] On 401 response → try token refresh → retry request
   - [ ] If refresh fails → logout and redirect to login

7. **Routing**
   - [ ] Public routes: `/`, `/login`, `/register`, `/confirm-email`
   - [ ] Protected routes: `/dashboard/*` (auth guard applied)

**Testing**:
- [ ] User can register
- [ ] User receives verification email
- [ ] User confirms email
- [ ] User logs in
- [ ] Token stored and sent with API requests
- [ ] Protected routes require auth
- [ ] Logout clears session

**Deliverable**: Full authentication flow working end-to-end

**Time for Phase 1**: 2-3 weeks (depending on familiarity with serverless)

---

## Phase 2: Organizations (2 weeks)

### Goal: Multi-tenant foundation established

**You'll learn**: DynamoDB single-table design, multi-tenant security patterns, GSI usage for relationships

### Week 1: Backend Organizations

**Domain Layer**:
- [ ] Expand `Organization.ts` entity:
  ```typescript
  class Organization {
    id: string;
    name: string;
    ownerId: string;
    createdAt: Date;
  }
  ```
- [ ] Create `OrganizationMember.ts` entity:
  ```typescript
  class OrganizationMember {
    organizationId: string;
    userId: string;
    role: 'owner' | 'member';
    joinedAt: Date;
  }
  ```

**Ports**:
- [ ] `IOrganizationRepository.ts`:
  ```typescript
  interface IOrganizationRepository {
    save(org: Organization): Promise<void>;
    findById(id: string): Promise<Organization | null>;
    findByUserId(userId: string): Promise<Organization[]>;
    addMember(member: OrganizationMember): Promise<void>;
    getMembers(orgId: string): Promise<OrganizationMember[]>;
    isMember(userId: string, orgId: string): Promise<boolean>;
  }
  ```

**Use Cases**:
- [ ] `CreateOrganizationUseCase.ts`:
  - Create org
  - Add creator as owner
  - Return organization

- [ ] `ListUserOrganizationsUseCase.ts`:
  - Query orgs where user is member
  - Return list with user's role

- [ ] `InviteMemberUseCase.ts` (simplified for MVP):
  - Verify inviter is owner
  - Send invitation (placeholder, full email in later phase)
  - For MVP: Direct add by email if user exists

- [ ] `GetOrganizationDetailsUseCase.ts`:
  - Verify user is member
  - Return org details + member list

**Adapters**:
- [ ] `DynamoDBOrganizationRepository.ts`:
  - Access patterns:
    - Org by ID: PK=ORG#{orgId}, SK=METADATA
    - Orgs by user: GSI1 where GSI1PK=USER#{userId}, GSI1SK=ORG#{orgId}
    - Member relationship: PK=ORG#{orgId}, SK=MEMBER#{userId}
    - Reverse (user's orgs): GSI1PK=USER#{userId}, GSI1SK begins_with ORG#

**Lambda Handlers**:
- [ ] POST /organizations - Create org
- [ ] GET /organizations - List user's orgs
- [ ] GET /organizations/:id - Get org details
- [ ] GET /organizations/:id/members - Get members
- [ ] POST /organizations/:id/members - Add member (simplified invite)

**Multi-Tenant Security Middleware**:
- [ ] Create `validateOrganizationAccess` middleware:
  ```typescript
  // Extract userId from Cognito authorizer context
  // Extract organizationId from path or body
  // Verify user is member of organization
  // Attach organizationId to request context
  ```

**Deploy**:
- [ ] Update CDKTF with new Lambda functions
- [ ] Deploy: `cdktf deploy`
- [ ] Test organization CRUD

### Week 2: Frontend Organizations

**NgRx Store**:
- [ ] Create organizations feature store:
  ```typescript
  interface OrganizationsState {
    organizations: Organization[];
    currentOrganization: Organization | null;
    members: User[];
    loading: boolean;
    error: string | null;
  }
  ```
- [ ] Actions: load, loadSuccess, create, createSuccess, selectOrg, etc.
- [ ] Effects: API calls for org operations
- [ ] Selectors: `selectAllOrganizations`, `selectCurrentOrganization`, etc.

**Components**:
- [ ] Dashboard page (after login):
  - List of user's organizations (cards)
  - "Create Organization" button
  - Click org → navigate to `/workspace/:orgId`

- [ ] Create organization modal:
  - Input: name
  - Submit → dispatch create action
  - On success → redirect to new workspace

- [ ] Workspace home page:
  - Header: Organization name
  - "Invite Members" button (placeholder)
  - Navigation: Projects (empty for now)
  - Sidebar: Workspace settings (future)

**Routing**:
- [ ] `/dashboard` → Dashboard page
- [ ] `/workspace/:orgId` → Workspace home (auth guard + org access check)

**Organization Context**:
- [ ] Store current organizationId in NgRx
- [ ] Pass organizationId in API calls when needed
- [ ] Display current org name in navbar

**Testing**:
- [ ] User sees list of organizations after login
- [ ] User creates new organization
- [ ] User switches between organizations
- [ ] User sees organization details

**Deliverable**: Multi-tenant organization system working

---

## Phase 3: Projects (2 weeks)

### Goal: Project management with DynamoDB access patterns

**You'll learn**: Complex DynamoDB queries, partition key design, Lambda layer organization

### Week 1: Backend Projects

**Domain Layer**:
- [ ] Create `Project.ts` entity:
  ```typescript
  class Project {
    id: string;
    organizationId: string;
    name: string;
    description: string;
    createdBy: string;
    createdAt: Date;
  }
  ```

**Ports**:
- [ ] `IProjectRepository.ts`:
  ```typescript
  interface IProjectRepository {
    save(project: Project): Promise<void>;
    findById(projectId: string): Promise<Project | null>;
    findByOrganization(orgId: string): Promise<Project[]>;
    update(project: Project): Promise<void>;
    delete(projectId: string): Promise<void>;
  }
  ```

**Use Cases**:
- [ ] `CreateProjectUseCase.ts`:
  - Validate user access to organization
  - Create project
  - Return project

- [ ] `ListProjectsUseCase.ts`:
  - Validate user access to organization
  - Query projects by organizationId
  - Return list

- [ ] `GetProjectUseCase.ts`:
  - Validate user access to project's organization
  - Return project details

- [ ] `UpdateProjectUseCase.ts`:
  - Validate user access
  - Update project

- [ ] `DeleteProjectUseCase.ts`:
  - Validate user access (owner or creator)
  - Delete project

**Adapters**:
- [ ] `DynamoDBProjectRepository.ts`:
  - Access patterns:
    - Projects in org: PK=ORG#{orgId}, SK=PROJECT#{projectId}
    - Project by ID: GSI1PK=PROJECT#{projectId}, GSI1SK=PROJECT#{projectId}

**Lambda Handlers**:
- [ ] GET /organizations/:orgId/projects
- [ ] POST /organizations/:orgId/projects
- [ ] GET /projects/:id
- [ ] PUT /projects/:id
- [ ] DELETE /projects/:id

**Security**:
- [ ] All endpoints validate organizationId access
- [ ] Use validateOrganizationAccess middleware

**Deploy**:
- [ ] Update CDKTF
- [ ] Deploy: `cdktf deploy`
- [ ] Test project CRUD

### Week 2: Frontend Projects

**NgRx Store**:
- [ ] Projects feature store:
  ```typescript
  interface ProjectsState {
    projects: Project[];
    selectedProject: Project | null;
    loading: boolean;
    error: string | null;
  }
  ```

**Components**:
- [ ] Workspace home (update):
  - Grid/list of projects
  - "Create Project" button
  - Empty state: "No projects yet"

- [ ] Create project modal:
  - Name (required), description (optional)
  - Submit → dispatch create action

- [ ] Project card component:
  - Project name, description preview
  - Created date
  - Click → navigate to `/workspace/:orgId/projects/:projectId`

- [ ] Project detail page:
  - Project header (name, description)
  - Edit/delete buttons
  - Placeholder for tasks (next phase)
  - Breadcrumb: Workspace > Project

**Routing**:
- [ ] `/workspace/:orgId/projects/:projectId` → Project detail

**Testing**:
- [ ] User creates project
- [ ] User sees project list
- [ ] User views project details
- [ ] User edits project
- [ ] User deletes project

**Deliverable**: Project management working

---

## Phase 4: Tasks - Core (2 weeks)

### Goal: Task CRUD with complex DynamoDB queries

**You'll learn**: Hierarchical data modeling in DynamoDB, advanced access patterns

### Week 1: Backend Tasks

**Domain Layer**:
- [ ] Create `Task.ts` entity:
  ```typescript
  class Task {
    id: string;
    projectId: string;
    organizationId: string;
    title: string;
    description: string;
    assigneeId?: string;
    status: 'todo' | 'in_progress' | 'done';
    priority?: 'low' | 'medium' | 'high';
    deadline?: Date;
    createdBy: string;
    createdAt: Date;
    updatedAt: Date;
  }
  ```

**Ports**:
- [ ] `ITaskRepository.ts`:
  ```typescript
  interface ITaskRepository {
    save(task: Task): Promise<void>;
    findById(taskId: string): Promise<Task | null>;
    findByProject(projectId: string): Promise<Task[]>;
    update(task: Task): Promise<void>;
    delete(taskId: string): Promise<void>;
  }
  ```

**Use Cases**:
- [ ] `CreateTaskUseCase.ts`
- [ ] `ListTasksUseCase.ts` (by project)
- [ ] `GetTaskUseCase.ts`
- [ ] `UpdateTaskUseCase.ts`
- [ ] `DeleteTaskUseCase.ts`

**Adapters**:
- [ ] `DynamoDBTaskRepository.ts`:
  - Access patterns:
    - Tasks in project: PK=PROJECT#{projectId}, SK=TASK#{taskId}
    - Task by ID: GSI1PK=TASK#{taskId}, GSI1SK=TASK#{taskId}

**Lambda Handlers**:
- [ ] GET /projects/:projectId/tasks
- [ ] POST /projects/:projectId/tasks
- [ ] GET /tasks/:id
- [ ] PUT /tasks/:id
- [ ] DELETE /tasks/:id

**Security**:
- [ ] Validate user access to project's organization
- [ ] Store organizationId in task for queries

**Deploy**:
- [ ] Update CDKTF
- [ ] Deploy: `cdktf deploy`

### Week 2: Frontend Tasks - List View

**NgRx Store**:
- [ ] Tasks feature store

**Components**:
- [ ] Project detail (update):
  - Task list
  - "Create Task" button

- [ ] Create task modal:
  - Title (required), description (optional)

- [ ] Task card component:
  - Title, status badge, assignee

- [ ] Task detail modal:
  - Full task info
  - Edit/delete buttons

**Testing**:
- [ ] User creates task
- [ ] User views task list
- [ ] User edits task
- [ ] User deletes task

**Deliverable**: Task CRUD working

---

## Phase 5: Tasks - Workflow (2 weeks)

### Goal: Status tracking, assignments, priorities, Kanban board

**You'll learn**: Complex NgRx state management, drag-and-drop patterns, filtering/sorting

### Week 1: Task Properties

**Backend**:
- [ ] Update use cases to handle:
  - Status updates
  - Assignee changes (validate user is org member)
  - Priority updates
  - Deadline updates

**Frontend**:
- [ ] Status selector dropdown
- [ ] Assignee selector (dropdown with org members)
- [ ] Priority selector
- [ ] Date picker for deadline
- [ ] Update task detail modal with all selectors

### Week 2: Kanban Board

**Frontend**:
- [ ] Create Kanban board component:
  - 3 columns: To Do, In Progress, Done
  - Tasks grouped by status
  - Drag-and-drop (optional) or manual status change

- [ ] View toggle: List / Board
- [ ] Filtering: by status, assignee, priority

**Testing**:
- [ ] User assigns tasks
- [ ] User changes status
- [ ] User sets priority/deadline
- [ ] Kanban board displays correctly

**Deliverable**: Full task workflow system

---

## Phase 6: Collaboration (2 weeks)

### Goal: Comments on tasks

**You'll learn**: Real-time data patterns, comment threading in DynamoDB

### Week 1: Backend Comments

**Domain Layer**:
- [ ] Create `Comment.ts` entity

**Use Cases**:
- [ ] `AddCommentUseCase.ts`
- [ ] `ListCommentsUseCase.ts` (by task)
- [ ] `DeleteCommentUseCase.ts` (only own comments)

**Adapters**:
- [ ] `DynamoDBCommentRepository.ts`:
  - Access pattern: PK=TASK#{taskId}, SK=COMMENT#{commentId}

**Lambda Handlers**:
- [ ] GET /tasks/:taskId/comments
- [ ] POST /tasks/:taskId/comments
- [ ] DELETE /comments/:id

### Week 2: Frontend Comments

**Components**:
- [ ] Comments section (in task detail):
  - List of comments (chronological)
  - Comment input textarea
  - Submit button

- [ ] Comment card:
  - Author name/avatar
  - Content
  - Timestamp
  - Delete button (own comments only)

**Testing**:
- [ ] User adds comment
- [ ] User sees all comments
- [ ] User deletes own comment

**Deliverable**: Comments working

---

## Phase 7: Polish & Deployment (2 weeks)

**You'll learn**: CloudWatch monitoring, GitHub Actions CI/CD, production deployment best practices

### Week 1: Polish

**UX Improvements**:
- [ ] Loading states (spinners, skeletons)
- [ ] Error messages (user-friendly)
- [ ] Success toasts
- [ ] Empty states everywhere
- [ ] Form validation improvements

**Responsive Design**:
- [ ] Test on mobile
- [ ] Fix layout issues
- [ ] Mobile navigation

**Performance**:
- [ ] Optimize Lambda cold starts (keep small)
- [ ] Add pagination to list endpoints
- [ ] Frontend bundle optimization

**Security Review**:
- [ ] Review all organizationId validations
- [ ] Test cross-tenant access prevention
- [ ] Input validation everywhere
- [ ] HTTPS configuration

### Week 2: Deployment & Launch

**Infrastructure**:
- [ ] Set up production CDKTF stack
- [ ] Configure CloudFront for frontend (S3 + CDN)
- [ ] Set up custom domain (optional)
- [ ] Configure production environment variables
- [ ] Enable CloudWatch logging

**CI/CD**:
- [ ] Create GitHub Actions workflows:
  - Backend: Build → Test → Deploy Lambda + layers
  - Infrastructure: Plan → Apply (on merge to main)
  - Frontend: Build → Deploy to S3 → Invalidate CloudFront
- [ ] Manual approval gate for production

**Monitoring**:
- [ ] CloudWatch dashboards
- [ ] Billing alarms (already set)
- [ ] Error rate alarms
- [ ] Lambda performance metrics

**Testing**:
- [ ] End-to-end testing in production
- [ ] Load testing (within free tier)
- [ ] Security testing
- [ ] Cross-browser testing

**Launch**:
- [ ] Soft launch (invite beta testers)
- [ ] Gather feedback
- [ ] Fix critical issues
- [ ] Public launch

**Deliverable**: Production MVP deployed and running

---

## Success Criteria

**Technical**:
- [ ] All core features working (auth, orgs, projects, tasks, comments)
- [ ] Multi-tenant security validated (no data leaks)
- [ ] DynamoDB single-table design implemented correctly
- [ ] Hexagonal architecture consistently applied
- [ ] Lambda cold starts acceptable (<2s for demo)
- [ ] All infrastructure defined in CDKTF
- [ ] CI/CD pipeline functional
- [ ] Monitoring and alarms set up

**User Experience**:
- [ ] Users can complete all MVP flows
- [ ] App responsive on mobile
- [ ] No critical bugs
- [ ] Performance acceptable for demo

**Learning Goals**:
- [ ] Team understands DynamoDB single-table design
- [ ] Team proficient with hexagonal architecture
- [ ] Team comfortable with CDKTF
- [ ] Team can debug serverless issues

---

## Anti-Patterns to Avoid

**During Development**:
- ❌ Business logic in Lambda handlers (always use cases in layer)
- ❌ Missing organizationId in any database query
- ❌ Trusting organizationId from request body (extract from JWT only)
- ❌ Creating Lambda functions without hexagonal architecture
- ❌ Not testing with multiple tenants (create org1, org2 from day one)
- ❌ Exceeding Lambda layer 50MB limit
- ❌ Using DynamoDB Scan operations (always Query)
- ❌ Skipping access pattern documentation (write it down first)

**During Deployment**:
- ❌ Deploying without testing in dev first
- ❌ Missing billing alarms
- ❌ Hardcoding secrets (use environment variables)
- ❌ Deploying all stacks at once (deploy incrementally)

---

## Tips for Success (Learn While Building)

**DynamoDB**:
- Document each access pattern as you build the feature
- Keep "The DynamoDB Book" handy for reference
- Test queries in AWS Console before coding
- Always include organizationId in queries
- Use Query, never Scan

**Lambda & Hexagonal Architecture**:
- Follow the pattern: Domain → Ports → Use Cases → Adapters → Handlers
- Keep handlers thin (3-5 lines max)
- Reuse SDK clients (initialize outside handler)
- Put ALL business logic in Lambda layer
- Monitor layer sizes (check before every deploy)

**CDKTF**:
- Start with one resource, then add more
- Run `cdktf plan` before every deploy
- Read error messages carefully (they're helpful)
- Keep CDKTF documentation open while coding
- Tag all resources for easy tracking

**Multi-Tenant Security**:
- Create two test organizations from day one (org1, org2)
- Test every feature with both organizations
- Extract organizationId from JWT claims, never trust request body
- Validate organizationId at handler, use case, and repository layers
- Log all authorization failures for security monitoring

**Learning Strategy**:
- Build one complete feature before moving to the next
- Consult documentation when stuck (don't guess)
- Copy patterns from completed features
- Test thoroughly before moving forward
- Document unusual solutions for future reference

---

## Learning Resources (Consult as Needed)

**DynamoDB**:
- "The DynamoDB Book" by Alex DeBrie (main reference for access patterns)
- AWS DynamoDB documentation: https://docs.aws.amazon.com/dynamodb/
- NoSQL Workbench for modeling: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/workbench.html
- Rick Houlihan re:Invent talks (search YouTube)

**Hexagonal Architecture**:
- Alistair Cockburn's original article
- TypeScript hexagonal architecture examples (GitHub)
- Clean Architecture principles (reference when designing)

**CDKTF**:
- Official documentation: https://developer.hashicorp.com/terraform/cdktf
- AWS Provider docs: https://registry.terraform.io/providers/hashicorp/aws/
- Example patterns in CDKTF GitHub repo

**Lambda**:
- AWS Lambda developer guide
- Lambda layers documentation
- Lambda best practices guide

**Angular + NgRx**:
- Angular documentation: https://angular.dev
- NgRx documentation: https://ngrx.io
- RxJS documentation for operators

**When You're Stuck**:
1. Check TECHNICAL_ARCHITECTURE_SERVERLESS.md (this project's patterns)
2. Read relevant documentation (AWS, CDKTF, Angular)
3. Look for similar patterns in completed features
4. Search for specific error messages
5. Consult example repositories on GitHub

---

## Appendix: Key Commands Reference

### CDKTF
```bash
cdktf synth                    # Generate Terraform JSON
cdktf plan                     # Preview changes
cdktf deploy [stack-name]      # Deploy infrastructure
cdktf destroy [stack-name]     # Destroy infrastructure
cdktf list                     # List all stacks
```

### AWS CLI
```bash
aws dynamodb scan --table-name teamflow-main --limit 10   # Debug DynamoDB
aws lambda invoke --function-name health-check out.json   # Test Lambda
aws logs tail /aws/lambda/function-name --follow           # View logs
```

### Development
```bash
npm run build:layer           # Build Lambda layer
npm run build:functions       # Build Lambda functions
npm run test                  # Run tests
npm run deploy                # Deploy (via CDKTF)
```

---

## Summary

This roadmap delivers a **production-grade MVP in 14-15 weeks** while learning DynamoDB, hexagonal architecture, CDKTF, and serverless patterns through practical implementation.

**Approach**: Learn by doing. Each phase introduces new concepts while building features.

**Key Success Factors**:
1. **Follow the architecture patterns** (hexagonal, single-table DynamoDB)
2. **Test with multiple tenants** from day one
3. **Consult documentation** when needed (don't guess)
4. **Deploy incrementally** (small, tested changes)
5. **Document as you go** (especially access patterns)

**Timeline**: ~3.5 months to production MVP with deep technical knowledge gained through hands-on implementation.

Start with Phase 1 and build forward. Each phase establishes patterns that accelerate the next.
