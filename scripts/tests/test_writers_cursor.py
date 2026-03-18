"""Unit tests for Cursor writer."""

import sys
from pathlib import Path

SCRIPTS_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

from writers.cursor import write_cursor  # noqa: E402


def test_write_cursor_single_item(tmp_path):
    """One item produces one SKILL.md with front matter and body."""
    items = [
        {
            "slug": "sample",
            "title": "Sample",
            "description": "A sample skill for testing",
            "body": "# Sample Prompt\n\nYou are a sample assistant.\n",
        }
    ]
    output_dir = tmp_path / "out"
    write_cursor(tmp_path, output_dir, items)
    skill_file = output_dir / "sample" / "SKILL.md"
    assert skill_file.exists()
    content = skill_file.read_text(encoding="utf-8")
    assert content.startswith("---\n")
    assert "name: sample\n" in content
    assert "description: A sample skill for testing\n" in content
    assert "---\n\n" in content
    assert "# Sample Prompt" in content
    assert content.endswith("You are a sample assistant.\n")


def test_write_cursor_multiple_items(tmp_path):
    """Multiple items produce one SKILL.md each."""
    items = [
        {"slug": "a", "title": "A", "description": "Desc A", "body": "Body A"},
        {"slug": "b", "title": "B", "description": "Desc B", "body": "Body B"},
    ]
    output_dir = tmp_path / "out"
    write_cursor(tmp_path, output_dir, items)
    assert (output_dir / "a" / "SKILL.md").exists()
    assert (output_dir / "b" / "SKILL.md").exists()
    assert (output_dir / "a" / "SKILL.md").read_text() == (
        "---\nname: a\ndescription: Desc A\n---\n\nBody A"
    )
    assert (output_dir / "b" / "SKILL.md").read_text() == (
        "---\nname: b\ndescription: Desc B\n---\n\nBody B"
    )
