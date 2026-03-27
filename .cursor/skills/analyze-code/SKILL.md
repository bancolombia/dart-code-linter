---
name: analyze-code
description: Run dart_code_linter analysis on the project and explain results
---

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
