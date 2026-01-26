/**
 * API Response Types
 */

/**
 * Generic API response wrapper
 */
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  count?: number;
  timestamp?: string;
}

/**
 * Generic API error response
 */
export interface ApiError {
  error: string;
  message: string;
  statusCode: number;
  path: string;
  timestamp: string;
}

/**
 * Home endpoint response
 */
export interface HomeResponse {
  message: string;
  source?: string;
  timestamp?: string;
}

/**
 * Project entity
 */
export interface Project {
  id: string;
  name: string;
  description?: string;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Projects list response
 */
export interface ProjectsResponse extends ApiResponse<Project[]> {
  count: number;
}

/**
 * Task entity
 */
export interface Task {
  id: string;
  projectId: string;
  title: string;
  description?: string;
  status: 'todo' | 'in_progress' | 'done';
  priority?: 'low' | 'medium' | 'high';
  assigneeId?: string;
  createdAt?: string;
  updatedAt?: string;
}

/**
 * Tasks list response
 */
export interface TasksResponse extends ApiResponse<Task[]> {
  count: number;
}
