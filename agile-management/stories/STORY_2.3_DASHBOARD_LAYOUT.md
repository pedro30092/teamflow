# Story 2.3: Dashboard Layout with Side Navigation

**Epic**: Epic 2 - UI Foundation  
**Story ID**: STORY-2.3  
**Status**: ✅ Completed  
**Priority**: MUST-HAVE  
**Estimated Effort**: 4-6 hours

---

## User Story

**As a** TeamFlow user,  
**I want** a dashboard-style interface with a side menu that I can open and close,  
**So that** I can navigate between features intuitively while maximizing my workspace.

---

## Why This Matters

### Business Value
- **Industry Standard Pattern**: Dashboard with side menu is expected in project management tools (Asana, Monday.com, Jira, Slack all use this pattern)
- **Competitive Positioning**: Professional dashboard layout signals that TeamFlow is a "real" SaaS product, not a prototype
- **User Familiarity**: Users transferring from competitors instantly recognize navigation pattern—zero learning curve
- **Scalable Architecture**: Side menu supports adding Calendar and Time Tracking modules without redesigning navigation
- **User Control**: Collapsible menu lets users maximize workspace (critical for Sarah's team viewing project boards on laptops)

### User Impact
- **All Users** (Sarah, Mike, Linda): Need consistent way to navigate between Workspaces, Projects, Tasks
- **Power Users**: Benefit from keyboard shortcuts to toggle menu (future enhancement)
- **Mobile Users**: Collapsible menu prevents navigation from dominating small screens
- **New Users**: Familiar pattern reduces "Where do I click?" confusion

### Product Vision Alignment
✅ **Simplicity**: Single, persistent menu (not scattered navigation)  
✅ **User-Focused**: Standard pattern reduces learning curve for non-technical teams  
✅ **Scalable**: Menu structure ready for future modules without redesign  
✅ **Flexible**: Users control menu visibility (respects different work styles)

---

## Acceptance Criteria

### Must-Have (MVP)

#### Navigation Structure
- [x] **Side Navigation Menu**: Vertical menu on left side of screen (Material sidenav component)
- [x] **Menu Toggle Button**: Visible button (hamburger icon) to open/close menu
- [x] **Default State**: Menu closed by default on page load (maximizes workspace)
- [x] **Home Menu Item**: Single menu item labeled "Home" that is static (always visible, not clickable yet)
- [x] **Smooth Animation**: Menu slides open/closed smoothly (Material's default animation, ~250ms duration)
- [x] **Main Content Area**: Welcome message (from Story 2.2) displayed in main content area beside menu

#### Visual Design
- [x] **Material Sidenav Styling**: Uses Material Design sidenav component (not custom CSS)
- [x] **Menu Width**: Sidenav width is 250-300px when open
- [x] **Icon in Toggle Button**: Material hamburger/menu icon (`<mat-icon>menu</mat-icon>`)
- [x] **Home Icon**: Home menu item shows house icon (`<mat-icon>home</mat-icon>`)
- [x] **Visual Feedback**: Menu item has hover state (Material's default)

#### Interaction Behavior
- [x] **Toggle Opens/Closes**: Clicking toggle button opens menu if closed, closes if open
- [x] **Content Shifts**: Main content area adjusts when menu opens/closes (no overlap)
- [x] **Persistent State**: Menu state persists during session (stays open/closed as user navigates)
- [x] **Mobile Behavior**: On mobile screens (<768px), menu overlays content (doesn't push it)

### Nice-to-Have (Post-MVP)
- Menu remembers open/closed state in localStorage
- Keyboard shortcut to toggle menu (e.g., Cmd+B / Ctrl+B)
- Breadcrumb navigation in header
- User profile icon in header

### Edge Cases & Error Handling
- [x] **Rapid Toggling**: Clicking toggle button rapidly doesn't break animation
- [x] **Mobile Screen**: Menu doesn't block main content when open (has close overlay)
- [x] **Small Screens**: Toggle button always visible and clickable

---

## User Scenarios

### Scenario 1: New User Opens TeamFlow
**Context**: Sarah opens TeamFlow for the first time

**Steps**:
1. Sarah navigates to `http://localhost:4200`
2. Page loads with dashboard layout

**Expected Outcome**:
- Menu is closed (maximizing workspace for welcome message)
- Toggle button is visible in top-left area
- Welcome message (from Story 2.2) visible in main content area
- Layout looks clean and professional

**What Success Looks Like**: Sarah immediately recognizes this is a dashboard app and sees the menu button

---

### Scenario 2: User Opens Side Menu
**Context**: Sarah wants to explore navigation options

**Steps**:
1. Sarah clicks the menu toggle button (hamburger icon)
2. Menu slides open from left side

**Expected Outcome**:
- Menu opens smoothly with slide animation
- Menu displays "Home" item with house icon
- Main content area shifts to the right (not covered by menu)
- Toggle button remains visible and clickable

**What Success Looks Like**: Sarah sees "Home" menu item and understands navigation will appear here

---

### Scenario 3: User Closes Side Menu
**Context**: Sarah wants more workspace to read content

**Steps**:
1. Menu is currently open
2. Sarah clicks the menu toggle button again

**Expected Outcome**:
- Menu closes smoothly with slide animation
- Main content area expands to fill space
- Toggle button still visible

**What Success Looks Like**: Sarah has control over her workspace layout

---

### Scenario 4: Mobile User Views on Phone
**Context**: Linda checks TeamFlow on her phone during meeting

**Steps**:
1. Linda opens TeamFlow on iPhone (375px width)
2. Linda clicks menu toggle button

**Expected Outcome**:
- Menu overlays main content (doesn't push it off-screen)
- Semi-transparent backdrop appears behind menu
- Clicking backdrop closes menu
- Welcome message remains readable when menu is closed

**What Success Looks Like**: Dashboard works on mobile without awkward scrolling or overlaps

---

## Success Metrics

### User Experience
- **Navigation Clarity**: 100% of test users find menu toggle button within 5 seconds
- **Pattern Recognition**: Users immediately recognize dashboard layout from other tools
- **Smooth Interaction**: Menu animation feels responsive (<300ms)
- **Control**: Users appreciate ability to hide/show menu

### Technical
- **Performance**: Menu toggle responds within 100ms of click
- **Animation**: No jank or stuttering during menu open/close
- **Responsive**: Layout adapts correctly from 320px to 1920px screen widths
- **Zero Errors**: No console errors related to sidenav

### Business
- **Professional Appearance**: Dashboard layout matches quality of Asana, Monday.com
- **Future-Proof**: Menu structure supports adding 10+ menu items without redesign

---

## Visual Design Specification

### Desktop Layout (Menu Closed)
```
┌─────────────────────────────────────────┐
│ [☰]                              Header │
├─────────────────────────────────────────┤
│                                         │
│         [Welcome Message Card]          │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

### Desktop Layout (Menu Open)
```
┌─────────┬───────────────────────────────┐
│ [☰]     │                        Header │
├─────────┼───────────────────────────────┤
│ Menu    │                               │
│ ┌─────┐ │    [Welcome Message Card]     │
│ │🏠Home│ │                               │
│ └─────┘ │                               │
│         │                               │
└─────────┴───────────────────────────────┘
```

### Mobile Layout (Menu Closed)
```
┌─────────────────┐
│ [☰]      Header │
├─────────────────┤
│                 │
│  [Welcome Msg]  │
│                 │
└─────────────────┘
```

### Mobile Layout (Menu Open - Overlay)
```
┌─────────────────┐
│ Menu    │ [X]   │
│ ┌─────┐ │       │
│ │🏠Home│ │       │
│ └─────┘ │       │
│         │ Backdrop
│         │ (dims)
└─────────┴───────┘
```

### Dimensions
- **Menu Width**: 280px (open)
- **Menu Width**: 0px (closed, or 60px if keeping icons visible - future)
- **Toggle Button**: 40x40px clickable area
- **Menu Item Height**: 48px (Material standard for list items)
- **Header Height**: 64px (Material toolbar height)

---

## Technical Notes (For Frontend Developer)

### Component Structure
```typescript
// app.component.ts
import { Component } from '@angular/core';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    MatSidenavModule,
    MatToolbarModule,
    MatButtonModule,
    MatIconModule,
    MatListModule
  ],
  template: `
    <mat-sidenav-container class="sidenav-container">
      <mat-sidenav #sidenav mode="side" opened="false">
        <mat-nav-list>
          <mat-list-item>
            <mat-icon matListItemIcon>home</mat-icon>
            <span matListItemTitle>Home</span>
          </mat-list-item>
        </mat-nav-list>
      </mat-sidenav>

      <mat-sidenav-content>
        <mat-toolbar color="primary">
          <button mat-icon-button (click)="sidenav.toggle()">
            <mat-icon>menu</mat-icon>
          </button>
          <span>TeamFlow</span>
        </mat-toolbar>

        <div class="content">
          <!-- Welcome message from Story 2.2 goes here -->
          <mat-card class="welcome-card">
            <mat-card-header>
              <mat-card-title>Welcome to TeamFlow</mat-card-title>
            </mat-card-header>
            <mat-card-content>
              <p>The simple project management tool designed for small teams...</p>
            </mat-card-content>
          </mat-card>
        </div>
      </mat-sidenav-content>
    </mat-sidenav-container>
  `,
  styles: [`
    .sidenav-container {
      height: 100vh;
    }
    .content {
      padding: 20px;
    }
    .welcome-card {
      max-width: 600px;
      margin: 100px auto;
    }
  `]
})
export class AppComponent {}
```

### Material Components Used
- `MatSidenavModule` (side navigation drawer)
- `MatToolbarModule` (header with toggle button)
- `MatButtonModule` (icon button for toggle)
- `MatIconModule` (hamburger/menu icons)
- `MatListModule` (menu items list)

### Sidenav Configuration
- **mode="side"**: Menu pushes content (desktop), use `mode="over"` for mobile
- **opened="false"**: Menu closed by default
- **Toggle method**: `sidenav.toggle()` opens/closes

### Responsive Behavior
```typescript
// Use Angular CDK Layout for responsive behavior
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';

// In component:
isHandset$ = this.breakpointObserver.observe(Breakpoints.Handset);

// In template:
<mat-sidenav [mode]="(isHandset$ | async) ? 'over' : 'side'">
```

---

## Definition of Done

This story is complete when:

- [x] Side navigation menu exists using Material sidenav
- [x] Toggle button opens/closes menu smoothly
- [x] "Home" menu item visible with icon
- [x] Welcome message (from Story 2.2) displayed in main content area
- [x] Layout responsive on desktop and mobile
- [x] No console errors
- [x] Code committed with descriptive message
- [x] Screenshots captured for demo (menu open + closed states)
- [x] Tested on Chrome, Firefox, Safari
- [x] Tested on mobile (iPhone and Android screen sizes)

---

## Dependencies

### Prerequisites
- ✅ Story 2.1: Angular Material installed
- ✅ Story 2.2: Welcome message created (will be placed in main content area)

### Enables
- Epic 3: Authentication (login form will go in main content area)
- Epic 4: Workspace Management (menu will contain workspace navigation)
- Epic 5: Project Management (menu will contain project links)
- Future: Module navigation (Calendar, Time Tracking menu items)

---

## Out of Scope

❌ **Not Included in This Story**:
- Multiple menu items (just "Home" for now)
- Clickable menu items with routing (static for MVP)
- Nested menu items / sub-menus
- User profile section in menu
- Menu search functionality
- Pinned/favorited items
- Menu customization by user
- Keyboard shortcuts
- Right-click context menus
- localStorage persistence of menu state

**Rationale**: Establish the pattern and structure. Additional menu items come in future epics as features are built.

---

## Acceptance Testing Steps

### Test 1: Menu Toggle Functionality
1. Open home page in browser
2. Verify menu is closed by default
3. Click hamburger toggle button
4. Verify menu opens with smooth animation
5. Click toggle button again
6. Verify menu closes smoothly
7. **Pass Criteria**: Menu toggles open/closed reliably

### Test 2: Menu Content
1. Open menu
2. Verify "Home" menu item is visible
3. Verify home icon (house) is displayed
4. **Pass Criteria**: Menu item renders correctly with icon and label

### Test 3: Content Area Layout
1. With menu closed, verify welcome message is centered
2. Open menu, verify welcome message shifts but remains readable
3. Close menu, verify welcome message re-centers
4. **Pass Criteria**: Content area adjusts correctly to menu state

### Test 4: Mobile Responsiveness
1. Open Chrome DevTools → Device Toolbar
2. Select iPhone SE (375px width)
3. Verify toggle button is visible and clickable
4. Open menu, verify it overlays content (not pushes off-screen)
5. Verify backdrop appears (semi-transparent overlay)
6. Click backdrop, verify menu closes
7. **Pass Criteria**: Mobile layout works without horizontal scroll

### Test 5: Animation Smoothness
1. Toggle menu open and closed 10 times rapidly
2. Verify animation doesn't stutter or break
3. **Pass Criteria**: Smooth animation every time

### Test 6: Cross-Browser
1. Test in Chrome, Firefox, Safari
2. Verify layout and toggle functionality works in all browsers
3. **Pass Criteria**: Consistent behavior across browsers

---

## Questions & Answers

**Q: Should the menu remember if it was open/closed when user returns?**  
**A**: Not for MVP. Keeping it simple—default closed every time. Post-MVP, add localStorage persistence.

**Q: Should "Home" menu item be clickable?**  
**A**: No, it's static for now. Once we have routing (Epic 3+), menu items become clickable links.

**Q: What about nested sub-menus (e.g., Projects → Project A, Project B)?**  
**A**: Not yet. Flat menu structure for MVP. Nested menus come later when we have multiple projects.

**Q: Should we show user profile in the menu header?**  
**A**: Not in MVP. Authentication comes in Epic 3, then we'll add profile section.

**Q: Desktop vs. mobile menu behavior—same or different?**  
**A**: Different. Desktop: menu pushes content (`mode="side"`). Mobile: menu overlays content (`mode="over"`).

**Q: Should the menu have a footer (e.g., Settings, Help)?**  
**A**: Not yet. Focus on main navigation. Footer links come later.

---

## Related Resources

### Material Documentation
- Sidenav Component: https://material.angular.io/components/sidenav
- Toolbar Component: https://material.angular.io/components/toolbar
- List Component: https://material.angular.io/components/list

### Design Patterns
- Dashboard layouts in Asana, Monday.com, Jira (reference for pattern)
- Material Design Navigation: https://material.io/components/navigation-drawer

### Project Files
- App Component: `src/frontend/src/app/app.ts`
- App Template: `src/frontend/src/app/app.html`
- App Styles: `src/frontend/src/app/app.css`

---

**Story Status**: ✅ Ready for Implementation

**Next Steps**:
1. Frontend developer implements sidenav layout
2. Frontend developer integrates welcome message into content area
3. Frontend developer tests on desktop and mobile
4. Story marked complete, Epic 2 done! 🎉
5. Demo dashboard layout to team
6. Begin Epic 3 planning (Authentication)

