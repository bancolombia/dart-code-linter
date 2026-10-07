import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/error/error.dart';
import 'package:dart_code_linter/src/analysis_server_plugin/dart_code_linter_plugin.dart';
import 'package:dart_code_linter/src/analyzers/lint_analyzer/rules/rules_factory.dart';
import 'package:test/test.dart';

void main() {
  test('registers configurable rules for independent option loading', () {
    final registry = _Registry();

    DartCodeLinterPlugin().register(registry);

    expect(registry.rules.map((rule) => rule.name), contains('ban-name'));
    expect(
      registry.rules.map((rule) => rule.name),
      contains('avoid-banned-imports'),
    );
    expect(registry.rules, hasLength(allRuleIds.length));
  });
}

class _Registry implements PluginRegistry {
  final rules = <AbstractAnalysisRule>[];

  @override
  void registerLintRule(AbstractAnalysisRule rule) => rules.add(rule);

  @override
  void registerAssist(Object generator) {}

  @override
  void registerFixForRule(DiagnosticCode code, Object generator) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
