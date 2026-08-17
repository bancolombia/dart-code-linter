import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:source_span/source_span.dart';

import '../analyzers/lint_analyzer/models/internal_resolved_unit_result.dart';

/// Returns [SourceSpan] with information about original code for [node] from [source]
SourceSpan nodeLocation({
  required SyntacticEntity node,
  required InternalResolvedUnitResult source,
  SyntacticEntity? endNode,
  bool withCommentOrMetadata = false,
}) {
  final offset = !withCommentOrMetadata && node is AnnotatedNode
      ? node.firstTokenAfterCommentAndMetadata.offset
      : node.offset;
  final end = endNode?.end ?? node.end;
  final sourceUrl = Uri.file(source.path);

  final offsetLocation = source.lineInfo.getLocation(offset);
  final endLocation = source.lineInfo.getLocation(end);

  return SourceSpan(
    SourceLocation(
      offset,
      sourceUrl: sourceUrl,
      line: offsetLocation.lineNumber,
      column: offsetLocation.columnNumber,
    ),
    SourceLocation(
      end,
      sourceUrl: sourceUrl,
      line: endLocation.lineNumber,
      column: endLocation.columnNumber,
    ),
    source.content.substring(offset, end),
  );
}

bool isOverride(List<Annotation> metadata) => metadata.any(
      (node) =>
          node.name.name == 'override' && node.atSign.type == TokenType.AT,
    );

bool haveSameParameterType(Expression left, Expression right) =>
    left.staticType == right.staticType;

bool isEntrypoint(String name, NodeList<Annotation> metadata) =>
    name == 'main' ||
    hasEntryPointPragma(metadata) ||
    _flutterInternalEntryFunctions.contains(name);

const _flutterInternalEntryFunctions = {'registerPlugins', 'testExecutable'};

/// Whether [metadata] carries `@JS`, which marks an `external` binding that
/// Dart calls into JavaScript.
///
/// Deliberately not `Metadata.hasJS`: that resolves the annotation's library,
/// and it only learned about `dart:js_interop` in analyzer 13
/// (`ElementAnnotation.isJS` matches `package:js` alone on 10 to 12), so it
/// silently misses modern interop code on the lower half of the supported
/// range. Matching by name behaves the same on every supported analyzer and
/// covers both `package:js` and `dart:js_interop`.
bool hasJSAnnotation(Iterable<Annotation> metadata) =>
    metadata.any((annotation) => _annotationName(annotation) == 'JS');

/// Whether [metadata] carries `@JSExport`, which marks Dart members that
/// JavaScript calls through `createJSInteropWrapper`.
///
/// Valid both on an individual instance member and on the enclosing class, in
/// which case it covers every instance member of that class. See the `JSExport`
/// doc in `dart:js_interop`.
///
/// Note this is the opposite direction from `@JS`, whose members are `external`
/// bindings that Dart calls into JavaScript.
bool hasJSExportAnnotation(Iterable<Annotation> metadata) =>
    metadata.any((annotation) => _annotationName(annotation) == 'JSExport');

/// The last component of an annotation's name, so that a prefixed annotation
/// matches as well: for `@js.JSExport()` after `import 'dart:js_interop' as
/// js;`, [Annotation.name] is a [PrefixedIdentifier] whose own `name` would be
/// `'js.JSExport'` rather than `'JSExport'`.
String _annotationName(Annotation annotation) {
  final name = annotation.name;

  return name is PrefixedIdentifier ? name.identifier.name : name.name;
}

/// See https://github.com/dart-lang/sdk/blob/master/runtime/docs/compiler/aot/entry_point_pragma.md
bool hasEntryPointPragma(Iterable<Annotation> metadata) =>
    metadata.where((annotation) {
      final arguments = annotation.arguments;

      return annotation.name.name == 'pragma' &&
          arguments != null &&
          arguments.arguments
              .where((argument) =>
                  argument is SimpleStringLiteral &&
                  argument.stringValue == 'vm:entry-point')
              .isNotEmpty;
    }).isNotEmpty;
