/// A documented class whose name is too short.
///
/// Documentation and metadata precede a declaration's own children, so a name
/// reading that does not step over them silently skips these declarations and
/// the rule reports nothing.
class ex {
  ex();
}

@Deprecated('annotated')
class alsoBad {
  alsoBad();
}

/// A documented enum whose name is not capitalised.
enum broken { a, b }
