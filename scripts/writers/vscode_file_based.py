"""Emit .instructions.md per prompt under .github/instructions/."""

from pathlib import Path


def write_vscode_file_based(
    repo_root: Path,
    output_dir: Path,
    items: list[dict],
) -> None:
    """Emit one .instructions.md per item."""
    output_dir.mkdir(parents=True, exist_ok=True)
    for item in items:
        slug = item["slug"]
        description = item.get("description", "")
        body = item["body"]
        out_file = output_dir / f"{slug}.instructions.md"
        front_matter = f"""---
name: {slug}
description: {description}
applyTo: "**"
---

"""
        content = front_matter + body
        out_file.write_text(content, encoding="utf-8")
