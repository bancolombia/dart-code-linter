# Release Process

This document describes the steps to bump the version and prepare a release.

## Files to Update

When releasing a new version (e.g. `X.Y.Z` → `X.Y.(Z+1)` for a patch, or `X.Y.Z` → `X.(Y+1).0` for a minor bump), update the following files:

| File | What to change |
|------|---------------|
| `pubspec.yaml` | `version:` field |
| `lib/src/version.dart` | `packageVersion` constant — must match `pubspec.yaml` |
| `tools/analyzer_plugin/pubspec.yaml` | `version:` field; keep `dart_code_linter` dependency as a range `>=X.Y.0 <X.(Y+1).0` |
| `CHANGELOG.md` | Add a new `## X.Y.Z` section at the top describing the changes |
| `README.md` | Add a new row to the compatibility table (copy analyzer/SDK constraints from the previous row if unchanged) |
| `extension/mcp/resources/getting_started.md` | Add a new row to the compatibility table (same as README.md) |

## Step-by-step

1. Create a feature/fix branch off `trunk`.
2. Make your changes.
3. Update all files listed above.
4. Run the checks below locally before opening a PR.
5. Open a pull request — include the CHANGELOG entry in the PR description to speed up review.
6. After merge, tag the release on `trunk`:
   ```
   git tag vX.Y.Z
   git push origin vX.Y.Z
   ```
7. Publish to pub.dev:
   ```
   dart pub publish
   ```

## Pre-release Checks

Run these independently before opening a PR or publishing:

| Check | Command | What it covers |
|-------|---------|----------------|
| Dart unit tests | `fvm dart test` | All Dart rule and analyzer tests |
| Python script tests | `make test` | Tests for scripts in `scripts/` |
| Analyzer compat (quick) | `make test-analyzer-compat` | Runs `dart analyze` against supported analyzer versions |
| Analyzer compat (full) | `make test-analyzer-compat-full` | Full analyzer compatibility matrix — slower, run before release |
| Pub score | `dart pub global activate pana && pana . --no-warning` | Validates pub.dev score (CI requires ≤10 points below max) |

## Notes

- `lib/src/version.dart` and `pubspec.yaml` must always stay in sync. A regression test (`test/src/version_test.dart`) will fail the build if they diverge.
- The `tools/analyzer_plugin/pubspec.yaml` `version:` should mirror the main package version. The `dart_code_linter` dependency should use a range (e.g. `">=4.0.0 <4.1.0"`) so it picks up patch releases without requiring a manual update.
- The SDK constraint in `tools/analyzer_plugin/pubspec.yaml` (`sdk: ">=3.0.0 <4.0.0"`) is intentionally `<4.0.0` (Dart SDK, not DCL version) and should not be confused with the DCL version number.
