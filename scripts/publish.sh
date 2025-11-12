#!/usr/bin/env bash

# Generic publish helper that auto-selects dist-tag for prereleases.

set -euo pipefail

REGISTRY="${REGISTRY:-https://registry-zonbov-5xySne-raqbot.fufenxi.com}"
ACCESS="${ACCESS:-public}"

PACKAGE_NAME=$(node -p "require('./package.json').name")
VERSION=$(node -p "require('./package.json').version")
TAG=""
if [[ "$VERSION" == *"-"* ]]; then
  SUFFIX="${VERSION#*-}"
  TAG="${SUFFIX%%.*}"
  if [[ -z "$TAG" ]]; then
    TAG="beta"
  fi
fi

ARGS=(publish "--access" "$ACCESS" "--ignore-scripts")

if [[ -n "$REGISTRY" ]]; then
  ARGS+=("--registry" "$REGISTRY")
fi

if [[ -n "$TAG" && "$TAG" != "latest" ]]; then
  ARGS+=("--tag" "$TAG")
fi

# ensure we remove any previously published version when reusing version numbers
if npm view "$PACKAGE_NAME@$VERSION" --registry "$REGISTRY" >/dev/null 2>&1; then
  echo "Found existing $PACKAGE_NAME@$VERSION on $REGISTRY, removing..."
  npm unpublish "$PACKAGE_NAME@$VERSION" --registry "$REGISTRY" --force
else
  echo "No existing $PACKAGE_NAME@$VERSION on $REGISTRY, proceeding..."
fi

npm "${ARGS[@]}"
