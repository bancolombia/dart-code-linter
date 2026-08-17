// `@JSExport` marks Dart members that JavaScript calls, through
// `createJSInteropWrapper`. That is the opposite direction from `@JS`, whose
// members are `external` bindings Dart calls into JS and whose callers are
// therefore visible to this analysis. Annotating the class covers all of its
// instance members, per the `JSExport` doc in `dart:js_interop`.

import 'dart:js_interop';
import 'dart:js_interop' as js;

@JSExport()
class ExportedService {
  // Wrapped by `createJSInteropWrapper`, so JavaScript reaches these without
  // any Dart reference to them.
  void handleEvent() {}

  int get currentValue => 1;

  // Statics are never wrapped, so this one really is dead. It is skipped
  // anyway: the skip is applied per enclosing class, not per member kind.
  // Deliberate false negative, documented in the README.
  static int unusedStatic() => 2;
}

class PartiallyExported {
  // Only this member is exported, by its own annotation rather than the
  // class's.
  @JSExport('renamed')
  void exportedMember() {}

  // Neither exported nor referenced.
  void unusedMember() {}
}

// The annotation reached through an import prefix, which is why the detection
// compares the last component of the annotation name rather than the whole
// thing: here `Annotation.name` is a prefixed identifier reading
// `js.JSExport`, not `JSExport`.
class PrefixExported {
  @js.JSExport()
  void prefixExportedMember() {}

  void prefixUnusedMember() {}
}

// No annotation anywhere: proves the skip is selective rather than whole-file.
class PlainControl {
  void alsoUnused() {}
}

void main() {
  ExportedService();
  PartiallyExported();
  PrefixExported();
  PlainControl();
}
