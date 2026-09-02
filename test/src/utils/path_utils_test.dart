import 'package:dart_code_linter/src/utils/path_utils.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('uriToPath returns', () {
    test('null for passed null', () {
      expect(uriToPath(null), isNull);
    });

    test(
      'normalize path for passed uri',
      () {
        expect(
          uriToPath(Uri.file('/home/develop/source.txt')),
          equals('/home/develop/source.txt'),
        );
      },
      testOn: 'posix',
    );

    test(
      'normalize path for passed uri',
      () {
        expect(
          uriToPath(Uri.file(r'C:\develop\source.txt')),
          equals(r'C:\develop\source.txt'),
        );
      },
      testOn: 'windows',
    );

    test('null for passed null', () {
      expect(
        uriToPath(
          Uri.parse('package:dart_code_linter/src/utils/path_utils.dart'),
        ),
        equals(p.absolute('dart_code_linter/src/utils/path_utils.dart')),
      );
    });
  });

  group('isOnPackageImportSurface', () {
    Uri pkg(String path) => Uri.parse('package:some_package/$path');

    test('is true for a library directly under lib', () {
      expect(isOnPackageImportSurface(pkg('api.dart')), isTrue);
    });

    test('is true for a library in a folder under lib', () {
      expect(isOnPackageImportSurface(pkg('models/user.dart')), isTrue);
    });

    test('is false for a library under lib/src', () {
      expect(isOnPackageImportSurface(pkg('src/internal.dart')), isFalse);
      expect(isOnPackageImportSurface(pkg('src/deep/internal.dart')), isFalse);
    });

    test('is not fooled by a name that merely starts with src', () {
      // Only the folder is off the surface: `lib/src.dart` and `lib/srcs/`
      // are both importable.
      expect(isOnPackageImportSurface(pkg('src.dart')), isTrue);
      expect(isOnPackageImportSurface(pkg('srcs/api.dart')), isTrue);
    });

    test('is false for a library that resolves to no package', () {
      // A script, a loose folder or a package that was never resolved: not
      // importable by anyone, so not on any surface.
      expect(
        isOnPackageImportSurface(Uri.file('/home/develop/pkg/lib/api.dart')),
        isFalse,
      );
      expect(isOnPackageImportSurface(Uri.parse('dart:core')), isFalse);
    });

    test('is false for a bare package URI naming no library', () {
      expect(isOnPackageImportSurface(Uri.parse('package:some_package')),
          isFalse);
    });
  });
}
