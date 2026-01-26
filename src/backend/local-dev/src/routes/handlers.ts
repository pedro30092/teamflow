import { Router, Request, Response } from 'express';
import path from 'path';
import { createMockAPIGatewayEvent, invokeLambdaHandler } from '../utils/lambda-invoker';

const router = Router();

router.get('/api/home', async (req: Request, res: Response) => {
  try {
    const handlerPath = path.resolve(__dirname, '../../../dist/functions/home/get-home.js');

    // Bust the require cache so changes in the compiled handler are picked up without restart.
    delete require.cache[require.resolve(handlerPath)];

    const { handler: homeHandler } = require(handlerPath);

    const event = createMockAPIGatewayEvent(req);
    const lambdaResponse = await invokeLambdaHandler(homeHandler, event);

    if (lambdaResponse.headers) {
      Object.entries(lambdaResponse.headers).forEach(([key, value]) => {
        res.setHeader(key, value as string);
      });
    }

    res.status(lambdaResponse.statusCode || 200).send(lambdaResponse.body);
  } catch (error) {
    console.error('[Handler] Error invoking Lambda:', error);
    res.status(500).json({
      error: 'Internal Server Error',
      message: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
