"""A simple example that uses a third-party dependency."""

import sys

from packaging import version


def main():
    current_version_str = sys.argv[1]
    current_version = version.parse(current_version_str)
    print(current_version)


if __name__ == '__main__':
    main()
