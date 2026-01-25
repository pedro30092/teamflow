import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { ChangeDetectionStrategy, Component, computed, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { RouterOutlet } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatToolbarModule } from '@angular/material/toolbar';
import { map } from 'rxjs/operators';
import { TreeMenu } from './core/navigation/tree-menu/tree-menu.component';

@Component({
  selector: 'app-root',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterOutlet, MatButtonModule, MatIconModule, MatSidenavModule, MatToolbarModule, TreeMenu],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  private readonly breakpointObserver = inject(BreakpointObserver);

  readonly isHandset = toSignal(
    this.breakpointObserver.observe(Breakpoints.Handset).pipe(map(result => result.matches)),
    { initialValue: false }
  );

  readonly sidenavOpen = signal(true);

  readonly sidenavMode = computed(() => (this.isHandset() ? 'over' : 'side'));

  toggleSidenav(): void {
    this.sidenavOpen.update(open => !open);
  }

  setSidenavState(open: boolean): void {
    this.sidenavOpen.set(open);
  }
}
