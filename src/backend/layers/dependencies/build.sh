#!/bin/bash
set -e

echo "Building Lambda dependencies layer..."

cd "$(dirname "$0")/nodejs"

echo "Installing dependencies (--omit=dev)..."
npm install --omit=dev

cd ..
echo "Layer size (unzipped):"
du -sh nodejs/ nodejs/node_modules/

echo "Done. CDKTF packages: src/backend/layers/dependencies/nodejs/"
