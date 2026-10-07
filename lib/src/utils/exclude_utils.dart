import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

bool isIncluded(String absolutePath, Iterable<Glob> includes) =>
    includes.isEmpty || _hasMatch(absolutePath, includes);

bool isExcluded(String absolutePath, Iterable<Glob> excludes) =>
    _hasMatch(absolutePath, excludes);

Iterable<Glob> createAbsolutePatterns(
  Iterable<String> patterns,
  String root,
) =>
    patterns.map((pattern) => Glob(_absolutePattern(pattern, root))).toList();

/// Joins [pattern] to [root]. A pattern that is a single brace group, such as
/// the default `{/**.g.dart,/**.freezed.dart}`, is joined one alternative at a
/// time, so an alternative starting with `/` stays absolute, as a pattern
/// starting with `/` does, instead of leaving a double slash after [root].
String _absolutePattern(String pattern, String root) {
  final alternatives = _braceAlternatives(pattern);

  return alternatives == null
      ? _joinPattern(root, pattern)
      : '{${alternatives.map((part) => _joinPattern(root, part)).join(',')}}';
}

String _joinPattern(String root, String pattern) =>
    p.normalize(p.join(root, pattern)).replaceAll(r'\', '/');

/// Returns the top level alternatives of [pattern] if the whole pattern is a
/// single brace group, otherwise null.
List<String>? _braceAlternatives(String pattern) {
  if (!pattern.startsWith('{') || !pattern.endsWith('}')) {
    return null;
  }

  final alternatives = <String>[];
  var depth = 0;
  var start = 1;
  for (var i = 0; i < pattern.length; i++) {
    final char = pattern[i];
    if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
      if (depth == 0 && i != pattern.length - 1) {
        return null;
      }
    } else if (char == ',' && depth == 1) {
      alternatives.add(pattern.substring(start, i));
      start = i + 1;
    }
  }

  if (depth != 0) {
    return null;
  }

  return alternatives..add(pattern.substring(start, pattern.length - 1));
}

bool _hasMatch(String absolutePath, Iterable<Glob> excludes) {
  final path = absolutePath.replaceAll(r'\', '/');

  return excludes.any((exclude) => exclude.matches(path));
}
