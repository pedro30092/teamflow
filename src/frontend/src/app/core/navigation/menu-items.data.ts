import { MenuItem } from './menu-item.model';

export const MENU_ITEMS: MenuItem[] = [
  {
    id: 'dashboard',
    label: 'Dashboard',
    icon: 'dashboard',
    route: '/dashboard'
  },
  {
    id: 'module-one',
    label: 'Module One',
    icon: 'folder',
    children: [
      {
        id: 'feature-a',
        label: 'Feature A',
        icon: 'folder_open',
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
      },
      {
        id: 'feature-b',
        label: 'Feature B',
        icon: 'folder_open',
        children: [
          {
            id: 'item-3',
            label: 'Lorem Item 3',
            icon: 'description',
            route: '/module-one/feature-b/item-3'
          }
        ]
      }
    ]
  },
  {
    id: 'module-two',
    label: 'Module Two',
    icon: 'folder',
    children: [
      {
        id: 'feature-c',
        label: 'Feature C',
        icon: 'folder_open',
        children: [
          {
            id: 'item-4',
            label: 'Lorem Item 4',
            icon: 'description',
            route: '/module-two/feature-c/item-4'
          },
          {
            id: 'item-5',
            label: 'Lorem Item 5',
            icon: 'description',
            route: '/module-two/feature-c/item-5'
          }
        ]
      },
      {
        id: 'feature-d',
        label: 'Feature D',
        icon: 'folder_open',
        children: [
          {
            id: 'item-6',
            label: 'Lorem Item 6',
            icon: 'description',
            route: '/module-two/feature-d/item-6'
          }
        ]
      }
    ]
  },
  {
    id: 'module-three',
    label: 'Module Three',
    icon: 'folder',
    children: [
      {
        id: 'feature-e',
        label: 'Feature E',
        icon: 'folder_open',
        children: [
          {
            id: 'item-7',
            label: 'Lorem Item 7',
            icon: 'description',
            route: '/module-three/feature-e/item-7'
          }
        ]
      }
    ]
  },
  {
    id: 'settings',
    label: 'Settings',
    icon: 'settings',
    route: '/settings'
  }
];
