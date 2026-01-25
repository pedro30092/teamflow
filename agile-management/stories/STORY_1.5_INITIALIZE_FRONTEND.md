# Story 1.5: Initialize Frontend (Angular)

**Story ID**: EPIC1-005
**Epic**: EPIC-1 (Development Environment Setup)
**Sprint**: SPRINT-0
**Status**: ✅ DONE

---

## User Story

```
As a developer,
I need an Angular 18 project initialized,
so that I can build the TeamFlow SPA.
```

---

## Requirements

1. **Angular 21 + CLI 21** scaffolded with `ng new frontend`
2. **TypeScript 5.9 strict** (defaults kept)
3. **Routing configured** (default from `ng new --routing`)
4. **Default starter app** renders and serves locally
5. **Build scripts** (`ng serve`, `ng build`) succeed on this machine

---

## Tasks

### Task 1: Verify Angular scaffold and versions

```bash
cd /home/pedro/Personal/development/teamflow/src/frontend
ng version  # Expect Angular CLI ~21.1, Angular ~21.1, TS ~5.9
```

---

### Task 2: Confirm TypeScript strict defaults

Open `src/frontend/tsconfig.json` and ensure the generated strict options remain enabled (they already are: `strict`, `noImplicitOverride`, `target: ES2022`).

---

### Task 3: Run dev server (default app)

```bash
cd /home/pedro/Personal/development/teamflow/src/frontend
ng serve
# Browser: http://localhost:4200 shows the Angular starter page
```

---

### Task 4: Run production build

```bash
npm run build  # Expect dist/frontend/ created, no errors
```

---

## Verification

```bash
cd src/frontend

ng version                    # Expected: Angular CLI ~21.1
ng serve                      # Expected: http://localhost:4200 starter page renders
npm run build                 # Expected: dist/ created, no errors
```

**Browser check:**
- Navigate to http://localhost:4200
- Verify Angular starter page renders without console errors

---

## Acceptance Criteria

- [x] Angular 21 project present in `src/frontend/`
- [x] `ng serve` starts dev server successfully (starter page renders)
- [x] `npm run build` completes without errors
- [x] TypeScript strict mode enabled (defaults kept)

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

**Last Updated**: 2026-01-25
