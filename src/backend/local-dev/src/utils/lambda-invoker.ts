import { Request } from 'express';
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

export function createMockAPIGatewayEvent(
  req: Request,
  body?: unknown
): APIGatewayProxyEvent {
  return {
    resource: req.path,
    path: req.path,
    httpMethod: req.method,
    headers: req.headers as Record<string, string>,
    multiValueHeaders: {},
    queryStringParameters: (req.query as Record<string, string>) || null,
    multiValueQueryStringParameters: null,
    pathParameters: null,
    stageVariables: null,
    requestContext: {
      accountId: '000000000000',
      apiId: 'local',
      protocol: 'HTTP/1.1',
      httpMethod: req.method,
      path: req.path,
      stage: 'local',
      requestId: `local-${Date.now()}`,
      requestTime: new Date().toISOString(),
      requestTimeEpoch: Date.now(),
      identity: {
        sourceIp: req.ip || '127.0.0.1',
      },
      authorizer: undefined,
    } as any,
    body: body ? JSON.stringify(body) : null,
    isBase64Encoded: false,
  } as APIGatewayProxyEvent;
}

export async function invokeLambdaHandler(
  handler: (event: APIGatewayProxyEvent, context: any) => Promise<APIGatewayProxyResult>,
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> {
  const context = {
    functionName: 'local-function',
    functionVersion: '$LATEST',
    invokedFunctionArn: 'arn:aws:lambda:local:000000000000:function:local',
    memoryLimitInMB: 256,
    awsRequestId: `local-${Date.now()}`,
    logGroupName: '/aws/lambda/local',
    logStreamName: 'local-stream',
    identity: undefined,
    clientContext: undefined,
    getRemainingTimeInMillis: () => 30000,
    done: () => {},
    fail: () => {},
    succeed: () => {},
  };

  console.log(`[Lambda] Invoking handler with path: ${event.path}`);
  const response = await handler(event, context);
  console.log(`[Lambda] Handler returned status: ${response.statusCode}`);
  return response;
}
