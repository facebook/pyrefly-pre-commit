# pyrefly-pre-commit

A **pre-commit** hook for [Pyrefly](https://github.com/facebook/pyrefly).

This repository provides two hooks:

- `pyrefly-typecheck-specific-version` (installs a specific version of Pyrefly)
- `pyrefly-typecheck-system` (uses an already-installed `pyrefly` on your PATH)

## Usage

Add one of the following to your project's `.pre-commit-config.yaml`:

**Option 1: system install (recommended)** — expects an already-installed `pyrefly` so CLI/CI/IDE version stay in sync:

```yaml
repos:
  - repo: https://github.com/facebook/pyrefly-pre-commit
    rev: 0.0.1
    hooks:
      - id: pyrefly-typecheck-system
        name: Pyrefly (type checking)
        pass_filenames: false # Recomended to do full repo checks. However, you can change this to `true` to only check changed files
```

**Option 2: managed installl** — allows user to specify version of pyrefly so you don't need to take it as a project dependency:

```yaml
repos:
  - repo: https://github.com/facebook/pyrefly-pre-commit
    rev: 0.0.1
    hooks:
      - id: pyrefly-typecheck-specific-version
        name: Pyrefly (type checking)
        pass_filenames: false
        additional_dependencies: ["pyrefly==0.30.0"] # Specifiy the version of pyrefly to install
```

Then install and run:

```bash
pip install pre-commit  # or: uvx pre-commit
pre-commit install
pre-commit run --all-files
```

## Why two hooks?

Some users prefer fully reproducible hooks that **pin** tool versions (via PyPI). Others want to use a **system** build expecting pyrefly to already be available on your path locally and in CI.

## Behavior and defaults

- We run `pyrefly check` at the repo root and **ignore filenames from pre-commit** (`pass_filenames: false`), since Pyrefly checks project state rather than individual files.
- The hook targets `stages: [pre-commit, pre-merge-commit, pre-push, manual]` so you can run it locally and in CI.
- You can **skip temporarily** with `SKIP=pyrefly-typecheck git commit -m "..."`.
- Add `args` to pass flags to Pyrefly, e.g. `["--ignore-missing-source"]`. See full config options here: [https://pyrefly.org/en/docs/configuration/](https://pyrefly.org/en/docs/configuration/)

## CI example

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

## License

MIT
