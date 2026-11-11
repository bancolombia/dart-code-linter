/// The first declaration in the file, and the one the file is named after.
///
/// The doc comment is the point of this fixture: a declaration's documentation
/// and metadata precede its own children, so a name reading that does not step
/// over them loses this class. The rule then reports the *next* declaration as
/// the first one, which is a false positive on a correctly named file.
class DocumentedExample {}

@Deprecated('also skipped when metadata is not stepped over')
class AnnotatedHelper {}
