import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import '../analyzers/lint_analyzer/rules/models/rule.dart';
import '../analyzers/lint_analyzer/rules/rules_factory.dart';
import 'dcl_analysis_rule.dart';

/// The `analysis_server_plugin` entry-point for Dart Code Linter.
///
/// This plugin registers all DCL lint rules with the [PluginRegistry] so they
/// are picked up by the Dart Analysis Server (Dart ≥ 3.9). Rules that require
/// mandatory user configuration (e.g. `avoid-banned-imports`, `ban-name`) are
/// skipped here; they can still be used via the legacy `analyzer.plugins`
/// mechanism or future per-rule configuration support.
///
/// **Usage in `analysis_options.yaml`:**
/// ```yaml
/// plugins:
///   dart_code_linter:
///     diagnostics:
///       avoid-dynamic: true
///       prefer-trailing-comma: true
///       # … add any DCL rule ID to enable it
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

/// Attempts to instantiate a DCL [Rule] with an empty configuration map.
///
/// Rules marked with [Rule.requiresConfig] need mandatory user-supplied
/// configuration values and cannot be instantiated with an empty map, so they
/// are skipped (returns `null`).
Rule? _tryCreateRule(String id) {
  // getRulesById only includes IDs present in the config map, so we call it
  // with a single-entry map to get one rule at a time with an empty config.
  try {
    final rules = getRulesById({id: {}});
    final rule = rules.firstOrNull;
    if (rule == null || rule.requiresConfig) {
      return null;
    }

    return rule;
  } on Exception catch (_) {
    // If instantiation fails (e.g. the rule validates its config eagerly),
    // skip it gracefully so other rules still load.
    return null;
  }
}
