"""Tests dart_code_linter against multiple analyzer versions to verify
cross-version compatibility (analyzer 10.x, 11.x, 12.x).

Usage:
    python scripts/test_analyzer_compat.py [--analyze-only]
"""

import argparse
import subprocess
import sys
from pathlib import Path

# Analyzer + analyzer_plugin version pairs to test
VERSION_PAIRS = [
    ("10.0.1", "0.14.1"),  # Flutter stable (meta 1.17.0 compatible)
    ("11.0.0", "0.14.5"),  # Current default
    ("12.0.0", "0.14.7"),  # Latest
]

PUBSPEC_PATH = Path("pubspec.yaml")


def run(cmd: list[str], label: str) -> bool:
    """Run a command, print output, return True on success."""
    print(f"-> {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    output = (result.stdout + result.stderr).strip()

    if label == "analyze":
        # Allow info-level issues, fail only on errors
        error_count = sum(
            1 for line in output.splitlines() if line.strip().startswith("error")
        )
        print(output[-500:] if len(output) > 500 else output)
        return error_count == 0

    # For pub get and test, just check exit code
    tail = "\n".join(output.splitlines()[-5:])
    print(tail)
    return result.returncode == 0


def test_version(
    analyzer_ver: str, plugin_ver: str, analyze_only: bool, original: str
) -> bool:
    """Test a single analyzer+plugin version pair. Returns True on success."""
    print(f"\n{'=' * 50}")
    print(f"Testing: analyzer {analyzer_ver} + analyzer_plugin {plugin_ver}")
    print(f"{'=' * 50}")

    # Append dependency_overrides to a clean copy of the original pubspec
    overrides = (
        "\ndependency_overrides:\n"
        f'  analyzer: "{analyzer_ver}"\n'
        f'  analyzer_plugin: "{plugin_ver}"\n'
    )
    PUBSPEC_PATH.write_text(original + overrides)

    if not run(["dart", "pub", "get", "--no-example"], "pub get"):
        print(f"FAIL: pub get failed for analyzer {analyzer_ver}")
        return False

    if not run(["dart", "analyze", "lib/"], "analyze"):
        print(f"FAIL: analyze failed for analyzer {analyzer_ver}")
        return False

    if not analyze_only:
        if not run(["dart", "test"], "test"):
            print(f"FAIL: tests failed for analyzer {analyzer_ver}")
            return False

    print(f"PASS: analyzer {analyzer_ver}")
    return True


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

    try:
        for analyzer_ver, plugin_ver in VERSION_PAIRS:
            if not test_version(analyzer_ver, plugin_ver, args.analyze_only, backup):
                failures.append(analyzer_ver)
    finally:
        # Always restore original pubspec
        PUBSPEC_PATH.write_text(backup)
        subprocess.run(
            ["dart", "pub", "get", "--no-example"],
            capture_output=True,
        )

    print(f"\n{'=' * 50}")
    if not failures:
        print("ALL VERSIONS PASSED")
    else:
        print(f"FAILURES: {', '.join(failures)}")
        sys.exit(1)


if __name__ == "__main__":
    main()
