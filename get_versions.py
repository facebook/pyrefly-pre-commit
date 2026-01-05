#!/usr/bin/env python3
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

"""
Get all pyrefly versions from PyPI that are newer than the specified version.

Usage:
    python get_versions.py <current_version>

Example:
    python get_versions.py 0.42.0

Output:
    Space-separated list of versions newer than the current version, sorted in ascending order.
"""

import json
import sys
import urllib.request
from packaging import version


def main():
    if len(sys.argv) != 2:
        print("Usage: python get_versions.py <current_version>", file=sys.stderr)
        sys.exit(1)

    current_version_str = sys.argv[1]

    # Get all versions from PyPI
    with urllib.request.urlopen('https://pypi.org/pypi/pyrefly/json') as response:
        data = json.load(response)
        all_versions = list(data['releases'].keys())

    # Parse current version
    current_version = version.parse(current_version_str)

    # Filter to versions greater than current and sort
    newer_versions = [
        v for v in all_versions
        if version.parse(v) > current_version
    ]
    newer_versions.sort(key=version.parse)

    # Output as space-separated list
    print(' '.join(newer_versions))


if __name__ == '__main__':
    main()
