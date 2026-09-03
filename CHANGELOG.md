# Changelog

## 4.4.0
- Add opt-in detection of public declarations that could be made private to `check-unused-code`, enabled via the `--suggest-private-members` CLI flag or the `unused-code.suggest-private-members` analysis-options key and disabled by default. A declaration is reported when it is referenced, but every reference to it sits in the library that declares it, so renaming it to a private name would compile unchanged. It covers type members and top level declarations alike, and is independent of `analyze-private-members` and `analyze-public-members`. Since it reports code that is used rather than dead code, it has its own exit gate, `--[no-]fatal-could-be-private`, and a declaration nothing references at all is never reported as a suggestion: when both checks are on, such a declaration is reported once, as unused. A member of a type the same run reports as dead is left out of the suggestions as well, since deleting the type is the answer for the whole group.
- The suggestions inherit every exemption of the public members check, and skip five more cases of their own: operators (which have no private spelling), enum constants (whose identifier is observable at run time through `name` and `toString`) and the `call` method that makes its type callable, since `obj(...)` binds a member spelled exactly `call` and the rename fails to compile even inside the declaring library (only a method is exempt, a field, a getter or a static named `call` being reached by an ordinary reference and still suggested); fields bound by a named `this.x` or `super.x` formal, which cannot be renamed at all since Dart forbids a named parameter starting with an underscore; instance members redeclared anywhere in the hierarchy of a type declared in another library, where a private name would compile but silently stop dispatch from reaching the override or the interface implementation, while a member no foreign subtype mentions is still suggested because a private member is inherited across libraries unchanged (an implementer that declares the member nowhere in its own hierarchy, an abstract class or a hand written mock answering through `noSuchMethod`, leaves nothing to match it against and is a known limitation of the check); members of a type that is already private, where the rename changes nothing because no other library can name the type (and, for a mixin, changes something bad, since a public class can mix a private mixin in and republish its members; an unnamed extension does not count as private here, its members applying in every importing library); and everything declared in a library any consumer of the package can import, which covers both a file re-exported by a barrel and one that simply sits under `lib/` outside `lib/src`, since Dart lets a consumer import that directly whether or not anything exports it. That last cut takes the members of the types in such a library along with its top level declarations, a consumer that can name the type reaching the public members of it just as directly, and it drops the suggestion alone: whether the analyzed code references such a declaration is still reported by the unused check, unchanged. A published package that keeps nothing under `lib/src` therefore sees no suggestions without `--monorepo`, every declaration it has being reachable by a consumer the analysis cannot see.
- Fix a false negative affecting `check-unused-code` whenever member analysis is enabled: a statically resolved assignment to a member (`target.value = 1`, including through a cascade) marked every member named `value` used across the whole program. A write resolves through the enclosing assignment rather than through the identifier naming the member, so the identifier's own element is null however precisely the target is typed, and that null was read as "reached through a dynamic target". Writes to a genuinely unknown target are still recorded by name, so a member only ever written dynamically is still not reported.
- Fix a second false negative in the same area, affecting the `analyze-public-members` and `analyze-private-members` verdicts shipped in 4.3.0 as much as the new suggestions: `!flag`, `x!`, `-x` and `~x` are compound assignment expressions whose write element is null because there is no write at all, not because one failed to resolve, and reading that null as "reached through a dynamic target" marked every member of that name used across the whole program. An ordinary negation of a member silenced every same-named member everywhere; on this package's own `lib` the gap hid 16 findings.
- Bump the `check-unused-code` JSON report to format version 3, for the new `issueKind` key on every issue (`unused` or `could-be-private`). The key alone is additive, but the meaning of a report is not: with `suggest-private-members` enabled it carries entries that are not unused code, which a consumer pinned to version 2 would count as dead declarations.

## 4.3.0
- Add opt-in detection of unused public members in type declarations to `check-unused-code`, enabled via the `--analyze-public-members` CLI flag or the `unused-code.analyze-public-members` analysis-options key and disabled by default. It is independent of `analyze-private-members`, so a large project can keep the cheaper private members check on while leaving this one off. Members that cannot be seen to be used through a reference are skipped instead of reported: members overriding or implementing an inherited member (found by walking `allSupertypes`, which also covers `toString`/`hashCode`/`noSuchMethod` and overrides written without `@override`), members carrying an annotation that says they are called from elsewhere (`@override`, `@mustBeOverridden`, `@visibleForOverriding`, `@redeclare`, `@protected`, `@visibleForTesting`, `@JS`, `@pragma('vm:entry-point')`), members exported to JavaScript with `@JSExport` (counted from the enclosing class too, but there only for its instance members, since a class level annotation never wraps statics; a class level `@pragma('vm:entry-point')` deliberately does not work this way at all, as it only permits allocation from native code and leaves members needing their own pragma), members whose name is invoked or read on a `dynamic` target anywhere in the program, `toJson` (called by `json.encode` rather than by reference), enum constants of an enum whose `values` is referenced, and unnamed constructors (their invocations carry no identifier to record; named constructors are analyzed).
- Record usages of members reached without an identifier: binary, index, unary and increment operator invocations (`a + b`, `a[b]`, `-a`, `a++`) and implicit `call` invocations previously marked only the enclosing extension as used, so a class's operators looked unused as soon as member analysis was on. The combiner of a compound assignment (`a += b`, which reaches `operator +`) was recorded nowhere at all, so an extension whose operator is used only that way was falsely reported even by the default top-level analysis. Operators and implicit `call` invocations on a `dynamic` target resolve to no element and are now recorded by the member name they reach, the same way dynamic method calls and property reads are.
- Fix the legacy analyzer plugin loader silently loading the wrong DCL version. The analysis server copies `tools/analyzer_plugin/pubspec.yaml` verbatim and resolves it against pub.dev, so its `dart_code_linter` range (frozen at `<4.2.0` since 4.1.7) resolved to 4.1.9 for anyone on 4.2.0 or later: the IDE ran 4.1.9's rules while the CLI ran the installed version, with no error, because a satisfying version always exists. Restored the exact version pin used up to 4.0.1, so each release's loader loads exactly that release.
- Fix a false negative in `check-unused-code` with `analyze-private-members` enabled: a used class member no longer marks a dead top-level declaration of the same name as used (a class calling its own `dispose` used to hide an unused top-level `dispose` function). The name based fallback that works around [dart-lang/sdk#49182](https://github.com/dart-lang/sdk/issues/49182) now requires both sides to agree on whether they are members, which cannot introduce false positives because member dispatch never resolves to a library level declaration.
- Document the `--analyze-private-members` flag and the `unused-code.analyze-private-members` analysis-options key in the README, including their precedence and known limitations.
- Extend the private members test coverage to mixin, enum and extension type members, static members, and member level `// ignore: unused-code` suppressions.
- Fix a false negative in `avoid-non-configurable-callbacks-in-init-state` where a named argument whose label reads `widget` or a known callback method name (e.g. `Options(widget: child)`) was mistaken for a real reference to the state's `widget` getter or to that method, suppressing the warning. Reproducible only on analyzer 10-12, where a named argument's label is a `Label`-wrapped identifier; analyzer 13+ uses a bare token for it instead.
- Fix a false negative in `avoid-non-exhaustive-switch-on-sealed-classes` where a parenthesized wildcard case (`case (_):`) was not recognized as defeating exhaustiveness the same way a bare `_` does.

## 4.2.2
- Fix Analysis Server plugin configuration loading across supported Dart runtimes.

## 4.2.1
- Fix `prefer-dot-shorthands` to also flag unnamed constructor calls (suggesting `.new(...)`) and enum/static member access used as a `switch` statement/expression case pattern matched against the switch's scrutinee type — both were previously left unflagged.

## 4.2.0
- Fix Analysis Server plugin rule configuration on Dart 3.13 by keeping plugin diagnostics scalar and loading full options from `dart_code_linter.rules`.
- Add the `avoid-non-configurable-callbacks-in-init-state` rule, which flags a `State.initState` that configures a widget-supplied object (e.g. `widget.controller.setNavigationDelegate(...)`) with a callback object whose named callbacks never reference the widget's own fields — a sign the behavior is fully hardcoded with no way for callers of the widget to customize it.
- Add the `avoid-non-exhaustive-switch-on-sealed-classes` rule, which flags a `default`/wildcard (`_`) case in a `switch` statement or expression over a sealed type. Relying on a fallback case defeats the compiler's exhaustiveness checking for sealed hierarchies, so newly added subtypes can silently fall through instead of forcing an explicit decision at each call site.
- Add the `prefer-dot-shorthands` rule (with auto-fix), which flags enum/static member access, static method calls, and named constructor calls that repeat a type name already inferable from context (a call argument's declared parameter type, or an explicitly typed variable's initializer) — Dart 3.10's dot-shorthand syntax lets these collapse to `.value` instead of `Type.value`. The rule only fires on files whose language version is 3.10 or later, since the shorthand syntax does not compile below that.

## 4.1.9
- Add opt-in detection of unused private members in type declarations (methods, fields, getters, setters and named constructors) to `check-unused-code`. Private members cannot be referenced from outside the declaring library, which rules out the reflection and cross-library false positives that make public members unreliable to analyze. Mirroring the SDK's `unused_element` semantics, a sole private constructor is never reported: it is the intentional prevent-instantiation/extension pattern (an entirely unused class is still reported by the class-level check). Enabled via the `--analyze-private-members` CLI flag or the `unused-code.analyze-private-members` analysis-options key; disabled by default.

## 4.1.8
- Raise the `analyzer` ceiling to `<15.0.0`, enabling analyzer 14.x support now that `dart_style` 3.1.11 added compatibility with it. Add 14.0.0 and 14.1.0 rows to the `scripts/test_analyzer_compat.py` matrix (`analyzer_plugin` 0.14.13/0.14.14, `analysis_server_plugin` 0.3.19/0.3.20).

## 4.1.7
- Replace the deprecated `Folder.getChildAssumingFile` with `ResourceProvider.getFile` in the analyzer plugin's UUID bootstrap, resolving the pana static-analysis deprecation warning on analyzer 13.x. The call stays compatible across the full `>=10.0.0 <14.0.0` range (`Folder.getFile` only exists in analyzer 13.3.0+).
- Replace the deprecated `MethodDeclaration.isAbstract` with a structural `ast_compat.isAbstractMethod()` helper in `avoid-unused-parameters`, keeping the call non-deprecated across the full `>=10.0.0 <14.0.0` range (`isComplete` only exists in analyzer 13.2+).

## 4.1.6
- Add an auto-fix to the `prefer-enums-by-name` rule that converts `Enum.values.firstWhere((e) => e.name == x)` to `Enum.values.byName(x)`. The fix is offered only when the call is safely convertible: a single-parameter `== name` arrow closure, no `orElse`, and a lookup that does not reference the closure parameter.
- Fix a deprecation warning for `ExtensionTypeDeclaration.primaryConstructor` (deprecated on analyzer 13.1+ in favor of `namePart`, which doesn't exist before 13.1) by reading the extension type's name structurally through a new `ast_compat` helper instead of the version-specific getter.

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


