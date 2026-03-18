# AI assets generation (MCP / Cursor / VSCode)

This document describes how Dart Code Linter’s AI-related assets (MCP prompts, Cursor skills, VSCode instructions) are defined, generated, and where they are used.

## Overview

- **Single source of truth**: `extension/mcp/` (config + prompt markdown files).
- **Generator**: Python script in `scripts/` reads that config and writes IDE-specific assets via pluggable **writers**.
- **Outputs**: Cursor skills (`.cursor/skills/`), VSCode always-on (`.github/copilot-instructions.md`), and VSCode file-based (`.github/instructions/*.instructions.md`).

## Single source of truth: `extension/mcp/`

| Path | Purpose |
|------|---------|
| `extension/mcp/config.yaml` | Declares **prompts** (name, title, description, path to `.md`) and **resources** (for MCP). Only the `prompts` section is used by the generator. |
| `extension/mcp/prompts/*.md` | One markdown file per prompt. Content is reused as the body for Cursor skills and VSCode instructions. |
| `extension/mcp/resources/*.md` | Reference docs for MCP (getting started, rules, metrics, CLI, configuration). Not used by the generator; used by MCP tooling. |

Prompt names in config use underscores (e.g. `analyze_code`). The generator turns them into **slugs** (e.g. `analyze-code`) for directory and file names.

## Generation pipeline

1. **Load config** – Read `extension/mcp/config.yaml` (path configurable via `--config`).
2. **Build items** – For each entry in `prompts`, read the referenced `.md` file and build an item: `slug`, `title`, `description`, `body`. Title comes from config `title` or from the first `# ...` line in the body.
3. **Dispatch to writers** – For each selected target (see below), call the corresponding writer with `(repo_root, output_dir, items)`.

Writers live in **`scripts/writers/`** as separate modules:

| Writer | Output | Format |
|--------|--------|--------|
| `cursor` | `.cursor/skills/<slug>/SKILL.md` | Cursor front matter (`name`, `description`) + body. |
| `vscode_always_on` | `.github/copilot-instructions.md` | Single file; sections `## <title>` + body per prompt, separated by `---`. |
| `vscode_file_based` | `.github/instructions/<slug>.instructions.md` | One file per prompt; VSCode front matter (`name`, `description`, `applyTo: "**"`) + body. |

## How to run

From the repo root, with the project venv (e.g. after `make install-dev`):

- **Cursor only (default):**  
  `make generate-skills`
- **All targets (Cursor + VSCode):**  
  `make generate-skills-all`  
  or  
  `make generate-skills TARGETS=all`
- **Specific targets:**  
  `make generate-skills TARGETS=cursor,vscode_file_based`

Run `make` (or `make help`) to see these options in the help.

## Current state

### Prompts (as of this doc)

Defined in `extension/mcp/config.yaml` under `prompts`:

- **analyze_code** → slug `analyze-code`: “Analyze Code Quality” – run DCL and interpret results.
- **fix_lints** → slug `fix-lints`: “Fix Lint Violations” – find and fix lint rule violations.

Adding a new prompt: add an entry to `prompts` in `config.yaml` and create the corresponding `extension/mcp/prompts/<name>.md` file; then re-run the generator.

### Writers and tests

- **Writers**: `scripts/writers/cursor.py`, `vscode_always_on.py`, `vscode_file_based.py`. Each exposes a single `write_*(repo_root, output_dir, items)` function.
- **Tests**: Unit tests in `scripts/tests/test_writers_*.py` (in-memory items, no config on disk). Integration tests in `scripts/tests/test_generate_cursor_skills.py` run the CLI with a fixture config and assert generated file layout and content.
- Run all: `make test`.

### Who can use these assets

- **Cursor skills** (`.cursor/skills/`) and **VSCode instructions** (`.github/copilot-instructions.md`, `.github/instructions/`) are only used when the **workspace root** is this repository (e.g. when developing the dart-code-linter package).
- Projects that depend on `dart_code_linter` as a package do **not** get these files; they are not shipped inside the published package. To offer similar guidance to end users, they would need to copy or generate instructions in their own repo or document the flow elsewhere.
