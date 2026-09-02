import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/models/unused_code_file_report.dart';
import 'package:dart_code_linter/src/analyzers/unused_code_analyzer/models/unused_code_issue.dart';
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

        test(
          'reports a private-named enum constant, since privacy routes it '
          'here rather than into analyzePublicMembers',
          () async {
            final result = await analyzer.runCliAnalysis(
              privateMembersFolders,
              rootDirectory,
              _createConfig(analyzePrivateMembers: true),
            );

            final report = result.firstWhere(
              (report) => report.path.endsWith('private_enum_constant.dart'),
            );

            final names = report.issues.map((issue) => issue.declarationName);

            expect(names, ['_unusedConstant']);
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

        test(
          'reports a dead member whose name a statically resolved assignment '
          'also writes, while keeping one a dynamic write could reach',
          () {
            // Nothing is dead in the file holding the writes themselves.
            expect(
              result.where((report) =>
                  basename(report.path) == 'setter_write_resolution.dart'),
              isEmpty,
            );

            expect(namesFor('setter_write_name_twin.dart'), ['shared']);
          },
        );

        test(
          'reports a dead member whose name a statically resolved prefix or '
          'postfix operator also reaches, while keeping one a dynamic '
          'negation could reach',
          () {
            // Nothing is dead in the file holding the operators themselves.
            expect(
              result.where((report) =>
                  basename(report.path) == 'non_writing_operators.dart'),
              isEmpty,
            );

            // `!x`, `x!`, `-x` and `~x` write nothing, so the null write
            // element of the expression enclosing them must not be read as a
            // dynamic target the way an unresolved assignment is.
            expect(
              namesFor('non_writing_operators_name_twin.dart'),
              unorderedEquals([
                'negated',
                'asserted',
                'negatedNumber',
                'complemented',
              ]),
            );
          },
        );

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

        test('records the combiner of a compound assignment', () {
          final names = namesFor('compound_assignment.dart');

          // `-` is the control: declared and never reached.
          expect(names, ['-']);

          // `accumulator += 2` reaches `operator +` through the combiner.
          expect(names, isNot(contains('+')));
        });

        test(
          'still reports unused members of a file that is re-exported by a '
          "barrel, even though the file's own top level declarations are "
          'exempt',
          () {
            final names = namesFor('reexported_members.dart');

            expect(names, ['deadMethod']);

            // Exempt because the file is exported: reachable through the
            // package's public API, which whole-program usage tracking
            // cannot see into.
            expect(names, isNot(contains('useReexportedApi')));
            expect(names, isNot(contains('ReexportedApi')));
          },
        );

        test(
          'reports a method that only shares its name with an unrelated '
          "record field access, since the field has no element of its own "
          'to be mistaken for a dynamic target',
          () {
            final names = namesFor('record_field_access.dart');

            expect(names, contains('name'));
          },
        );

        test(
          'reports a dead instance method that only shares its name with an '
          'unrelated static member on a supertype, since statics are never '
          'inherited',
          () {
            final names = namesFor('static_name_collision.dart');

            expect(names, contains('log'));
          },
        );

        test(
          'reports a dead named constructor that only shares its name with '
          'an unrelated instance method on a supertype, since constructors '
          'and instance members are separate namespaces',
          () {
            final names = namesFor('constructor_supertype_collision.dart');

            expect(names, contains('Derived.build'));
          },
        );

        test(
          'does not report a member annotated with vm:entry-point through a '
          'prefixed import',
          () {
            final names = namesFor('prefixed_entry_point_pragma.dart');

            expect(names, ['deadControl']);
            expect(names, isNot(contains('calledFromNative')));
          },
        );

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
          // `wrapper += 1` reaches the extension's `operator +` through the
          // compound assignment's combiner, which also marks the extension
          // declaration itself used.
          expect(names, isNot(contains('WrapperMath')));
        });

        test(
          'reports a dead operator []= that only shares its name with one '
          'reached through a plain, statically typed index write',
          () {
            final names = namesFor('index_operator_write.dart');

            expect(names, ['[]=']);
          },
        );

        test(
          'does not report a private-named enum constant, since privacy '
          'routes it into analyzePrivateMembers instead',
          () {
            final report = result.firstWhereOrNull((report) =>
                report.path.endsWith('private_named_enum_constant.dart'));

            // A file with no issues at all is omitted from the result set
            // entirely.
            expect(report, null);
          },
        );

        test(
          'does not report any member of a type whose own supertype fails '
          'to resolve, since allSupertypes then comes back incomplete and '
          'an unannotated override could be falsely flagged as unused',
          () {
            final report = result.firstWhereOrNull(
                (report) => report.path.endsWith('unresolved_supertype.dart'));

            // A file with no issues at all is omitted from the result set
            // entirely. `unrelated`, which shares no name with anything, is
            // exempted too: once a type's hierarchy fails to resolve, every
            // member of it is treated as possibly declared by the missing
            // supertype, trading a missed detection for no false positive.
            expect(report, null);
          },
        );
      });

      group('suggest-private-members', () {
        final couldBePrivateFolders = [
          normalize(
            File('test/resources/unused_code_could_be_private_analyzer')
                .absolute
                .path,
          ),
        ];

        late Iterable<UnusedCodeFileReport> result;

        setUpAll(() async {
          result = await analyzer.runCliAnalysis(
            couldBePrivateFolders,
            rootDirectory,
            _createConfig(suggestPrivateMembers: true),
          );
        });

        Iterable<String> suggestionsFor(String fileName) =>
            _namesOfKind(result, fileName, UnusedCodeIssueKind.couldBePrivate);

        Iterable<String> unusedFor(String fileName) =>
            _namesOfKind(result, fileName, UnusedCodeIssueKind.unused);

        test('is disabled by default', () async {
          final defaultResult = await analyzer.runCliAnalysis(
            couldBePrivateFolders,
            rootDirectory,
            _createConfig(),
          );

          expect(
            defaultResult
                .expand((report) => report.issues)
                .map((issue) => issue.kind),
            isNot(contains(UnusedCodeIssueKind.couldBePrivate)),
          );
        });

        test('suggests declarations referenced only from their own library',
            () {
          expect(
            suggestionsFor('could_be_private.dart'),
            unorderedEquals([
              'localField',
              'localGetter',
              'localSetter',
              'localMethod',
              'localStatic',
              'Api.localNamed',
              'usesThePrivateOne',
              // A top level declaration follows the same rule as a member.
              'ApiCaller',
              'run',
            ]),
          );
        });

        test('does not suggest declarations another library references', () {
          final names = suggestionsFor('could_be_private.dart');

          expect(names, isNot(contains('foreignField')));
          expect(names, isNot(contains('foreignGetter')));
          expect(names, isNot(contains('foreignSetter')));
          expect(names, isNot(contains('foreignMethod')));
          expect(names, isNot(contains('foreignStatic')));
          expect(names, isNot(contains('Api.foreignNamed')));
          // The class itself is named by the importing library.
          expect(names, isNot(contains('Api')));
          // Already private, and the unnamed constructor is never a candidate.
          expect(names, isNot(contains('_privateMethod')));
          expect(names, isNot(contains('Api')));
        });

        test('suggests a top level function used only by its own library', () {
          expect(
            suggestionsFor('could_be_private_consumer.dart'),
            ['useForeignMembers'],
          );
        });

        test('never reports a declaration as both unused and privatizable', () {
          for (final report in result) {
            final suggested = _namesOfKind(
              [report],
              basename(report.path),
              UnusedCodeIssueKind.couldBePrivate,
            ).toSet();
            final unused = _namesOfKind(
              [report],
              basename(report.path),
              UnusedCodeIssueKind.unused,
            ).toSet();

            expect(suggested.intersection(unused), isEmpty);
          }
        });

        test('does not suggest a declaration nothing references at all', () {
          // Dead code is the other flags' verdict: with only this flag on, an
          // unreferenced member is silently skipped rather than mislabelled.
          final names = suggestionsFor('precedence.dart');

          expect(names, isNot(contains('neverUsed')));
          expect(
            names,
            unorderedEquals(['Precedence', 'usedLocally', 'caller']),
          );
          expect(unusedFor('precedence.dart'), isEmpty);
        });

        test('does not suggest a member of a type reported as dead code', () {
          final report = result.firstWhere(
            (report) => report.path.endsWith('unused_enclosing_type.dart'),
          );

          expect(
            unusedFor('unused_enclosing_type.dart'),
            contains('NeverReferenced'),
          );

          // Both classes here declare a `sharedName`, which is what makes the
          // dead one look used to the loose same library name fallback, so
          // the suggestions have to be counted rather than looked up by name:
          // only the one on the referenced class is reported.
          final suggestedLines = report.issues
              .where((issue) =>
                  issue.kind == UnusedCodeIssueKind.couldBePrivate &&
                  issue.declarationName == 'sharedName')
              .map((issue) => issue.location.line);

          expect(suggestedLines, [14]);
        });

        test('reports a dead member as unused rather than as a suggestion',
            () async {
          final withPublicMembers = await analyzer.runCliAnalysis(
            couldBePrivateFolders,
            rootDirectory,
            _createConfig(
              analyzePublicMembers: true,
              suggestPrivateMembers: true,
            ),
          );

          expect(
            _namesOfKind(
              withPublicMembers,
              'precedence.dart',
              UnusedCodeIssueKind.unused,
            ),
            ['neverUsed'],
          );
          expect(
            _namesOfKind(
              withPublicMembers,
              'precedence.dart',
              UnusedCodeIssueKind.couldBePrivate,
            ),
            unorderedEquals(['Precedence', 'usedLocally', 'caller']),
          );
        });

        test('counts a reference from a part of the same library as local', () {
          expect(
            suggestionsFor('parts_owner.dart'),
            unorderedEquals(['PartOwner', 'usedFromThePart']),
          );
        });

        test(
          'suggests a member a foreign subclass never redeclares',
          () {
            final names = suggestionsFor('external_subclass.dart');

            // Inherited untouched by `Derived`: a private name is still
            // inherited across libraries, so the rename changes nothing there.
            expect(names, contains('untouchedBySubclass'));
            // Overridden in `Derived`. The rename compiles and silently stops
            // dispatching to the override, which is why this is blocked.
            expect(names, isNot(contains('redeclaredBySubclass')));
            // Called from the other library.
            expect(names, isNot(contains('callBoth')));
            expect(names, isNot(contains('Base')));
          },
        );

        test(
          'does not suggest the interface of a foreign implementer, even for a '
          'member the implementer inherits from a third class',
          () {
            final names = suggestionsFor('external_implementer.dart');

            expect(names, isNot(contains('suppliedByASuperclass')));
            expect(names, isNot(contains('suppliedByTheImplementer')));
            expect(names, isNot(contains('useEverything')));
            // A static is never part of the interface an implementer supplies.
            expect(names, contains('neverInherited'));
          },
        );

        test(
          'blocks a member redeclared through a supertype edge that is not a '
          'class declaration',
          () {
            final names = suggestionsFor('external_subtype_kinds.dart');

            // A mixin's `on` constraint, a mixin application written as a
            // class type alias, an enum's `implements` and an extension
            // type's `implements` each carry the supertype edge on a
            // declaration kind of its own, and none of them is a class.
            expect(names, isNot(contains('mixedRedeclared')));
            expect(names, isNot(contains('aliasRedeclared')));
            expect(names, isNot(contains('enumRedeclared')));
            expect(names, isNot(contains('wrappedRedeclared')));

            // The controls: the other library declares no member of these
            // names, and a private member is inherited across libraries
            // untouched, so the rename is safe.
            expect(names, contains('mixedUntouched'));
            expect(names, contains('aliasUntouched'));
            expect(names, contains('wrappedUntouched'));
            // A static is never inherited, so no implementer redeclares one.
            expect(names, contains('enumNeverInherited'));

            // Every host type is named by the other library.
            expect(names, isNot(contains('MixinHost')));
            expect(names, isNot(contains('AliasHost')));
            expect(names, isNot(contains('EnumInterface')));
            expect(names, isNot(contains('ExtensionTypeHost')));
          },
        );

        test('is unaffected by a subtype in the same library', () {
          expect(
            suggestionsFor('same_library_subtype.dart'),
            unorderedEquals([
              'LocalBase',
              'LocalDerived',
              'overriddenLocally',
              'callIt',
            ]),
          );
        });

        test('does not suggest members that are reached without a reference',
            () {
          final names = suggestionsFor('annotated_members.dart');

          expect(names, isNot(contains('protectedMember')));
          expect(names, isNot(contains('testOnlyMember')));
          expect(names, isNot(contains('overridableMember')));
          expect(names, isNot(contains('mustBeOverriddenMember')));
          expect(names, isNot(contains('nativeEntryPoint')));
          expect(names, isNot(contains('toJson')));
          expect(names, isNot(contains('toString')));
          // The same annotations on a top level declaration.
          expect(names, isNot(contains('testOnlyTopLevel')));
          expect(names, isNot(contains('nativeTopLevel')));

          expect(names, contains('plainMember'));
        });

        test('does not suggest a member whose name is called dynamically', () {
          final names = suggestionsFor('dynamic_name_collision.dart');

          expect(names, isNot(contains('shared')));
          expect(names, contains('notShared'));
          expect(names, contains('callBoth'));
        });

        test('never suggests an operator or an enum constant', () {
          final names = suggestionsFor('enums_and_operators.dart');

          // `operator +` has no private spelling at all.
          expect(names, isNot(contains('+')));
          // Renaming a constant changes `name` and `toString`.
          expect(names, isNot(contains('spring')));
          expect(names, isNot(contains('summer')));

          expect(names, contains('combine'));
        });

        test('does not suggest a field bound by a named formal', () {
          final names = suggestionsFor('named_initializing_formals.dart');

          expect(names, isNot(contains('viaNamedFormal')));
          expect(names, contains('viaPositionalFormal'));
        });

        test('counts a foreign super constructor call as a reference', () {
          final names = suggestionsFor('super_constructor.dart');

          expect(names, isNot(contains('SuperBase.namedForSuper')));
          expect(names, contains('SuperBase.onlyLocal'));
        });

        test('counts a foreign write to a field as a reference', () {
          final names = suggestionsFor('field_write_only.dart');

          expect(names, isNot(contains('writtenElsewhere')));
          expect(names, contains('readLocally'));
        });

        test('suggests extension members', () {
          expect(
            suggestionsFor('extension_members.dart'),
            unorderedEquals(['LocalExtension', 'doubled', 'useTheExtension']),
          );
        });

        test('counts a prefixed type reference from another library', () {
          final names = suggestionsFor('prefixed_usage.dart');

          expect(names, isNot(contains('PrefixedType')));
          // Only the class is named over there, so its members are untouched.
          expect(names, contains('member'));
          expect(names, contains('makeLocally'));
        });

        test('answers to the unused-code ignore comment', () {
          final names = suggestionsFor('suppressed.dart');

          expect(names, isNot(contains('suppressedMember')));
          expect(names, contains('reportedMember'));

          // A file level ignore covers everything in the file, members and
          // top level declarations alike.
          expect(suggestionsFor('suppressed_file.dart'), isEmpty);
        });

        test('does not suggest a member of an already private type', () {
          final names = suggestionsFor('private_enclosing_types.dart');

          expect(
            names,
            unorderedEquals([
              // An unnamed extension reads as private through
              // `Element.isPrivate`, but its members apply in every importing
              // library, so it stays a candidate.
              'unnamedExtensionMember',
              'PublicHost',
              'publicHostMember',
              'PublicMixesInPrivate',
            ]),
          );

          // Pointless: the enclosing type cannot be named from outside.
          expect(names, isNot(contains('hostMember')));
          expect(names, isNot(contains('enumMember')));
          expect(names, isNot(contains('extensionMember')));
          expect(names, isNot(contains('typeMember')));
          // Not merely pointless: `PublicMixesInPrivate` republishes this one.
          expect(names, isNot(contains('mixinMember')));
        });

        test('does not suggest a top level declaration that is exported', () {
          final names = suggestionsFor('export_surface_src.dart');

          // On the package's import surface through the barrel file.
          expect(names, isNot(contains('Exported')));
          // Its members are not, so they stay analyzed.
          expect(names, unorderedEquals(['memberUsedLocally', 'caller']));
        });
      });

      group('suggest-private-members on a package import surface', () {
        const fixtureRoot =
            'test/resources/unused_code_public_library_analyzer';
        final publicLibraryFolders = [
          normalize(File(fixtureRoot).absolute.path),
        ];

        setUpAll(() {
          // The fixture is only on an import surface if it resolves as a
          // package, which is what gives its libraries `package:` URIs. Its
          // package config is generated rather than committed: `.dart_tool`
          // is git ignored, and this keeps the test exercising the same code
          // path a real, resolved project does.
          File('$fixtureRoot/.dart_tool/package_config.json')
            ..createSync(recursive: true)
            ..writeAsStringSync('''
{
  "configVersion": 2,
  "packages": [
    {
      "name": "unused_code_public_library_fixture",
      "rootUri": "../",
      "packageUri": "lib/",
      "languageVersion": "3.5"
    }
  ]
}
''');
        });

        Future<Iterable<String>> suggestionsFor(
          String fileName, {
          bool isMonorepo = false,
        }) async =>
            _namesOfKind(
              await analyzer.runCliAnalysis(
                publicLibraryFolders,
                rootDirectory,
                _createConfig(
                  suggestPrivateMembers: true,
                  isMonorepo: isMonorepo,
                ),
              ),
              fileName,
              UnusedCodeIssueKind.couldBePrivate,
            );

        test(
          'does not suggest a top level declaration of a library any consumer '
          'can import',
          () async {
            // `lib/public_api.dart` is importable as
            // `package:.../public_api.dart` with nothing exporting it, so the
            // barrel exemption never sees it.
            final names = await suggestionsFor('public_api.dart');

            expect(names, isNot(contains('SurfaceType')));
            // The members of its types are not on that surface.
            expect(names, unorderedEquals(['usedOnlyHere', 'caller']));
          },
        );

        test('suggests everything under lib/src', () async {
          expect(
            await suggestionsFor('internal.dart'),
            unorderedEquals([
              'InternalType',
              'internalMember',
              'internalCaller',
            ]),
          );
        });

        test('--monorepo lifts the exemption', () async {
          // The flag says there are no unseen consumers to protect, exactly as
          // it does for the barrel exemption.
          expect(
            await suggestionsFor('public_api.dart', isMonorepo: true),
            contains('SurfaceType'),
          );
        });
      });

      group('dynamic operator usages', () {
        final dynamicOperatorsFolders = [
          normalize(
              File('test/resources/unused_code_dynamic_operators_analyzer')
                  .absolute
                  .path),
        ];

        // In its own folder because dynamically used names are matched
        // program-wide: the `~host` in the fixture would otherwise defuse the
        // `~` control member of unary_operators.dart.
        test('does not report operators reached through a dynamic target',
            () async {
          final result = await analyzer.runCliAnalysis(
            dynamicOperatorsFolders,
            rootDirectory,
            _createConfig(analyzePublicMembers: true),
          );

          final names = result
              .firstWhere(
                (report) => report.path.endsWith('dynamic_operators.dart'),
              )
              .issues
              .map((issue) => issue.declarationName);

          // `%` is the control: declared and never reached, so it is the one
          // member reported.
          expect(names, ['%']);

          // One operator per expression kind on a `dynamic` target: binary,
          // postfix increment, compound assignment combiner, unary minus,
          // tilde, index read, index write and implicit `call`. The reported
          // name of a unary minus is its display name `unary-`.
          expect(names, isNot(contains('~/')));
          expect(names, isNot(contains('+')));
          expect(names, isNot(contains('*')));
          expect(names, isNot(contains('unary-')));
          expect(names, isNot(contains('-')));
          expect(names, isNot(contains('~')));
          expect(names, isNot(contains('[]')));
          expect(names, isNot(contains('[]=')));
          expect(names, isNot(contains('call')));
        });
      });

      group(
        'operator usages are bridged across a conditional import',
        () {
          test(
            'does not report the unselected sibling of an operator that is '
            'used only through the conditionally imported declaration',
            () async {
              final folders = [
                normalize(File(
                  'test/resources/unused_code_conditional_operator_member_analyzer',
                ).absolute.path),
              ];

              final result = await analyzer.runCliAnalysis(
                folders,
                rootDirectory,
                _createConfig(analyzePublicMembers: true),
              );

              final report = result.firstWhereOrNull(
                (report) => report.path.endsWith('conditional_impl.dart'),
              );

              expect(
                report?.issues.map((issue) => issue.declarationName) ?? [],
                isNot(contains('+')),
              );
            },
          );
        },
      );

      group(
        'member usages do not mask top level declarations through a '
        'conditional import',
        () {
          test(
            'reports a dead top level declaration that shares a name and '
            'kind with a used member reached through a conditional import',
            () async {
              final folders = [
                normalize(File(
                  'test/resources/unused_code_conditional_masked_top_level_analyzer',
                ).absolute.path),
              ];

              final result = await analyzer.runCliAnalysis(
                folders,
                rootDirectory,
                _createConfig(),
              );

              final report = result.firstWhere(
                (report) => report.path.endsWith('conditional_impl.dart'),
              );

              expect(
                report.issues.map((issue) => issue.declarationName),
                contains('value'),
              );
            },
          );
        },
      );

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

Iterable<String> _namesOfKind(
  Iterable<UnusedCodeFileReport> result,
  String fileName,
  UnusedCodeIssueKind kind,
) =>
    result
        // Compared as a whole file name: several fixtures here share a
        // suffix, so `endsWith` would silently merge their reports.
        .where((report) => basename(report.path) == fileName)
        .expand((report) => report.issues)
        .where((issue) => issue.kind == kind)
        .map((issue) => issue.declarationName);

UnusedCodeConfig _createConfig({
  Iterable<String> analyzerExcludePatterns = const [],
  bool analyzePrivateMembers = false,
  bool analyzePublicMembers = false,
  bool suggestPrivateMembers = false,
  bool isMonorepo = false,
}) =>
    UnusedCodeConfig(
      excludePatterns: const [],
      analyzerExcludePatterns: analyzerExcludePatterns,
      isMonorepo: isMonorepo,
      shouldPrintConfig: false,
      analyzePrivateMembers: analyzePrivateMembers,
      analyzePublicMembers: analyzePublicMembers,
      suggestPrivateMembers: suggestPrivateMembers,
    );
