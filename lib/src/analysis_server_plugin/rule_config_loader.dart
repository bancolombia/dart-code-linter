import 'dart:async';

import '../analyzers/lint_analyzer/lint_config.dart';
import '../analyzers/lint_analyzer/models/severity.dart';
import '../analyzers/lint_analyzer/rules/models/rule.dart';
import '../analyzers/lint_analyzer/rules/rules_factory.dart';
import '../config_builder/config_builder.dart';
import '../config_builder/models/analysis_options.dart';
import '../utils/analyzer_utils.dart';

/// Loads [ruleId]'s full DCL configuration for Analysis Server integration.
({Rule? rule, Iterable<String> rulesExcludes}) loadAnalysisServerRule(
  String packageRoot,
  String ruleId,
) {
  // ponytail: reload on registration; correctness beats dependency-cache
  // invalidation until profiling proves config loading is hot.
  final config = _loadConfig(packageRoot);
  final ruleConfig = config.rules[ruleId];
  if (ruleConfig == null) {
    return (rule: null, rulesExcludes: config.excludeForRulesPatterns);
  }

  _validateSeverity(ruleId, ruleConfig, config.analysisOptionsPath);
  try {
    return (
      rule: getRulesById({ruleId: ruleConfig}).firstOrNull,
      rulesExcludes: config.excludeForRulesPatterns,
    );
  } on Object catch (error) {
    throw FormatException(
      "Invalid configuration for '$ruleId': $error",
      config.analysisOptionsPath,
    );
  }
}

LintConfig _loadConfig(String packageRoot) {
  final collection = createAnalysisContextCollection(
    [packageRoot],
    packageRoot,
    null,
  );
  try {
    final context = collection.contexts.first;
    final options = analysisOptionsFromContext(context);
    if (options == null) {
      return const LintConfig(
        excludePatterns: [],
        excludeForMetricsPatterns: [],
        metrics: {},
        rules: {},
        excludeForRulesPatterns: [],
        antiPatterns: {},
        shouldPrintConfig: false,
        analysisOptionsPath: null,
      );
    }

    _validateResolvedRules(options.options, options.fullPath!);
    return ConfigBuilder.getLintConfigFromOptions(options);
  } finally {
    unawaited(collection.dispose());
  }
}

void _validateResolvedRules(Map<String, Object> options, String source) {
  final dcl = options['dart_code_linter'];
  if (dcl == null) {
    return;
  }
  if (dcl is! Map<String, Object>) {
    throw FormatException("Expected 'dart_code_linter' to be a map.", source);
  }

  final rules = dcl['rules'];
  if (rules == null) {
    return;
  }
  final validMap = rules is Map<String, Object> &&
      rules.values
          .every((value) => value is bool || value is Map<String, Object>);
  final validList = rules is Iterable<Object> &&
      rules.every(
        (entry) =>
            entry is String ||
            entry is Map<String, Object> &&
                entry.length == 1 &&
                (entry.values.single is bool ||
                    entry.values.single is Map<String, Object>),
      );
  if (!validMap && !validList) {
    throw FormatException(
      "Expected 'dart_code_linter.rules' to be a list or map containing rule names, booleans, or maps.",
      source,
    );
  }
}

void _validateSeverity(
  String ruleId,
  Map<String, Object> config,
  String? source,
) {
  final severity = config['severity'];
  final validSeverity = severity is String &&
      (Severity.fromString(severity) != Severity.none ||
          severity.toLowerCase() == 'none');
  if (severity != null && !validSeverity) {
    throw FormatException(
      "Invalid severity '$severity' for '$ruleId'.",
      source,
    );
  }
}
