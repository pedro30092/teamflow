# Story 1.5: Initialize Frontend (Angular)

**Story ID**: EPIC1-005
**Epic**: EPIC-1 (Development Environment Setup)
**Sprint**: SPRINT-0
**Status**: 📋 TODO

---

## User Story

```
As a developer,
I need an Angular 18 project initialized,
so that I can build the TeamFlow SPA.
```

---

## Requirements

1. **Angular 21 + CLI 21** - Standalone by default, npm@11.6.2
2. **TypeScript 5.9 strict** - Strict mode kept on
3. **Routing configured** - Ready for feature modules
4. **Environment files** - Development and production configs
5. **Build scripts** - Compile and serve functionality

---

## Tasks

### Task 1: Create Angular Project

```bash
cd /home/pedro/Personal/development/teamflow/src
ng new frontend --routing --style=css --ssr=false --standalone
cd frontend
ng version  # Verify Angular CLI ~21.1
```

---

### Task 2: Configure TypeScript

Edit `src/frontend/tsconfig.json` (keep defaults, ensure):
- `strict: true`
- `target: ES2022`
- `moduleResolution: bundler`

---

### Task 3: Create Environment Config

Create `src/frontend/src/environments/`:
- `environment.development.ts` - apiUrl: http://localhost:3000
- `environment.ts` - apiUrl: https://api.teamflow.com

---

### Task 4: Update App Component

Edit `src/frontend/src/app/app.component.ts`:
- Import RouterOutlet (standalone)
- Add basic template for verification
- Test displays "TeamFlow - MVP"

---

### Task 5: Configure .gitignore

Add Angular-specific ignores:
```
/dist
/tmp
/.angular/cache
.env
.env.local
```

---

## Verification

```bash
cd src/frontend

ng version                    # Expected: Angular CLI ~21.1
ng serve                      # Expected: http://localhost:4200
npm run build                 # Expected: dist/ created, no errors
```

**Browser check:**
- Navigate to http://localhost:4200
- Verify "TeamFlow - MVP" displays
- No console errors

---

## Acceptance Criteria

- [ ] Angular 21 project created in `src/frontend/`
- [ ] `ng serve` starts dev server successfully
- [ ] App component displays in browser
- [ ] `npm run build` completes without errors
- [ ] Environment configuration files created
- [ ] TypeScript strict mode enabled
- [ ] `.gitignore` configured

---

## Definition of Done

- [ ] Development server runs locally
- [ ] Production build succeeds
- [ ] All verification checks pass
- [ ] Ready for Phase 1 (NgRx, auth, components)

---

## Notes

**Development workflow:**
```bash
ng serve           # Start dev server
ng generate component <path>  # Create component
npm run build      # Production build
```

**Estimated Time**: 30-45 minutes

---

**Last Updated**: 2026-01-24
