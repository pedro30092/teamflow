# Project Manager Overview - TeamFlow

**Last Updated**: 2026-01-22

This document defines how project management is handled for TeamFlow, especially during early-stage infrastructure development.

---

## Table of Contents

1. [Overview](#overview)
2. [Epic & Story Structure](#epic--story-structure)
3. [Early-Stage Development Approach](#early-stage-development-approach)
4. [Story Templates](#story-templates)
5. [Tracking System](#tracking-system)
6. [Sprint Planning](#sprint-planning)

---

## Overview

TeamFlow uses **Agile/Scrum methodology** adapted for infrastructure-first development. Since we're building serverless architecture before user-facing features, our approach differs from traditional product development.

**Key Principle**: At early stages, we write **technical enablement stories** ("As a developer...") rather than user stories ("As a user...").

---

## Epic & Story Structure

### What is an Epic?

An **Epic** represents a large body of work that can be broken down into smaller stories. In early-stage development, epics focus on technical capabilities rather than user features.

**Format**:
```
Epic [Number]: [Name]
Goal: [What technical capability this enables]
Duration: [Estimated time]
Phase: [Which roadmap phase this belongs to]
```

**Example**:
```
Epic 1: Development Environment Setup
Goal: Get local development environment ready for building
Duration: 1-2 days
Phase: Prerequisites (before Phase 1)
```

### What is a Story?

A **Story** is a single, testable piece of work that contributes to an epic. Stories should be completable in 1-3 days.

**Format for Infrastructure Stories**:
```
As a [developer/frontend developer/DevOps engineer],
I need [technical capability],
so that [reason/benefit].
```

**Example**:
```
As a developer,
I need CDKTF CLI installed and configured,
so that I can deploy AWS infrastructure as code.
```

---

## Early-Stage Development Approach

### Phase-Based Epic Organization

Early development (Phases 1-2) focuses on **infrastructure and foundation**. Epics are organized differently than traditional feature development:

| Traditional Approach | Infrastructure Approach |
|---------------------|------------------------|
| "User Registration Feature" | "Authentication Infrastructure" |
| "Task Board" | "DynamoDB Table + API Gateway Setup" |
| "User can assign tasks" | "Multi-tenant security middleware" |

### Epic Categories for Phases 1-2

**Infrastructure Epics** (Phase 1):
- Epic 1: Development Environment Setup
- Epic 2: Core Infrastructure (DynamoDB, API Gateway, Lambda)
- Epic 3: Authentication Infrastructure (Cognito + Hexagonal Backend + Frontend)

**Foundation Epics** (Phase 2):
- Epic 4: Multi-Tenant Foundation (Organizations + Membership)

**Feature Epics** (Phase 3+):
- Epic 5: Projects Module
- Epic 6: Tasks Module
- Epic 7: Task Workflow
- Epic 8: Collaboration Features
- Epic 9: Deployment & Polish

---

## Story Templates

### Template 1: Infra-Backend-Expert (Backend/Infrastructure)

**Template File**: [`templates/INFRA_BACKEND_STORY_TEMPLATE.md`](templates/INFRA_BACKEND_STORY_TEMPLATE.md)

**Used for**: Backend code, infrastructure setup, database configuration, Lambda functions, DynamoDB access patterns, CDKTF stacks

**Key Sections**:
- Story ID, Epic, Sprint, Status
- User Story: "As an infra-backend-expert..."
- Requirements (with version specifications)
- Verification (command-line tests)
- Acceptance Criteria (checkbox list)
- Definition of Done (high-level requirements)
- Notes (installation methods, time estimates)
- Completion Notes (filled when done)

**Example**: See [`stories/STORY_1.1_INSTALL_TOOLS.md`](stories/STORY_1.1_INSTALL_TOOLS.md) for a completed example.

---

### Template 2: "As a Frontend Developer" (UI/UX)

Used for: Angular components, NgRx store, UI pages

```markdown
**Story ID**: [EPIC_ID]-[NUMBER]
**Type**: Frontend Development
**Epic**: [Epic Name]

**Story**:
As a frontend developer,
I need [UI component/feature],
so that [users can do X / system can do Y].

**Tasks**:
- [ ] [Create component/module]
- [ ] [Implement NgRx store]
- [ ] [Wire up API calls]
- [ ] [Add routing]
- [ ] [Style components]

**Acceptance Criteria**:
- [ ] [UI displays correctly]
- [ ] [User interaction works]
- [ ] [Data flows correctly]
- [ ] [Responsive on mobile]

**Dependencies**:
- [Backend API endpoints must exist]
- [NgRx store structure defined]

**Definition of Done**:
- [ ] Component code written and builds
- [ ] Functionality tested in browser
- [ ] No console errors
- [ ] Code reviewed (if applicable)
```

---

### Template 3: "As a DevOps/Platform Engineer" (Deployment/CI-CD)

Used for: Deployment pipelines, monitoring, infrastructure automation

```markdown
**Story ID**: [EPIC_ID]-[NUMBER]
**Type**: DevOps/Platform
**Epic**: [Epic Name]

**Story**:
As a DevOps engineer,
I need [CI/CD capability],
so that [deployment/monitoring goal].

**Tasks**:
- [ ] [Setup CI/CD pipeline]
- [ ] [Configure monitoring]
- [ ] [Add automation]

**Acceptance Criteria**:
- [ ] [Pipeline runs successfully]
- [ ] [Monitoring alerts work]
- [ ] [Automation verified]

**Definition of Done**:
- [ ] Pipeline/monitoring deployed
- [ ] Documentation updated
- [ ] Team trained on process
```

---

## Tracking System

Since JIRA is not available, we use a **file-based tracking system** in the project repository.

### Directory Structure

```
teamflow/
├── .agile-management/
│           ├── PROJECT_MANAGER_OVERVIEW.md (this file)
│           ├── templates/
│           │   ├── INFRA_BACKEND_STORY_TEMPLATE.md
│           │   └── ... (future templates)
│           ├── stories/
│           │   ├── STORY_1.1_INSTALL_TOOLS.md
│           │   └── ... (individual story files)
│           ├── epics/
│           │   ├── EPIC_1_SETUP.md
│           │   ├── EPIC_2_CORE_INFRASTRUCTURE.md
│           │   ├── EPIC_3_AUTHENTICATION.md
│           │   ├── EPIC_4_ORGANIZATIONS.md
│           │   └── ...
│           └── sprints/
│               ├── SPRINT_0_SETUP.md
│               ├── SPRINT_1_INFRASTRUCTURE.md
│               ├── SPRINT_2_AUTH_BACKEND.md
│               └── ...
```

### Epic Files

Each epic gets its own markdown file with:
- Epic overview
- All stories belonging to that epic
- Task checklists
- Acceptance criteria
- Progress tracking

**Example**: `EPIC_1_SETUP.md` contains all stories for development environment setup.

### Sprint Files

Each sprint gets a markdown file tracking:
- Sprint goal
- Stories committed to sprint
- Daily progress updates
- Blockers
- Retrospective notes

**Example**: `SPRINT_0_SETUP.md` tracks the initial setup sprint.

### Story Status Tracking

Stories use checkboxes for status:

```markdown
## Story: Setup AWS Account

**Status**: ✅ DONE

**Tasks**:
- [x] Create AWS account
- [x] Set up IAM user
- [x] Configure AWS CLI
- [x] Test: `aws sts get-caller-identity`

**Progress Notes**:
- 2026-01-22: Completed AWS setup, credentials configured
```

**Status Labels**:
- 📋 **TODO** - Not started
- 🚧 **IN PROGRESS** - Currently working on
- ⏸️ **BLOCKED** - Waiting on dependency or issue
- ✅ **DONE** - Completed and verified
- ❌ **CANCELLED** - No longer needed

---

## Sprint Planning

### Sprint Structure for Phases 1-2

**Sprint Duration**: 1 week (recommended for early stage)

**Sprint Composition**:
- Select 1 epic (or portion of epic) per sprint
- Break into 5-10 stories
- Each story: 1-3 days of work
- Account for learning time (new technologies)

### Sprint Planning Process

1. **Review Backlog**:
   - Check `epics/` directory for next priority epic
   - Ensure dependencies are met

2. **Select Stories**:
   - Choose stories from next epic
   - Verify all dependencies complete
   - Commit to realistic amount of work

3. **Create Sprint File**:
   - Create `sprints/SPRINT_X_NAME.md`
   - List committed stories
   - Define sprint goal
   - Set dates

4. **Daily Updates**:
   - Update story status in epic files
   - Note progress in sprint file
   - Flag blockers immediately

5. **Sprint Review**:
   - Demo completed work (API calls, deployed infrastructure, UI)
   - Update sprint file with what was accomplished
   - Move incomplete stories to next sprint

6. **Sprint Retrospective**:
   - What went well?
   - What didn't go well?
   - What will we improve next sprint?
   - Document in sprint file

### Example Sprint Breakdown (Phases 1-2)

**Sprint 0**: Setup (1-2 days)
- Epic 1: Development Environment Setup
- Goal: All verification checks pass
- Stories: 4 setup stories

**Sprint 1**: Core Infrastructure (1 week)
- Epic 2: Core Infrastructure
- Goal: Health check endpoint working
- Stories: 5 infrastructure stories

**Sprint 2**: Auth Backend (1 week)
- Epic 3.1: Authentication Infrastructure (Backend)
- Goal: Register/login APIs working
- Stories: 4 backend auth stories

**Sprint 3**: Auth Frontend (1 week)
- Epic 3.2: Authentication Infrastructure (Frontend)
- Goal: Complete auth flow in browser
- Stories: 3 frontend auth stories

**Sprint 4**: Organizations Backend (1 week)
- Epic 4.1: Multi-Tenant Foundation (Backend)
- Goal: Organization CRUD working
- Stories: 3 backend org stories

**Sprint 5**: Organizations Frontend (1 week)
- Epic 4.2: Multi-Tenant Foundation (Frontend)
- Goal: Users can create/switch workspaces
- Stories: 2 frontend org stories

---

## Key Principles for Early-Stage PM

### 1. Focus on Technical Enablement

Early sprints deliver **technical capabilities**, not user features:
- ✅ "DynamoDB table deployed and tested"
- ✅ "Cognito authentication working"
- ❌ "Users can collaborate on tasks" (too early)

### 2. Document Infrastructure Patterns

Every infrastructure story should result in:
- Working code/configuration
- Documentation of the pattern
- Tests or verification steps
- Reusable templates for future work

### 3. Multi-Tenant Testing from Day 1

Every data operation story should include:
- Creating test data for multiple organizations
- Verifying cross-tenant access prevention
- Testing with org1, org2, org3

### 4. Dependencies are Critical

Infrastructure has strict dependencies:
- DynamoDB must exist before Lambda can write to it
- Cognito must exist before auth endpoints work
- Backend APIs must exist before frontend can call them

**Always**:
- Document dependencies in story
- Verify dependencies before starting
- Don't start blocked stories

### 5. Definition of Done Matters

A story is NOT done until:
- Code written and working
- Deployed to dev environment
- Tested and verified
- Documented (if reusable pattern)

---

## Working with Roadmap

### Alignment with DEVELOPMENT_ROADMAP_SERVERLESS.md

The roadmap is the **source of truth** for:
- What phases exist
- What technologies to use
- What order to build in

**This project management system**:
- Breaks roadmap phases into epics
- Breaks epics into stories
- Organizes stories into sprints
- Tracks progress

### Updating Progress

As stories complete:
1. Mark tasks done in epic file: `- [x] Task`
2. Update story status: `📋 TODO` → `✅ DONE`
3. Check off items in DEVELOPMENT_ROADMAP_SERVERLESS.md
4. Update sprint file with progress

---

## Quick Reference

### Creating a New Epic

1. Copy epic template from `epics/EPIC_1_SETUP.md`
2. Create new file: `epics/EPIC_X_NAME.md`
3. Define epic goal, duration, phase
4. Break into stories using templates from `templates/` directory
5. List dependencies
6. Define acceptance criteria

### Creating a New Story

1. Copy appropriate template from `templates/` directory:
   - `INFRA_BACKEND_STORY_TEMPLATE.md` for infrastructure/backend work
   - (Future templates will be added here)
2. Create new file: `stories/STORY_X.Y_NAME.md`
3. Fill in all sections (Story ID, Epic, Sprint, Requirements, Acceptance Criteria)
4. Add verification commands where applicable
5. Link story to parent epic

### Creating a New Sprint

1. Create file: `sprints/SPRINT_X_NAME.md`
2. Define sprint goal and dates
3. List committed stories (copy from epic files)
4. Update daily with progress
5. Complete with review/retrospective notes

### Daily Workflow

**Morning**:
- Review yesterday's progress
- Update story status in epic files
- Identify any blockers

**During Day**:
- Work on in-progress stories
- Check off completed tasks

**End of Day**:
- Update sprint file with progress
- Note any issues or learnings

---

## Tools & Commands

### Markdown Checklist Usage

```markdown
- [ ] Unchecked (not done)
- [x] Checked (done)
```
---

## Next Steps

1. **Read**: EPIC_1_SETUP.md for detailed first epic breakdown
2. **Start**: Sprint 0 (Setup) following SETUP_GUIDE.md
3. **Track**: Update epic file as tasks complete
4. **Review**: Check progress daily, update sprint file

---

**Remember**: Keep it simple. The goal is to track progress and stay organized, not to create process overhead.
