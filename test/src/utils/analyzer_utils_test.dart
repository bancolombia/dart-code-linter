import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/context_root.dart';
import 'package:analyzer/file_system/file_system.dart' hide File;
import 'package:dart_code_linter/src/utils/analyzer_utils.dart';
import 'package:dart_code_linter/src/utils/exclude_utils.dart';
import 'package:glob/glob.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

class AnalysisContextMock extends Mock implements AnalysisContext {}

class ContextRootMock extends Mock implements ContextRoot {}

class FolderMock extends Mock implements Folder {}

void main() {
  group('getFilePaths', () {
    const folderPath = 'file_paths_folder';
    const rootFolder = 'test/resources';

    final folder = FolderMock();
    final contextRoot = ContextRootMock();
    final context = AnalysisContextMock();

    setUp(() {
      when(() => folder.path).thenReturn('test/resources');
      when(() => contextRoot.root).thenReturn(folder);
      when(() => context.contextRoot).thenReturn(contextRoot);
    });

    test(
      'should return paths to the files',
      () {
        const excludes = <Glob>[];

        final filePaths =
            getFilePaths([folderPath], context, rootFolder, excludes).toList()
              ..sort();

        expect(filePaths, hasLength(3));

        const startPath = '$rootFolder/$folderPath';

        final firstPath = filePaths.first;
        expect(firstPath, '$startPath/first_file.dart');

        final secondPath = filePaths.elementAt(1);
        expect(secondPath, '$startPath/inner_folder/first_inner_file.dart');

        final thirdPath = filePaths.last;
        expect(thirdPath, '$startPath/second_file.dart');
      },
      testOn: 'posix',
    );

    test(
      'should return paths to the files without excluded',
      () {
        final excludes = [Glob('**/second_file.dart')];

        final filePaths =
            getFilePaths([folderPath], context, rootFolder, excludes).toList()
              ..sort();

        expect(filePaths, hasLength(2));

        const startPath = '$rootFolder/$folderPath';

        final firstPath = filePaths.first;
        expect(firstPath, '$startPath/first_file.dart');

        final secondPath = filePaths.last;
        expect(secondPath, '$startPath/inner_folder/first_inner_file.dart');
      },
      testOn: 'posix',
    );

    test(
      'should normalize file path if root path has relative parts',
      () {
        const rootFolder = 'test/resources/./';
        final excludes = [Glob('**/first*file.dart')];

        final filePaths =
            getFilePaths([folderPath], context, rootFolder, excludes).toList()
              ..sort();

        expect(filePaths, hasLength(1));

        final firstPath = filePaths.first;
        expect(firstPath, 'test/resources/file_paths_folder/second_file.dart');
        expect(firstPath, isNot(contains(rootFolder)));
      },
      testOn: 'posix',
    );
  });

  group(
    'getFilePaths with an absolute root folder outside the current directory',
    () {
      late Directory root;

      final rootFolder = FolderMock();
      final contextRoot = ContextRootMock();
      final context = AnalysisContextMock();

      setUp(() {
        root = Directory.systemTemp.createTempSync('dcl_exclude_');
        root = Directory(root.resolveSymbolicLinksSync());
        for (final name in ['x.g.dart', 'x.freezed.dart', 'y.dart']) {
          File(join(root.path, 'lib', name)).createSync(recursive: true);
        }

        when(() => rootFolder.path).thenReturn(root.path);
        when(() => contextRoot.root).thenReturn(rootFolder);
        when(() => context.contextRoot).thenReturn(contextRoot);
      });

      tearDown(() => root.deleteSync(recursive: true));

      Iterable<String> selectedNames(String pattern) => getFilePaths(
            ['lib'],
            context,
            root.path,
            createAbsolutePatterns([pattern], root.path),
          ).map(basename);

      test('excludes generated files with the default pattern', () {
        expect(
          selectedNames('{/**.g.dart,/**.freezed.dart}'),
          unorderedEquals(['y.dart']),
        );
      });

      test('excludes files matched by a pattern relative to the root', () {
        expect(
          selectedNames('lib/*.g.dart'),
          unorderedEquals(['x.freezed.dart', 'y.dart']),
        );
      });

      test('excludes files matched by a recursive pattern', () {
        expect(
          selectedNames('**.g.dart'),
          unorderedEquals(['x.freezed.dart', 'y.dart']),
        );
      });
    },
    testOn: 'posix',
  );
}
