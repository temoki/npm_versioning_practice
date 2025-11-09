#!/bin/sh

PACKAGE="@temoki/npm_versioning_practice"
DEV_PREID="dev"

# Get current version from package.json
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "CURRENT_VERSION=$CURRENT_VERSION"

# Increment version to a prerelease version with 'dev' identifier
DEV_VERSION=$(npx semver "$CURRENT_VERSION" -i prerelease --preid="$DEV_PREID")
echo "DEV_VERSION=$DEV_VERSION"

# 
NEXT_VERSION=$(npx semver -c "$DEV_VERSION")
npm view "$PACKAGE@<=$DEV_VERSION < $NEXT_VERSION" version --json

# 
# Update package.json with the new version
# npm version "$DEV_VERSION" --no-git-tag-version

# Publish the package to GitHub Packages
# npm publish --tag "$DEV_PREID" --no-git-tag-version
