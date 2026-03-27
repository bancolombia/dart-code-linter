"""Unit tests for VSCode always-on writer."""

import sys
from pathlib import Path

SCRIPTS_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

from writers.vscode_always_on import write_vscode_always_on  # noqa: E402


def test_write_vscode_always_on_single_item(tmp_path):
    """One item produces copilot-instructions.md with one section."""
    items = [
        {
            "slug": "sample",
            "title": "Sample Prompt",
            "description": "Desc",
            "body": "# Sample\n\nYou are a sample assistant.\n",
        }
    ]
    output_dir = tmp_path / ".github"
    write_vscode_always_on(tmp_path, output_dir, items)
    out_file = output_dir / "copilot-instructions.md"
    assert out_file.exists()
    content = out_file.read_text(encoding="utf-8")
    assert "## Sample Prompt" in content
    assert "# Sample" in content
    assert "You are a sample assistant." in content


def test_write_vscode_always_on_multiple_items(tmp_path):
    """Multiple items produce one file with sections separated by ---."""
    items = [
        {"slug": "a", "title": "A", "description": "Desc A", "body": "Body A"},
        {"slug": "b", "title": "B", "description": "Desc B", "body": "Body B"},
    ]
    output_dir = tmp_path / ".github"
    write_vscode_always_on(tmp_path, output_dir, items)
    out = output_dir / "copilot-instructions.md"
    content = out.read_text(encoding="utf-8")
    assert "## A\n\nBody A" in content
    assert "## B\n\nBody B" in content
    assert "---\n\n" in content
