import { Construct } from "constructs";
import { App, TerraformStack, TerraformAsset, AssetType } from "cdktf";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { LambdaFunction } from "@cdktf/provider-aws/lib/lambda-function";
import { IamRole } from "@cdktf/provider-aws/lib/iam-role";
import { IamRolePolicyAttachment } from "@cdktf/provider-aws/lib/iam-role-policy-attachment";
import * as path from "path";

class TeamFlowStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    // AWS Provider - tells Terraform which region/profile to use
    new AwsProvider(this, "aws", {
      region: "us-east-1",
      profile: "teamflow-developer",
    });

    // Lambda IAM Role - allows Lambda to execute
    const lambdaRole = new IamRole(this, "lambda-role", {
      name: "teamflow-hello-lambda-role",
      assumeRolePolicy: JSON.stringify({
        Version: "2012-10-17",
        Statement: [{
          Effect: "Allow",
          Principal: { Service: "lambda.amazonaws.com" },
          Action: "sts:AssumeRole",
        }],
      }),
    });

    // Attach CloudWatch Logs policy - allows console.log to work
    new IamRolePolicyAttachment(this, "lambda-logs", {
      role: lambdaRole.name,
      policyArn: "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    });

    // Package Lambda code - zips the dist/handlers directory
    const lambdaAsset = new TerraformAsset(this, "lambda-asset", {
      path: path.resolve(__dirname, "../backend/dist/handlers"),
      type: AssetType.ARCHIVE,
    });

    // Lambda Function - the actual serverless function
    new LambdaFunction(this, "hello-lambda", {
      functionName: "teamflow-hello",
      runtime: "nodejs20.x",
      architectures: ["arm64"],
      handler: "hello.handler",
      role: lambdaRole.arn,
      filename: lambdaAsset.path,
      sourceCodeHash: lambdaAsset.assetHash,
      timeout: 10,
      memorySize: 128,
    });
  }
}

const app = new App();
new TeamFlowStack(app, "teamflow-dev");
app.synth();