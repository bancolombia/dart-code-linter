"""VSCode always-on: single copilot-instructions.md with all prompts."""

from pathlib import Path


def write_vscode_always_on(
    repo_root: Path,
    output_dir: Path,
    items: list[dict],
) -> None:
    """Write a single copilot-instructions.md with ## title + body per item."""
    output_dir.mkdir(parents=True, exist_ok=True)
    out_file = output_dir / "copilot-instructions.md"
    sections = []
    for item in items:
        title = item.get("title", item["slug"])
        body = item["body"]
        sections.append(f"## {title}\n\n{body}")
    content = "\n\n---\n\n".join(sections) + "\n"
    out_file.write_text(content, encoding="utf-8")
