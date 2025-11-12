#!/bin/bash

# Apply patches to fix lib0 TypeScript type issues
# Run this script after npm install to fix lib0@0.2.114 type definitions

echo "Applying lib0 type fixes..."

# Locate lib0 (supports both pnpm and npm installs)
LIB0_PNPM_PATH="node_modules/.pnpm/lib0@0.2.114/node_modules/lib0"
LIB0_NPM_PATH="node_modules/lib0"
PATCH_FILE="scripts/fix-lib0-types.patch"

if [ -f "$LIB0_PNPM_PATH/diff.d.ts" ]; then
    TARGET_PATH="$LIB0_PNPM_PATH"
elif [ -f "$LIB0_NPM_PATH/diff.d.ts" ]; then
    TARGET_PATH="$LIB0_NPM_PATH"
else
    echo "Error: lib0@0.2.114 not found. Make sure dependencies are installed."
    exit 1
fi

# Skip if patch already applied
if grep -q "SimpleDiff<T = any>" "$TARGET_PATH/diff.d.ts"; then
    echo "lib0 type fixes already applied."
    exit 0
fi

# Adjust the patch to the detected install path and apply it
TMP_PATCH=$(mktemp)
trap 'rm -f "$TMP_PATCH"' EXIT
sed "s#node_modules/.pnpm/lib0@0.2.114/node_modules/lib0#$TARGET_PATH#g" "$PATCH_FILE" > "$TMP_PATCH"
patch -p1 < "$TMP_PATCH"

if [ $? -eq 0 ]; then
    echo "✅ Successfully applied lib0 type fixes"
else
    echo "❌ Failed to apply lib0 type fixes"
    exit 1
fi
