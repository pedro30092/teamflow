# Story 2.4: Multi-Level Tree Navigation Menu

**Epic**: Epic 2 - UI Foundation  
**Story ID**: STORY-2.4  
**Status**: 📋 Ready for Development  
**Priority**: MUST-HAVE  
**Estimated Effort**: 6-8 hours

---

## User Story

**As a** TeamFlow user navigating complex feature hierarchies,  
**I want** to expand and collapse menu sections to reveal sub-items and navigate to specific pages,  
**So that** I can find features intuitively without overwhelming the UI with a flat menu.

---

## Why This Matters

### Business Value
- **Information Architecture**: Hierarchical menu scales to support Workspaces → Projects → Tasks without flat, cluttered navigation
- **Familiar Pattern**: Users from Slack, Jira, Monday.com expect expandable menu sections
- **Scalability**: Foundation ready for Calendar and Time Tracking modules as sub-sections
- **User Control**: Expanding only relevant sections keeps cognitive load low
- **Professional UX**: Nested menus with expand/collapse is standard SaaS pattern

### User Impact
- **Power Users** (Sarah managing 50+ projects): Can expand Projects section to see specific projects without scrolling
- **New Users**: Expandable sections feel less overwhelming than flat lists
- **Mobile Users**: Hierarchical structure saves space better than flat alternative

### Product Vision Alignment
✅ **Simplicity**: Hide complexity in collapsible sections (users expand only what they need)  
✅ **Scalable**: Menu structure ready for 100+ items without UI redesign  
✅ **Familiar**: Standard pattern from competitors (reduces learning curve)

---

## Acceptance Criteria

### Must-Have (MVP)

#### Menu Structure & Content
- [ ] **3-Level Hierarchy**: Menu supports parent → child → grandchild nesting (3 levels)
- [ ] **Static Test Data**: Implement with Lorem Ipsum-style naming (not real data)
  - Level 1: "Modules" (e.g., Dashboard, Workspace, Settings)
  - Level 2: "Features" (e.g., Projects, Members, Calendar)
  - Level 3: "Items" (e.g., Project A, Project B, Team Calendar)
- [ ] **Expandable Sections**: Parent items with children show expand/collapse icon
- [ ] **Leaf Navigation**: Grandchild (Level 3) items are clickable links → route to SPA pages
- [ ] **Non-Leaf Items**: Parent and Level 2 items expand/collapse on click (not navigate)

#### Visual Design & Interaction
- [ ] **Material Expansion Panel or Custom Tree**: Use Material or custom component (decision per developer)
- [ ] **Expand/Collapse Icon**: Chevron or arrow icon rotates on expand (visual feedback)
- [ ] **Indentation**: Each level indented further (visual hierarchy)
  - Level 1: No indent (0px)
  - Level 2: 20-30px indent
  - Level 3: 40-60px indent
- [ ] **Smooth Animation**: Expand/collapse animates smoothly (~200ms)
- [ ] **Active Route Highlighting**: Current route (leaf item) highlighted in menu
- [ ] **Hover States**: Menu items have hover effect (darker background or highlight)

#### Routing & Navigation
- [ ] **Router Configuration**: Angular routes configured for each menu path
  - Example routes:
    - `/dashboard` → Dashboard Home
    - `/workspace/settings` → Workspace Settings
    - `/projects` → Projects Overview
    - `/projects/:id` → Specific Project
- [ ] **Route Parameters**: Leaf items pass route parameters to components
- [ ] **Active Link Indicator**: Current route item shows as active in menu
- [ ] **Navigation Works**: Clicking leaf item navigates to correct page, menu updates

#### State Management
- [ ] **Expand/Collapse State**: Stores which sections are expanded (during session)
- [ ] **Active Route State**: Tracks current route and highlights matching menu item
- [ ] **Menu Updates**: Menu reflects route changes when navigating

#### Responsive Behavior
- [ ] **Desktop**: Full menu visible with all nesting levels
- [ ] **Tablet** (768px-1024px): Menu adapts to available space
- [ ] **Mobile**: Menu overlays content (from Story 2.3), all nesting levels accessible
- [ ] **No Overflow**: Long menu item names don't break layout (text truncation or wrap)

### Edge Cases & Error Handling
- [ ] **Deep Clicking**: Rapidly expanding/collapsing doesn't break state
- [ ] **Long Item Names**: Menu item text with 50+ characters doesn't overflow
- [ ] **Many Items**: 20+ items in single section remains scrollable within menu
- [ ] **Missing Routes**: Clicking non-existent route shows 404 (graceful error)

---

## User Scenarios

### Scenario 1: User Explores Menu Structure
**Context**: Sarah opens TeamFlow and wants to understand available features

**Steps**:
1. Menu is open (from Story 2.3)
2. Sarah sees 3-4 top-level items with chevron icons (expandable)
3. Sarah clicks "Projects" to expand it
4. Sub-menu appears below "Projects" (indented)
5. Sarah sees "Project A", "Project B", "Create Project" items
6. Sarah clicks "Project A" 
7. Menu closes/updates, page navigates to Project A detail view

**Expected Outcome**:
- Expanding "Projects" reveals 2nd-level items
- Clicking "Project A" navigates to `/projects/project-a` page
- Menu item "Project A" is highlighted as active
- Chevron icon for "Projects" points down (expanded state)

**What Success Looks Like**: Sarah understands menu structure and navigates intuitively

---

### Scenario 2: User Navigates with Deep Nesting
**Context**: Sarah wants to access a specific task in a specific project

**Steps**:
1. Sarah expands "Projects" → shows Project A, B, C
2. Sarah clicks "Project A" → expands to show 2nd level
3. Sarah sees nested items: "Tasks", "Settings", "Members"
4. Sarah clicks "Tasks" → expands to show 3rd level
5. Sarah sees "Task 1", "Task 2", "Task 3"
6. Sarah clicks "Task 2" → navigates to Task 2 detail page

**Expected Outcome**:
- Each click expands correct level
- 3 levels of indentation visible
- Final click (Task 2) navigates to page
- Active menu item (Task 2) is highlighted

**What Success Looks Like**: User can navigate deep hierarchies without confusion

---

### Scenario 3: User Collapses Section to Hide Items
**Context**: Sarah is working on a task but accidentally expands the Projects menu

**Steps**:
1. "Projects" menu is currently expanded
2. Sarah clicks the expanded "Projects" item again
3. Sub-menu collapses
4. Menu returns to cleaner, less cluttered view

**Expected Outcome**:
- Expanded menu collapses smoothly
- Chevron icon rotates to closed position
- Child items disappear
- Active route item remains highlighted when relevant

**What Success Looks Like**: User has control and can manage menu clutter

---

### Scenario 4: User Navigates to Route Directly (from URL)
**Context**: Sarah pastes URL from slack message: `teamflow.app/projects/project-a/tasks/task-2`

**Steps**:
1. URL loads directly (no menu navigation)
2. Page renders Task 2 content
3. Menu automatically expands to show the active route

**Expected Outcome**:
- Menu expands "Projects" → "Project A" → "Tasks"
- Menu item "Task 2" is highlighted as active
- Menu reflects current location without user clicking

**What Success Looks Like**: Menu state syncs with URL (deep linking works)

---

## Success Metrics

### User Experience
- **Intuitive Navigation**: 100% of test users can navigate 3 levels without instruction
- **Visual Clarity**: Users immediately understand which items expand vs. navigate
- **Performance**: Expand/collapse animation feels instant (<200ms)
- **Pattern Recognition**: Users familiar with Slack/Jira/Monday immediately understand menu

### Technical
- **Route Sync**: Menu always reflects current route
- **Expand Performance**: Expanding 10+ nested items remains smooth
- **Mobile Responsiveness**: Menu overlays correctly on mobile
- **No Memory Leaks**: Expand/collapse 100 times doesn't degrade performance

### Business
- **Reduced Support**: No "How do I navigate to...?" questions
- **Feature Discoverability**: Menu structure naturally guides users to features
- **Scalability**: Structure supports 100+ menu items without redesign

---

## Menu Structure Specification

### Recommended Test Data Structure

```
📋 Dashboard
└─ (Leaf) Routes to: /dashboard

📁 Workspaces
├─ 🏢 Workspace Alpha
│  ├─ 📊 Projects
│  │  ├─ 🎯 Project Omega (Leaf → /workspaces/alpha/projects/omega)
│  │  ├─ 🎯 Project Beta (Leaf → /workspaces/alpha/projects/beta)
│  │  └─ ➕ Create Project (Leaf → /workspaces/alpha/projects/create)
│  ├─ 👥 Members
│  │  └─ 🔗 Manage Members (Leaf → /workspaces/alpha/members)
│  └─ ⚙️ Settings
│     └─ 🔗 Workspace Settings (Leaf → /workspaces/alpha/settings)
├─ 🏢 Workspace Beta
│  ├─ 📊 Projects
│  │  ├─ 🎯 Project Delta (Leaf → /workspaces/beta/projects/delta)
│  │  └─ ➕ Create Project (Leaf → /workspaces/beta/projects/create)
│  └─ 👥 Members
│     └─ 🔗 Manage Members (Leaf → /workspaces/beta/members)
└─ ➕ Create Workspace (Leaf → /workspaces/create)

📅 Modules (Future)
├─ 📆 Calendar
│  └─ 🔗 Team Calendar (Leaf → /modules/calendar)
└─ ⏱️ Time Tracking
   └─ 🔗 My Timesheets (Leaf → /modules/timesheets)

⚙️ Settings
└─ 🔗 Account Settings (Leaf → /settings/account)
```

### Alternative Simpler Structure (Lorem Ipsum)

```
📌 Module One
├─ Feature A
│  ├─ Lorem Item 1 (Leaf → /module-one/feature-a/item-1)
│  └─ Lorem Item 2 (Leaf → /module-one/feature-a/item-2)
└─ Feature B
   └─ Lorem Item 3 (Leaf → /module-one/feature-b/item-3)

📌 Module Two
├─ Feature C
│  ├─ Lorem Item 4 (Leaf → /module-two/feature-c/item-4)
│  └─ Lorem Item 5 (Leaf → /module-two/feature-c/item-5)
└─ Feature D
   └─ Lorem Item 6 (Leaf → /module-two/feature-d/item-6)

📌 Module Three
└─ Feature E
   └─ Lorem Item 7 (Leaf → /module-three/feature-e/item-7)
```

**Recommendation**: Use simpler structure with numbered/lorem naming for MVP clarity.

---

## Technical Notes (For Frontend Developer)

### Component Architecture

**Option 1: Angular Material Expansion Panel (Recommended)**
```typescript
// Use MatExpansionModule for built-in expand/collapse behavior
import { MatExpansionModule } from '@angular/material/expansion';
import { MatIconModule } from '@angular/material/icon';
import { RouterModule } from '@angular/router';

// Recursive component for tree structure
@Component({
  selector: 'app-menu-item',
  template: `
    <mat-expansion-panel>
      <mat-expansion-panel-header>
        <mat-icon>{{ item.icon }}</mat-icon>
        <span>{{ item.label }}</span>
      </mat-expansion-panel-header>
      <div *ngIf="item.children">
        <app-menu-item 
          *ngFor="let child of item.children"
          [item]="child"
          [level]="level + 1">
        </app-menu-item>
      </div>
      <a *ngIf="!item.children" [routerLink]="item.route">
        {{ item.label }}
      </a>
    </mat-expansion-panel>
  `
})
```

**Option 2: Custom Recursive Component**
```typescript
// More control over expand/collapse behavior
@Component({
  selector: 'app-tree-menu',
  template: `
    <div class="menu-item" [class.expanded]="isExpanded">
      <div class="menu-header" (click)="toggleExpand()">
        <mat-icon class="chevron" [style.transform]="'rotate(' + (isExpanded ? 90 : 0) + 'deg'">
          chevron_right
        </mat-icon>
        <a [routerLink]="item.route" 
           routerLinkActive="active"
           [routerLinkActiveOptions]="{ exact: false }">
          {{ item.label }}
        </a>
      </div>
      <div class="menu-children" *ngIf="isExpanded && item.children">
        <app-tree-menu 
          *ngFor="let child of item.children"
          [item]="child"
          [level]="level + 1">
        </app-tree-menu>
      </div>
    </div>
  `,
  styles: [`
    .menu-item { margin-left: calc(var(--level) * 20px); }
    .chevron { transition: transform 0.2s; }
    .menu-header a.active { font-weight: bold; color: #1976d2; }
  `]
})
```

### Data Structure

```typescript
interface MenuItem {
  id: string;
  label: string;
  icon?: string;
  route?: string;           // Only for leaf items (no children)
  children?: MenuItem[];    // If has children, non-clickable header
}

// Example data
const menuItems: MenuItem[] = [
  {
    id: 'module-1',
    label: 'Module One',
    icon: 'dashboard',
    children: [
      {
        id: 'feature-a',
        label: 'Feature A',
        icon: 'folder',
        children: [
          {
            id: 'item-1',
            label: 'Lorem Item 1',
            icon: 'description',
            route: '/module-one/feature-a/item-1'
          },
          {
            id: 'item-2',
            label: 'Lorem Item 2',
            icon: 'description',
            route: '/module-one/feature-a/item-2'
          }
        ]
      }
    ]
  }
];
```

### Router Configuration

```typescript
// app.routes.ts
const routes: Routes = [
  {
    path: '',
    component: DashboardComponent,
    canActivate: [AuthGuard]
  },
  {
    path: 'module-one',
    component: ModuleOneComponent,
    children: [
      {
        path: 'feature-a/item-1',
        component: LoremItem1Component
      },
      {
        path: 'feature-a/item-2',
        component: LoremItem2Component
      }
    ]
  },
  {
    path: '**',
    component: NotFoundComponent
  }
];
```

### Styling

```css
/* Menu item indentation */
.menu-item {
  --level: 0;
}

.menu-item[level="1"] { --level: 1; }
.menu-item[level="2"] { --level: 2; }
.menu-item[level="3"] { --level: 3; }

/* Smooth expand animation */
.menu-children {
  max-height: 500px;
  overflow: hidden;
  animation: slideDown 0.3s ease-out;
}

@keyframes slideDown {
  from {
    max-height: 0;
    opacity: 0;
  }
  to {
    max-height: 500px;
    opacity: 1;
  }
}

/* Active route indicator */
a.active {
  font-weight: 600;
  color: var(--primary-color);
  background-color: rgba(25, 118, 210, 0.08);
  border-left: 3px solid var(--primary-color);
  padding-left: 12px;
}
```

---

## Definition of Done

This story is complete when:

- ✅ Menu structure supports 3 levels (parent → child → grandchild)
- ✅ Test data implemented with Lorem Ipsum or simple naming
- ✅ Parent/Level 2 items expand/collapse on click
- ✅ Level 3 items navigate to SPA routes
- ✅ Expand/collapse animates smoothly
- ✅ Active route is highlighted in menu
- ✅ Menu indentation shows hierarchy visually
- ✅ Routes configured for all leaf items
- ✅ Menu state syncs with current route
- ✅ Responsive on desktop, tablet, mobile
- ✅ No console errors
- ✅ Code uses recursive component (scales to N levels)
- ✅ Code committed with clear commit message
- ✅ Screenshots captured: collapsed, expanded, mobile states

---

## Dependencies

### Prerequisites
- ✅ Story 2.1: Angular Material installed
- ✅ Story 2.3: Dashboard layout with side menu exists
- ✅ Angular Router configured
- ✅ SPA pages exist (or placeholder components for routes)

### Enables
- Epic 3: Authentication (menu updates for logged-in state)
- Epic 4: Workspace Management (real workspace data replaces lorem ipsum)
- Epic 5: Project Management (real project routes implemented)

---

## Out of Scope

❌ **Not Included in This Story**:
- Real data binding (uses static test data only)
- localStorage persistence of expand/collapse state
- Drag-and-drop menu reordering
- Search within menu
- Menu item badges or counters
- Context menus (right-click)
- Breadcrumb navigation (separate)
- Keyboard navigation / accessibility audit
- Animation customization
- Multiple menu themes

**Rationale**: MVP establishes pattern. Polish and features come in later sprints.

---

## Acceptance Testing Steps

### Test 1: Basic Expansion
1. Open menu with 3-level structure visible
2. Click on expandable Level 1 item
3. Verify Level 2 items appear
4. Click again
5. Verify Level 2 items disappear
6. **Pass Criteria**: Smooth expand/collapse works

### Test 2: Deep Nesting
1. Expand Level 1 → Level 2 → Level 3
2. Verify 3 levels of indentation visible
3. Each level indented correctly (0px, 20px, 40px)
4. **Pass Criteria**: Hierarchy is visually clear

### Test 3: Navigation
1. Click a Level 3 (leaf) item
2. Verify page navigates to correct route
3. Verify URL changes
4. Verify clicked item remains highlighted as active
5. **Pass Criteria**: Navigation works correctly

### Test 4: Route Sync
1. Navigate to a route directly (via URL or programmatically)
2. Verify menu automatically expands to show active item
3. Verify active item is highlighted
4. **Pass Criteria**: Menu reflects current route

### Test 5: Responsive
1. Test on desktop (1920px) → all levels visible
2. Test on tablet (768px) → all levels visible, menu scrolls if needed
3. Test on mobile (375px) → menu overlays, all levels accessible
4. **Pass Criteria**: Works on all screen sizes

### Test 6: Animation Smoothness
1. Expand/collapse menu sections 10 times rapidly
2. Verify no jank or stutter
3. **Pass Criteria**: Smooth animation every time

### Test 7: Edge Cases
1. Click expand/collapse repeatedly
2. Navigate while menu is expanding
3. Resize window during menu expansion
4. **Pass Criteria**: No broken state, UI recovers gracefully

---

## Questions & Answers

**Q: Should we use Material Expansion Panel or custom component?**  
**A**: Your choice. Material Expansion Panel (easier) or custom component (more control). Recommend Material for MVP.

**Q: How many menu items for testing?**  
**A**: Minimum 3 Level-1, 2-3 Level-2 per item, 2-3 Level-3 items. Total 15-20 items to test deep nesting.

**Q: Should expand/collapse state persist?**  
**A**: Not for MVP. Users see same menu state every page load. Post-MVP, add localStorage.

**Q: What about keyboard navigation (arrow keys, Enter)?**  
**A**: Not for MVP. Click-based navigation only. Keyboard shortcuts come in accessibility sprint.

**Q: How deep can the menu go?**  
**A**: 3 levels for MVP. Recursive component scales to N levels if needed later.

**Q: Should non-expandable items (leaf nodes) look different?**  
**A**: Yes. Leaf items are clickable links (no chevron icon). Parent items have chevron.

---

## Related Resources

### Material Documentation
- Expansion Panel: https://material.angular.io/components/expansion
- Tree Component: https://material.angular.io/components/tree
- Navigation (List): https://material.angular.io/components/list

### Angular Documentation
- Router: https://angular.io/guide/routing-overview
- RouterLink: https://angular.io/api/router/RouterLink
- Recursive Components: Angular docs on component composition

### Project Files
- App Component: `src/frontend/src/app/app.ts`
- App Routes: `src/frontend/src/app/app.routes.ts`
- Menu Component (to create): `src/frontend/src/app/core/navigation/tree-menu.component.ts`

---

**Story Status**: ✅ Ready for Implementation

**Next Steps**:
1. Frontend developer reviews story and asks clarifying questions
2. Frontend developer implements tree-menu component
3. Frontend developer creates test data with lorem ipsum structure
4. Frontend developer configures routes for all leaf items
5. Story marked complete, Epic 2 complete! 🎉
6. Demo multi-level navigation to team

