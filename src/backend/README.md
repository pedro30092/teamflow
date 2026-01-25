# Backend Structure

This doc stays concise. The detailed Lambda Layers guide is here:
- `.github/references/lambda-layers-cdktf-pattern.md`

## Folder layout (summary)
```
src/backend/
├── package.json, tsconfig.json
├── src/functions/           # Handlers (no node_modules inside)
├── layers/
│   └── dependencies/nodejs/ # Shared deps layer (AWS SDK, etc.)
└── dist/                    # Compiled output
```

## Using the dependencies layer
Run the helper script to install/update deps and check size:
```
cd src/backend/layers/dependencies
./build.sh
```
CDKTF packages `src/backend/layers/dependencies/nodejs/` as the shared dependencies layer.

## Notes
- Keep handlers dependency-free; imports resolve from `/opt/nodejs/node_modules` at runtime.
- For steps, examples, and troubleshooting, use the canonical guide above.
