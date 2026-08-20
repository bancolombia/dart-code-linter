import 'package:analyzer/dart/analysis/analysis_context_collection.dart';

import '../analyzers/lint_analyzer/lint_config.dart';
import '../analyzers/lint_analyzer/models/severity.dart';
import '../analyzers/lint_analyzer/rules/models/rule.dart';
import '../analyzers/lint_analyzer/rules/rules_factory.dart';
import '../config_builder/config_builder.dart';
import '../config_builder/models/analysis_options.dart';
import '../utils/analyzer_utils.dart';

// ponytail: retain one collection per package root for plugin lifetime; evict
// only if multi-workspace analysis shows measurable memory pressure.
final _analysisContextCollections = <String, AnalysisContextCollection>{};

/// Loads [ruleId]'s full DCL configuration for Analysis Server integration.
({Rule? rule, Iterable<String> rulesExcludes, FormatException? error})
    loadAnalysisServerRule(String packageRoot, String ruleId) {
  final loaded = _loadConfig(packageRoot);
  final config = loaded.config;
  try {
    if (loaded.source case final source?) {
      _validateResolvedRules(loaded.options, source);
    }

    final ruleConfig = config.rules[ruleId];
    if (ruleConfig == null) {
      return (
        rule: null,
        rulesExcludes: config.excludeForRulesPatterns,
        error: null,
      );
    }

    _validateSeverity(ruleId, ruleConfig, config.analysisOptionsPath);
    return (
      rule: getRulesById({ruleId: ruleConfig}).firstOrNull,
      rulesExcludes: config.excludeForRulesPatterns,
      error: null,
    );
  } on FormatException catch (error) {
    return (
      rule: null,
      rulesExcludes: config.excludeForRulesPatterns,
      error: error,
    );
  } on Object catch (error) {
    return (
      rule: null,
      rulesExcludes: config.excludeForRulesPatterns,
      error: FormatException(
        "Invalid configuration for '$ruleId': $error",
        config.analysisOptionsPath,
      ),
    );
  }
}

({LintConfig config, Map<String, Object> options, String? source}) _loadConfig(
    String packageRoot) {
  final collection = _analysisContextCollections.putIfAbsent(
    packageRoot,
    () => createAnalysisContextCollection(
      [packageRoot],
      packageRoot,
      null,
    ),
  );
  if (collection.contexts.isEmpty) {
    throw FormatException(
      "No analysis context found for '$packageRoot'.",
      packageRoot,
    );
  }

  final context = collection.contexts.first;
  final analysisOptions = analysisOptionsFromContext(context);
  if (analysisOptions == null) {
    return (
      config: const LintConfig(
        excludePatterns: [],
        excludeForMetricsPatterns: [],
        metrics: {},
        rules: {},
        excludeForRulesPatterns: [],
        antiPatterns: {},
        shouldPrintConfig: false,
        analysisOptionsPath: null,
      ),
      options: <String, Object>{},
      source: null,
    );
  }

  return (
    config: ConfigBuilder.getLintConfigFromOptions(analysisOptions),
    options: analysisOptions.options,
    source: analysisOptions.fullPath,
  );
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
