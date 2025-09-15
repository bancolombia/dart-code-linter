// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/replacement.dart';
import '../../../models/severity.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class PreferNamedRecordFieldsRule extends DartRule {
  static const ruleId = 'prefer-named-record-fields';
  static const warningMessage =
      'Prefer named record fields over positional fields for better code readability.';
  static const replaceComment = 'Consider using named record fields.';

  PreferNamedRecordFieldsRule([Map<String, Object> config = const {}])
      : super(
          id: ruleId,
          severity: readSeverity(config, Severity.style),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor();
    source.unit.visitChildren(visitor);

    return [
      ...visitor.recordTypeAnnotations.map((recordType) => createIssue(
            rule: this,
            location: nodeLocation(node: recordType, source: source),
            message: warningMessage,
            replacement: _createReplacementForRecordType(recordType),
          )),
      ...visitor.recordLiterals.map((recordLiteral) => createIssue(
            rule: this,
            location: nodeLocation(node: recordLiteral, source: source),
            message: warningMessage,
            replacement: _createReplacementForRecordLiteral(recordLiteral),
          )),
    ].toList(growable: false);
  }

  Replacement _createReplacementForRecordType(RecordTypeAnnotation recordType) {
    final positionalFields = recordType.positionalFields;

    if (positionalFields.isEmpty) {
      return const Replacement(
        comment: replaceComment,
        replacement: '',
      );
    }

    final namedFields = <String>[];
    for (var i = 0; i < positionalFields.length; i++) {
      final field = positionalFields[i];
      final fieldName = _generateFieldName(field.type, i);
      namedFields.add('${field.type} $fieldName');
    }

    final namedFieldsStr = namedFields.join(', ');
    final existingNamed = recordType.namedFields;

    String replacement;
    replacement = existingNamed != null && existingNamed.fields.isNotEmpty
        ? '({$namedFieldsStr, ${existingNamed.toSource()}})'
        : '({$namedFieldsStr})';

    return Replacement(
      comment: replaceComment,
      replacement: replacement,
    );
  }

  Replacement _createReplacementForRecordLiteral(RecordLiteral recordLiteral) {
    final positionalFields = recordLiteral.fields
        .where((field) => field is! NamedExpression)
        .toList();

    if (positionalFields.isEmpty) {
      return const Replacement(
        comment: replaceComment,
        replacement: '',
      );
    }

    final namedFields = <String>[];
    for (var i = 0; i < positionalFields.length; i++) {
      final field = positionalFields[i];
      final fieldName = _generateFieldNameFromExpression(field, i);
      namedFields.add('$fieldName: ${field.toSource()}');
    }

    final namedFieldsStr = namedFields.join(', ');
    final existingNamed = recordLiteral.fields
        .whereType<NamedExpression>()
        .map((field) => field.toSource())
        .join(', ');

    String replacement;
    replacement = existingNamed.isNotEmpty
        ? '($namedFieldsStr, $existingNamed)'
        : '($namedFieldsStr)';

    return Replacement(
      comment: replaceComment,
      replacement: replacement,
    );
  }

  String _generateFieldName(TypeAnnotation? type, int index) {
    if (type != null) {
      final typeName = type.toSource().toLowerCase();

      switch (typeName) {
        case 'string':
          return 'text';
        case 'int':
        case 'integer':
          return 'number';
        case 'double':
        case 'num':
          return 'value';
        case 'bool':
        case 'boolean':
          return 'flag';
        case 'list':
          return 'items';
        case 'map':
          return 'data';
        default:
          if (typeName.startsWith('list<')) {
            return 'items';
          } else if (typeName.startsWith('map<')) {
            return 'data';
          } else if (typeName.length > 3) {
            return typeName.substring(0, 1).toLowerCase() +
                typeName.substring(1);
          }
      }
    }

    return 'field${index + 1}';
  }

  String _generateFieldNameFromExpression(AstNode expression, int index) {
    if (expression is StringLiteral) {
      return 'text';
    } else if (expression is IntegerLiteral) {
      return 'number';
    } else if (expression is DoubleLiteral) {
      return 'value';
    } else if (expression is BooleanLiteral) {
      return 'flag';
    } else if (expression is ListLiteral) {
      return 'items';
    } else if (expression is SetOrMapLiteral) {
      return 'data';
    } else if (expression is Identifier) {
      final name = expression.name;
      if (name.length > 1) {
        return name;
      }
    }

    return 'field${index + 1}';
  }
}
