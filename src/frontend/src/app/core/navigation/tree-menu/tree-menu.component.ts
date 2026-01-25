import { ChangeDetectionStrategy, Component } from '@angular/core';
import { TreeMenuItem } from '../tree-menu-item/tree-menu-item.component';
import { MENU_ITEMS } from '../menu-items.data';

@Component({
  selector: 'app-tree-menu',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TreeMenuItem],
  templateUrl: './tree-menu.component.html',
  styleUrl: './tree-menu.component.css'
})
export class TreeMenu {
  readonly menuItems = MENU_ITEMS;
}
