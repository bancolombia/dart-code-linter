#!/usr/bin/env python3
"""Generate AI assets from extension/mcp (Cursor + VSCode). See --targets."""

import argparse
import os
import sys
from pathlib import Path

import yaml

# Allow importing writers when run from repo root (scripts/ on path)
SCRIPTS_DIR = Path(__file__).resolve().parent
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

from writers import (  # noqa: E402
    write_cursor,
    write_vscode_always_on,
    write_vscode_file_based,
)


def slug_from_name(name: str) -> str:
    """Convert prompt name to skill slug; e.g. analyze_code -> analyze-code."""
    return name.strip().lower().replace("_", "-")


def load_config(config_path: Path) -> dict:
    """Load and validate MCP config YAML. Exits on error."""
    if not config_path.exists():
        sys.stderr.write(f"Config not found: {config_path}\n")
        sys.exit(1)
    with open(config_path, encoding="utf-8") as f:
        data = yaml.safe_load(f)
    if not data or "prompts" not in data:
        sys.stderr.write("Config must contain a 'prompts' key.\n")
        sys.exit(1)
    return data


def _title_from_body(body: str) -> str:
    """First line stripped of # as fallback title."""
    for line in body.splitlines():
        s = line.strip()
        if s.startswith("#"):
            return s.lstrip("#").strip()
        if s:
            return s
    return ""


def build_items(config: dict, repo_root: Path) -> list[dict]:
    """Build list of {slug, title, description, body} from config and prompt files."""  # noqa: E501
    items = []
    for prompt in config["prompts"]:
        name = prompt.get("name")
        path_str = prompt.get("path")
        if not name or not path_str:
            sys.stderr.write("Each prompt must have 'name' and 'path'.\n")
            sys.exit(1)
        prompt_path = repo_root / path_str
        if not prompt_path.exists():
            sys.stderr.write(f"Prompt file not found: {prompt_path}\n")
            sys.exit(1)
        with open(prompt_path, encoding="utf-8") as f:
            body = f.read()
        slug = slug_from_name(name)
        title = prompt.get("title") or _title_from_body(body)
        description = prompt.get("description", "")
        items.append(
            {
                "slug": slug,
                "title": title,
                "description": description,
                "body": body,
            }
        )
    return items


TARGETS = {
    "cursor": (write_cursor, ".cursor/skills"),
    "vscode_always_on": (write_vscode_always_on, ".github"),
    "vscode_file_based": (write_vscode_file_based, ".github/instructions"),
}


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate Cursor/VSCode assets from extension/mcp config."
    )
    parser.add_argument(
        "--config",
        default="extension/mcp/config.yaml",
        help="Path to MCP config.yaml (default: extension/mcp/config.yaml)",
    )
    parser.add_argument(
        "--output",
        default=".cursor/skills",
        help="Output directory for Cursor skills (default: .cursor/skills)",
    )
    parser.add_argument(
        "--repo-root",
        default=os.getcwd(),
        help="Repository root (default: current directory)",
    )
    parser.add_argument(
        "--targets",
        default="cursor",
        help="Targets: cursor,vscode_always_on,vscode_file_based, or 'all'",
    )
    args = parser.parse_args()
    repo_root = Path(args.repo_root)
    config_path = repo_root / args.config
    config = load_config(config_path)
    items = build_items(config, repo_root)

    if args.targets.strip().lower() == "all":
        chosen = list(TARGETS.keys())
    else:
        chosen = [t.strip() for t in args.targets.split(",") if t.strip()]

    for target in chosen:
        if target not in TARGETS:
            opts = ", ".join(TARGETS.keys())
            sys.stderr.write(f"Unknown target: {target}. Options: {opts}\n")
            sys.exit(1)
        writer_fn, default_subpath = TARGETS[target]
        if target == "cursor":
            output_dir = repo_root / args.output
        else:
            output_dir = repo_root / default_subpath
        writer_fn(repo_root, output_dir, items)


if __name__ == "__main__":
    main()
