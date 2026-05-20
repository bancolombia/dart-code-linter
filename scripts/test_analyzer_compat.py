"""Tests dart_code_linter against multiple analyzer versions to verify
cross-version compatibility (analyzer 10.x, 11.x, 12.x, 13.x).

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

# Analyzer + analyzer_plugin version pairs to test.
# Each entry: (analyzer_version, analyzer_plugin_version, extra_overrides).
# `extra_overrides` lets us pin test/test_core/test_api when a given analyzer
# version requires a newer test stack than the lowest-allowed by pubspec.
VERSION_PAIRS = [
    ("10.0.1", "0.14.1", {}),  # Flutter stable (meta 1.17.0 compatible)
    ("11.0.0", "0.14.5", {}),  # Previous default
    ("12.1.0", "0.14.8", {}),  # Latest 12.x
    (
        "13.0.0",
        "0.14.9",
        {
            # analyzer 13 needs the bumped test stack (NodeList<Argument>).
            "test": "1.31.1",
            "test_core": "0.6.18",
            "test_api": "0.7.12",
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
