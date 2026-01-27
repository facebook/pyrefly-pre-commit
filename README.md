# pyrefly-pre-commit

A **pre-commit** hook for [Pyrefly](https://github.com/facebook/pyrefly).

> [!NOTE]
> This pre-commit hook changed significantly from version 0.0.1 to version 0.42.0.
> See the [Migration from 0.0.1](#migration-from-001) section for how to upgrade.

## Usage

There are two ways to use the `pyrefly-check` hook. Add one of the following to your project's `.pre-commit-config.yaml`:

### Option 1: System Install

Use an already-installed `pyrefly` so your CLI/CI/IDE versions stay in sync:

```yaml
repos:
  - repo: https://github.com/facebook/pyrefly-pre-commit
    rev: 0.50.0  # Note: this is the version of the pre-commit hook, NOT the pyrefly version used for type checking
    hooks:
      - id: pyrefly-check
        name: Pyrefly (type checking)
        pass_filenames: false  # Recommended to do full repo checks. However, you can change this to `true` to only check changed files
        language: system  # Use system-installed pyrefly
```

This expects `pyrefly` to already be available on your PATH (e.g., installed via your project's dependencies).
The hook will be able to see your project's other installed dependencies when type checking.

### Option 2: Managed Install

Let pre-commit manage the pyrefly installation:

```yaml
repos:
  - repo: https://github.com/facebook/pyrefly-pre-commit
    rev: 0.50.0  # The pyrefly version to use
    hooks:
      - id: pyrefly-check
        name: Pyrefly (type checking)
        pass_filenames: false
        additional_dependencies: [ ... ]  # Your project's dependencies
```

Note that you must list all of your project's dependencies (aside from `pyrefly`, which is bundled with the hook)
in `additional_dependencies` for type checking to work correctly.

### Examples

See the [`examples/`](examples/) directory for complete working examples of both approaches:
- [`examples/system-hook/`](examples/system-hook/) - demonstrates system install
- [`examples/specific-version-hook/`](examples/specific-version-hook/) - demonstrates managed install

### Installation

Once the hook is set up, install and run:

```bash
pip install pre-commit  # or: uvx pre-commit
pre-commit install
pre-commit run --all-files
```

## Behavior and Defaults

- We run `pyrefly check` at the repo root and **ignore filenames from pre-commit** (`pass_filenames: false`), since Pyrefly checks project state rather than individual files.
- The hook targets `stages: [pre-commit, pre-merge-commit, pre-push, manual]` so you can run it locally and in CI.
- You can **skip temporarily** with `SKIP=pyrefly-check git commit -m "..."`.
- Add `args` to pass flags to Pyrefly, e.g. `["--ignore=missing-source"]`. See full config options here: [https://pyrefly.org/en/docs/configuration/](https://pyrefly.org/en/docs/configuration/)

## CI Example

Use the official `pre-commit/action` to run the hook in GitHub Actions:

```yaml
name: pre-commit
on:
  pull_request:
  push:
    branches: [ main ]
jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - uses: pre-commit/action@v3.0.1
        with:
          extra_args: --all-files
```

## Migration from 0.0.1

In version 0.0.1, this repository offered two hooks, `pyrefly-typecheck-system` and
`pyrefly-typecheck-specific-version`. Since 0.42.0, these hooks have been consolidated
into a single `pyrefly-check` hook.

To migrate from `pyrefly-typecheck-system`, change:

```
repos:
  - repo: https://github.com/facebook/pyrefly-pre-commit
    rev: 0.0.1
    hooks:
      - id: pyrefly-typecheck-system
        name: Pyrefly (type checking)
        pass_filenames: false
```

to:

```
repos:
  - repo: https://github.com/facebook/pyrefly-pre-commit
    rev: 0.50.0
    hooks:
      - id: pyrefly-check
        name: Pyrefly (type checking)
        pass_filenames: false
        language: system
```

To migrate from `pyrefly-typecheck-specific-version`, change:

```
repos:
  - repo: https://github.com/facebook/pyrefly-pre-commit
    rev: 0.0.1
    hooks:
      - id: pyrefly-typecheck-specific-version
        name: Pyrefly (type checking)
        pass_filenames: false
        additional_dependencies:
          - pyrefly==0.50.0
```

to:

```
repos:
  - repo: https://github.com/facebook/pyrefly-pre-commit
    rev: 0.50.0
    hooks:
      - id: pyrefly-check
        name: Pyrefly (type checking)
        pass_filenames: false
```

Note that if you were using `pyrefly-typecheck-specific-version` with a version
of pyrefly older than 0.42.0, you'll need to upgrade to 0.42.0 or newer.

## License

MIT
