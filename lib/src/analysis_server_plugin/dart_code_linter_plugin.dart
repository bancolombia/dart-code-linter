import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import '../analyzers/lint_analyzer/rules/models/rule.dart';
import '../analyzers/lint_analyzer/rules/rules_factory.dart';
import 'dcl_analysis_rule.dart';

/// The `analysis_server_plugin` entry-point for Dart Code Linter.
///
/// are picked up by the Dart Analysis Server (Dart ≥ 3.9). Analyzer-owned
/// scalar diagnostics control enablement and IDE severity. Full DCL severity
/// and parameters are loaded from the active `dart_code_linter.rules`
/// configuration when each rule registers its processors.
///
/// **Usage in `analysis_options.yaml`:**
/// ```yaml
/// plugins:
///   dart_code_linter:
///     diagnostics:
///       no-magic-number: warning
/// dart_code_linter:
///   rules:
///     - no-magic-number:
///         severity: warning
///         allowed: [42]
/// ```
final class DartCodeLinterPlugin extends Plugin {
  @override
  String get name => 'dart_code_linter';

  @override
  void register(PluginRegistry registry) {
    for (final id in allRuleIds) {
      final rule = _tryCreateRule(id);
      if (rule != null) {
        registry.registerLintRule(DclAnalysisRule(rule));
      }
    }
  }
}

/// Instantiates a registration placeholder with default configuration.
///
/// [DclAnalysisRule] replaces it with package-supplied options before analysis.
Rule? _tryCreateRule(String id) {
  // getRulesById only includes IDs present in the config map, so we call it
  // with a single-entry map to get one rule at a time with an empty config.
  try {
    return getRulesById({id: {}}).firstOrNull;
  } on Exception catch (_) {
    // If instantiation fails (e.g. the rule validates its config eagerly),
    // skip it gracefully so other rules still load.
    return null;
  }
}
