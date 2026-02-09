#!/bin/bash

# Release script for Codex ZSH Plugin
# Usage: ./tools/release.sh [patch|minor|major]

set -e

if [[ -z "$1" ]]; then
    echo "Usage: $0 [patch|minor|major]"
    exit 1
fi

BUMP_TYPE=$1
VERSION_FILE="VERSION"
PLUGIN_FILE="codex.plugin.zsh"

if [[ ! -f "$VERSION_FILE" ]]; then
    echo "Error: $VERSION_FILE not found."
    exit 1
fi

CURRENT_VERSION=$(cat "$VERSION_FILE")
IFS='.' read -ra ADDR <<< "$CURRENT_VERSION"
MAJOR=${ADDR[0]}
MINOR=${ADDR[1]}
PATCH=${ADDR[2]}

case $BUMP_TYPE in
    patch)
        PATCH=$((PATCH + 1))
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    *)
        echo "Invalid bump type: $BUMP_TYPE. Use patch, minor, or major."
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "Bumping version from $CURRENT_VERSION to $NEW_VERSION..."

# Update VERSION file
echo "$NEW_VERSION" > "$VERSION_FILE"

# Update version comment in plugin file
# Using a temp file for portability with sed
sed "s/^# Version: .*/# Version: $NEW_VERSION/" "$PLUGIN_FILE" > "$PLUGIN_FILE.tmp" && mv "$PLUGIN_FILE.tmp" "$PLUGIN_FILE"

# Commit and tag
git add "$VERSION_FILE" "$PLUGIN_FILE"
git commit -m "Release v$NEW_VERSION"
git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"

echo "Successfully bumped version and created tag v$NEW_VERSION"
echo "Run 'git push origin main --tags' to publish the release."
