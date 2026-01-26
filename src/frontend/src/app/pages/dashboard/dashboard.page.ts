import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { ApiService } from '../../core/http/api.service';

@Component({
  selector: 'app-dashboard',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatButtonModule, MatCardModule],
  templateUrl: './dashboard.page.html',
  styleUrl: './dashboard.page.css'
})
export class DashboardPage {
  private api = inject(ApiService);

  onGetStarted(): void {
    this.api.get<any>('/api/home').subscribe({
      next: (response) => {
        console.log('✅ API Home Response:', response);
      },
      error: (error) => {
        console.error('❌ API Home Error:', error);
      }
    });
  }
}
