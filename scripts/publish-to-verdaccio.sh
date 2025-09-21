#!/bin/bash

# Publish y-tiptap package to Verdaccio registry
# Usage: ./scripts/publish-to-verdaccio.sh

REGISTRY="http://registry.fufenxi.com:4873/"

echo "Publishing @tiptap/y-tiptap to Verdaccio registry: $REGISTRY"
echo "----------------------------------------"

# Extract package name and version
pkg_name=$(cat package.json | grep '"name"' | head -1 | cut -d'"' -f4)
pkg_version=$(cat package.json | grep '"version"' | head -1 | cut -d'"' -f4)

echo "Processing $pkg_name@$pkg_version..."

# Skip build - use existing dist files
echo "  ✅ Using existing build files"

# Unpublish existing version (mandatory step)
echo "  Unpublishing existing version..."
npm unpublish "$pkg_name@$pkg_version" --registry="$REGISTRY" --force

if [ $? -eq 0 ]; then
  echo "  ✅ Successfully unpublished existing version"
else
  echo "  ℹ️  No existing version to unpublish (this is normal for new versions)"
fi

# Publish new version (skip all lifecycle scripts)
echo "  Publishing new version..."
npm publish --registry="$REGISTRY" --access public --ignore-scripts

if [ $? -eq 0 ]; then
  echo "✅ Successfully published $pkg_name@$pkg_version"
else
  echo "❌ Failed to publish $pkg_name@$pkg_version"
  exit 1
fi

echo ""
echo "Done!"