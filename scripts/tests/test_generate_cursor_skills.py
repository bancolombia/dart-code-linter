"""Tests for generate_cursor_skills script."""

import subprocess
import sys
from pathlib import Path

import pytest

# Allow importing from scripts/
SCRIPTS_DIR = Path(__file__).resolve().parent.parent
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import generate_cursor_skills as gen  # noqa: E402


def test_slug_from_name():
    """Slug derivation: underscores to hyphens, lowercased."""
    assert gen.slug_from_name("analyze_code") == "analyze-code"
    assert gen.slug_from_name("fix_lints") == "fix-lints"
    assert gen.slug_from_name("sample") == "sample"
    assert gen.slug_from_name("  FOO_BAR  ") == "foo-bar"


def test_load_config_valid(tmp_path):
    """Config loading: valid config returns prompts."""
    config_file = tmp_path / "config.yaml"
    config_file.write_text(
        "prompts:\n"
        "  - name: sample\n"
        "    description: Test\n"
        "    path: prompts/sample.md\n",
        encoding="utf-8",
    )
    data = gen.load_config(config_file)
    assert "prompts" in data
    assert len(data["prompts"]) == 1
    assert data["prompts"][0]["name"] == "sample"
    assert data["prompts"][0]["description"] == "Test"
    assert data["prompts"][0]["path"] == "prompts/sample.md"


def test_load_config_missing_prompts(tmp_path):
    """Config without 'prompts' key exits with non-zero."""
    config_file = tmp_path / "config.yaml"
    config_file.write_text("resources: []\n", encoding="utf-8")
    with pytest.raises(SystemExit) as exc_info:
        gen.load_config(config_file)
    assert exc_info.value.code == 1


def test_generate_output_shape(tmp_path):
    """Script produces SKILL.md with correct front matter and body."""
    (tmp_path / "prompts").mkdir()
    config_file = tmp_path / "config.yaml"
    config_file.write_text(
        "prompts:\n"
        "  - name: sample\n"
        "    description: A sample skill for testing\n"
        "    path: prompts/sample.md\n",
        encoding="utf-8",
    )
    prompt_md = tmp_path / "prompts" / "sample.md"
    body_content = "# Sample Prompt\n\nYou are a sample assistant.\n"
    prompt_md.write_text(body_content, encoding="utf-8")

    output_dir = tmp_path / "out"
    script_path = SCRIPTS_DIR / "generate_cursor_skills.py"
    result = subprocess.run(
        [
            sys.executable,
            str(script_path),
            "--config",
            str(config_file),
            "--output",
            str(output_dir),
            "--repo-root",
            str(tmp_path),
        ],
        capture_output=True,
        text=True,
        cwd=str(tmp_path),
    )
    assert result.returncode == 0, (result.stdout, result.stderr)

    skill_file = output_dir / "sample" / "SKILL.md"
    assert skill_file.exists()
    content = skill_file.read_text(encoding="utf-8")
    assert content.startswith("---\n")
    assert "name: sample\n" in content
    assert "description: A sample skill for testing\n" in content
    assert "---\n\n" in content
    assert body_content in content
    assert content.endswith(body_content)


def test_generate_idempotent(tmp_path):
    """Running the script twice produces the same file content."""
    (tmp_path / "prompts").mkdir()
    config_file = tmp_path / "config.yaml"
    config_file.write_text(
        "prompts:\n"
        "  - name: sample\n"
        "    description: Idempotent test\n"
        "    path: prompts/sample.md\n",
        encoding="utf-8",
    )
    (tmp_path / "prompts" / "sample.md").write_text(
        "# Sample\n\nBody.\n", encoding="utf-8"
    )
    output_dir = tmp_path / "out"
    script_path = SCRIPTS_DIR / "generate_cursor_skills.py"
    args = [
        sys.executable,
        str(script_path),
        "--config",
        str(config_file),
        "--output",
        str(output_dir),
        "--repo-root",
        str(tmp_path),
    ]
    subprocess.run(args, capture_output=True, check=True, cwd=str(tmp_path))
    skill_path = output_dir / "sample" / "SKILL.md"
    first_content = skill_path.read_text(encoding="utf-8")
    subprocess.run(args, capture_output=True, check=True, cwd=str(tmp_path))
    second_content = skill_path.read_text(encoding="utf-8")
    assert first_content == second_content


def _make_fixture_config_and_prompt(tmp_path, body_content=None):
    """Create config and prompts/sample.md in tmp_path; return config path."""
    if body_content is None:
        body_content = "# Sample\n\nBody.\n"
    (tmp_path / "prompts").mkdir()
    config_file = tmp_path / "config.yaml"
    config_file.write_text(
        "prompts:\n"
        "  - name: sample\n"
        "    title: Sample Prompt\n"
        "    description: A sample for testing\n"
        "    path: prompts/sample.md\n",
        encoding="utf-8",
    )
    prompt_md = tmp_path / "prompts" / "sample.md"
    prompt_md.write_text(body_content, encoding="utf-8")
    return config_file


def test_generate_vscode_always_on_integration(tmp_path):
    """CLI vscode_always_on produces .github/copilot-instructions.md."""
    body = "# Sample Prompt\n\nYou are a sample assistant.\n"
    config_file = _make_fixture_config_and_prompt(tmp_path, body)
    script_path = SCRIPTS_DIR / "generate_cursor_skills.py"
    result = subprocess.run(
        [
            sys.executable,
            str(script_path),
            "--config",
            str(config_file),
            "--repo-root",
            str(tmp_path),
            "--targets",
            "vscode_always_on",
        ],
        capture_output=True,
        text=True,
        cwd=str(tmp_path),
    )
    assert result.returncode == 0, (result.stdout, result.stderr)
    out_file = tmp_path / ".github" / "copilot-instructions.md"
    assert out_file.exists()
    content = out_file.read_text(encoding="utf-8")
    assert "## Sample Prompt" in content
    assert "You are a sample assistant." in content


def test_generate_vscode_file_based_integration(tmp_path):
    """CLI vscode_file_based writes .github/instructions/*.instructions.md."""
    body = "# Sample Prompt\n\nYou are a sample assistant.\n"
    config_file = _make_fixture_config_and_prompt(tmp_path, body)
    script_path = SCRIPTS_DIR / "generate_cursor_skills.py"
    result = subprocess.run(
        [
            sys.executable,
            str(script_path),
            "--config",
            str(config_file),
            "--repo-root",
            str(tmp_path),
            "--targets",
            "vscode_file_based",
        ],
        capture_output=True,
        text=True,
        cwd=str(tmp_path),
    )
    assert result.returncode == 0, (result.stdout, result.stderr)
    out = tmp_path / ".github" / "instructions" / "sample.instructions.md"
    assert out.exists()
    content = out.read_text(encoding="utf-8")
    assert "name: sample\n" in content
    assert 'applyTo: "**"' in content
    assert "# Sample Prompt" in content
    assert "You are a sample assistant." in content
