import express, { Express, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { config, validateConfig } from './config';
import handlersRoutes from './routes/handlers';

try {
  validateConfig();
} catch (error) {
  console.error('❌ Configuration error:', error);
  process.exit(1);
}

const app: Express = express();

app.use(cors({
  origin: config.frontendUrl,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());

app.use((req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${req.method}] ${req.path} - ${res.statusCode} (${duration}ms)`);
  });
  next();
});

app.use('/', handlersRoutes);

app.use((req: Request, res: Response) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    method: req.method,
  });
});

app.use((error: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('❌ Error:', error.message);
  res.status(500).json({
    error: 'Internal Server Error',
    message: config.isDevelopment ? error.message : 'An error occurred',
  });
});

const server = app.listen(config.port, () => {
  console.log(`\n🚀 Local Backend Server Started`);
  console.log(`📡 http://localhost:${config.port}`);
  console.log(`✅ CORS enabled for ${config.frontendUrl}`);
  console.log(`\n⚡ Lambda handler integration active`);
  console.log(`\nTry this endpoint:`);
  console.log(`  - http://localhost:${config.port}/api/home (invokes Lambda handler)`);
  console.log(`\nPress Ctrl+C to stop\n`);
});

process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down...');
  server.close(() => {
    console.log('✅ Server stopped');
    process.exit(0);
  });
});

export default app;
