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

class NoBlankLineBeforeSingleReturnRule extends DartRule {
  static const String ruleId = 'no-blank-line-before-single-return';

  static const warning =
      'Remove blank line before single return statement in a block.';

  static const _fixComment = 'Remove blank line before return.';

  NoBlankLineBeforeSingleReturnRule([Map<String, Object> config = const {}])
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
        // Ensure the return statement is in a block
        .where((statement) => statement.parent is Block)
        // Ensure the return statement is the only statement in the block
        .where((statement) {
      final parentBlock = statement.parent as Block;

      return parentBlock.statements.length == 1;
    })
        // Keep only returns with a blank line before them, ignoring comments
        .where((statement) {
      final lineInfo = source.lineInfo;

      // Get the last non-comment token before the return statement
      final previousTokenLine = lineInfo
          .getLocation(statement.returnKeyword.previous!.end)
          .lineNumber;

      final tokenLine = lineInfo
          .getLocation(
            _optimalToken(statement.returnKeyword, lineInfo).offset,
          )
          .lineNumber;

      return tokenLine > previousTokenLine + 1;
    }).map((statement) {
      final content = source.content;
      final startOffset =
          content.indexOf('\n', _braceLineEnd(statement, source.lineInfo)) + 1;
      final endOffset = statement.end;

      return createIssue(
        rule: this,
        location: _locationFromOffsets(
          source: source,
          startOffset: startOffset,
          endOffset: endOffset,
        ),
        message: warning,
        replacements: [
          Replacement(
            comment: _fixComment,
            replacement: _buildReplacement(statement, startOffset, content),
          ),
        ],
      );
    }).toList(growable: false);
  }
}

// The region without its blank lines; comments and the return's line stay
// as they are.
String _buildReplacement(
  ReturnStatement statement,
  int startOffset,
  String content,
) {
  final comments = <Token>[];
  for (Token? comment = statement.returnKeyword.precedingComments;
      comment != null;
      comment = comment.next) {
    comments.add(comment);
  }

  final buffer = StringBuffer();
  final returnLineStart =
      _lineStartOffset(statement.returnKeyword.offset, content);
  var lineStart = startOffset;
  while (lineStart < returnLineStart) {
    final lineEnd = content.indexOf('\n', lineStart) + 1;
    final line = content.substring(lineStart, lineEnd);
    final inComment = comments.any(
        (comment) => comment.offset < lineStart && lineStart < comment.end);
    if (inComment || line.trim().isNotEmpty) {
      buffer.write(line);
    }
    lineStart = lineEnd;
  }
  buffer.write(content.substring(returnLineStart, statement.end));

  return buffer.toString();
}

// The end of the opening brace, or of the last comment starting on its line.
int _braceLineEnd(ReturnStatement statement, LineInfo lineInfo) {
  final brace = statement.returnKeyword.previous!;
  final braceLine = lineInfo.getLocation(brace.end).lineNumber;

  var end = brace.end;
  Token? comment = statement.returnKeyword.precedingComments;
  while (comment != null &&
      lineInfo.getLocation(comment.offset).lineNumber == braceLine) {
    end = comment.end;
    comment = comment.next;
  }

  return end;
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

  // Line of the previous non-comment token (e.g. the block's opening brace).
  final previousToken = token.previous;
  final previousLine = previousToken != null
      ? lineInfo.getLocation(previousToken.end).lineNumber
      : -1;

  while (commentToken != null) {
    final commentTokenLineNumber =
        lineInfo.getLocation(commentToken.end).lineNumber;
    final optimalTokenLineNumber =
        lineInfo.getLocation(optimalToken.offset).lineNumber;

    final isDirectlyPrecedingComment =
        commentTokenLineNumber + 1 >= optimalTokenLineNumber;

    // A comment sharing the previous token's line is a trailing comment (e.g.
    // on the opening brace), not an own-line comment, so it must not pull the
    // optimal token up to that line and hide the real return position.
    final isTrailingComment = commentTokenLineNumber <= previousLine;

    if (!isDirectlyPrecedingComment || isTrailingComment) {
      break;
    }

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
