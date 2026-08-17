import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/models/unused_code_file_report.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/reporters/reporters_list/console/unused_code_console_reporter.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/unused_code_analyzer.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/unused_code_config.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group(
    'UnusedCodeAnalyzer',
    () {
      const analyzer = UnusedCodeAnalyzer();
      const rootDirectory = '';
      const analyzerExcludes = [
        'test/resources/unused_code_analyzer/generated/**',
      ];
      final folders = [
        normalize(File('test/resources/unused_code_analyzer').absolute.path),
      ];

      group('run analysis', () {
        late Iterable<UnusedCodeFileReport> result;

        setUpAll(() async {
          final config =
              _createConfig(analyzerExcludePatterns: analyzerExcludes);

          result = await analyzer.runCliAnalysis(
            folders,
            rootDirectory,
            config,
          );
        });

        test('should report 5 files and not report excluded file', () {
          expect(result, hasLength(5));
        });

        test('should analyze not used files', () async {
          final report = result
              .firstWhere((report) => report.path.endsWith('not_used.dart'));

          expect(report.issues, hasLength(3));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'NotUsed');
          expect(firstIssue.declarationType, 'class');
          expect(firstIssue.location.line, 1);
          expect(firstIssue.location.column, 1);

          final secondIssue = report.issues.elementAt(1);
          expect(secondIssue.declarationName, 'value');
          expect(secondIssue.declarationType, 'top level variable');
          expect(secondIssue.location.line, 3);
          expect(secondIssue.location.column, 1);

          final thirdIssue = report.issues.elementAt(2);
          expect(thirdIssue.declarationName, 'someFunction');
          expect(thirdIssue.declarationType, 'function');
          expect(thirdIssue.location.line, 6);
          expect(thirdIssue.location.column, 1);
        });

        test('should analyze conditional import files', () async {
          final unconditionalReport = result.firstWhereOrNull(
            (report) => report.path.endsWith('unconditional_file.dart'),
          );

          expect(unconditionalReport, null);

          final report = result.firstWhere(
            (report) => report.path.endsWith('conditional_file.dart'),
          );

          expect(report.issues, hasLength(1));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'hello');
          expect(firstIssue.declarationType, 'function');
          expect(firstIssue.location.line, 6);
          expect(firstIssue.location.column, 1);
        });

        test('should analyze conditional prefixed import files', () async {
          final unconditionalReport = result.firstWhereOrNull(
            (report) =>
                report.path.endsWith('unconditional_prefixed_file.dart'),
          );

          expect(unconditionalReport, null);

          final report = result.firstWhere(
            (report) => report.path.endsWith('conditional_prefixed_file.dart'),
          );

          expect(report.issues, hasLength(1));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'helloWorld');
          expect(firstIssue.declarationType, 'function');
          expect(firstIssue.location.line, 3);
          expect(firstIssue.location.column, 1);
        });

        test('should analyze files', () async {
          final report = result.firstWhere(
            (report) => report.path.endsWith('public_members.dart'),
          );

          expect(report.issues, hasLength(8));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'printInteger');
          expect(firstIssue.declarationType, 'function');
          expect(firstIssue.location.line, 4);
          expect(firstIssue.location.column, 1);

          final secondIssue = report.issues.elementAt(1);
          expect(secondIssue.declarationName, 'someVariable');
          expect(secondIssue.declarationType, 'top level variable');
          expect(secondIssue.location.line, 13);
          expect(secondIssue.location.column, 1);

          final thirdIssue = report.issues.elementAt(2);
          expect(thirdIssue.declarationName, 'SomeClassWithMethod');
          expect(thirdIssue.declarationType, 'class');
          expect(thirdIssue.location.line, 97);
          expect(thirdIssue.location.column, 1);

          final forthIssue = report.issues.elementAt(3);
          expect(forthIssue.declarationName, 'SomeOtherService');
          expect(forthIssue.declarationType, 'class');
          expect(forthIssue.location.line, 123);
          expect(forthIssue.location.column, 1);

          final fifthIssue = report.issues.elementAt(4);
          expect(fifthIssue.declarationName, 'IntX');
          expect(fifthIssue.declarationType, 'extension');
          expect(fifthIssue.location.line, 144);
          expect(fifthIssue.location.column, 1);

          final sixthIssue = report.issues.elementAt(5);
          expect(sixthIssue.declarationName, 'SomeOtherEnum');
          expect(sixthIssue.declarationType, 'enum');
          expect(sixthIssue.location.line, 153);
          expect(sixthIssue.location.column, 1);

          final seventhIssue = report.issues.elementAt(6);
          expect(seventhIssue.declarationName, 'World');
          expect(seventhIssue.declarationType, 'type alias');
          expect(seventhIssue.location.line, 162);
          expect(seventhIssue.location.column, 1);

          final eightsIssue = report.issues.elementAt(7);
          expect(eightsIssue.declarationName, 'MyOtherWidget');
          expect(eightsIssue.declarationType, 'class');
          expect(eightsIssue.location.line, 171);
          expect(eightsIssue.location.column, 1);
        });

        test('should analyze elements from incorrectly parsed library', () {
          final report = result.firstWhere(
            (report) => report.path.endsWith('app_icons.dart'),
          );

          expect(report.issues, hasLength(1));

          final firstIssue = report.issues.first;
          expect(firstIssue.declarationName, 'AppIcons');
          expect(firstIssue.declarationType, 'class');
          expect(firstIssue.location.line, 3);
          expect(firstIssue.location.column, 1);
        });
      });

      test('should return a reporter', () {
        final reporter = analyzer.getReporter(name: 'console', output: stdout);

        expect(reporter, isA<UnusedCodeConsoleReporter>());
      });

      group('analyze-private-members', () {
        final privateMembersFolders = [
          normalize(File('test/resources/unused_code_private_members_analyzer')
              .absolute
              .path),
        ];

        test('is disabled by default', () async {
          final result = await analyzer.runCliAnalysis(
            privateMembersFolders,
            rootDirectory,
            _createConfig(),
          );

          expect(result, isEmpty);
        });

        test('reports only unused private members when enabled', () async {
          final result = await analyzer.runCliAnalysis(
            privateMembersFolders,
            rootDirectory,
            _createConfig(analyzePrivateMembers: true),
          );

          final report = result.firstWhere(
            (report) => report.path.endsWith('private_members.dart'),
          );

          final names = report.issues.map((issue) => issue.declarationName);

          expect(
            names,
            unorderedEquals([
              '_unusedField',
              '_unusedMethod',
              '_unusedGetter',
              '_unusedSetter',
              '_unusedExtensionGetter',
              '_unusedExtensionMethod',
            ]),
          );
          expect(names, isNot(contains('publicUnusedMethod')));
          expect(names, isNot(contains('_usedField')));
          expect(names, isNot(contains('_usedMethod')));
          expect(names, isNot(contains('_usedGetter')));
          expect(names, isNot(contains('_usedSetter')));
          expect(names, isNot(contains('_setterBackingField')));
          expect(names, isNot(contains('_usedExtensionGetter')));
          expect(names, isNot(contains('_usedExtensionMethod')));
        });

        test('reports only unused private named constructors', () async {
          final result = await analyzer.runCliAnalysis(
            privateMembersFolders,
            rootDirectory,
            _createConfig(analyzePrivateMembers: true),
          );

          final report = result.firstWhere(
            (report) => report.path.endsWith('private_constructors.dart'),
          );

          final names = report.issues.map((issue) => issue.declarationName);

          expect(
            names,
            unorderedEquals([
              'InstanceCreation._unusedNamed',
              'FactoryRedirect._unusedInFactoryClass',
              'GenerativeRedirect._unusedInRedirectClass',
              'SuperBase._unusedInBase',
              'TearOff._unusedInTearOffClass',
              'SelectorEnum._unusedEnumCtor',
              'Meters._unusedSecondary',
            ]),
          );

          // Used via instance creation, factory redirect, `this.` redirect,
          // `super.` invocation, tear-off and enum constant selector.
          expect(names, isNot(contains('InstanceCreation._used')));
          expect(names, isNot(contains('FactoryRedirect._impl')));
          expect(names, isNot(contains('GenerativeRedirect._delegate')));
          expect(names, isNot(contains('SuperBase._base')));
          expect(names, isNot(contains('TearOff._tearOff')));
          expect(names, isNot(contains('SelectorEnum._select')));
          // Sole private constructor (prevent-instantiation pattern).
          expect(names, isNot(contains('StaticOnly._')));
          // Public constructors are out of scope.
          expect(names, isNot(contains('PublicCtors.publicUnused')));
          // Suppressed with an ignore comment.
          expect(names, isNot(contains('SuppressedCtor._suppressed')));

          expect(
            report.issues
                .map((issue) => issue.declarationType)
                .toSet()
                .single,
            'constructor',
          );
        });

        test('reports unused private members of every type kind', () async {
          final result = await analyzer.runCliAnalysis(
            privateMembersFolders,
            rootDirectory,
            _createConfig(analyzePrivateMembers: true),
          );

          final report = result.firstWhere(
            (report) => report.path.endsWith('private_type_kinds.dart'),
          );

          final names = report.issues.map((issue) => issue.declarationName);

          expect(
            names,
            unorderedEquals([
              '_unusedInMixin',
              '_unusedStaticInEnum',
              '_unusedEnumGetter',
              '_unusedEnumMethod',
              '_unusedInExtensionType',
              '_unusedStaticConst',
              '_unusedStaticMethod',
              '_unusedStaticGetter',
              '_reportedUnusedMethod',
            ]),
          );

          // Used from the mixing in class, from another member of the same
          // enum, extension type or class, and suppressed with a member level
          // ignore comment.
          expect(names, isNot(contains('_usedInMixin')));
          expect(names, isNot(contains('_usedStaticInEnum')));
          expect(names, isNot(contains('_usedEnumGetter')));
          expect(names, isNot(contains('_usedInExtensionType')));
          expect(names, isNot(contains('_usedStaticConst')));
          expect(names, isNot(contains('_usedStaticMethod')));
          expect(names, isNot(contains('_suppressedUnusedMethod')));
        });

        test(
          'known limitation: a dead private override sharing a name with a '
          'live ancestor member is not reported (see private_override.dart)',
          () async {
            final result = await analyzer.runCliAnalysis(
              privateMembersFolders,
              rootDirectory,
              _createConfig(analyzePrivateMembers: true),
            );

            final report = result.firstWhereOrNull(
              (report) => report.path.endsWith('private_override.dart'),
            );

            // Derived2 is instantiated (so the class itself isn't flagged),
            // but Derived2._template2 is never called on it and is
            // genuinely dead. It is NOT flagged: the name+library fallback
            // in _isEqualElements treats it as used because Base2._template2
            // (same name, same library) is used elsewhere. Tracked as a
            // known limitation, not a regression to fix here. A file with no
            // issues at all is omitted from the result set entirely.
            expect(report, null);
          },
        );
      });

      group('analyze-public-members', () {
        final publicMembersFolders = [
          normalize(File('test/resources/unused_code_public_members_analyzer')
              .absolute
              .path),
        ];

        late Iterable<UnusedCodeFileReport> result;

        setUpAll(() async {
          result = await analyzer.runCliAnalysis(
            publicMembersFolders,
            rootDirectory,
            _createConfig(analyzePublicMembers: true),
          );
        });

        Iterable<String> namesFor(String fileName) => result
            .firstWhere((report) => report.path.endsWith(fileName))
            .issues
            .map((issue) => issue.declarationName);

        test('is disabled by default', () async {
          final defaultResult = await analyzer.runCliAnalysis(
            publicMembersFolders,
            rootDirectory,
            _createConfig(),
          );

          expect(defaultResult, isEmpty);
        });

        test('reports unused public members of a class', () {
          final names = namesFor('public_members.dart');

          expect(
            names,
            unorderedEquals([
              'unusedField',
              'unusedGetter',
              'unusedSetter',
              'unusedMethod',
              'unusedStatic',
              'Api.unusedNamed',
            ]),
          );

          // Private members belong to the other flag.
          expect(names, isNot(contains('_privateUnusedMethod')));
          // The unnamed constructor is never a candidate.
          expect(names, isNot(contains('Api')));
        });

        test('does not report members that override an inherited member', () {
          final names = namesFor('overrides.dart');

          expect(names, unorderedEquals(['unusedInBase', 'derivedUnused']));

          // Annotated override, and an override without the annotation: both
          // are reached by dispatch on `Base`.
          expect(names, isNot(contains('template')));
          expect(names, isNot(contains('hook')));
        });

        test(
          'does not report an override whose supertype is in another library',
          () {
            expect(
              namesFor('cross_library_override.dart'),
              ['unusedInSubclass'],
            );
            expect(namesFor('cross_library_base.dart'), ['unusedInBase']);
          },
        );

        test('does not report members reached without a reference', () {
          final names = namesFor('enums_and_dynamic.dart');

          expect(names, unorderedEquals(['unused', 'notInvoked']));

          // Reached through `IteratedStatus.values`.
          expect(names, isNot(contains('first')));
          expect(names, isNot(contains('second')));
          // Reached through a call on a `dynamic` target, and through reads on
          // a `dynamic` target as a prefixed identifier and property access.
          expect(names, isNot(contains('dynamicallyInvoked')));
          expect(names, isNot(contains('dynamicallyRead')));
          expect(names, isNot(contains('alsoDynamicallyRead')));
        });

        test('reports unused public members of every type kind', () {
          final names = namesFor('public_type_kinds.dart');

          expect(
            names,
            unorderedEquals([
              'unusedInMixin',
              'second',
              'unusedEnumMethod',
              'unusedInExtensionType',
            ]),
          );

          // Used from the mixing in class, from another member of the same
          // enum or extension type, suppressed with an ignore comment on the
          // constant, and redeclaring a member of the implemented type.
          expect(names, isNot(contains('usedInMixin')));
          expect(names, isNot(contains('first')));
          expect(names, isNot(contains('suppressedConstant')));
          expect(names, isNot(contains('usedEnumMethod')));
          expect(names, isNot(contains('usedInExtensionType')));
          expect(names, isNot(contains('abs')));
        });

        test('does not report members annotated as reachable', () {
          final names = namesFor('annotated_members.dart');

          expect(names, unorderedEquals(['plainUnused', 'notAnEntryPoint']));
        });

        // Characterization test, green on arrival: it pins the SDK semantics
        // that a type level `vm:entry-point` covers allocation only, so that
        // the deliberate asymmetry with `@JSExport` (which does cover the whole
        // class) is not "fixed" into a false negative later.
        test(
          'characterization: a type level vm:entry-point pragma does not '
          'protect its members',
          () {
            final names = namesFor('annotated_members.dart');

            // No pragma of its own, so still dead code despite the class
            // carrying one.
            expect(names, contains('notAnEntryPoint'));
            // Carries its own pragma, so it is retained.
            expect(names, isNot(contains('calledFromNative')));
          },
        );

        // Characterization test for the one skip reason that is a judgement
        // call rather than a reachability fact: a `@JS` binding's callers are
        // Dart-side and visible here, so it is reportable in principle and is
        // skipped only to avoid flagging the unused part of an interop surface.
        test('does not report members bound to JavaScript with @JS', () {
          final names = namesFor('js_binding_members.dart');

          // `clear` is the control: equally unreferenced, but unannotated.
          expect(names, ['clear']);
          expect(names, isNot(contains('writeLine')));
        });

        test('does not report members exported to JavaScript', () {
          final names = namesFor('js_exported_members.dart');

          expect(
            names,
            unorderedEquals([
              'unusedStatic',
              'unusedStaticField',
              'unusedMember',
              'prefixUnusedMember',
              'alsoUnused',
            ]),
          );

          // Wrapped by `createJSInteropWrapper` because the class carries
          // `@JSExport`, so JavaScript reaches these with no Dart reference.
          expect(names, isNot(contains('handleEvent')));
          expect(names, isNot(contains('currentValue')));
          expect(names, isNot(contains('exportedField')));
          // Exported by its own member level annotation instead.
          expect(names, isNot(contains('exportedMember')));
          // Annotated through an import prefix (`@js.JSExport()`).
          expect(names, isNot(contains('prefixExportedMember')));
          // A class level `@JSExport` wraps only instance members, so statics
          // in an exported class are still reported. Both kinds are checked:
          // methods and fields carry staticness on different AST nodes.
          expect(names, contains('unusedStatic'));
          expect(names, contains('unusedStaticField'));
        });

        test('records unary operator and increment usages', () {
          final names = namesFor('unary_operators.dart');

          expect(names, ['~']);

          // `-counter` reaches `unary-` and `counter++` reaches `+`.
          expect(names, isNot(contains('unary-')));
          expect(names, isNot(contains('+')));
        });

        test('records operator, call and extension member usages', () {
          final names = namesFor('operators_and_extensions.dart');

          expect(names, unorderedEquals(['*', 'tripled']));

          // `+` and `[]` are used through expressions, `call` through an
          // implicit invocation, and `==`/`hashCode` are inherited from Object.
          expect(names, isNot(contains('+')));
          expect(names, isNot(contains('[]')));
          expect(names, isNot(contains('call')));
          expect(names, isNot(contains('==')));
          expect(names, isNot(contains('hashCode')));
          expect(names, isNot(contains('doubled')));
        });
      });

      group('member usages do not mask top level declarations', () {
        final maskedFolders = [
          normalize(File('test/resources/unused_code_masked_top_level_analyzer')
              .absolute
              .path),
        ];

        for (final analyzePrivateMembers in [false, true]) {
          test(
            'reports dead top level declarations sharing a name with a used '
            'member (analyze-private-members: $analyzePrivateMembers)',
            () async {
              final result = await analyzer.runCliAnalysis(
                maskedFolders,
                rootDirectory,
                _createConfig(analyzePrivateMembers: analyzePrivateMembers),
              );

              final report = result.firstWhere(
                (report) => report.path.endsWith('masked_top_level.dart'),
              );

              expect(
                report.issues.map((issue) => issue.declarationName),
                unorderedEquals(['reset', 'counter']),
              );
            },
          );
        }
      });
    },
    testOn: 'posix',
  );
}

UnusedCodeConfig _createConfig({
  Iterable<String> analyzerExcludePatterns = const [],
  bool analyzePrivateMembers = false,
  bool analyzePublicMembers = false,
}) =>
    UnusedCodeConfig(
      excludePatterns: const [],
      analyzerExcludePatterns: analyzerExcludePatterns,
      isMonorepo: false,
      shouldPrintConfig: false,
      analyzePrivateMembers: analyzePrivateMembers,
      analyzePublicMembers: analyzePublicMembers,
    );
