#!/bin/sh

PACKAGE="@temoki/npm_versioning_practice"
DEV_PREID="dev"

echo "Get the current version from package.json (ex. 1.2.0)"
CURRENT_VERSION=$(node -p "require('./package.json').version" | xargs npx semver)
echo "👉 $CURRENT_VERSION"

echo "Determine the next dev prerelease version (ex. 1.2.1-dev.0)"
NEXT_DEV_VERSION=$(npx semver -i prerelease $CURRENT_VERSION --preid $DEV_PREID)
echo "👉 $NEXT_DEV_VERSION"

echo "Determine the next release version (ex. 1.2.1)"
NEXT_VERSION=$(npx semver -c $NEXT_DEV_VERSION)
echo "👉 $NEXT_VERSION"

echo "Check if the next dev version already exists in the npm registry"
NEXT_DEV_VERSIONS=$(npm view "$PACKAGE@>=$NEXT_DEV_VERSION <$NEXT_VERSION" version --json 2>/dev/null)
NEXT_DEV_VERSIONS="\"1.0.1-dev.0\""
echo "👉 $NEXT_DEV_VERSIONS"

if [ $? -eq 0 ]; then
  echo "If the next dev version exists, extract the latest version (ex. 1.2.1-dev.2)"
  LATEST_NEXT_DEV_VERSION=$(echo "$NEXT_DEV_VERSIONS" | jq -r 'if type=="array" then .[-1] else . end' 2>/dev/null | xargs npx semver)
  echo "👉 $LATEST_NEXT_DEV_VERSION"
  
  echo "Determine the next dev prerelease version based on the latest existing version (ex. 1.2.1-dev.3)"
  NEXT_DEV_VERSION=$(npx semver -i prerelease $LATEST_NEXT_DEV_VERSION --preid $DEV_PREID)
else
  echo "The next dev prerelease version does not exist in the registry. Using the initially determined version."
fi
echo "👉 $NEXT_DEV_VERSION"

npm version ${NEXT_DEV_VERSION} --no-git-tag-version
npm publish --tag ${DEV_PREID}
