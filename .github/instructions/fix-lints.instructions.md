---
name: fix-lints
description: Identify and fix lint rule violations in the current project
applyTo: "**"
---

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
