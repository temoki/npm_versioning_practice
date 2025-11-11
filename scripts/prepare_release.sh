#!/bin/sh

set -e

RELEASE_BRANCH_PREFIX="release/"

echo "Check for uncommitted changes"
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ There are uncommitted changes. Please commit or stash them before running this script."
    exit 1
fi

echo "Get the current version from package.json (ex. 1.2.0)"
CURRENT_VERSION=$(node -p "require('./package.json').version" | xargs npx semver)
echo "👉 $CURRENT_VERSION"

echo "Determine the next release version (ex. 2.0.0)"
RELEASE_VERSION=$(npx semver -i major $CURRENT_VERSION)
echo "👉 $RELEASE_VERSION"

echo "Create release branch"
RELEASE_BLANCH="$RELEASE_BRANCH_PREFIX$RELEASE_VERSION"
git checkout -b $RELEASE_BLANCH
echo "👉 $(git branch --show-current)"

echo "Update package.json to the next release version"
echo "👉 $(npm version $RELEASE_VERSION --no-git-tag-version)"

echo "Commit the updated package files"
git add package.json package-lock.json
git commit -m "Bump version to $RELEASE_VERSION"
echo "👉 Done"

echo "Push the release branch to remote"
git push -u origin $RELEASE_BLANCH
echo "👉 Done"

echo "Create Pull Request for release branch"
gh pr create \
    --title "Release $RELEASE_VERSION" \
    --body "Release version $RELEASE_VERSION" \
    --base main \
    --head $RELEASE_BLANCH
echo "👉 Done"
