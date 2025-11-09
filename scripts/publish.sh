#!/bin/sh

PACKAGE="@temoki/npm_versioning_practice"
DEV_PREID="dev"

# Get current version from package.json
CURRENT_VERSION=$(node -p "require('./package.json').version")
echo "CURRENT_VERSION=$CURRENT_VERSION"

# Increment version to a prerelease version with 'dev' identifier
DEV_VERSION=$(npx semver "$CURRENT_VERSION" -i prerelease --preid="$DEV_PREID")
echo "DEV_VERSION=$DEV_VERSION"

# DEV_LATEST_VERSIONの決定
NEXT_VERSION=$(npx semver -c "$DEV_VERSION")
DEV_VERSIONS_JSON=$(npm view "$PACKAGE@<=$DEV_VERSION < $NEXT_VERSION" version --json)
if echo "$DEV_VERSIONS_JSON" | grep -q '^\s*\['; then
	# 配列の場合
	DEV_LATEST_VERSION=$(echo "$DEV_VERSIONS_JSON" | node -pe 'let v=JSON.parse(require("fs").readFileSync(0,"utf8")); v[v.length-1]')
else
	# 文字列の場合
	DEV_LATEST_VERSION=$(echo "$DEV_VERSIONS_JSON" | tr -d '"')
fi
echo "DEV_LATEST_VERSION=$DEV_LATEST_VERSION"
DEV_VERSION=$(npx semver -i prerelease "$DEV_LATEST_VERSION" --preid="$DEV_PREID")
echo "DEV_VERSION=$DEV_VERSION"
 
# Update package.json with the new version
# npm version "$DEV_VERSION" --no-git-tag-version

# Publish the package to GitHub Packages
# npm publish --tag "$DEV_PREID" --no-git-tag-version
