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

class OnlyBarrelImportRule extends DartRule {
  static const ruleId = 'only-barrel-import';
  static const _warningMessage =
      'You should only use barrel imports for external modules. Please use the following format: `package:package_name/package_name.dart`.';

  List<String> allowedBarrels = [];

  OnlyBarrelImportRule([Map<String, Object> config = const {}])
      : super(
          id: ruleId,
          severity: readSeverity(config, Severity.error),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        ) {
    if (config.containsKey('barrels') && config['barrels'] is List) {
      allowedBarrels =
          (config['barrels'] as List).map((e) => e.toString()).toList();
    }
  }
  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor(allowedBarrels);

    source.unit.visitChildren(visitor);

    return visitor.invalidImports
        .map((importDirective) => createIssue(
              rule: this,
              location: nodeLocation(
                node: importDirective,
                source: source,
                withCommentOrMetadata: false,
              ),
              message: _warningMessage,
              verboseMessage:
                  'We use only barrel imports for external modules so these modules can define some internal private APIs and hide them from the public API. This is a good practice to keep the codebase clean and maintainable.',
              replacements: [
                _createReplacement(importDirective),
                _createReplacementWithValidImport(importDirective),
              ],
            ))
        .toList(growable: false);
  }

  // Creates a quick fix to remove the invalid import if the
  Replacement _createReplacement(ImportDirective _) => const Replacement(
        comment: 'Remove the invalid import.',
        replacement: '',
      );

  // Creates a quick fix to replae the invalid import with a valid one
  Replacement _createReplacementWithValidImport(
    ImportDirective importDirective,
  ) {
    final uri = importDirective.uri.stringValue ?? '';
    final hostImport = uri.split('/').first;
    final packageName = hostImport.split(':').last;
    final validImport = "import 'package:$packageName/$packageName.dart';";

    return Replacement(
      comment: 'Replace with the corresponding barrel import.',
      replacement: validImport,
    );
  }
}
