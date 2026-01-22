# TeamFlow Skills Organization

This document explains how skills are organized in this project.

## Directory Structure

```
teamflow/
├── research/
│   └── PRODUCT_OVERVIEW.md          # General project documentation
│                                      # (Referenced by skills)
└── .claude/
    ├── skills/
    │   ├── product-owner/
    │   │   └── SKILL.md              # Product Owner role
    │   ├── project-manager/
    │   │   └── SKILL.md              # Project Manager role
    │   └── README.md                 # This file
    └── prompt-templates/
        └── skill-loader.md           # How to use skills
```

## Design Principles

### 1. Separation of Concerns

**Project Documentation** (`research/`)
- General information about TeamFlow
- Accessible to all team members and skills
- Single source of truth for product details

**Skill Definitions** (`.claude/skills/`)
- How to act in a specific role
- References project documentation as needed
- Focused on behavior, not content

### 2. Skills Reference, Don't Duplicate

Following Claude Code best practices:
- Keep SKILL.md under 500 lines
- Reference supporting files explicitly
- Load detailed docs on-demand

**Example from product-owner skill:**
```markdown
For complete product details, see:
- [Product Overview](../../../research/PRODUCT_OVERVIEW.md)
```

### 3. When to Use Each Location

| Content Type | Location | Reason |
|--------------|----------|--------|
| Product specs, features, roadmaps | `research/` | General project docs |
| Market analysis, user personas | `research/` | Shared across roles |
| Technical architecture | `docs/` or `research/` | General reference |
| Role behavior & responsibilities | `.claude/skills/{role}/SKILL.md` | Skill-specific |
| Skill templates & examples | `.claude/skills/{role}/` | Supporting skill files |

## Current Skills

### product-owner
**Purpose**: Act as Product Owner focusing on user needs and business value

**References**:
- `research/PRODUCT_OVERVIEW.md` - Complete product details

**Usage**:
```bash
/product-owner create user stories for the calendar module
/product-owner explain teamflow to an investor
```

### project-manager
**Purpose**: Manage development execution, break down features into tasks, coordinate work

**References**:
- `research/PRODUCT_OVERVIEW.md` - Complete product details

**Usage**:
```bash
/project-manager break down the calendar module into development tasks
/project-manager create a task list for the MVP
/project-manager identify dependencies for user authentication
```

## Adding New Skills

When creating a new skill:

1. **Create skill directory**: `.claude/skills/{skill-name}/`
2. **Write SKILL.md**: Define role, responsibilities, constraints
3. **Reference existing docs**: Link to `research/` or other project docs
4. **Add supporting files** (if needed): examples, templates, scripts
5. **Update this README**: Document the new skill

## Examples

### Good: Reference General Docs
```markdown
For API conventions, see [API_STANDARDS.md](../../../docs/API_STANDARDS.md)
```

### Bad: Duplicate Content
```markdown
# API Standards
[Copying entire API standards document into skill...]
```

## Questions?

- **Should this go in research/ or skills/?** → If multiple roles/people need it, put it in research/
- **My SKILL.md is too long** → Extract detailed content to supporting files and reference them
- **Can skills reference each other?** → Yes, but prefer referencing shared project docs instead
