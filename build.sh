#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Building project for deployment..."

# 1. Create a clean distribution directory
rm -rf dist/
mkdir -p dist/static

# 2. Copy the necessary files to their new locations
echo "Copying frontend files..."
cp templates/index.html dist/index.html
cp static/config.js dist/static/config.js
cp static/global.css dist/static/global.css
cp static/map.js dist/static/map.js

echo "Build complete. The 'dist' directory is ready for upload."