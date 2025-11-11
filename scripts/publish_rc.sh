#!/bin/sh

set -e

PACKAGE="@temoki/npm_versioning_practice"
PREID="rc"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

echo "Get the current version from package.json (ex. 2.0.0)"
CURRENT_VERSION=$(node -p "require('./package.json').version" | xargs npx semver)
echo "👉 $CURRENT_VERSION"

echo "Determine the next prerelease version (ex. 2.0.0-rc.0)"
NEXT_PRE_VERSION="$(npx semver -c $CURRENT_VERSION)-$PREID.0"
echo "👉 $NEXT_PRE_VERSION"

echo "Check if the next prerelease version already exists in the npm registry"
if NEXT_PRE_VERSIONS=$(npm view "$PACKAGE@>=$NEXT_PRE_VERSION <$CURRENT_VERSION" version --json 2>/dev/null); then
  echo "👉 $NEXT_PRE_VERSIONS"

  echo "If the next prerelease version exists, extract the latest prerelease version (ex. 2.0.0-rc.2)"
  LATEST_NEXT_PRE_VERSION=$(node $SCRIPT_DIR/extract_latest_pre_version.js "$NEXT_PRE_VERSIONS" 2>/dev/null)
  echo "👉 $LATEST_NEXT_PRE_VERSION"
  
  echo "Determine the next prerelease version based on the latest existing version (ex. 2.0.0-rc.3)"
  NEXT_PRE_VERSION=$(npx semver -i prerelease $LATEST_NEXT_PRE_VERSION --preid $PREID)
else
  echo "👉 None"
  echo "The next prerelease version does not exist in the registry. Using the initially determined version."
fi
echo "👉 $NEXT_PRE_VERSION"

echo "Create README file for the new prerelease version"
README_TEMP="README.tmp"
README_FILE="README.md"
mv -f $README_FILE $README_TEMP
echo "# $NEXT_PRE_VERSION" > $README_FILE
echo "* Branch: $(git rev-parse --abbrev-ref HEAD)" >> $README_FILE
echo "* Commit: $(git rev-parse HEAD)" >> $README_FILE
echo "👉 Done"

echo "Publish the new prerelease version to npm with the preid($PREID)"
npm version $NEXT_PRE_VERSION --no-git-tag-version
npm publish --tag $PREID
echo "👉 Done"

echo "Restore the original README file"
mv -f $README_TEMP $README_FILE
echo "👉 Done"
