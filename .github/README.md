# .github Directory - GitHub Copilot Configuration

This directory contains instructions and context for working with GitHub Copilot on the TeamFlow project.

---

## Directory Structure

```
.github/
├── copilot-instructions.md      # Main Copilot guidelines
├── project-context.md            # Quick reference to project information
├── skills/                       # Role-based agent definitions
│   ├── product-owner.md
│   ├── project-manager.md
│   ├── software-architect.md
│   └── infra-backend-expert.md
├── references/                   # Technical reference docs
│   ├── aws-cli-reference.md
│   └── tmp-directory-convention.md
└── README.md                     # This file
```

---

## How to Use

### Start Here

**First Time Working with TeamFlow?**

1. Read [copilot-instructions.md](copilot-instructions.md) - Main guidelines
2. Check [project-context.md](project-context.md) - Quick links to everything
3. Review [../SETUP_GUIDE.md](../SETUP_GUIDE.md) - Set up your environment

### Working on a Task

**Choose the appropriate skill/agent based on your work**:

- **Defining Features?** → [skills/product-owner.md](skills/product-owner.md)
- **Breaking Down Work?** → [skills/project-manager.md](skills/project-manager.md)
- **Architecture Decisions?** → [skills/software-architect.md](skills/software-architect.md)
- **Writing Code?** → [skills/infra-backend-expert.md](skills/infra-backend-expert.md)

### Need Technical References?

- **AWS CLI Commands** → [references/aws-cli-reference.md](references/aws-cli-reference.md)
- **Temporary Files** → [references/tmp-directory-convention.md](references/tmp-directory-convention.md)

---

## Key Files Explained

### copilot-instructions.md

**Purpose**: Main instruction file for GitHub Copilot

**Contains**:
- General principles (work in steps, directories to skip)
- Temporary files convention
- AWS CLI operations guidelines
- Project structure and context
- Best practices for code, security, performance
- Links to skills and references

**When to Read**: Always - this is your primary reference

### project-context.md

**Purpose**: Quick navigation guide to all project documentation

**Contains**:
- Product overview and features
- Technical stack summary
- Links to detailed architecture docs
- Development roadmap overview
- Common questions and answers

**When to Read**: When you need to find specific documentation quickly

### skills/ (Agents)

**Purpose**: Role-based instructions for different types of work

**Four Agent Types**:

1. **product-owner.md**
   - Defines features from user perspective
   - Creates user stories with acceptance criteria
   - Prioritizes based on business value
   - Use when: Defining what to build and why

2. **project-manager.md**
   - Breaks features into tasks
   - Uses Agile/Scrum methodology
   - Tracks progress and dependencies
   - Use when: Organizing and planning work

3. **software-architect.md**
   - Makes architectural decisions
   - Defines technical patterns
   - Ensures system scalability and security
   - Use when: Designing system components or answering architecture questions

4. **infra-backend-expert.md**
   - Implements serverless architecture
   - Writes production-grade code
   - Deploys infrastructure with CDKTF
   - Use when: Writing code or deploying infrastructure

### references/

**Purpose**: Technical reference documentation for common operations

**Files**:
- **aws-cli-reference.md**: AWS CLI command examples
- **tmp-directory-convention.md**: Where to save temporary files

**When to Read**: When you need specific command syntax or conventions

---

## Important Rules

### Directories to Skip

Copilot must **NEVER** read these directories:
- ❌ `learning/` - Personal notes and experiments
- ❌ `scripts/` - Personal scripts
- ❌ `src/` - Not relevant for current phase

### Temporary Files

- ✅ **ALWAYS** save temporary files to `tmp/` directory
- ✅ **ALWAYS** use timestamped filenames
- ✅ **NEVER** commit `tmp/` contents to git

### AWS CLI Operations

- ✅ **ALWAYS** set `export AWS_PAGER=""`
- ✅ **ALWAYS** use `--profile teamflow-admin`
- ✅ **ALWAYS** save outputs to `tmp/` directory

---

## Quick Start Examples

### Example 1: Defining a New Feature

```
Task: Define a new feature for task assignments

Steps:
1. Reference: skills/product-owner.md
2. Create user story: "As a project manager, I want to assign tasks..."
3. Define acceptance criteria
4. Explain business value
```

### Example 2: Breaking Down a Feature into Tasks

```
Task: Break down authentication feature

Steps:
1. Reference: skills/project-manager.md
2. List technical components (database, API, UI)
3. Create task list with dependencies
4. Estimate effort
```

### Example 3: Implementing DynamoDB Access Pattern

```
Task: Implement project listing by organization

Steps:
1. Reference: skills/software-architect.md (for pattern design)
2. Reference: skills/infra-backend-expert.md (for implementation)
3. Design access pattern (PK=ORG#{id}, SK=PROJECT#{id})
4. Implement repository adapter
5. Test with multiple organizations
```

### Example 4: Using AWS CLI

```
Task: Check Lambda function logs

Steps:
1. Reference: references/aws-cli-reference.md
2. Set environment: export AWS_PAGER=""
3. Run command: aws logs tail /aws/lambda/FUNCTION_NAME --follow --profile teamflow-admin
4. Save output if needed: > tmp/logs-$(date +%Y%m%d-%H%M%S).txt
```

---

## Learning Path

**New to the Project?**

1. **Day 1: Setup & Context**
   - Complete [../SETUP_GUIDE.md](../SETUP_GUIDE.md)
   - Read [copilot-instructions.md](copilot-instructions.md)
   - Skim [project-context.md](project-context.md)

2. **Day 2: Product Understanding**
   - Read [../research/PRODUCT_OVERVIEW.md](../research/PRODUCT_OVERVIEW.md)
   - Review [skills/product-owner.md](skills/product-owner.md)

3. **Day 3: Architecture Understanding**
   - Read [../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md](../research/TECHNICAL_ARCHITECTURE_SERVERLESS.md)
   - Review [skills/software-architect.md](skills/software-architect.md)

4. **Day 4: Implementation Prep**
   - Review [../research/DEVELOPMENT_ROADMAP_SERVERLESS.md](../research/DEVELOPMENT_ROADMAP_SERVERLESS.md)
   - Study [skills/infra-backend-expert.md](skills/infra-backend-expert.md)

5. **Day 5+: Start Building**
   - Follow Phase 1 tasks from roadmap
   - Reference skills as needed
   - Use AWS CLI reference for operations

---

## Tips for Working with Copilot

### Be Specific with Context

**Good**:
```
Using the product-owner agent, create a user story for task assignment 
with acceptance criteria focused on user experience.
```

**Bad**:
```
Create a task assignment story.
```

### Reference the Right Skill

Match your work to the appropriate agent:
- **Defining features** → product-owner
- **Planning tasks** → project-manager
- **Designing systems** → software-architect
- **Writing code** → infra-backend-expert

### Use References for Syntax

Don't memorize commands - reference them:
- AWS CLI commands → aws-cli-reference.md
- File conventions → tmp-directory-convention.md

---

## Getting Help

**Where to Look**:

| Issue | Solution |
|-------|----------|
| Don't know what to build | Read product-owner.md + PRODUCT_OVERVIEW.md |
| Don't know how to organize work | Read project-manager.md |
| Don't understand architecture | Read software-architect.md + TECHNICAL_ARCHITECTURE_SERVERLESS.md |
| Don't know how to implement | Read infra-backend-expert.md + code examples |
| Need AWS command syntax | Check aws-cli-reference.md |
| Where to save temp files | Check tmp-directory-convention.md |

**Still Stuck?**
- Review error messages carefully
- Check relevant documentation in research/
- Consult AWS/CDKTF documentation
- Search for similar patterns in completed work

---

## Maintaining This Directory

**When to Update**:
- Architecture changes → Update software-architect.md
- New workflows → Update relevant skill files
- New AWS patterns → Update aws-cli-reference.md
- New conventions → Update copilot-instructions.md

**Keep It Current**: These files are living documentation. Update them as the project evolves.

---

**Ready to Start?** Begin with [copilot-instructions.md](copilot-instructions.md) and [project-context.md](project-context.md)!
