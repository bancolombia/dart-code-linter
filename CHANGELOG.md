# Changelog

## 4.1.6
- Add an auto-fix to the `prefer-enums-by-name` rule that converts `Enum.values.firstWhere((e) => e.name == x)` to `Enum.values.byName(x)`. The fix is offered only when the call is safely convertible: a single-parameter `== name` arrow closure, no `orElse`, and a lookup that does not reference the closure parameter.
- Replace the deprecated `Folder.getChildAssumingFile` with `ResourceProvider.getFile` in the analyzer plugin's UUID bootstrap, resolving the pana static-analysis deprecation warning on analyzer 13.x. The call stays compatible across the full `>=10.0.0 <14.0.0` range (`Folder.getFile` only exists in analyzer 13.3.0+).

## 4.1.5
- Add an auto-fix to the `avoid-duplicate-exports` rule that deletes the duplicate export directive (the earlier export already covers the same URI, so the removal is behavior-preserving).
- Fix a `RangeError` crash in the `fix` command when a file had multiple auto-fixable issues; fixes are now applied from the end of the file towards the start so earlier edits no longer invalidate later offsets.

## 4.1.4
- Add an auto-fix to the `no-blank-line-before-single-return` rule that removes the blank line(s) before a single `return` statement in a block, preserving any comments.
- Fix a false positive in `no-blank-line-before-single-return` where a trailing comment on the block's opening brace (e.g. `{ // comment`) was reported even without a blank line before the return.

## 4.1.3
- Add an auto-fix to the `avoid-unnecessary-type-casts` rule that removes the redundant `as` cast (e.g. `value as String` becomes `value`).

## 4.1.2
- Remove two self-reported `parameter_assignments` analyzer warnings in the `no-magic-number` rule implementation by replacing `++count` with `count + 1` in the literal-counting callbacks (no behavioral change).

## 4.1.1
- Add config option `prefer-match-file-name.ignore-enums` and `prefer-match-file-name.ignore-typedefs` to suppress reports for enum and typedef declarations whose name doesn't match the file name.

## 4.1.0
- Add support for `analysis_server_plugin` (analyzer 13.x).
- Add support for `analyzer` 13.x via a cross-version AST shim ([lib/src/utils/ast_compat.dart](lib/src/utils/ast_compat.dart)) that recognises the reshaped named-argument, record-field, default-parameter and label nodes structurally.
- Widen `analyzer` constraint to `>=10.0.0 <14.0.0`.
- Extend `make test-analyzer-compat-full` to cover analyzer 10.x, 11.x, 12.x and 13.x; skip versions whose Dart SDK constraint is incompatible with the host SDK instead of failing.

## 4.0.5
- Add `ignored-invocations` and `ignored-targets` options to `prefer-moving-to-variable` rule to suppress reports for specific method/getter names or target receivers.
- Add autofix for `newline-before-return` with comment-aware, whitespace-preserving behavior and edge-case fixture coverage.

## 4.0.4
- Honor per-line `// ignore: <metric-id>` comments for function- and class-level metric violations (both leading and trailing forms). File-level metrics keep their `// ignore_for_file:` behavior.

## 4.0.3
- Fix `prefer-moving-to-variable` rule not detecting duplicate invocations in expression function bodies (`=> expr`).

## 4.0.2
- Update `packageVersion` constant to match pubspec version (was hardcoded as `3.2.0`).

## 4.0.1
- Relax `analyzer` constraint to >=10.0.0 <13.0.0 to support Flutter stable with `meta` 1.17.0.
- Relax `analyzer_plugin` constraint to >=0.14.0 <0.16.0.
- Add support for `analyzer` 12.x (replace removed `LibraryIdentifier` with version-agnostic approach).
- Remove `dependency_overrides` from main and example pubspecs.

## 4.0.0
- **BREAKING**: Update minimum Dart SDK to >=3.5.0 (compatible with Flutter 3.24+).
- Update `analyzer` to >=11.0.0 <12.0.0.
- Update `analyzer_plugin` to ^0.14.5.
- Fix element comparison for substituted elements in `always-remove-listener` rule.
- Add Packaged AI Assets for MCP integration (`extension/mcp/`).

## 3.2.1
- Update homepage in `pubspec.yaml`.

## 3.2.0
- Update `analyzer` constraint to ^8.2.0. Only works with `dart >= 3.9.0`.
- Add rule `use-design-system-items`.
- Add rule `only-barrel-import`.
- Allow to specify more than one suggestion for each rule.

## 3.2.0-alpha.2
- Update `analyzer` constraint to ^8.2.0

## 3.2.0-alpha.1
- Add rule `use-design-system-items`.
- Add rule `only-barrel-import`.
- Allow to specify more than one suggestion for each rule.
- Bump `analyzer` to ^8.0.0

## 3.1.1
- Changed `prefer-media-query-direct-access` to `FlutterRule`.

## 3.1.0
- Add rule `prefer-media-query-direct-access`.
- Add rule `prefer-named-record-fields`.

## 3.1.0-beta.3
- Add rule `prefer-media-query-direct-access`.

## 3.1.0-beta.2
- Fixed DCL version in analyzer_plugin.

## 3.1.0-beta.1
- Add rule `prefer-named-record-fields`.

## 3.0.0-beta.1
- [Breaking] Update dart sdk constraints to `>=3.4.0 <4.0.0`.
- Update `analyzer` to version ^7.4.4
## 2.0.0
- Update `analyzer` to version ^6.0.0
## 1.3.0
- Added `fatal-warnings-threshold` `fatal-performance-threshold` and `fatal-style-threshold` to set the failure threshold for analyze command
## 1.2.1
- Fixed generating report file when find issues in the report
## 1.2.0
- Added fix command
- Added prefer single quotes rule
- Added prefer first or null rule
- Added no blank line before single return rule
- Fixed rule avoid dynamic to extensions definition
## 1.1.5
- Removed deprecated fields in analysis options and collection method
- Fixed changelog URL for update available warning
## 1.1.4
- Fixed some test
- Reverted `analyzer` ^6.0.0 to ^5.14.0
## 1.1.3
- Fixed some test
## 1.1.2
- Append new presset `analysis_options.1.0.0.yaml`
## 1.1.1
- Rename common rules to dart rules
## 1.1.0
- Added new presets
- Removed Angular framework rules
- Added example

## 1.0.2
- Fix: report in IDE'S is adjusted
## 1.0.1
- Automated publishing of packages to pub.dev

## 1.0.0
- Fork: [Dart code metrics 5.7.3](https://github.com/dart-code-checker/dart-code-metrics)


