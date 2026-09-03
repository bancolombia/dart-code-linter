import 'external_subtype_kinds.dart';

// The mixin is deliberately never applied to a class here: an application
// would be a class declaration reaching `MixinHost` too, and what needs
// pinning is that the mixin declaration on its own blocks the member.
mixin RedeclaringMixin on MixinHost {
  @override
  int mixedRedeclared() => 10;
}

int useTheMixin(RedeclaringMixin? instance) => instance?.mixedRedeclared() ?? 0;

// No `@override`: this mixin declares the member without inheriting it. The
// mixin application below is what puts it in front of `AliasHost`.
mixin AliasMixin {
  int aliasRedeclared() => 11;
}

class AliasSubtype = AliasHost with AliasMixin;

enum RedeclaringEnum implements EnumInterface {
  only;

  @override
  int enumRedeclared() => 12;
}

extension type WrappingExtensionType(ExtensionTypeHost host)
    implements ExtensionTypeHost {
  int wrappedRedeclared() => 13;
}

void main() {
  useTheMixin(null);
  AliasSubtype().aliasRedeclared();
  RedeclaringEnum.only.enumRedeclared();
  WrappingExtensionType(ExtensionTypeHost()).wrappedRedeclared();
}
