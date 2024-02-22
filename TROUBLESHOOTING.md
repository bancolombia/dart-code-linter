# Troubleshooting

**Note:** If the plugin is analyzing files it should not analyze (like `.dart_tool/` or an external package source code), please create [an issue](https://github.com/bancolombia/dart-code-linter/issues), it's most likely a bug.

If the plugin is not working as you'd expect it to work, please consider going through the following steps before creating [an issue](https://github.com/bancolombia/dart-code-linter/issues):

1. Check that the plugin is added to an `analyzer` entry in the `analysis_options.yaml` as described in the [Configuration](./README.md#Configuration) section.

2. Check that the `dart_code_linter` entry in the `analysis_options.yaml` is configured correctly. Note, that you need to add each rule or metric you want to be checked to the config and there is **no** default rule or metric lists config. **Note:** for a rule config there is a 4 spaces / 2 tabs indentation.

3. Check that the `dart_code_linter` package is added as a dev dependency to the same package, where the plugin entry added to the `analysis_options.yaml`.

4. Restart the IDE to invalidate the cache and check if the issue remains.

5. Open Analyzer Diagnostics and check that the plugin is active. To do that:
    - For VS Code: open the command palette (`Ctrl+Shift+P` or `Cmd+Shift+P`) and invoke `Dart: Open Analyzer Diagnostics`.

    - For Android Studio (or any other JetBrains IDE): open the `Dart Analysis` tab, click `Analyzer settings` and then click `View analyzer diagnostics`.

    then a `Analyzer Server Diagnostics` webpage will be opened.

    To check that the plugin is active, open the `Plugins` tab and ensure that there is no errors.
