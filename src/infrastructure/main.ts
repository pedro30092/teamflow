import { App } from "cdktf";
import { ApiStack } from "./stacks/api-stack";

const app = new App();

// Create API stack with configuration
new ApiStack(app, "teamflow-api-dev", {
  environment: "dev",
  awsRegion: "us-east-1",
  awsProfile: "teamflow-developer",
});

app.synth();