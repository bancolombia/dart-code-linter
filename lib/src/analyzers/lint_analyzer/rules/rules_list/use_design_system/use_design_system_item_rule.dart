import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import '../../../../../../lint_analyzer.dart';
import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';
part 'config_parser.dart';

class UseDesignSystemItemRule extends DartRule {
  static const String ruleId = 'use-design-system-item';

  final Map<String, _ReplacementSuggestion> _configurations;

  UseDesignSystemItemRule([Map<String, Object> config = const {}])
      : _configurations = _ConfigParser.parseConfig(config),
        super(
          id: ruleId,
          severity: readSeverity(config, Severity.warning),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Map<String, Object?> toJson() {
    final json = super.toJson();
    json['configurations'] = _configurations;

    return json;
  }

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor(_configurations, this, source);
    source.unit.visitChildren(visitor);

    return visitor.issues;
  }
}
