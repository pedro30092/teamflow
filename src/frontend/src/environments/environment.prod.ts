// src/environments/environment.prod.ts
// Production environment configuration
// Angular automatically uses this file during ng build --configuration production

export const environment = {
  production: true,

  // Cloud API endpoint
  apiUrl: 'https://your-api-id.execute-api.us-east-1.amazonaws.com/dev',

  // Production always uses cloud
  environment: 'cloud',
};
