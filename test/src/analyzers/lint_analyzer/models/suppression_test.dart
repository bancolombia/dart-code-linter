import 'package:analyzer/source/line_info.dart';
import 'package:dart_code_linter/src/utils/suppression.dart';
import 'package:test/test.dart';

import '../../../helpers/file_resolver.dart';

const _examplePath = 'test/resources/suppression_example.dart';
const _exampleAllPath = 'test/resources/suppression_all_example.dart';

void main() {
  test('suppression in content', () async {
    final parseResult = await FileResolver.resolve(_examplePath);

    final suppression = Suppression(
      parseResult.content,
      parseResult.lineInfo,
      supportsTypeLintIgnore: true,
    );

    expect(suppression.isSuppressed('rule_id1'), isTrue);
    expect(suppression.isSuppressed('rule_id2'), isTrue);
    expect(suppression.isSuppressed('rule_id3'), isTrue);
    expect(suppression.isSuppressed('rule_id4'), isFalse);

    expect(suppression.isSuppressedAt('rule_id4', 5), isTrue);
    expect(suppression.isSuppressedAt('rule_id5', 5), isTrue);
    expect(suppression.isSuppressedAt('rule_id6', 9), isTrue);
    expect(suppression.isSuppressedAt('rule_id7', 9), isTrue);
    expect(suppression.isSuppressedAt('rule_id8', 9), isTrue);
    expect(suppression.isSuppressedAt('rule_id9', 9), isTrue);
  });

  test('suppression with type=lint', () async {
    final parseResult = await FileResolver.resolve(_exampleAllPath);

    final suppression = Suppression(
      parseResult.content,
      parseResult.lineInfo,
      supportsTypeLintIgnore: true,
    );

    expect(suppression.isSuppressed('rule_id1'), isTrue);
    expect(suppression.isSuppressed('rule_id2'), isTrue);
    expect(suppression.isSuppressed('rule_id3'), isTrue);
    expect(suppression.isSuppressed('rule_id4'), isTrue);

    expect(suppression.isSuppressedAt('rule_id4', 5), isTrue);
    expect(suppression.isSuppressedAt('rule_id5', 5), isTrue);
    expect(suppression.isSuppressedAt('rule_id6', 9), isTrue);
    expect(suppression.isSuppressedAt('rule_id7', 9), isTrue);
    expect(suppression.isSuppressedAt('rule_id8', 9), isTrue);
    expect(suppression.isSuppressedAt('rule_id9', 9), isTrue);
  });

  test('suppression of ids prefixed with the plugin name', () {
    // As the IDE's "Ignore ... for this line" and "for the whole file" quick
    // fixes write them since Dart 3.12.
    const content = '''
// ignore_for_file: dart_code_linter/rule-id1
// ignore: dart_code_linter/rule-id2
void f() {}
void g() {} // ignore: dart_code_linter/rule-id3, rule-id4
// ignore: other_plugin/rule-id5
void h() {}
''';

    final suppression = Suppression(content, LineInfo.fromContent(content));

    expect(suppression.isSuppressed('rule-id1'), isTrue);
    expect(suppression.isSuppressed('rule-id2'), isFalse);
    expect(suppression.isSuppressedAt('rule-id2', 3), isTrue);
    expect(suppression.isSuppressedAt('rule-id3', 4), isTrue);
    expect(suppression.isSuppressedAt('rule-id4', 4), isTrue);
    expect(suppression.isSuppressedAt('rule-id5', 6), isFalse);
  });
}
