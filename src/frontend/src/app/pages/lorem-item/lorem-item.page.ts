import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { toSignal } from '@angular/core/rxjs-interop';
import { map } from 'rxjs/operators';

@Component({
  selector: 'app-lorem-item',
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './lorem-item.page.html',
  styleUrl: './lorem-item.page.css'
})
export class LoremItemPage {
  private readonly route = inject(ActivatedRoute);

  readonly title = toSignal(this.route.data.pipe(map(data => data['title'])), { initialValue: 'Item' });
  readonly description = toSignal(
    this.route.data.pipe(map(data => data['description'] || 'This is a placeholder page demonstrating multi-level navigation and routing.')),
    { initialValue: '' }
  );
  readonly module = toSignal(this.route.data.pipe(map(data => data['module'])), { initialValue: '' });
  readonly feature = toSignal(this.route.data.pipe(map(data => data['feature'])), { initialValue: '' });
}
