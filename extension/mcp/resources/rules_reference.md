# Lint Rules Reference

Dart Code Linter provides 70+ lint rules organized by category. Enable rules in `analysis_options.yaml` under `dart_code_linter > rules`.

## Common (Dart) Rules

These rules apply to all Dart code.

| Rule | Description |
|------|-------------|
| `arguments-ordering` | Enforce consistent ordering of arguments |
| `avoid-banned-imports` | Prohibit importing specified packages or files |
| `avoid-cascade-after-if-null` | Avoid using cascade operators after if-null expressions |
| `avoid-collection-methods-with-unrelated-types` | Warn when collection methods are called with unrelated types |
| `avoid-double-slash-imports` | Avoid using double-slash in import paths |
| `avoid-duplicate-exports` | Warn on duplicate export directives |
| `avoid-dynamic` | Avoid using the `dynamic` type |
| `avoid-global-state` | Avoid mutable global state |
| `avoid-ignoring-return-values` | Warn when return values are ignored |
| `avoid-late-keyword` | Avoid using the `late` keyword |
| `avoid-missing-enum-constant-in-map` | Ensure all enum constants are present in map literals |
| `avoid-nested-conditional-expressions` | Limit nesting of conditional (ternary) expressions |
| `avoid-non-ascii-symbols` | Avoid non-ASCII symbols in source code |
| `avoid-non-exhaustive-switch-on-sealed-classes` | Avoid a default/wildcard case in a switch over a sealed type |
| `avoid-non-null-assertion` | Avoid using the `!` non-null assertion operator |
| `avoid-passing-async-when-sync-expected` | Warn when async functions are passed where sync is expected |
| `avoid-redundant-async` | Remove unnecessary `async` keyword from functions |
| `avoid-substring` | Prefer other string methods over `substring` |
| `avoid-throw-in-catch-block` | Avoid throwing exceptions inside catch blocks |
| `avoid-top-level-members-in-tests` | Avoid top-level members in test files |
| `avoid-unnecessary-conditionals` | Remove unnecessary conditional expressions |
| `avoid-unnecessary-type-assertions` | Remove unnecessary `is` type checks |
| `avoid-unnecessary-type-casts` | Remove unnecessary `as` type casts |
| `avoid-unrelated-type-assertions` | Warn on type assertions between unrelated types |
| `avoid-unused-parameters` | Warn on unused function/method parameters |
| `ban-name` | Ban specific identifiers by name |
| `binary-expression-operand-order` | Enforce consistent operand order in binary expressions |
| `double-literal-format` | Enforce consistent double literal formatting |
| `format-comment` | Enforce comment formatting rules |
| `list-all-equatable-fields` | Ensure all fields are listed in Equatable props |
| `member-ordering` | Enforce consistent member ordering in classes |
| `missing-test-assertion` | Warn on test bodies without assertions |
| `newline-before-return` | Require a blank line before return statements |
| `no-blank-line-before-single-return` | Disallow blank line before single return statement |
| `no-boolean-literal-compare` | Avoid comparing boolean values to boolean literals |
| `no-empty-block` | Warn on empty blocks |
| `no-equal-arguments` | Warn when the same argument is passed to multiple parameters |
| `no-equal-then-else` | Warn when then and else branches are identical |
| `no-magic-number` | Avoid magic numbers; use named constants |
| `no-object-declaration` | Avoid declaring variables with the `Object` type |
| `only-barrel-import` | Enforce importing only from barrel files |
| `prefer-async-await` | Prefer async/await over raw Futures |
| `prefer-commenting-analyzer-ignores` | Require comments explaining analyzer ignore directives |
| `prefer-conditional-expressions` | Prefer conditional expressions over if-else for assignments |
| `prefer-correct-identifier-length` | Enforce min/max length for identifiers |
| `prefer-correct-test-file-name` | Enforce test file naming conventions |
| `prefer-correct-type-name` | Enforce type naming conventions |
| `prefer-dot-shorthands` | Prefer dot shorthands (`.value`) over repeating a type name inferable from context |
| `prefer-enums-by-name` | Prefer using `byName` for enum lookups |
| `prefer-first` | Prefer `.first` over `.elementAt(0)` or `[0]` |
| `prefer-first-or-null` | Prefer `.firstOrNull` over manual null checks |
| `prefer-immediate-return` | Return expressions directly instead of assigning to a variable first |
| `prefer-iterable-of` | Prefer `Iterable.of` constructor |
| `prefer-last` | Prefer `.last` over `.elementAt(length - 1)` |
| `prefer-match-file-name` | Ensure the main declaration matches the file name |
| `prefer-moving-to-variable` | Extract repeated expressions into variables |
| `prefer-named-record-fields` | Prefer named fields in record types |
| `prefer-single-quotes` | Prefer single quotes for strings |
| `prefer-static-class` | Prefer static class members over top-level functions |
| `prefer-trailing-comma` | Enforce trailing commas in multi-line collections and parameters |
| `tag-name` | Enforce tag naming conventions |

## Flutter Rules

These rules apply specifically to Flutter code.

| Rule | Description |
|------|-------------|
| `always-remove-listener` | Ensure listeners are removed in dispose methods |
| `avoid-border-all` | Avoid `Border.all` constructor; use `Border.fromBorderSide` |
| `avoid-expanded-as-spacer` | Avoid using `Expanded` with empty `Container` as spacer |
| `avoid-non-configurable-callbacks-in-init-state` | Avoid configuring a widget-supplied object in `initState` with fully hardcoded callbacks that never reference the widget's own fields |
| `avoid-returning-widgets` | Avoid returning widgets from methods; extract to separate widgets |
| `avoid-shrink-wrap-in-lists` | Avoid `shrinkWrap` in scrollable lists for performance |
| `avoid-unnecessary-setstate` | Avoid unnecessary `setState` calls |
| `avoid-wrapping-in-padding` | Avoid wrapping widgets in `Padding`; use the widget's padding property |
| `check-for-equals-in-render-object-setters` | Ensure equality check in RenderObject setters |
| `consistent-update-render-object` | Ensure `updateRenderObject` is consistent with `createRenderObject` |
| `prefer-const-border-radius` | Prefer const `BorderRadius` constructors |
| `prefer-correct-edge-insets-constructor` | Use the most appropriate `EdgeInsets` constructor |
| `prefer-define-hero-tag` | Require explicit `heroTag` in Hero widgets |
| `prefer-extracting-callbacks` | Extract callback functions from widget build methods |
| `prefer-media-query-direct-access` | Prefer `MediaQuery.of(context).size` direct access |
| `prefer-single-widget-per-file` | Limit one widget class per file |
| `prefer-using-list-view` | Prefer `ListView` over `SingleChildScrollView` with `Column` |
| `use-design-system` | Enforce usage of design system components |
| `use-setstate-synchronously` | Ensure `setState` is called synchronously |

## Intl Rules

These rules apply to internationalization code using the `intl` package.

| Rule | Description |
|------|-------------|
| `prefer-intl-name` | Enforce correct naming for Intl messages |
| `prefer-provide-intl-description` | Require description for Intl messages |
| `provide-correct-intl-args` | Ensure correct arguments in Intl methods |

## Flame Rules

These rules apply to Flame game engine code.

| Rule | Description |
|------|-------------|
| `avoid-creating-vector-in-update` | Avoid creating Vector2/Vector3 in update methods |
| `avoid-initializing-in-on-mount` | Avoid heavy initialization in onMount |
| `avoid-redundant-async-on-load` | Remove unnecessary async from onLoad |
| `correct-game-instantiating` | Ensure correct game class instantiation |

## Enabling Rules

Add rules to your `analysis_options.yaml`:

```yaml
dart_code_linter:
  rules:
    - avoid-dynamic
    - no-empty-block
    - prefer-trailing-comma
```

Some rules accept configuration parameters:

```yaml
dart_code_linter:
  rules:
    - avoid-nested-conditional-expressions:
        acceptable-level: 2
    - prefer-correct-identifier-length:
        min-identifier-length: 3
        max-identifier-length: 30
    - member-ordering:
        order:
          - constructors
          - public-fields
          - private-fields
          - public-methods
          - private-methods
```
