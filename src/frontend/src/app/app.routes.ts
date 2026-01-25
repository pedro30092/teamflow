import { Routes } from '@angular/router';
import { DashboardPage } from './pages/dashboard/dashboard.page';
import { SettingsPage } from './pages/settings/settings.page';
import { LoremItemPage } from './pages/lorem-item/lorem-item.page';

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/dashboard',
    pathMatch: 'full'
  },
  {
    path: 'dashboard',
    component: DashboardPage
  },
  {
    path: 'settings',
    component: SettingsPage
  },
  {
    path: 'module-one/feature-a/item-1',
    component: LoremItemPage,
    data: { title: 'Lorem Item 1', module: 'Module One', feature: 'Feature A' }
  },
  {
    path: 'module-one/feature-a/item-2',
    component: LoremItemPage,
    data: { title: 'Lorem Item 2', module: 'Module One', feature: 'Feature A' }
  },
  {
    path: 'module-one/feature-b/item-3',
    component: LoremItemPage,
    data: { title: 'Lorem Item 3', module: 'Module One', feature: 'Feature B' }
  },
  {
    path: 'module-two/feature-c/item-4',
    component: LoremItemPage,
    data: { title: 'Lorem Item 4', module: 'Module Two', feature: 'Feature C' }
  },
  {
    path: 'module-two/feature-c/item-5',
    component: LoremItemPage,
    data: { title: 'Lorem Item 5', module: 'Module Two', feature: 'Feature C' }
  },
  {
    path: 'module-two/feature-d/item-6',
    component: LoremItemPage,
    data: { title: 'Lorem Item 6', module: 'Module Two', feature: 'Feature D' }
  },
  {
    path: 'module-three/feature-e/item-7',
    component: LoremItemPage,
    data: { title: 'Lorem Item 7', module: 'Module Three', feature: 'Feature E' }
  },
  {
    path: '**',
    redirectTo: '/dashboard'
  }
];
