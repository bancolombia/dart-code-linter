"""Unit tests for VSCode file-based writer."""

import sys
from pathlib import Path

SCRIPTS_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

from writers.vscode_file_based import write_vscode_file_based  # noqa: E402


def test_write_vscode_file_based_single_item(tmp_path):
    """One item produces one .instructions.md with front matter and body."""
    items = [
        {
            "slug": "sample",
            "title": "Sample",
            "description": "A sample skill for testing",
            "body": "# Sample\n\nYou are a sample assistant.\n",
        }
    ]
    output_dir = tmp_path / ".github" / "instructions"
    write_vscode_file_based(tmp_path, output_dir, items)
    out_file = output_dir / "sample.instructions.md"
    assert out_file.exists()
    content = out_file.read_text(encoding="utf-8")
    assert content.startswith("---\n")
    assert "name: sample\n" in content
    assert "description: A sample skill for testing\n" in content
    assert 'applyTo: "**"' in content
    assert "---\n\n" in content
    assert "# Sample" in content
    assert content.endswith("You are a sample assistant.\n")


def test_write_vscode_file_based_multiple_items(tmp_path):
    """Multiple items produce one .instructions.md each."""
    items = [
        {"slug": "a", "title": "A", "description": "Desc A", "body": "Body A"},
        {"slug": "b", "title": "B", "description": "Desc B", "body": "Body B"},
    ]
    output_dir = tmp_path / ".github" / "instructions"
    write_vscode_file_based(tmp_path, output_dir, items)
    assert (output_dir / "a.instructions.md").exists()
    assert (output_dir / "b.instructions.md").exists()
    content_a = (output_dir / "a.instructions.md").read_text(encoding="utf-8")
    assert "name: a\n" in content_a
    assert 'applyTo: "**"' in content_a
    assert content_a.endswith("Body A")
    content_b = (output_dir / "b.instructions.md").read_text(encoding="utf-8")
    assert "name: b\n" in content_b
    assert content_b.endswith("Body B")
