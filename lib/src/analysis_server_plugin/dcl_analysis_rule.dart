import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

import '../analyzers/lint_analyzer/models/internal_resolved_unit_result.dart';
import '../analyzers/lint_analyzer/rules/models/rule.dart';

/// Bridges a DCL [Rule] into the new [AnalysisRule] interface required by
/// `analysis_server_plugin` (Dart ≥ 3.9 / Dart Analysis Server plugin API).
///
/// Each DCL rule is wrapped in one [DclAnalysisRule]. The wrapper visits every
/// [CompilationUnit], delegates analysis to the underlying DCL rule via
/// `Rule.check`, and reports the returned issues using [reportAtOffset].
///
/// The [LintCode.problemMessage] uses the `{0}` placeholder so that the
/// per-issue message from DCL is forwarded verbatim to the IDE/CLI.
/// The optional [LintCode.correctionMessage] uses `{1}` for the verbose message.
final class DclAnalysisRule extends AnalysisRule {
  final Rule _dclRule;

  /// The [LintCode] is created lazily and cached so it is only allocated once
  /// per rule instance.
  late final LintCode _lintCode = LintCode(
    _dclRule.id,
    '{0}',
    correctionMessage: '{1}',
  );

  DclAnalysisRule(this._dclRule)
    : super(name: _dclRule.id, description: _dclRule.id);

  @override
  DiagnosticCode get diagnosticCode => _lintCode;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addCompilationUnit(this, _DclVisitor(this, context));
  }
}

class _DclVisitor extends SimpleAstVisitor<void> {
  final DclAnalysisRule _rule;
  final RuleContext _context;

  _DclVisitor(this._rule, this._context);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final contextUnit = _context.currentUnit;
    if (contextUnit == null) {
      return;
    }

    final source = InternalResolvedUnitResult(
      contextUnit.file.path,
      contextUnit.content,
      node,
      node.lineInfo,
    );

    for (final issue in _rule._dclRule.check(source)) {
      _rule.reportAtOffset(
        issue.location.start.offset,
        issue.location.length,
        arguments: [issue.message, issue.verboseMessage ?? ''],
      );
    }
  }
}
