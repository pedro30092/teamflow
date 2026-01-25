import { Construct } from "constructs";
import { TerraformStack, TerraformOutput } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { LambdaFunction } from "@cdktf/provider-aws/lib/lambda-function";
import { LambdaLayerVersion } from "@cdktf/provider-aws/lib/lambda-layer-version";
import { LambdaPermission } from "@cdktf/provider-aws/lib/lambda-permission";
import { IamRole } from "@cdktf/provider-aws/lib/iam-role";
import { IamRolePolicyAttachment } from "@cdktf/provider-aws/lib/iam-role-policy-attachment";
import { ApiGatewayRestApi } from "@cdktf/provider-aws/lib/api-gateway-rest-api";
import { ApiGatewayResource } from "@cdktf/provider-aws/lib/api-gateway-resource";
import { ApiGatewayMethod } from "@cdktf/provider-aws/lib/api-gateway-method";
import { ApiGatewayIntegration } from "@cdktf/provider-aws/lib/api-gateway-integration";
import { ApiGatewayStage } from "@cdktf/provider-aws/lib/api-gateway-stage";
import { ApiGatewayDeployment } from "@cdktf/provider-aws/lib/api-gateway-deployment";
import { ArchiveProvider } from "../.gen/providers/archive/provider";
import { DataArchiveFile } from "../.gen/providers/archive/data-archive-file";
import * as path from "path";

interface ApiStackConfig {
  environment: string;
  awsRegion: string;
  awsProfile: string;
}

export class ApiStack extends TerraformStack {
  constructor(scope: Construct, id: string, config: ApiStackConfig) {
    super(scope, id);

    // AWS Provider
    new AwsProvider(this, "aws", {
      region: config.awsRegion,
      profile: config.awsProfile,
    });

    // Archive Provider (for zipping Lambda layers)
    new ArchiveProvider(this, "archive", {});

    // ============================================================
    // 1. Lambda Layers
    // ============================================================

    // Archive dependencies directory into zip using DataArchiveFile
    const dependenciesArchive = new DataArchiveFile(this, "dependencies-archive", {
      type: "zip",
      sourceDir: path.resolve(__dirname, "../../backend/layers/dependencies/nodejs"),
      outputPath: path.resolve(__dirname, "../../dist/layers/dependencies.zip"),
    });

    // Dependencies layer (AWS SDK, shared packages) from archived zip
    const dependenciesLayer = new LambdaLayerVersion(this, "dependencies-layer", {
      layerName: `teamflow-dependencies-${config.environment}`,
      filename: dependenciesArchive.outputPath,
      compatibleRuntimes: ["nodejs24.x"],
    });

    // ============================================================
    // 2. Lambda Function - Get Home
    // ============================================================

    // Lambda IAM Role
    const lambdaRole = new IamRole(this, "lambda-role", {
      name: `teamflow-lambda-role-${config.environment}`,
      assumeRolePolicy: JSON.stringify({
        Version: "2012-10-17",
        Statement: [
          {
            Effect: "Allow",
            Principal: {
              Service: "lambda.amazonaws.com",
            },
            Action: "sts:AssumeRole",
          },
        ],
      }),
    });

    // Attach basic Lambda execution policy (CloudWatch Logs)
    new IamRolePolicyAttachment(this, "lambda-basic-execution", {
      role: lambdaRole.name,
      policyArn:
        "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    });

    // Archive Lambda function directory into zip using DataArchiveFile
    const lambdaFunctionArchive = new DataArchiveFile(this, "lambda-function-archive", {
      type: "zip",
      sourceDir: path.resolve(__dirname, "../../backend/dist/functions/home"),
      outputPath: path.resolve(__dirname, "../../dist/functions/home.zip"),
    });

    // Lambda Function
    const lambdaFunction = new LambdaFunction(this, "get-home-function", {
      functionName: `teamflow-get-home-${config.environment}`,
      runtime: "nodejs24.x",
      architectures: ["arm64"],
      handler: "get-home.handler",
      role: lambdaRole.arn,
      filename: lambdaFunctionArchive.outputPath,
      sourceCodeHash: lambdaFunctionArchive.outputBase64Sha256,
      timeout: 30,
      memorySize: 256,
      layers: [dependenciesLayer.arn],
      environment: {
        variables: {
          ENVIRONMENT: config.environment,
        },
      },
    });

    // ============================================================
    // 3. API Gateway
    // ============================================================

    // REST API
    const api = new ApiGatewayRestApi(this, "api", {
      name: `teamflow-api-${config.environment}`,
      description: "TeamFlow API Gateway",
      endpointConfiguration: {
        types: ["REGIONAL"],
      },
    });

    // /api resource
    const apiResource = new ApiGatewayResource(this, "api-resource", {
      restApiId: api.id,
      parentId: api.rootResourceId,
      pathPart: "api",
    });

    // /api/home resource
    const homeResource = new ApiGatewayResource(this, "home-resource", {
      restApiId: api.id,
      parentId: apiResource.id,
      pathPart: "home",
    });

    // GET /api/home method
    const getMethod = new ApiGatewayMethod(this, "get-method", {
      restApiId: api.id,
      resourceId: homeResource.id,
      httpMethod: "GET",
      authorization: "NONE",
    });

    // Lambda integration (proxy)
    const integration = new ApiGatewayIntegration(this, "lambda-integration", {
      restApiId: api.id,
      resourceId: homeResource.id,
      httpMethod: getMethod.httpMethod,
      type: "AWS_PROXY",
      integrationHttpMethod: "POST",
      uri: lambdaFunction.invokeArn,
    });

    // Lambda permission for API Gateway
    new LambdaPermission(this, "api-gateway-permission", {
      statementId: "AllowAPIGatewayInvoke",
      action: "lambda:InvokeFunction",
      functionName: lambdaFunction.functionName,
      principal: "apigateway.amazonaws.com",
      sourceArn: `${api.executionArn}/*/*`,
    });

    // API Gateway deployment must exist before stage
    const deployment = new ApiGatewayDeployment(this, "api-deployment", {
      restApiId: api.id,
      description: "Initial deployment",
      dependsOn: [getMethod, integration],
    });

    // Deploy API using stage
    new ApiGatewayStage(this, "api-stage", {
      deploymentId: deployment.id,
      restApiId: api.id,
      stageName: config.environment,
    });

    // ============================================================
    // 4. Outputs
    // ============================================================

    new TerraformOutput(this, "api_endpoint_url", {
      value: `https://${api.id}.execute-api.${config.awsRegion}.amazonaws.com/${config.environment}/api/home`,
      description: "GET /api/home endpoint URL",
    });

    new TerraformOutput(this, "lambda_function_name", {
      value: lambdaFunction.functionName,
      description: "Lambda function name",
    });

    new TerraformOutput(this, "api_id", {
      value: api.id,
      description: "API Gateway REST API ID",
    });
  }
}
