// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:source_span/source_span.dart';

import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/replacement.dart';
import '../../../models/severity.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

// Inspired by ESLint (https://eslint.org/docs/rules/newline-before-return)

class NewlineBeforeReturnRule extends DartRule {
  static const String ruleId = 'newline-before-return';

  static const _warning = 'Missing blank line before return.';
  static const _fixComment = 'Insert blank line before return.';

  NewlineBeforeReturnRule([Map<String, Object> config = const {}])
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

    return visitor.statements
        // return statement is in a block
        .where((statement) => statement.parent is Block)
        // return statement isn't first token in a block
        .where((statement) =>
            statement.returnKeyword.previous != statement.parent?.beginToken)
        .where((statement) {
      final lineInfo = source.lineInfo;

      final previousTokenLine = lineInfo
          .getLocation(statement.returnKeyword.previous!.end)
          .lineNumber;
      final tokenLine = lineInfo
          .getLocation(
            _optimalToken(statement.returnKeyword, lineInfo).offset,
          )
          .lineNumber;

      return !(tokenLine > previousTokenLine + 1);
    }).map((statement) {
      final fixStartOffset = _fixStartOffset(statement, source);
      final fixEndOffset = statement.end;

      return createIssue(
        rule: this,
        location: _locationFromOffsets(
          source: source,
          startOffset: fixStartOffset,
          endOffset: fixEndOffset,
        ),
        message: _warning,
        replacements: [
          Replacement(
            comment: _fixComment,
            replacement:
                '\n${source.content.substring(fixStartOffset, fixEndOffset)}',
          ),
        ],
      );
    }).toList(growable: false);
  }
}

int _fixStartOffset(
  ReturnStatement statement,
  InternalResolvedUnitResult source,
) {
  final token = _optimalToken(statement.returnKeyword, source.lineInfo);
  return _lineStartOffset(token.offset, source.content);
}

int _lineStartOffset(int offset, String content) =>
    content.lastIndexOf('\n', offset - 1) + 1;

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

Token _optimalToken(Token token, LineInfo lineInfo) {
  var optimalToken = token;

  var commentToken = _latestCommentToken(token);
  while (commentToken != null &&
      lineInfo.getLocation(commentToken.end).lineNumber + 1 >=
          lineInfo.getLocation(optimalToken.offset).lineNumber) {
    optimalToken = commentToken;
    commentToken = commentToken.previous;
  }

  return optimalToken;
}

Token? _latestCommentToken(Token token) {
  Token? latestCommentToken = token.precedingComments;
  while (latestCommentToken?.next != null) {
    latestCommentToken = latestCommentToken?.next;
  }

  return latestCommentToken;
}
