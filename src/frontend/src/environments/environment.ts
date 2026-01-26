// src/environments/environment.ts
// Development environment configuration
// Angular automatically uses this file during ng serve

export const environment = {
  production: false,
  
  // Local backend - change to cloud API URL when testing against cloud
  apiUrl: 'http://localhost:3000',
  
  // Current environment name
  environment: 'local',
};
