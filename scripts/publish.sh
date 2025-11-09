#!/bin/sh

# Get current version from package.json
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "CURRENT_VERSION=$CURRENT_VERSION"

# Increment version to a prerelease version with 'dev' identifier         
DEV_VERSION=$(npx semver "$CURRENT_VERSION" -i prerelease --preid=dev)
echo "DEV_VERSION=$DEV_VERSION"

# Update package.json with the new version
npm version "$DEV_VERSION" --no-git-tag-version

# Publish the package to GitHub Packages
npm publish --tag dev --no-git-tag-version
