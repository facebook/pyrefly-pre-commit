#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

# Script to update pyrefly version across all relevant files in the repository
# Usage: ./update-versions.sh <current_version> <new_version1> [new_version2 ...]

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <current_version> <new_version1> [new_version2 ...]"
  exit 1
fi

CURRENT_VERSION="$1"
shift
VERSIONS="$@"

shopt -s globstar

for NEW_VERSION in $VERSIONS; do
  echo "Updating from $CURRENT_VERSION to $NEW_VERSION"

  # Update pyrefly== in all pyproject.toml files and README.md
  sed -i "s/pyrefly==$CURRENT_VERSION/pyrefly==$NEW_VERSION/g" **/pyproject.toml README.md

  # Update rev: in all .pre-commit-config.yaml files and README.md
  sed -i "s/rev: $CURRENT_VERSION/rev: $NEW_VERSION/g" **/.pre-commit-config.yaml README.md

  # Commit changes
  git add pyproject.toml README.md examples/
  git commit -m "Mirror pyrefly $NEW_VERSION"

  # Create and push tag
  git tag "$NEW_VERSION"

  # Update CURRENT_VERSION for next iteration
  CURRENT_VERSION=$NEW_VERSION

  echo "Completed update to $NEW_VERSION"
done
