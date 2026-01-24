# Story 1.1: Install Development Tools

**Story ID**: EPIC1-001
**Epic**: EPIC-1 (Development Environment Setup)
**Sprint**: SPRINT-0
**Status**: ✅ DONE

---

## User Story

```
As an infra-backend-expert,
I need Node.js, AWS CLI, CDKTF CLI, and Angular CLI installed,
so that I can build and deploy the TeamFlow application.
```

---

## Requirements

### Required Tools

1. **Node.js** - v20.x LTS or higher
2. **npm** - v10.x or higher (comes with Node.js)
3. **Git** - Any recent version
4. **AWS CLI** - v2.x
5. **CDKTF CLI** - Latest version
6. **Angular CLI** - v18.x

---

## Verification

Test each tool with these commands:

```bash
node --version          # Expected: v20.x+ (LTS)
npm --version           # Expected: 10.x+
git --version           # Expected: Any recent version
aws --version           # Expected: aws-cli/2.x
cdktf --version         # Expected: Latest (e.g., 0.20.x+)
ng version              # Expected: Angular CLI 18.x
```

## Acceptance Criteria

- [x] Node.js v20.x or higher installed ✅ v24.13.0
- [x] npm v10.x or higher installed ✅ v11.6.2
- [x] Git installed and configured with user name/email ✅ v2.52.0 (pedro30092@gmail.com)
- [x] AWS CLI v2.x installed ✅ v2.33.5
- [x] CDKTF CLI latest version installed ✅ v0.21.0
- [x] Angular CLI v18.x installed ✅ v21.1.1
- [x] All verification commands return expected versions ✅

---

## Definition of Done

- All 6 tools installed and verified
- Git configured with user credentials
- All acceptance criteria met
- Ready to proceed to Story 1.2

---

## Notes

**Installation Methods**:
- Node.js: Use `nvm` (recommended) or download from nodejs.org
- AWS CLI: Platform-specific (brew, apt, direct download)
- CDKTF: `npm install -g cdktf-cli@latest`
- Angular CLI: `npm install -g @angular/cli@18`

**Estimated Time**: 15-30 minutes

---

## Completion Notes

**Completed**: 2026-01-22 14:30 UTC
**Status**: All tools installed and verified successfully. ✅

---

**Last Updated**: 2026-01-22 14:30 UTC
