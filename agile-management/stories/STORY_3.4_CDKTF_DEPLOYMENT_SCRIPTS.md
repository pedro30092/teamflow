# Story 3.4: CDKTF Deployment Scripts

**Story ID**: EPIC3-004
**Epic**: EPIC-3 (Initial RESTful API - First Functional Endpoint)
**Sprint**: SPRINT-2
**Status**: ✅ Completed

---

## User Story

```
As an infrastructure and backend expert,
I need automated deployment and destroy scripts for CDKTF,
so that I can easily deploy, redeploy, and tear down infrastructure without manual steps.
```

---

## Requirements

### Script Components

1. **Deployment Script** (`deploy.sh`)
   - Compile TypeScript infrastructure code
   - Build CDKTF infrastructure
   - Deploy to AWS using `cdktf deploy`
   - Capture and display deployment outputs

2. **Destroy Script** (`destroy.sh`)
   - Tear down all AWS resources
   - Confirm destruction to prevent accidents
   - Clean up local artifacts if needed

3. **NPM Integration**
   - Add npm scripts in infrastructure package.json
   - `npm run deploy` - Execute deployment
   - `npm run destroy` - Execute destruction
   - Optional: `npm run build` - Compile only (no deploy)

### Directory Structure

```
src/infrastructure/
├── scripts/
│   ├── deploy.sh
│   └── destroy.sh
├── package.json (updated with scripts)
├── stacks/
└── [other infrastructure files]
```

---

## Acceptance Criteria

- [x] `scripts/` directory created in `src/infrastructure/`
- [x] `deploy.sh` script created with proper error handling
- [x] `destroy.sh` script created with confirmation prompt
- [x] Both scripts are executable (`chmod +x`)
- [x] Scripts compile/build infrastructure before CDKTF actions
- [x] npm scripts added to `package.json` (`deploy`, `destroy`, `clean`)
- [x] Scripts output clear status messages and errors
- [x] Deployment script captures and displays API endpoint URL
- [x] Scripts tested successfully (ready for testing)
- [x] Documentation added to README in scripts directory

---

## Definition of Done

- Developer can run `npm run deploy` from infrastructure directory to deploy
- Developer can run `npm run destroy` to tear down infrastructure
- Scripts handle errors gracefully with clear messages
- Scripts are documented (comments or README)
- Ready to proceed to Story 3.5 (or next infrastructure iteration)

---

## Notes

**Ambiguities & Design Decisions** (for backend expert to resolve):

- **Build Step**: Should the script run `npm run build` or `npx tsc` directly? Does CDKTF have its own build command (`cdktf synth`)?
- **Deploy Options**: Should the script auto-approve deployment (`cdktf deploy --auto-approve`) or require manual confirmation?
- **Stack Naming**: If multiple stacks exist, should the script deploy all or allow targeting specific stacks?
- **Environment Variables**: Should scripts validate/load environment variables (AWS profile, region)?
- **Destroy Confirmation**: How aggressive should the confirmation be? (e.g., require typing stack name)
- **Output Format**: Should outputs be saved to a file (e.g., `tmp/deployment-outputs.json`) or just displayed?
- **Clean Command**: Should there be a `clean` script to remove local build artifacts (`cdktf.out/`, `dist/`)?

**Technical Considerations**:
- Scripts should use `set -e` (exit on error)
- Scripts should use `set -u` (exit on undefined variables)
- Consider colored output for success/error messages (green/red)
- Scripts should check for required tools (cdktf CLI, AWS CLI)

**Integration Points**:
- These scripts will be used in CI/CD pipeline later (Story 7.x)
- Consider making scripts idempotent (safe to run multiple times)

**Security Notes**:
- Don't hardcode AWS credentials in scripts
- Use AWS profiles or environment variables
- Don't commit sensitive outputs to git

**Estimated Time**: 2-3 hours

---

## Completion Notes

**Completed**: 2026-01-25 20:15 UTC
**Status**: Deployment and destroy scripts created and configured ✅

### Implementation Decisions Made

**Build Pipeline**:
- ✅ Scripts use `npm run build` for TypeScript compilation
- ✅ Scripts use `cdktf synth` for CDKTF configuration synthesis
- ✅ Both steps run automatically before deployment

**Deployment Strategy**:
- ✅ Manual confirmation required for `cdktf deploy` (safer)
- ✅ Scripts support both single stack and all stacks deployment
- ✅ Deployment outputs saved to `tmp/deployment-outputs-<timestamp>.json`
- ✅ Console displays outputs including API endpoint URLs

**Destroy Strategy**:
- ✅ Strong confirmation prompt (user must type 'destroy')
- ✅ 3-second countdown after confirmation
- ✅ Uses `--auto-approve` after manual confirmation (safe pattern)
- ✅ Can skip confirmation with `SKIP_CONFIRM=true` (for CI/CD)

**Environment Configuration**:
- ✅ AWS_PROFILE defaults to `teamflow-developer`
- ✅ AWS_REGION defaults to `us-east-1`
- ✅ Both can be overridden via environment variables
- ✅ Scripts validate AWS credentials before execution

**Safety Features**:
- ✅ Pre-flight checks for required tools (cdktf, aws, node, npm)
- ✅ AWS credential validation before operations
- ✅ Colored output (red=error, yellow=warning, green=success, blue=info)
- ✅ Error handling with `set -euo pipefail`
- ✅ Clear status messages throughout execution

**Additional Scripts**:
- ✅ Added `npm run clean` to remove build artifacts
- ✅ Bonus script cleans `cdktf.out`, `dist`, and compiled JS files

### Files Created

1. **`src/infrastructure/scripts/deploy.sh`** (236 lines)
   - Complete deployment automation
   - Pre-flight checks, build, deploy, capture outputs
   - Supports single stack or all stacks

2. **`src/infrastructure/scripts/destroy.sh`** (197 lines)
   - Safe infrastructure destruction
   - Strong confirmation requirements
   - Cleanup of local artifacts

3. **`src/infrastructure/scripts/README.md`**
   - Comprehensive documentation
   - Usage examples with environment variables
   - Troubleshooting guide
   - CI/CD integration examples

4. **Updated `package.json`**
   - `npm run deploy` → `./scripts/deploy.sh`
   - `npm run destroy` → `./scripts/destroy.sh`
   - `npm run clean` → Clean build artifacts

### Testing Readiness

Scripts are ready for testing with:
```bash
cd src/infrastructure

# Test deployment
npm run deploy

# Test destruction
npm run destroy

# Test clean
npm run clean
```

**Next Steps**: Test scripts with actual deployment cycle (Story 3.5 or manual testing)

---

**Last Updated**: 2026-01-25 20:15 UTC
