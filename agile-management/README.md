# Project Management Tracking System

**TeamFlow - File-Based Agile/Scrum Tracking**

This directory contains the project management system for TeamFlow, organized using a file-based approach (no JIRA required).

---

## Directory Structure

```
project-manager/
├── README.md                       # This file - system overview
├── PROJECT_MANAGER_OVERVIEW.md     # Complete PM methodology guide
├── epics/                          # Epic breakdown files
│   ├── EPIC_1_SETUP.md
│   ├── EPIC_2_CORE_INFRASTRUCTURE.md
│   ├── EPIC_3_AUTHENTICATION.md
│   └── ...
└── sprints/                        # Sprint tracking files
    ├── SPRINT_0_SETUP.md
    ├── SPRINT_1_INFRASTRUCTURE.md
    └── ...
```

---

## Quick Start

### For Project Managers

1. **Read**: [PROJECT_MANAGER_OVERVIEW.md](PROJECT_MANAGER_OVERVIEW.md) for complete methodology
2. **Review**: [epics/EPIC_1_SETUP.md](epics/EPIC_1_SETUP.md) for epic file format
3. **Start**: Create sprint file for current sprint using template
4. **Track**: Update epic and sprint files as work progresses

### For Developers

1. **Check**: Current sprint file in `sprints/` directory
2. **Pick**: A story from the sprint backlog
3. **Update**: Mark tasks as done in the epic file
4. **Complete**: Update story status when finished

---

## How to Use This System

### Planning a Sprint

1. Review next epic in `epics/` directory
2. Select stories for sprint (usually 5-10 stories)
3. Create sprint file: `sprints/SPRINT_X_NAME.md`
4. List committed stories and sprint goal

### During Sprint

1. **Daily**: Update story progress in epic files
2. **Mark tasks**: Change `- [ ]` to `- [x]` as tasks complete
3. **Update status**: Change story status from 📋 TODO → 🚧 IN PROGRESS → ✅ DONE
4. **Track blockers**: Note issues in sprint file

### Completing Sprint

1. Mark all completed stories as ✅ DONE in epic files
2. Add retrospective notes to sprint file
3. Create next sprint file with remaining/new stories

---

## File Format Standards

### Epic Files

Each epic file contains:
- Epic overview (goal, duration, success criteria)
- All stories belonging to that epic
- Detailed task breakdowns
- Acceptance criteria
- Progress tracking

**Naming**: `EPIC_[NUMBER]_[NAME].md`
**Example**: `EPIC_1_SETUP.md`

### Sprint Files

Each sprint file contains:
- Sprint goal and dates
- Committed stories (referenced from epics)
- Daily progress notes
- Blocker tracking
- Retrospective

**Naming**: `SPRINT_[NUMBER]_[NAME].md`
**Example**: `SPRINT_0_SETUP.md`

---

## Status Labels

Use these emojis to mark status:

| Emoji | Status | Meaning |
|-------|--------|---------|
| 📋 | TODO | Not started |
| 🚧 | IN PROGRESS | Currently working on |
| ⏸️ | BLOCKED | Waiting on dependency or issue |
| ✅ | DONE | Completed and verified |
| ❌ | CANCELLED | No longer needed |

**In Epic Files**:
```markdown
## Story 1.1: Install Development Tools

**Story ID**: EPIC1-001
**Status**: ✅ DONE

**Tasks**:
- [x] Install Node.js 20.x
- [x] Install AWS CLI v2
- [x] Verify installations
```

**In Sprint Files**:
```markdown
## Stories in Sprint

- ✅ EPIC1-001: Install Development Tools (DONE)
- 🚧 EPIC1-002: Configure AWS Account (IN PROGRESS)
- 📋 EPIC1-003: Initialize Project Structure (TODO)
```

---

## Workflow Examples

### Example 1: Starting a New Epic

```bash
# 1. Create new epic file
cd epics/
cp EPIC_1_SETUP.md EPIC_2_CORE_INFRASTRUCTURE.md

# 2. Edit file with epic details
# - Update epic overview
# - Add stories
# - Define acceptance criteria

# 3. Commit to Git
git add EPIC_2_CORE_INFRASTRUCTURE.md
git commit -m "docs: add Epic 2 - Core Infrastructure"
```

### Example 2: Working on a Story

```bash
# 1. Open relevant epic file
code epics/EPIC_1_SETUP.md

# 2. Find your story (e.g., Story 1.2: Configure AWS Account)

# 3. Mark tasks as you complete them:
#    Change: - [ ] Create AWS account
#    To:     - [x] Create AWS account

# 4. When all tasks done, update status:
#    Change: **Status**: 📋 TODO
#    To:     **Status**: ✅ DONE

# 5. Commit progress
git add epics/EPIC_1_SETUP.md
git commit -m "chore: complete Story 1.2 - AWS account setup"
```

### Example 3: Running a Sprint

```bash
# Sprint Planning (start of sprint)
cd sprints/
cp SPRINT_0_SETUP.md SPRINT_1_INFRASTRUCTURE.md
# Edit file: add goal, dates, committed stories

# Daily Updates (during sprint)
# Update epic files as tasks complete
# Add notes to sprint file about progress/blockers

# Sprint Review (end of sprint)
# Add "What was completed" section to sprint file
# Add retrospective notes

# Commit sprint record
git add sprints/SPRINT_1_INFRASTRUCTURE.md
git commit -m "docs: complete Sprint 1 retrospective"
```

---

## Checking Progress

### View All Epics

```bash
ls -l epics/
```

### View Current Sprint

```bash
cat sprints/SPRINT_X_NAME.md
```

### Count Completed Stories

```bash
# In a specific epic
grep "Status.*DONE" epics/EPIC_1_SETUP.md

# Across all epics
grep -r "Status.*DONE" epics/ | wc -l
```

### See All Blockers

```bash
grep -r "BLOCKED" epics/
grep -r "BLOCKED" sprints/
```

---

## Integration with Development

### Linking to Code

Reference story IDs in commit messages:

```bash
git commit -m "feat: implement DynamoDB repository [EPIC2-004]"
git commit -m "fix: handle auth token expiry [EPIC3-005]"
```

### Linking to Issues

If using GitHub Issues later, reference stories:

```markdown
Issue #42: Auth guard not redirecting to login

**Related Story**: EPIC3-004 (Auth Guard implementation)
**Epic File**: epics/EPIC_3_AUTHENTICATION.md
```

---

## Tips for Success

### For Effective Tracking

✅ **Do**:
- Update story status immediately when work is done
- Mark tasks as complete as you go (don't batch)
- Note blockers as soon as they occur
- Commit epic file updates to Git regularly
- Write retrospective notes while fresh

❌ **Don't**:
- Leave stories in IN PROGRESS for days
- Skip updating task checkboxes
- Forget to mark epics as DONE when complete
- Let sprint files become stale

### For Team Collaboration

- **Daily Standup**: Everyone reviews sprint file, updates their stories
- **Sprint Planning**: Review next epic file together, commit to stories
- **Sprint Review**: Demo completed stories, check epic file for acceptance criteria
- **Retrospective**: Add notes to sprint file collaboratively

---

## Maintenance

### Weekly

- Update story statuses
- Check for blockers
- Review sprint progress

### End of Sprint

- Complete sprint retrospective
- Mark epic as DONE if all stories complete
- Create next sprint file

### Monthly

- Review all epic statuses
- Archive completed epics (move to `archive/` folder if desired)
- Update PROJECT_MANAGER_OVERVIEW.md if process changes

---

## Migration to JIRA (Future)

If you later get access to JIRA:

1. **Import epics**: Each epic file becomes a JIRA Epic
2. **Import stories**: Each story becomes a JIRA Story
3. **Preserve IDs**: Use epic/story IDs as reference in JIRA
4. **Keep files**: Maintain as documentation even after JIRA import

---

## Resources

- **PM Methodology**: [PROJECT_MANAGER_OVERVIEW.md](PROJECT_MANAGER_OVERVIEW.md)
- **Example Epic**: [epics/EPIC_1_SETUP.md](epics/EPIC_1_SETUP.md)
- **Roadmap Reference**: [../../../research/DEVELOPMENT_ROADMAP_SERVERLESS.md](../../../research/DEVELOPMENT_ROADMAP_SERVERLESS.md)
- **Setup Guide**: [../../../SETUP_GUIDE.md](../../../SETUP_GUIDE.md)

---

## Questions?

This system is designed to be simple and flexible. If you need to adjust the format or add new tracking mechanisms, update this README and PROJECT_MANAGER_OVERVIEW.md accordingly.

**Remember**: The goal is to track progress and stay organized, not to create process overhead. Keep it simple!
