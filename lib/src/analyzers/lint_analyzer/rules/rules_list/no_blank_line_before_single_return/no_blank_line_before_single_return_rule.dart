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
        // Ensure there is no blank line before the return statement, ignoring comments
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

          return tokenLine != previousTokenLine + 1;
        })
        .map((statement) {
          final content = source.content;
          final startOffset =
              content.indexOf('\n', statement.returnKeyword.previous!.end) + 1;
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
        })
        .toList(growable: false);
  }
}

// Rebuilds the region between the block's opening token and the return
// statement, keeping any comments (verbatim, on their own lines) and the
// return line while dropping the blank lines in between.
String _buildReplacement(
  ReturnStatement statement,
  int startOffset,
  String content,
) {
  final buffer = StringBuffer();

  Token? comment = statement.returnKeyword.precedingComments;
  while (comment != null) {
    // Skip comments that share the line with the previous token (e.g. a
    // trailing comment on the opening brace); they stay outside the region.
    if (comment.offset >= startOffset) {
      final lineStart = _lineStartOffset(comment.offset, content);
      final indentation = content.substring(lineStart, comment.offset);
      buffer.write('$indentation${comment.lexeme}\n');
    }
    comment = comment.next;
  }

  final returnOffset = statement.returnKeyword.offset;
  final returnLineStart = _lineStartOffset(returnOffset, content);
  buffer.write(content.substring(returnLineStart, statement.end));

  return buffer.toString();
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
