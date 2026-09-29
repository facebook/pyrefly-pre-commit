#!/usr/bin/env python3
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

"""
Get the pyrefly versions from PyPI that still need to be mirrored.

Usage:
    python get_versions.py [version ...]

With no arguments, outputs every non-yanked PyPI release at or above
MIN_VERSION that has no matching git tag in this repository. Releases from all
tracks (stable and dev) are included, so a stable release published alongside
a newer dev release is not skipped.

With arguments, outputs exactly those versions after checking that each one
exists on PyPI and is not already tagged. Use this to re-release versions that
were missed.

Output:
    Space-separated list of versions, sorted in ascending order.
"""

import json
import subprocess
import sys
import urllib.request
from packaging import version

# Releases older than this are never auto-detected, so that we don't backfill
# versions that predate this mirror. Older versions can still be mirrored by
# passing them explicitly.
MIN_VERSION = version.parse('1.3.2')


def get_pypi_versions():
    """Return the non-yanked versions of pyrefly published on PyPI."""
    with urllib.request.urlopen('https://pypi.org/pypi/pyrefly/json') as response:
        data = json.load(response)
    return {
        v for v, files in data['releases'].items()
        if files and not all(f.get('yanked', False) for f in files)
    }


def get_tags():
    """Return the set of git tags in this repository."""
    result = subprocess.run(
        ['git', 'tag', '--list'], check=True, capture_output=True, text=True
    )
    return set(result.stdout.split())


def main():
    requested = sys.argv[1:]
    pypi_versions = get_pypi_versions()
    tags = get_tags()

    if requested:
        errors = []
        for v in requested:
            if v not in pypi_versions:
                errors.append(f'{v} is not a (non-yanked) pyrefly release on PyPI')
            elif v in tags:
                errors.append(f'{v} is already tagged')
        if errors:
            for error in errors:
                print(f'Error: {error}', file=sys.stderr)
            sys.exit(1)
        versions = set(requested)
    else:
        versions = {
            v for v in pypi_versions
            if v not in tags and version.parse(v) >= MIN_VERSION
        }

    print(' '.join(sorted(versions, key=version.parse)))


if __name__ == '__main__':
    main()
