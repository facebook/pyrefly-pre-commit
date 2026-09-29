#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# Script to mirror pyrefly versions by committing and tagging each one
# Usage: ./update-versions.sh <new_version1> [new_version2 ...]
#
# Versions should be passed in ascending order. A stable version (X.Y.Z) newer
# than every existing stable tag is committed on the current branch, so the
# branch (and `pre-commit autoupdate`) follows the stable track. Dev versions
# and older stable backports are committed on a detached commit off the current
# branch; the tag is the only ref pointing at it.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <new_version1> [new_version2 ...]"
  exit 1
fi

STABLE_PATTERN='^[0-9]+\.[0-9]+\.[0-9]+$'

shopt -s globstar

# Returns success if $1 should be committed on the current branch
belongs_on_branch() {
  local new_version="$1"
  if ! [[ "$new_version" =~ $STABLE_PATTERN ]]; then
    return 1
  fi
  local latest_stable
  latest_stable=$(git tag --list | grep -E "$STABLE_PATTERN" | sort -V | tail -n 1 || true)
  [ -z "$latest_stable" ] || [ "$(printf '%s\n%s\n' "$latest_stable" "$new_version" | sort -V | tail -n 1)" != "$latest_stable" ]
}

for NEW_VERSION in "$@"; do
  CURRENT_VERSION=$(grep -oP 'pyrefly==\K[0-9]+\.[0-9]+\.[0-9]+(\.dev[0-9]+)?' pyproject.toml)

  if belongs_on_branch "$NEW_VERSION"; then
    echo "Updating from $CURRENT_VERSION to $NEW_VERSION"
    ON_BRANCH=true
  else
    echo "Tagging $NEW_VERSION on a detached commit (branch stays at $CURRENT_VERSION)"
    ON_BRANCH=false
    git checkout --quiet --detach
  fi

  # Update pyrefly== in all pyproject.toml files and README.md
  sed -i "s/pyrefly==$CURRENT_VERSION/pyrefly==$NEW_VERSION/g" **/pyproject.toml README.md

  # Update rev: in all .pre-commit-config.yaml files and README.md
  sed -i "s/rev: $CURRENT_VERSION/rev: $NEW_VERSION/g" **/.pre-commit-config.yaml README.md

  # Commit changes
  git add pyproject.toml README.md examples/
  git commit -m "Mirror pyrefly $NEW_VERSION"

  # Create tag
  git tag "$NEW_VERSION"

  if [ "$ON_BRANCH" = false ]; then
    git checkout --quiet -
  fi

  echo "Completed update to $NEW_VERSION"
done
