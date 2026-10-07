import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// The default `--exclude` pattern.
const defaultExcludes = ['{/**.g.dart,/**.freezed.dart}'];

/// Creates a project in a temporary directory outside the current one, where
/// generated files, which the default `--exclude` pattern matches, are the
/// only users of some of the hand written code, and returns its root.
///
/// The directory is deleted when the current test ends.
String createGeneratedUsagesProject() {
  final root = Directory.systemTemp
      .createTempSync('dcl_generated_usages_')
      .resolveSymbolicLinksSync();
  addTearDown(() => Directory(root).deleteSync(recursive: true));

  File(p.join(root, 'analysis_options.yaml')).writeAsStringSync('');

  _files.forEach((name, content) {
    File(p.join(root, 'lib', name))
      ..createSync(recursive: true)
      ..writeAsStringSync(content);
  });

  return root;
}

const _files = {
  'main.dart': '''
import 'gen.g.dart';
import 'l10n.dart';
import 'model.dart';
import 'strings.g.dart';

void main() {
  generated();
  print(const Foo());
  print(AppI18n.usedKey);
  print(GenI18n.usedKey);
  takes(1);
  alsoTakes(1);
  genTakes(1);
}
''',
  // A generated library, not a part, which is the only user of helper.dart,
  // AppI18n.genKey and the null passed to takes.
  'gen.g.dart': '''
import 'helper.dart';
import 'l10n.dart';
import 'model.dart';

void generated() {
  helper();
  print(AppI18n.genKey);
  takes(null);
}

void genTakes(int? a) {}

void unusedGenerated() {}
''',
  'helper.dart': '''
void helper() {}
''',
  // The freezed shape: the private constructor is only called from the
  // generated part.
  'model.dart': '''
part 'model.freezed.dart';

void takes(int? a) {}

void alsoTakes(int? a) {}

void unusedFunction() {}

class Foo {
  const Foo._();

  const factory Foo() = _Foo;
}
''',
  'model.freezed.dart': '''
part of 'model.dart';

class _Foo extends Foo {
  const _Foo() : super._();
}
''',
  'l10n.dart': '''
class AppI18n {
  static String get usedKey => 'used';

  static String get genKey => 'gen';

  static String get unusedKey => 'unused';
}
''',
  'strings.g.dart': '''
class GenI18n {
  static String get usedKey => 'used';

  static String get unusedKey => 'unused';
}
''',
  'unused.dart': '''
void orphan() {}
''',
  'orphan.g.dart': '''
int orphanGenerated = 1;
''',
};
