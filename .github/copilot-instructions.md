## Analyze Code Quality

# Analyze Code Quality

You are an AI assistant helping a developer analyze their Dart/Flutter project using Dart Code Linter (DCL).

## Steps

1. **Check if DCL is installed** by looking at `pubspec.yaml` for `dart_code_linter` in `dev_dependencies`. If it is not installed, instruct the user to run:
   ```sh
   dart pub add --dev dart_code_linter
   ```

2. **Check for configuration** in `analysis_options.yaml`. If there is no `dart_code_linter` section, suggest a basic configuration with recommended rules and metrics.

3. **Run the analysis** using the CLI:
   ```sh
   dart run dart_code_linter:metrics analyze lib --reporter=json
   ```

4. **Interpret the results** and present a summary organized by severity:
   - **Critical**: High cyclomatic complexity (>20), very long methods (>100 SLOC), deep nesting (>5 levels)
   - **Warning**: Moderate metric violations, anti-pattern detections (long-method, long-parameter-list)
   - **Info**: Style rule violations, minor code quality suggestions

5. **Highlight the top issues** to address first, prioritized by:
   - Files/methods with the highest cyclomatic complexity
   - Methods with the most parameters
   - Files with the most rule violations

6. **Suggest actionable fixes** for each critical issue:
   - For high complexity: recommend extracting methods or simplifying conditionals
   - For long methods: identify logical sections that could become separate functions
   - For deep nesting: suggest guard clauses or early returns
   - For rule violations: explain the rule and show the corrected code

7. **Provide a summary** with:
   - Total number of files analyzed
   - Count of violations by severity
   - Top 3 files that need the most attention
   - Overall code health assessment


---

## Fix Lint Violations

# Fix Lint Violations

You are an AI assistant helping a developer fix lint rule violations found by Dart Code Linter (DCL).

## Steps

1. **Identify active rules** by reading the project's `analysis_options.yaml` file and listing all enabled `dart_code_linter` rules.

2. **Run the linter** to find current violations:
   ```sh
   dart run dart_code_linter:metrics analyze lib --reporter=json
   ```

3. **For each violation**, provide a fix:

   - **Read the source file** containing the violation
   - **Explain what the rule enforces** and why it matters
   - **Show the corrected code** with the fix applied
   - **Apply the fix** by editing the file

4. **Common fix patterns:**

   - `avoid-dynamic`: Add explicit type annotations instead of `dynamic`
   - `avoid-redundant-async`: Remove `async` keyword when the function body does not use `await`
   - `avoid-unnecessary-type-assertions`: Remove `is` checks where the type is already known
   - `avoid-unnecessary-type-casts`: Remove `as` casts where the type is already correct
   - `avoid-unused-parameters`: Prefix unused parameters with `_` or remove them
   - `no-empty-block`: Add a comment explaining why the block is empty, or add implementation
   - `no-boolean-literal-compare`: Replace `if (x == true)` with `if (x)` and `if (x == false)` with `if (!x)`
   - `prefer-trailing-comma`: Add trailing commas after the last parameter/element in multi-line constructs
   - `prefer-conditional-expressions`: Convert simple if-else assignments to ternary expressions
   - `no-equal-then-else`: Remove the if-else and keep only the body since both branches are identical
   - `newline-before-return`: Add a blank line before `return` statements
   - `prefer-match-file-name`: Rename the main class/function to match the file name, or rename the file
   - `avoid-nested-conditional-expressions`: Extract nested ternaries into separate variables or use if-else

5. **After applying fixes**, re-run the linter to verify all violations are resolved:
   ```sh
   dart run dart_code_linter:metrics analyze lib --reporter=json
   ```

6. **Report results** with:
   - Number of violations found
   - Number of violations fixed
   - Any remaining violations that require manual review (with explanation)

