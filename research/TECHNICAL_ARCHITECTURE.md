# TeamFlow - Technical Architecture & Decisions

This document outlines the initial technical decisions and architecture for TeamFlow.

---

## Application Type

**Multi-Tenant SaaS Web Application**
- Multiple organizations (tenants) share the same application instance
- Each organization's data is isolated
- Single codebase serves all customers

---

## Key Technical Questions & Decisions

### 1. Technology Stack

**Frontend**
- Framework: [To be decided: React, Vue, Next.js, etc.]
- State Management: [To be decided: Redux, Context API, Zustand, etc.]
- UI Components: [To be decided: Material-UI, Tailwind, Chakra UI, custom, etc.]
- Build Tool: [To be decided: Vite, Webpack, etc.]

**Backend**
- Language/Framework: [To be decided: Node.js/Express, Python/Django, Ruby/Rails, etc.]
- API Style: REST or GraphQL
- Authentication: JWT tokens or session-based
- File Storage: Local filesystem or cloud (S3, Cloudinary, etc.)

**Database**
- Type: [To be decided: PostgreSQL, MySQL, MongoDB, etc.]
- ORM: [To be decided: Prisma, Sequelize, TypeORM, etc.]

**Hosting/Infrastructure**
- Frontend: [To be decided: Vercel, Netlify, AWS, etc.]
- Backend: [To be decided: Heroku, AWS, DigitalOcean, Railway, etc.]
- Database: [To be decided: Managed service or self-hosted]

**Version Control**
- Git + GitHub ✅ (Already set up)

---

## Data Model (High-Level)

### Core Entities

**Users**
- id, email, password_hash, name, created_at

**Organizations** (Workspaces/Tenants)
- id, name, owner_id, created_at
- Represents a company/team workspace

**Organization Members** (Join table)
- organization_id, user_id, role
- Links users to organizations with roles

**Projects**
- id, organization_id, name, description, created_at
- Projects belong to organizations

**Tasks**
- id, project_id, title, description, assignee_id, status, priority, deadline, created_at
- Tasks belong to projects

**Comments**
- id, task_id, user_id, content, created_at
- Comments belong to tasks

**Attachments** (Post-MVP or later)
- id, task_id, filename, file_url, uploaded_by, created_at

### Multi-Tenancy Strategy

**Access Pattern Decision (MVP)**: Shared Domain
- All users access via single domain: `app.teamflow.com` (or `teamflow.com`)
- URL structure: `/workspace/:orgId/projects/:projectId`
- Subdomain-based routing (e.g., `famsa.teamflow.com`) deferred to post-MVP
- Simpler deployment, single SSL certificate, easier testing for MVP

**Data Isolation**: All queries filtered by organization_id
- Users can only access data from their organizations
- Application enforces organization boundaries at API level
- Security enforced at three levels:
  1. **Middleware**: Validates user belongs to requested organization
  2. **Controller**: Checks permissions before processing
  3. **Database**: All queries filtered by organization_id

**Example Query Pattern**:
```sql
-- Always include organization_id in queries
SELECT * FROM projects
WHERE organization_id = :current_user_organization_id;
```

---

## Authentication & Authorization

### Authentication
- User registers with email + password
- Password hashed with bcrypt (or similar)
- Login returns JWT token
- Frontend stores token and sends with each request
- Backend validates token on protected routes

### Authorization (MVP)
- **Owner**: Full access to organization (delete workspace, manage billing)
- **Member**: Can create projects, tasks, comment (standard user)
- **Guest** (Post-MVP): View-only access

### Security Considerations
- Password minimum requirements (8+ characters)
- JWT token expiration (e.g., 7 days)
- HTTPS only in production
- Input validation and sanitization
- SQL injection prevention (use parameterized queries/ORM)
- Rate limiting on auth endpoints

---

## API Design

### RESTful API Structure

**Authentication**
- POST `/api/auth/register` - Create account
- POST `/api/auth/login` - Login and get token
- POST `/api/auth/logout` - Logout (invalidate token)

**Organizations**
- POST `/api/organizations` - Create workspace
- GET `/api/organizations` - List user's workspaces
- GET `/api/organizations/:id` - Get workspace details
- POST `/api/organizations/:id/invite` - Invite members

**Projects**
- GET `/api/projects` - List projects (filtered by org)
- POST `/api/projects` - Create project
- GET `/api/projects/:id` - Get project details
- PUT `/api/projects/:id` - Update project
- DELETE `/api/projects/:id` - Delete project

**Tasks**
- GET `/api/projects/:projectId/tasks` - List tasks in project
- POST `/api/projects/:projectId/tasks` - Create task
- GET `/api/tasks/:id` - Get task details
- PUT `/api/tasks/:id` - Update task
- DELETE `/api/tasks/:id` - Delete task

**Comments**
- GET `/api/tasks/:taskId/comments` - List comments
- POST `/api/tasks/:taskId/comments` - Create comment
- DELETE `/api/comments/:id` - Delete comment

### API Response Format

**Success Response**:
```json
{
  "success": true,
  "data": { ... }
}
```

**Error Response**:
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

---

## Frontend Architecture

### Page Structure (MVP)

**Public Pages**
- `/` - Landing page
- `/login` - Login page
- `/register` - Registration page

**Authenticated Pages**
- `/dashboard` - User dashboard (list of workspaces)
- `/workspace/:orgId` - Workspace home (list of projects)
- `/workspace/:orgId/projects/:projectId` - Project detail (task board)
- `/workspace/:orgId/settings` - Workspace settings

### Component Structure (Example)

```
src/
├── components/
│   ├── auth/
│   │   ├── LoginForm.jsx
│   │   └── RegisterForm.jsx
│   ├── projects/
│   │   ├── ProjectList.jsx
│   │   ├── ProjectCard.jsx
│   │   └── CreateProjectModal.jsx
│   ├── tasks/
│   │   ├── TaskBoard.jsx
│   │   ├── TaskCard.jsx
│   │   ├── TaskDetail.jsx
│   │   └── CreateTaskModal.jsx
│   └── common/
│       ├── Navbar.jsx
│       └── Sidebar.jsx
├── pages/
│   ├── Dashboard.jsx
│   ├── WorkspaceHome.jsx
│   └── ProjectDetail.jsx
├── api/
│   └── client.js (API calls)
├── utils/
│   └── auth.js (token management)
└── App.jsx
```

---

## Backend Architecture

### Project Structure (Example - Node.js/Express)

```
server/
├── config/
│   └── database.js
├── middleware/
│   ├── auth.js (JWT validation)
│   └── errorHandler.js
├── models/
│   ├── User.js
│   ├── Organization.js
│   ├── Project.js
│   └── Task.js
├── routes/
│   ├── auth.js
│   ├── organizations.js
│   ├── projects.js
│   └── tasks.js
├── controllers/
│   ├── authController.js
│   ├── organizationController.js
│   ├── projectController.js
│   └── taskController.js
├── utils/
│   └── validation.js
└── server.js (entry point)
```

---

## Development Environment Setup

### Prerequisites
- Node.js (v18+ recommended) or chosen backend runtime
- Database (PostgreSQL/MySQL) installed locally
- Git (already set up ✅)
- Code editor (VS Code recommended)

### Local Development Workflow
1. Clone repository
2. Install dependencies (`npm install` or equivalent)
3. Set up `.env` file with local configuration
4. Run database migrations
5. Start backend server (e.g., `npm run dev`)
6. Start frontend dev server (e.g., `npm run dev`)
7. Access app at `http://localhost:3000` (or configured port)

### Environment Variables (.env)
```
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/teamflow_dev

# JWT
JWT_SECRET=your-secret-key-here
JWT_EXPIRES_IN=7d

# Server
PORT=3001
NODE_ENV=development

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

---

## Testing Strategy (MVP)

### Manual Testing
- Test critical user flows manually
- Auth flow: Register → Login → Access protected pages
- Core flow: Create workspace → Create project → Create task → Complete task

### Automated Testing (Post-MVP Priority)
- Unit tests for business logic
- Integration tests for API endpoints
- E2E tests for critical user flows

---

## Deployment Strategy (MVP)

### Simple Deployment Options

**Option 1: All-in-One Platform**
- Vercel/Netlify for frontend
- Railway/Render for backend + database
- Easiest for MVP

**Option 2: Separate Services**
- Frontend: Vercel/Netlify
- Backend: Heroku/Railway/DigitalOcean
- Database: Managed service (AWS RDS, DigitalOcean Managed DB)

### Deployment Checklist
- [ ] Environment variables configured in production
- [ ] Database migrations run
- [ ] HTTPS enabled
- [ ] CORS configured correctly
- [ ] JWT secret is secure (not the dev one)
- [ ] Error logging set up (Sentry, LogRocket, etc.)

---

## Scalability Considerations (Post-MVP)

These don't need to be solved now, but keep in mind:

**Database**
- Add indexes on frequently queried columns (organization_id, project_id, etc.)
- Connection pooling

**Caching**
- Cache frequently accessed data (user info, org details)
- Redis for session/cache storage

**File Storage**
- Move from local storage to cloud (S3, Cloudinary)

**Performance**
- API response time monitoring
- Database query optimization
- Frontend bundle size optimization

---

## Security Checklist (MVP)

- [ ] Passwords are hashed (bcrypt with salt)
- [ ] JWT tokens have expiration
- [ ] HTTPS in production
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention (parameterized queries/ORM)
- [ ] XSS prevention (sanitize user input in frontend)
- [ ] CORS configured correctly
- [ ] Rate limiting on auth endpoints
- [ ] Organization ID verified on all data access

---

## Architecture Decision

**⚠️ IMPORTANT: A specific serverless architecture has been chosen for TeamFlow.**

This document remains as a **reference for general SaaS architecture concepts**. For the **actual implementation architecture** that will be used for TeamFlow, see:

👉 **[TECHNICAL_ARCHITECTURE_SERVERLESS.md](./TECHNICAL_ARCHITECTURE_SERVERLESS.md)** 👈

### Decisions Made

- [x] **Multi-Tenancy Access Pattern**: Shared domain for MVP (subdomain routing post-MVP)
- [x] **Frontend Framework**: Angular 18+ with NgRx and signals
- [x] **Backend Framework**: AWS Lambda (Node.js/TypeScript, serverless)
- [x] **Database**: DynamoDB with single-table design
- [x] **Hosting**: AWS (Lambda, API Gateway, S3, CloudFront)
- [x] **Infrastructure as Code**: CDKTF (Terraform CDK with TypeScript)
- [x] **Architecture Pattern**: Hexagonal architecture (ports & adapters)
- [x] **Business Logic**: Lambda layers for shared code
- [ ] **Email Service**: TBD (SendGrid, AWS SES, etc.)
- [x] **File Storage**: S3 with pre-signed URLs

---

## Open Questions / Decisions Needed

Document remaining decisions:

- [ ] **Email Service**: For invitations (SendGrid, AWS SES, etc.)?
- [ ] **Authentication Details**: Cognito configuration, social login, MFA strategy
- [ ] **UI Component Library**: Angular Material, PrimeNG, or custom?
- [ ] **Testing Framework**: Jest vs. Vitest, Playwright vs. Cypress?

---

## Next Steps

1. Decide on technology stack (frontend, backend, database)
2. Set up development environment
3. Create database schema
4. Build authentication (Sprint 1)
5. Iterate from there following MVP plan

---

**Last Updated**: 2026-01-22
