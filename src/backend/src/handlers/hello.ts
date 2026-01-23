import { Handler } from 'aws-lambda';

export const handler: Handler = async (event, context) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  console.log('Context:', JSON.stringify(context, null, 2));
  
  return {
    statusCode: 200,
    body: JSON.stringify({
      message: 'Hello from TeamFlow Lambda!',
      timestamp: new Date().toISOString(),
    }),
  };
};
