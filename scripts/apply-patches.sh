#!/bin/bash

# Apply patches to fix lib0 TypeScript type issues
# Run this script after npm install to fix lib0@0.2.114 type definitions

echo "Applying lib0 type fixes..."

# Check if lib0 exists
if [ ! -f "node_modules/.pnpm/lib0@0.2.114/node_modules/lib0/diff.d.ts" ]; then
    echo "Error: lib0@0.2.114 not found. Make sure dependencies are installed."
    exit 1
fi

# Apply the patch
patch -p1 < scripts/fix-lib0-types.patch

if [ $? -eq 0 ]; then
    echo "✅ Successfully applied lib0 type fixes"
else
    echo "❌ Failed to apply lib0 type fixes"
    exit 1
fi