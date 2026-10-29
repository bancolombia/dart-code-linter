// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:file/file.dart' as file;
import 'package:file/local.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

import '../exceptions/invalid_argument_exception.dart';

/// Finds each Pub workspace package's `lib` directory under [rootFolder].
///
/// Workspace member paths are relative to the package that declares them.
/// Nested workspaces and Pub's directory glob entries are supported.
List<String> discoverWorkspaceLibraryPaths(String rootFolder) {
  final rootPath = normalize(absolute(rootFolder));
  final rootPubspecPath = join(rootPath, 'pubspec.yaml');
  final rootPubspec = File(rootPubspecPath);

  if (!rootPubspec.existsSync()) {
    throw InvalidArgumentException(
      'Cannot discover workspace packages: $rootPubspecPath does not exist.',
    );
  }

  final rootManifest = _readManifest(rootPubspecPath);
  if (!rootManifest.containsKey('workspace')) {
    throw InvalidArgumentException(
      'Cannot discover workspace packages: $rootPubspecPath has no workspace list.',
    );
  }

  final visitedPackages = <String>{};
  final libraryPaths = <String>{};

  void visitPackage(String packagePath, {required bool rootPackage}) {
    final normalizedPackagePath = normalize(absolute(packagePath));
    if (!visitedPackages.add(normalizedPackagePath)) {
      return;
    }

    final pubspecPath = join(normalizedPackagePath, 'pubspec.yaml');
    if (!File(pubspecPath).existsSync()) {
      throw InvalidArgumentException(
        'Workspace member has no pubspec.yaml: $pubspecPath.',
      );
    }

    final manifest = rootPackage ? rootManifest : _readManifest(pubspecPath);
    final libPath = join(normalizedPackagePath, 'lib');
    if (Directory(libPath).existsSync()) {
      libraryPaths.add(relative(libPath, from: rootPath));
    }

    if (!manifest.containsKey('workspace')) {
      return;
    }

    final members = manifest['workspace'];
    if (members is! List) {
      throw InvalidArgumentException(
        'Workspace entries in $pubspecPath must be a list.',
      );
    }

    for (final member in members) {
      if (member is! String || member.isEmpty || isAbsolute(member)) {
        throw InvalidArgumentException(
          'Workspace entries in $pubspecPath must be non-empty relative paths.',
        );
      }
      final resolvedMemberPath =
          normalize(absolute(join(normalizedPackagePath, member)));
      if (resolvedMemberPath != normalizedPackagePath &&
          !isWithin(normalizedPackagePath, resolvedMemberPath)) {
        throw InvalidArgumentException(
          'Workspace entry "$member" in $pubspecPath cannot leave its workspace root.',
        );
      }

      final matches = Glob(member)
          .listFileSystemSync(
            const LocalFileSystem(),
            root: normalizedPackagePath,
            followLinks: false,
          )
          .whereType<file.Directory>()
          .toList();

      final packageDirectories = matches
          .where(
            (package) => File(join(package.path, 'pubspec.yaml')).existsSync(),
          )
          .toList();
      if (packageDirectories.isEmpty) {
        throw InvalidArgumentException(
          'Workspace entry "$member" in $pubspecPath matches no packages.',
        );
      }

      for (final package in packageDirectories) {
        visitPackage(package.path, rootPackage: false);
      }
    }
  }

  visitPackage(rootPath, rootPackage: true);

  return libraryPaths.toList()..sort();
}

Map<Object?, Object?> _readManifest(String path) {
  try {
    final yaml = loadYaml(File(path).readAsStringSync());
    if (yaml is Map<Object?, Object?>) {
      return yaml;
    }
  } on YamlException catch (error) {
    throw InvalidArgumentException('Cannot parse $path: ${error.message}.');
  } on FileSystemException catch (error) {
    throw InvalidArgumentException('Cannot read $path: ${error.message}.');
  }

  throw InvalidArgumentException('$path must contain a YAML mapping.');
}
