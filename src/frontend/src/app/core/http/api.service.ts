import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiUrl = environment.apiUrl;

  constructor(private http: HttpClient) {
    console.log(`✅ API Service initialized`);
    console.log(`📡 API Endpoint: ${this.apiUrl}`);
    console.log(`🌍 Environment: ${environment.environment}`);
  }

  /**
   * Generic GET request
   * @param endpoint - Path after base URL (e.g., '/api/projects')
   * @returns Observable with response of type T
   */
  get<T>(endpoint: string): Observable<T> {
    const url = `${this.apiUrl}${endpoint}`;
    console.log(`[API GET] ${url}`);
    return this.http.get<T>(url);
  }

  /**
   * Generic POST request
   * @param endpoint - Path after base URL
   * @param data - Request body
   * @returns Observable with response of type T
   */
  post<T>(endpoint: string, data: any): Observable<T> {
    const url = `${this.apiUrl}${endpoint}`;
    console.log(`[API POST] ${url}`, data);
    return this.http.post<T>(url, data);
  }

  /**
   * Generic PUT request
   * @param endpoint - Path after base URL
   * @param data - Request body
   * @returns Observable with response of type T
   */
  put<T>(endpoint: string, data: any): Observable<T> {
    const url = `${this.apiUrl}${endpoint}`;
    console.log(`[API PUT] ${url}`, data);
    return this.http.put<T>(url, data);
  }

  /**
   * Generic PATCH request
   * @param endpoint - Path after base URL
   * @param data - Request body
   * @returns Observable with response of type T
   */
  patch<T>(endpoint: string, data: any): Observable<T> {
    const url = `${this.apiUrl}${endpoint}`;
    console.log(`[API PATCH] ${url}`, data);
    return this.http.patch<T>(url, data);
  }

  /**
   * Generic DELETE request
   * @param endpoint - Path after base URL
   * @returns Observable with response of type T
   */
  delete<T>(endpoint: string): Observable<T> {
    const url = `${this.apiUrl}${endpoint}`;
    console.log(`[API DELETE] ${url}`);
    return this.http.delete<T>(url);
  }

  /**
   * Generic OPTIONS request (for CORS preflight)
   * @param endpoint - Path after base URL
   * @returns Observable with response
   */
  options(endpoint: string): Observable<any> {
    const url = `${this.apiUrl}${endpoint}`;
    console.log(`[API OPTIONS] ${url}`);
    return this.http.options(url);
  }
}
