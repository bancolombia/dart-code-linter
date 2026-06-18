// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:source_span/source_span.dart';

import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/replacement.dart';
import '../../../models/severity.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

class AvoidDuplicateExportsRule extends DartRule {
  static const ruleId = 'avoid-duplicate-exports';
  static const _issueMessage = 'Avoid declaring duplicate exports.';
  static const _fixComment = 'Delete the duplicate export directive.';

  AvoidDuplicateExportsRule([Map<String, Object> config = const {}])
      : super(
          id: ruleId,
          severity: readSeverity(config, Severity.warning),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor();

    source.unit.visitChildren(visitor);

    final content = source.content;

    return visitor.nodes.map((node) {
      // The earlier export already covers this URI, so deleting the duplicate
      // directive is behavior-preserving.
      final startOffset = _lineStartOffset(node.offset, content);
      final endOffset = _deletionEndOffset(node.end, content);

      return createIssue(
        rule: this,
        location: _locationFromOffsets(
          source: source,
          startOffset: startOffset,
          endOffset: endOffset,
        ),
        message: _issueMessage,
        replacements: const [
          Replacement(comment: _fixComment, replacement: ''),
        ],
      );
    }).toList(growable: false);
  }
}

int _lineStartOffset(int offset, String content) =>
    content.lastIndexOf('\n', offset - 1) + 1;

// Where to stop deleting, starting from the end of the directive ([offset]).
//
// When the rest of the physical line holds nothing but whitespace and/or a
// `//` comment, the whole line (including its trailing line break) is removed
// so no dangling blank line is left. Otherwise — e.g. a block comment that
// runs onto the next line, or another directive sharing the line — only the
// directive itself is removed, since swallowing the line would corrupt that
// trailing content.
int _deletionEndOffset(int offset, String content) {
  final newlineIndex = content.indexOf('\n', offset);
  final lineEnd = newlineIndex == -1 ? content.length : newlineIndex;
  final lineTail = content.substring(offset, lineEnd).trimLeft();

  final isCleanLine = lineTail.isEmpty || lineTail.startsWith('//');

  if (!isCleanLine) {
    return offset;
  }

  return newlineIndex == -1 ? content.length : newlineIndex + 1;
}

SourceSpan _locationFromOffsets({
  required InternalResolvedUnitResult source,
  required int startOffset,
  required int endOffset,
}) {
  final sourceUrl = Uri.file(source.path);

  final startLocation = source.lineInfo.getLocation(startOffset);
  final endLocation = source.lineInfo.getLocation(endOffset);

  return SourceSpan(
    SourceLocation(
      startOffset,
      sourceUrl: sourceUrl,
      line: startLocation.lineNumber,
      column: startLocation.columnNumber,
    ),
    SourceLocation(
      endOffset,
      sourceUrl: sourceUrl,
      line: endLocation.lineNumber,
      column: endLocation.columnNumber,
    ),
    source.content.substring(startOffset, endOffset),
  );
}
