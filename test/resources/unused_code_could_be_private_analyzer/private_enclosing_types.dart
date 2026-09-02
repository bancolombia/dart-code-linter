// A member of a type that is already private is never suggested.
//
// For most of these the rename is simply pointless: the type cannot be named
// outside this library, so nothing out there could have been reaching the
// member anyway. For a mixin it is more than pointless, since a public class
// can mix a private mixin in and republish its members under a name other
// libraries can reach, which is why skipping is the right direction for the
// whole group rather than just the harmless part of it.

class _PrivateHost {
  int hostMember() => 1;
}

mixin _PrivateMixin {
  int mixinMember() => 2;
}

enum _PrivateEnum {
  only;

  int enumMember() => 3;
}

extension _PrivateExtension on int {
  int get extensionMember => this + 4;
}

extension type _PrivateExtensionType(int representation) {
  int typeMember() => 5;
}

extension on String {
  // The one exception. An unnamed extension has no name to be private with,
  // so `Element.isPrivate` reports it private, but its members apply in every
  // library that imports this one and are a genuine rename candidate.
  int get unnamedExtensionMember => length;
}

class PublicHost {
  int publicHostMember() => 6;
}

class PublicMixesInPrivate with _PrivateMixin {}

int usePrivateEnclosingTypes() =>
    _PrivateHost().hostMember() +
    PublicMixesInPrivate().mixinMember() +
    _PrivateEnum.only.enumMember() +
    7.extensionMember +
    _PrivateExtensionType(8).typeMember() +
    'x'.unnamedExtensionMember +
    PublicHost().publicHostMember();
