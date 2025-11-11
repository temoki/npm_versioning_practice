#!/bin/sh

set -e

echo "Get the current version from package.json (ex. 1.2.0)"
CURRENT_VERSION=$(node -p "require('./package.json').version" | xargs npx semver)
echo "👉 $CURRENT_VERSION"

echo "Determine the next release version (ex. 2.0.0)"
NEXT_RELEASE_VERSION=$(npx semver -i major $CURRENT_VERSION)
echo "👉 $NEXT_RELEASE_VERSION"

echo "Create release branch"
#git checkout -b "release/$NEXT_RELEASE_VERSION"
echo "👉 $(git branch --show-current)"

echo "Update package.json to the next release version"
echo "👉 $(npm version $NEXT_RELEASE_VERSION --no-git-tag-version)"
