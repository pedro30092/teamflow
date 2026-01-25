import { APIGatewayProxyHandlerV2 } from 'aws-lambda';

export const handler: APIGatewayProxyHandlerV2 = async (event) => {
  try {
    console.log('GET /api/home request received', {
      requestId: event.requestContext?.requestId,
      path: event.rawPath,
      method: event.requestContext?.http?.method,
    });

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
      body: JSON.stringify({
        message: 'hello world',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'production',
      }),
    };
  } catch (error) {
    console.error('Error in GET /api/home:', error);

    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Internal server error',
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
    };
  }
};
