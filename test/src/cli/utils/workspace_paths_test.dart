import 'dart:io';

import 'package:dart_code_linter/src/cli/exceptions/invalid_argument_exception.dart';
import 'package:dart_code_linter/src/cli/utils/workspace_paths.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('discoverWorkspaceLibraryPaths', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('dcl_workspace_paths_');
    });

    tearDown(() {
      root.deleteSync(recursive: true);
    });

    test(
      'discovers package lib directories from nested and glob entries',
      () {
        _writePubspec(root, '''
name: workspace
workspace:
  - packages/*
  - apps/mobile
''');
        _createPackage(root, 'packages/core', includeLib: true);
        _createPackage(root, 'packages/tool', includeLib: false);
        _createPackage(
          root,
          'apps/mobile',
          includeLib: true,
          workspace: ['packages/nested'],
        );
        _createPackage(root, 'apps/mobile/packages/nested', includeLib: true);
        Directory(p.join(root.path, 'lib')).createSync();

        final result = discoverWorkspaceLibraryPaths(root.path);

        expect(
          result,
          equals([
            p.join('apps', 'mobile', 'lib'),
            p.join('apps', 'mobile', 'packages', 'nested', 'lib'),
            'lib',
            p.join('packages', 'core', 'lib'),
          ]),
        );
      },
      testOn: 'posix',
    );

    test('rejects a root manifest without a workspace list', () {
      _writePubspec(root, 'name: standalone\n');

      expect(
        () => discoverWorkspaceLibraryPaths(root.path),
        throwsA(isA<InvalidArgumentException>()),
      );
    });

    test('includes a root package lib directory when the member list is empty',
        () {
      _writePubspec(
        root,
        '''
name: workspace
workspace: []
''',
      );
      Directory(p.join(root.path, 'lib')).createSync();

      expect(discoverWorkspaceLibraryPaths(root.path), equals(['lib']));
    }, testOn: 'posix');

    test('rejects an empty malformed workspace value', () {
      _writePubspec(
        root,
        '''
name: workspace
workspace:
''',
      );

      expect(
        () => discoverWorkspaceLibraryPaths(root.path),
        throwsA(isA<InvalidArgumentException>()),
      );
    });

    test('rejects workspace entries that match no package', () {
      _writePubspec(root, '''
name: workspace
workspace:
  - packages/*
''');
      Directory(
        p.join(root.path, 'packages', 'not-a-package'),
      ).createSync(recursive: true);

      expect(
        () => discoverWorkspaceLibraryPaths(root.path),
        throwsA(isA<InvalidArgumentException>()),
      );
    }, testOn: 'posix');

    test('rejects workspace entries that leave their declaring root', () {
      _writePubspec(
        root,
        '''
name: workspace
workspace:
  - ../outside
''',
      );

      expect(
        () => discoverWorkspaceLibraryPaths(root.path),
        throwsA(isA<InvalidArgumentException>()),
      );
    }, testOn: 'posix');
  });
}

void _writePubspec(Directory directory, String content) {
  File(p.join(directory.path, 'pubspec.yaml')).writeAsStringSync(content);
}

void _createPackage(
  Directory root,
  String path, {
  required bool includeLib,
  List<String> workspace = const [],
}) {
  final package = Directory(p.join(root.path, path))
    ..createSync(recursive: true);
  final members = workspace.map((entry) => '  - $entry\n').join();
  _writePubspec(
    package,
    'name: ${p.basename(path)}\n'
    '${workspace.isEmpty ? '' : 'workspace:\n$members'}',
  );
  if (includeLib) {
    Directory(p.join(package.path, 'lib')).createSync();
  }
}
