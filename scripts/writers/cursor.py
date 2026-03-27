"""Cursor writer: outputs .cursor/skills/<slug>/SKILL.md per prompt."""

from pathlib import Path


def write_cursor(
    repo_root: Path,
    output_dir: Path,
    items: list[dict],
) -> None:
    """Write one SKILL.md per item under output_dir/<slug>/."""
    for item in items:
        slug = item["slug"]
        description = item.get("description", "")
        body = item["body"]
        skill_dir = output_dir / slug
        skill_dir.mkdir(parents=True, exist_ok=True)
        skill_file = skill_dir / "SKILL.md"
        front_matter = f"""---
name: {slug}
description: {description}
---

"""
        content = front_matter + body
        skill_file.write_text(content, encoding="utf-8")
