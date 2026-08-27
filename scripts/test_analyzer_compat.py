"""Tests dart_code_linter against multiple analyzer versions to verify
cross-version compatibility (analyzer 8.x, 9.x, 10.x, 11.x, 12.x, 13.x, 14.x).

Usage:
    python scripts/test_analyzer_compat.py [--analyze-only]

Note: analyzer 13.x requires Dart SDK >= 3.11.0 (Flutter 3.41+). Older
analyzer versions impose lower SDK ceilings. The script reports each
version's pub-get outcome; if pub-get fails for SDK reasons the entry is
marked SKIPPED rather than failed so the script can still run on any one
SDK.
"""

import argparse
import subprocess
import sys
from pathlib import Path

# Analyzer + analyzer_plugin version pairs to test. One representative per
# analyzer major spanned by the pubspec range (>=8.2.0 <15.0.0), plus extra rows
# straddling API reshapes (see the 8.4.0 and 13.3.0 entries).
# Each entry: (analyzer_version, analyzer_plugin_version, extra_overrides).
# `extra_overrides` pins whatever else a row needs on top of the analyzer pair.

# The test runner stack, pinned on every row rather than left to resolution:
# pubspec.lock is gitignored, so an unpinned row inherits whatever lock happens
# to be lying around, and a clean checkout fails inside test_core itself, which
# looks nothing like a code regression.
#
# There is no slack in the value. test_core 0.6.18 is both the floor (analyzer
# 13+ fails on NodeList<Argument> below it) and the ceiling (0.6.19 fails against
# analyzer 10 with "'NamedArgument' isn't a type"), so a bump breaks one end.
# test_core 0.6.18's own pubspec declares `analyzer: >=8.0.0 <14.0.0`, which on
# paper excludes analyzer 14, but that constraint is never checked here: both
# packages are forced through dependency_overrides, and pub does not re-verify
# an overridden package's declared constraint against another overridden
# package. Verified: the full matrix below passes on every row, 8.2.0 through
# 14.1.0, with this single stack applied uniformly.
TEST_STACK = {
    "test": "1.31.1",
    "test_core": "0.6.18",
    "test_api": "0.7.12",
}

# dart_style is a transitive dependency of analyzer_plugin
# (`change_builder_dart.dart`, used by fix-producing rules), and each
# dart_style release exact-brackets the analyzer AST shape it compiles
# against (e.g. 3.1.7 declares `analyzer: '>=10.0.0 <12.0.0'`). Overriding
# `analyzer` via dependency_overrides does not make pub re-check dart_style's
# own constraint against it, so an unpinned dart_style silently keeps
# whatever version the ambient lockfile already holds even when it no longer
# supports the row's analyzer. That mismatch only breaks the build once
# something actually compiles dart_style's visitor code (the modern
# analysis_server_plugin bridge in dcl_analysis_rule.dart reaches every
# rule's fix-building code, which reaches change_builder_dart.dart), so every
# row must pin a dart_style compatible with its own analyzer version.
_DART_STYLE_BY_ANALYZER = {
    "8.2.0": "3.1.3",  # >=8.2.0 <10.0.0
    "8.4.0": "3.1.3",
    "9.0.0": "3.1.3",
    "10.0.1": "3.1.6",  # ^10.0.0
    "11.0.0": "3.1.7",  # >=10.0.0 <12.0.0
    "12.1.0": "3.1.8",  # ^12.0.0
    "13.0.0": "3.1.9",  # ^13.0.0
    "13.3.0": "3.1.9",
    "14.0.0": "3.1.11",  # >=13.1.0 <15.0.0
    "14.1.0": "3.1.12",
}

VERSION_PAIRS = [
    # 8.2.0: the pubspec floor. analysis_server_plugin 0.3.0 is the oldest
    # release in the `^0.3.0` range and exact-pins analyzer 8.2.0, so this is
    # the lowest analyzer reachable without widening the plugin constraint.
    # Pre-reshape row: no `ClassDeclaration.namePart`/`body`, so it exercises
    # the structural fallbacks in ast_compat (name read after the `class`/`enum`
    # keyword, members read off the declaration's own braces).
    (
        "8.2.0",
        "0.13.8",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.0",
            "dart_style": _DART_STYLE_BY_ANALYZER["8.2.0"],
        },
    ),
    (
        # 8.4.0 introduced `namePart`/`body` (with `namePart` still nullable
        # here, non-nullable from 9.0), so this straddles the reshape: the same
        # call sites must resolve through the new nodes on this row and through
        # the old direct getters on 8.2.0.
        "8.4.0",
        "0.13.10",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.3",
            "dart_style": _DART_STYLE_BY_ANALYZER["8.4.0"],
        },
    ),
    (
        # 9.x: post-reshape, but before `isOriginDeclaration` existed on
        # Field/MethodElement, which is why the l10n analyzer uses
        # `nonSynthetic` unconditionally instead.
        "9.0.0",
        "0.13.11",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.4",
            "dart_style": _DART_STYLE_BY_ANALYZER["9.0.0"],
        },
    ),
    (
        # 10.x: the pubspec floor before 4.4.0 lowered it to 8.2.0.
        # .0.1 patch is the lowest that resolves with meta 1.17.0.
        "10.0.1",
        "0.14.1",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.7",
            "dart_style": _DART_STYLE_BY_ANALYZER["10.0.1"],
        },
    ),
    (
        "11.0.0",  # 11.x
        "0.14.5",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.11",
            "dart_style": _DART_STYLE_BY_ANALYZER["11.0.0"],
        },
    ),
    (
        "12.1.0",  # 12.x
        "0.14.8",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.14",
            "dart_style": _DART_STYLE_BY_ANALYZER["12.1.0"],
        },
    ),
    (
        "13.0.0",
        "0.14.9",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.15",
            "dart_style": _DART_STYLE_BY_ANALYZER["13.0.0"],
        },
    ),
    (
        # 13.1+ deprecated ExtensionTypeDeclaration.primaryConstructor in favour
        # of namePart, and 13.2+ deprecated MethodDeclaration.isAbstract in
        # favour of isComplete; 13.0.0 (above) predates both. This row covers
        # the post-deprecation side so ast_compat.extensionTypeName and
        # ast_compat.isAbstractMethod stay valid on both.
        "13.3.0",
        "0.14.12",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.18",
            "dart_style": _DART_STYLE_BY_ANALYZER["13.3.0"],
        },
    ),
    (
        # 14.x requires dart_style 3.1.11+ (transitive via analyzer_plugin),
        # which only just added analyzer-14 support.
        "14.0.0",
        "0.14.13",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.19",
            "dart_style": _DART_STYLE_BY_ANALYZER["14.0.0"],
        },
    ),
    (
        # Upper boundary of the current <15.0.0 ceiling: latest 14.x patch,
        # which is what `dart pub upgrade` actually resolves to today.
        "14.1.0",
        "0.14.14",
        {
            **TEST_STACK,
            "analysis_server_plugin": "0.3.20",
            "dart_style": _DART_STYLE_BY_ANALYZER["14.1.0"],
        },
    ),
]

PUBSPEC_PATH = Path("pubspec.yaml")


def run(cmd: list[str], label: str) -> tuple[bool, str]:
    """Run a command, print output, return (success, combined_output)."""
    print(f"-> {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    output = (result.stdout + result.stderr).strip()

    if label == "analyze":
        # Allow info-level issues, fail only on errors
        error_count = sum(
            1 for line in output.splitlines() if line.strip().startswith("error")
        )
        print(output[-500:] if len(output) > 500 else output)
        return error_count == 0, output

    # For pub get and test, just check exit code
    tail = "\n".join(output.splitlines()[-5:])
    print(tail)
    return result.returncode == 0, output


def test_version(
    analyzer_ver: str,
    plugin_ver: str,
    extra_overrides: dict[str, str],
    analyze_only: bool,
    original: str,
) -> str:
    """Test a single analyzer+plugin version pair.

    Returns one of "pass", "fail", or "skip" (when pub-get rejects the
    combination because of SDK constraints).
    """
    print(f"\n{'=' * 50}")
    print(f"Testing: analyzer {analyzer_ver} + analyzer_plugin {plugin_ver}")
    print(f"{'=' * 50}")

    overrides_lines = [
        "\ndependency_overrides:",
        f'  analyzer: "{analyzer_ver}"',
        f'  analyzer_plugin: "{plugin_ver}"',
    ]
    for pkg, ver in extra_overrides.items():
        overrides_lines.append(f'  {pkg}: "{ver}"')
    overrides = "\n".join(overrides_lines) + "\n"
    PUBSPEC_PATH.write_text(original + overrides)

    ok, output = run(["dart", "pub", "get", "--no-example"], "pub get")
    if not ok:
        if "requires SDK version" in output or "Dart SDK version" in output:
            print(f"SKIP: analyzer {analyzer_ver} (incompatible with current SDK)")
            return "skip"
        print(f"FAIL: pub get failed for analyzer {analyzer_ver}")
        return "fail"

    ok, _ = run(["dart", "analyze", "lib/"], "analyze")
    if not ok:
        print(f"FAIL: analyze failed for analyzer {analyzer_ver}")
        return "fail"

    if not analyze_only:
        ok, _ = run(["dart", "test"], "test")
        if not ok:
            print(f"FAIL: tests failed for analyzer {analyzer_ver}")
            return "fail"

    print(f"PASS: analyzer {analyzer_ver}")
    return "pass"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--analyze-only",
        action="store_true",
        help="Only run dart analyze, skip dart test",
    )
    args = parser.parse_args()

    if not PUBSPEC_PATH.exists():
        print("Error: pubspec.yaml not found. Run from the project root.")
        sys.exit(1)

    backup = PUBSPEC_PATH.read_text()
    failures: list[str] = []
    skipped: list[str] = []

    try:
        for analyzer_ver, plugin_ver, extra_overrides in VERSION_PAIRS:
            outcome = test_version(
                analyzer_ver,
                plugin_ver,
                extra_overrides,
                args.analyze_only,
                backup,
            )
            if outcome == "fail":
                failures.append(analyzer_ver)
            elif outcome == "skip":
                skipped.append(analyzer_ver)
    finally:
        # Always restore original pubspec
        PUBSPEC_PATH.write_text(backup)
        subprocess.run(
            ["dart", "pub", "get", "--no-example"],
            capture_output=True,
        )

    print(f"\n{'=' * 50}")
    if skipped:
        print(f"SKIPPED (SDK incompatible): {', '.join(skipped)}")
    if not failures:
        print("ALL TESTED VERSIONS PASSED")
    else:
        print(f"FAILURES: {', '.join(failures)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
