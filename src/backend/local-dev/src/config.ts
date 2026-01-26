import dotenv from 'dotenv';
import path from 'path';

// Load .env file located at project root
dotenv.config({ path: path.join(__dirname, '../.env') });

export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  frontendUrl: process.env.FRONTEND_URL || 'http://localhost:4200',
  logLevel: process.env.LOG_LEVEL || 'info',
  isDevelopment: process.env.NODE_ENV === 'development',
  isProduction: process.env.NODE_ENV === 'production',
};

export function validateConfig(): void {
  if (!config.port || config.port < 1 || config.port > 65535) {
    throw new Error('Invalid PORT in .env (must be 1-65535)');
  }

  if (!config.frontendUrl) {
    throw new Error('FRONTEND_URL not set in .env');
  }

  console.log('✅ Configuration loaded:');
  console.log(`   Port: ${config.port}`);
  console.log(`   Environment: ${config.nodeEnv}`);
  console.log(`   Frontend URL: ${config.frontendUrl}`);
}
