import 'known_limitation_mock_implementer.dart';

// Nothing here is instantiated or called on purpose. A call through one of
// these types would be an ordinary reference from another library, which
// would keep the member out of the suggestions for a completely different
// reason and hide the limitation this pair is here to pin. The usage visitor
// walks every declaration of every analyzed file whether or not the
// declaration itself is used, so declaring them is enough.

/// The shape a hand written mock takes: every call is answered by
/// `noSuchMethod`, matched on the member name at run time.
class Mock {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Declares no member of its own, which is legal because of the inherited
// concrete `noSuchMethod`, and is what leaves the guard with nothing to
// match `stubbedByName` against.
class HandWrittenMock extends Mock implements MockedService {}

// The control: a generated mock declares a concrete override of the member,
// so the guard sees the redeclaration and blocks the suggestion.
class GeneratedMock extends Mock implements MockedService {
  @override
  int declaredByTheMock() => 20;
}

// An abstract implementer declares nothing either, and needs no
// `noSuchMethod` to be legal. Same gap, second shape.
abstract class PartialImplementer implements MockedService {}
