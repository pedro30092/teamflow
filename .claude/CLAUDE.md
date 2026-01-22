# Working with Claude - TeamFlow Project Guidelines

**Last Updated**: 2026-01-22

This document provides guidelines for effectively working with Claude Code on the TeamFlow project.

---

## General Principles

### 1. Work in Steps for Large Processes

**Rule**: When dealing with large, complex processes that involve multiple files or extensive documentation, always work in steps to avoid overwhelming Claude's token budget.

**Why**: Claude has a token limit per conversation. Breaking work into smaller steps:
- Prevents token exhaustion
- Allows for better focus on each subtask
- Makes it easier to review and iterate
- Reduces context switching

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
*Problem*: This would consume too many tokens and risk incomplete work.

**✅ Good Approach** (step-by-step):
```
Step 1: Create PROJECT_MANAGER_OVERVIEW.md with general structure
Step 2: Create EPIC_1_SETUP.md with detailed breakdown
Step 3: Create EPIC_2_CORE_INFRASTRUCTURE.md (next session)
Step 4: Create sprint templates (when needed)
```
*Benefit*: Each step is complete, reviewable, and doesn't exhaust tokens.

### 2. Directories to Always Skip

**CRITICAL RULE**: Claude must NEVER read, review, or reference the `learning/` directory or any of its nested content.

**What Claude CANNOT do**:
- ❌ **NEVER read files** inside `learning/` or any subdirectory
- ❌ **NEVER search** within the `learning/` directory
- ❌ **NEVER reference** content from `learning/` in responses
- ❌ **NEVER use** ideas or concepts from `learning/` files

**What Claude CAN do**:
- ✅ Acknowledge that `learning/` exists if asked
- ✅ Explain that it's excluded from Claude's scope

**Rationale**: The `learning/` directory contains personal ideas, notes, and experimental concepts that are not relevant to Claude's tasks. Reading this content can:
- Cause confusion about project requirements
- Mix personal ideas with actual project specifications
- Lead to incorrect assumptions about the codebase
- Waste tokens on irrelevant content

**Excluded Paths**:
```
learning/           # Skip entirely
learning/**/*       # All nested files and folders
```

---

## Requesting Work from Claude

### Format for Large Requests

When you need Claude to do substantial work, structure your request like this:

```
Let's do this by steps:

Step 1: [First clear task]
Step 2: [Second clear task]
Step 3: [Third clear task]

For this session, please complete Step 1 only.
We'll do the remaining steps in follow-up sessions.
```

### Format for Clarifying Scope

If unsure about scope, let Claude know:

```
This is a large task. Please:
1. Break it down into logical steps
2. Estimate token usage for each step
3. Suggest which steps to do together and which to separate
4. Complete the first step only
```

---

## Claude's Response Pattern

When working step-by-step, Claude should:

1. **Acknowledge the step-by-step approach**
   - Confirm which step is being worked on
   - Note what will be deferred to later steps

2. **Complete the current step fully**
   - Don't leave placeholders for future steps
   - Finish what's in scope for this step

3. **Provide clear next steps**
   - Tell you what Step 2, 3, etc. will involve
   - Estimate if they can be done together or need separate sessions

---

## Project-Specific Guidelines

### Epic and Story Creation

**Approach**: Create one epic file at a time

**Process**:
1. Session 1: Create PROJECT_MANAGER_OVERVIEW.md (general structure)
2. Session 2: Create EPIC_1_SETUP.md (detailed first epic)
3. Session 3: Create EPIC_2_CORE_INFRASTRUCTURE.md
4. Session 4: Create EPIC_3_AUTHENTICATION.md
5. And so on...

**Rationale**: Each epic file is substantial (500-1000 lines). Creating them separately:
- Keeps token usage manageable
- Allows for review and feedback between epics
- Enables iterating on the format based on first epic

### Infrastructure Development

**Approach**: Deploy one stack at a time

**Process**:
1. Session 1: Create and deploy DatabaseStack (DynamoDB)
2. Session 2: Create and deploy ApiStack (API Gateway)
3. Session 3: Create and deploy AuthStack (Cognito)
4. Review and test before proceeding

**Rationale**: Infrastructure has dependencies. Deploying incrementally:
- Verifies each piece works before building on it
- Easier to debug issues
- Avoids large rollbacks

### Feature Development

**Approach**: Complete one layer at a time (backend → frontend)

**Process**:
1. Session 1: Backend domain layer (entities, ports)
2. Session 2: Backend use cases and adapters
3. Session 3: Lambda handlers and deployment
4. Session 4: Frontend NgRx store
5. Session 5: Frontend components and pages

**Rationale**: Completing backend first:
- Frontend can call working APIs
- Easier to test end-to-end
- Clear separation of concerns

---

## Token Management Tips

### For Users

**Check token usage**:
- Claude will show warnings when tokens are running low
- If warned, wrap up current work and start new session

**Start fresh when**:
- Beginning a new epic or major feature
- Switching between unrelated tasks
- Previous session context no longer needed

**Continue session when**:
- Iterating on same file
- Debugging recent changes
- Building on just-completed work

### For Claude

**Be mindful of**:
- Reading large files repeatedly (use Read tool sparingly)
- Generating very long files (break into sections if needed)
- Extensive code generation (focus on one feature at a time)

**Optimize by**:
- Referencing previous work without re-reading files
- Using concise explanations
- Focusing on current step only

---

## Communication Style

### Asking Questions

**Clear and Specific**:
✅ "Create EPIC_2_CORE_INFRASTRUCTURE.md with the same structure as EPIC_1_SETUP.md, covering the 5 stories from Phase 1 Week 1 of the roadmap"

❌ "Make the next epic file"

**Provide Context**:
✅ "Following the same format we used for Epic 1, create Epic 2 which covers DynamoDB setup, IAM roles, Lambda layers, API Gateway, and health check endpoint"

❌ "Do Epic 2"

### Reviewing Work

**Specific Feedback**:
✅ "In EPIC_1_SETUP.md, Story 1.2, add a task for testing the AWS CLI configuration"

❌ "Add more details"

---

## Git & Version Control

### Committing Changes

**CRITICAL RULE**: Claude should NEVER create commits automatically.

**What Claude CANNOT do**:
- ❌ **NEVER run `git commit`** unless explicitly requested by the user
- ❌ **NEVER run `git add` followed by `git commit`**
- ❌ **DO NOT commit** after completing tasks, even if it seems helpful
- ❌ **DO NOT run `git push`** unless explicitly requested
- ❌ **NO destructive git operations** (`reset --hard`, `push --force`, etc.) without explicit permission

**What Claude CAN do**:
- ✅ Run `git status` to check repository state
- ✅ Run `git diff` to show changes
- ✅ Run `git log` to view history
- ✅ Run `git branch` to see branches
- ✅ Suggest what should be committed
- ✅ Draft commit messages for user review

**Rationale**: The user wants full control over when commits are made, what is committed, and what commit messages are used. Claude should focus on completing work and let the user handle version control.

**Correct Workflow**:
```
1. Claude completes a task (creates/edits files)
2. Claude summarizes what was done
3. User decides when to commit
4. User runs git commands manually OR explicitly asks Claude to commit
```

---

## File Organization

### Keep Related Files Together

**Project Management**:
```
.claude/skills/project-manager/
├── PROJECT_MANAGER_OVERVIEW.md (general guide)
├── epics/
│   ├── EPIC_1_SETUP.md (detailed)
│   ├── EPIC_2_CORE_INFRASTRUCTURE.md (detailed)
│   └── ...
└── sprints/
    ├── SPRINT_0_SETUP.md
    └── ...
```

**Why**: Easy to find related content, maintains organization

### Use Descriptive Names

✅ Good:
- `EPIC_1_SETUP.md`
- `PROJECT_MANAGER_OVERVIEW.md`
- `SPRINT_0_SETUP.md`

❌ Bad:
- `epic1.md`
- `pm.md`
- `sprint.md`

---

## Examples of Effective Collaboration

### Example 1: Creating Documentation

**User Request**:
```
Let's create the project management documentation system:

Step 1: Create PROJECT_MANAGER_OVERVIEW.md with the general structure,
        story templates, and tracking system approach

Step 2: Create detailed EPIC_1_SETUP.md based on the SETUP_GUIDE.md

For this session, complete Step 1 and Step 2.
Other epic files will be created in future sessions.
```

**Claude Response**:
```
I'll create both files in this session:

1. PROJECT_MANAGER_OVERVIEW.md - General PM approach
2. EPIC_1_SETUP.md - Detailed breakdown of setup stories

The remaining epic files (EPIC_2, EPIC_3, etc.) should be
created in separate sessions to manage token usage effectively.

[Creates both files with full detail]

Next steps for future sessions:
- Create EPIC_2_CORE_INFRASTRUCTURE.md
- Create EPIC_3_AUTHENTICATION.md
- Create sprint template files as needed
```

### Example 2: Infrastructure Development

**User Request**:
```
Let's implement Phase 1 Week 1 infrastructure:

Step 1: Create and deploy DatabaseStack with DynamoDB table
Step 2: Create and deploy IAM roles for Lambda
Step 3: Set up Lambda layers structure

Let's do Step 1 in this session. We'll tackle Steps 2 and 3 after
we verify the database is working.
```

**Claude Response**:
```
I'll focus on Step 1: DatabaseStack with DynamoDB.

[Creates infrastructure/stacks/database-stack.ts]
[Updates infrastructure/main.ts]
[Provides deployment instructions]
[Includes verification steps]

After deploying and verifying the database works, we can proceed
to Step 2 (IAM roles) in the next session.
```

---

## Troubleshooting

### "I'm running out of tokens"

**Solution**:
- Complete current file/task
- Provide summary of what was done
- Start fresh session for next step

### "The file is too large to create in one go"

**Solution**:
- Break into sections
- Create file with structure/overview first
- Fill in details in follow-up requests

### "I need to reference a large file"

**Solution**:
- Read file once at start of session
- Reference specific sections by line number
- Avoid re-reading entire file repeatedly

---

## Quick Reference

### Starting a Session

1. State the goal clearly
2. Break into steps if needed
3. Specify what to do in THIS session
4. Provide relevant context

### During a Session

1. Focus on current step
2. Complete tasks fully (no placeholders)
3. Test/verify as you go
4. Document as you work

### Ending a Session

1. Summarize what was completed
2. List any follow-up tasks
3. Note what's ready for next session
4. User decides if/when to commit (Claude does NOT commit)

---

## Summary

**Key Takeaway**: When working on large processes, always break them into logical steps. Complete each step fully before moving to the next. This approach:

- Prevents token exhaustion
- Produces better quality work
- Allows for iteration and feedback
- Maintains clear project organization

**Remember**: It's better to complete 1-2 things fully than to partially complete 5 things.

---

**Questions or Issues?**

If you encounter challenges working with Claude on this project:
1. Review this document
2. Break your request into smaller steps
3. Provide clear context and examples
4. Reference existing patterns in the project
