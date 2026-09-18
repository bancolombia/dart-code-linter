import 'dart:io';

/// Whether [libraryUri] names a library on its package's import surface: one
/// any consumer can import directly, with nothing re-exporting it.
///
/// Dart has no way to declare which libraries a package publishes. The
/// convention pub, pana and the SDK's own lints all rely on is that a
/// consumer may import anything under `lib/` except `lib/src`. A declaration
/// in such a library therefore cannot be made private on the evidence of the
/// analyzed code alone, since the libraries naming it may live in a package
/// that is not part of the analysis.
///
/// Takes the library's canonical URI rather than its path, because that is
/// what actually answers the question: the analyzer hands out a `package:`
/// URI exactly when the file resolves inside some package's `lib/`, whichever
/// folder the analysis happens to have been pointed at. A file that resolves
/// to no package (a script, a loose folder, an unresolved package) is not
/// importable by anyone and is not on any surface.
bool isOnPackageImportSurface(Uri libraryUri) {
  if (!libraryUri.isScheme('package')) {
    return false;
  }

  final segments = libraryUri.pathSegments;

  // Segment 0 is the package name. `package:foo/src.dart` is on the surface
  // and `package:foo/src/a.dart` is not: only the `src` *folder* is excluded.
  return segments.length > 1 && segments[1] != 'src';
}

String? uriToPath(Uri? uri) {
  if (uri == null) {
    return null;
  }

  if (uri.scheme == 'file') {
    return uri.toFilePath();
  }

  return File(uri.path).absolute.path;
}
