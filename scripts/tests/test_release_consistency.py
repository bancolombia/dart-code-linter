"""Tests that verify release version consistency across all files."""

import re
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parent.parent.parent


def _pubspec_version() -> str:
    pubspec = yaml.safe_load((REPO_ROOT / "pubspec.yaml").read_text(encoding="utf-8"))
    return pubspec["version"]


def test_plugin_pubspec_version_matches_main():
    """tools/analyzer_plugin/pubspec.yaml version must match pubspec.yaml."""
    main_version = _pubspec_version()
    plugin = yaml.safe_load(
        (REPO_ROOT / "tools" / "analyzer_plugin" / "pubspec.yaml").read_text(
            encoding="utf-8"
        )
    )
    assert plugin["version"] == main_version, (
        f"tools/analyzer_plugin/pubspec.yaml version '{plugin['version']}' "
        f"does not match pubspec.yaml version '{main_version}'"
    )


def test_plugin_dependency_is_range_not_pin():
    """tools/analyzer_plugin/pubspec.yaml dart_code_linter dep must be a range, not a pin."""
    plugin = yaml.safe_load(
        (REPO_ROOT / "tools" / "analyzer_plugin" / "pubspec.yaml").read_text(
            encoding="utf-8"
        )
    )
    dep = plugin["dependencies"]["dart_code_linter"]
    assert isinstance(dep, str) and ">=" in dep, (
        f"dart_code_linter dependency should be a version range (e.g. '>=4.0.0 <4.1.0'), "
        f"got: '{dep}'"
    )


def test_changelog_has_entry_for_current_version():
    """CHANGELOG.md must have a section for the current pubspec.yaml version."""
    version = _pubspec_version()
    changelog = (REPO_ROOT / "CHANGELOG.md").read_text(encoding="utf-8")
    assert f"## {version}" in changelog, (
        f"CHANGELOG.md is missing a '## {version}' section"
    )


def test_readme_compatibility_table_has_current_version():
    """README.md compatibility table must have a row for the current version."""
    version = _pubspec_version()
    readme = (REPO_ROOT / "README.md").read_text(encoding="utf-8")
    assert f"| {version}" in readme, (
        f"README.md compatibility table is missing a row for version '{version}'"
    )


def test_getting_started_compatibility_table_has_current_version():
    """extension/mcp/resources/getting_started.md compatibility table must have a row for the current version."""
    version = _pubspec_version()
    getting_started = (
        REPO_ROOT / "extension" / "mcp" / "resources" / "getting_started.md"
    ).read_text(encoding="utf-8")
    assert f"| {version}" in getting_started, (
        f"extension/mcp/resources/getting_started.md compatibility table "
        f"is missing a row for version '{version}'"
    )
