# Story 1.4: Initialize Infrastructure (CDKTF)

**Story ID**: EPIC1-004
**Epic**: EPIC-1 (Development Environment Setup)
**Sprint**: SPRINT-0
**Status**: ✅ DONE

---

## User Story

```
As a developer,
I need infrastructure-as-code using CDKTF,
so that I can deploy Lambda functions to AWS with repeatable, version-controlled infrastructure.
```

---

## Requirements

**Set up CDKTF project to deploy Lambda infrastructure:**
- Initialize CDKTF with TypeScript template
- Install AWS provider
- Define Lambda function with IAM role and policies
- Deploy to AWS using Terraform workflow
- Verify Lambda is callable and logs to CloudWatch

**Target Structure:**
```
src/infrastructure/
├── package.json              # CDKTF dependencies
├── tsconfig.json             # TypeScript config
├── cdktf.json               # CDKTF configuration
├── main.ts                  # Infrastructure stack
└── terraform.teamflow-dev.tfstate  # Terraform state
```

**Resources to create:**
- AWS Provider (region + profile configuration)
- IAM Role (Lambda execution role)
- IAM Role Policy Attachment (CloudWatch Logs permission)
- Lambda Function (hello handler from Story 1.3)

---

## Acceptance Criteria

- [x] CDKTF project initialized in `src/infrastructure/`
- [x] `main.ts` defines Lambda + IAM resources in TypeScript
- [x] `cdktf deploy` successfully creates AWS resources
- [x] Lambda function `teamflow-hello` deployed to AWS
- [x] Lambda is invokable via AWS CLI
- [x] CloudWatch logs show console.log output
- [x] Terraform state file created and managed

---

## Dependencies

- Story 1.1 complete (Node.js, npm, TypeScript installed)
- Story 1.2 complete (AWS CLI configured with `teamflow-developer` profile)
- **Story 1.3 complete** (Backend Lambda handler compiled)

---

## Definition of Done

- [x] CDKTF infrastructure deployed to AWS
- [x] Lambda tested and working
- [x] Infrastructure code version-controlled
- [x] Deployment workflow understood (synth → diff → deploy)
- [x] Ready for additional infrastructure or Story 1.5 (Frontend)

---

## Notes

**Deployment workflow:**
```bash
npm run build    # Compile infrastructure TypeScript
cdktf synth      # Generate Terraform JSON
cdktf diff       # Preview changes (CRITICAL - always run first!)
cdktf deploy     # Apply to AWS
```

**Key learning:** Always run `cdktf diff` before deploying to avoid unintended resource changes.

**Reference:** See [CDKTF_CHANGE_MANAGEMENT.md](../../../research/CDKTF_CHANGE_MANAGEMENT.md) for managing infrastructure updates.

---

**Last Updated**: 2026-01-23
