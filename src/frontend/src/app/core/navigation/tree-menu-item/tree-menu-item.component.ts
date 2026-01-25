import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';
import { MenuItem } from '../menu-item.model';
import { input } from '@angular/core';

@Component({
  selector: 'app-tree-menu-item',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterLink, RouterLinkActive, MatIconModule, MatListModule],
  templateUrl: './tree-menu-item.component.html',
  styleUrl: './tree-menu-item.component.css'
})
export class TreeMenuItem {
  readonly item = input.required<MenuItem>();
  readonly level = input(0);

  readonly isExpanded = signal(false);

  toggleExpand(): void {
    this.isExpanded.update(expanded => !expanded);
  }
}
