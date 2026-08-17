// `@JS` members are `external` bindings that Dart calls *into* JavaScript. That
// is the opposite direction from `@JSExport` (see js_exported_members.dart):
// the callers of a binding live in Dart, so this analysis can see them, and an
// unreferenced binding is therefore reportable in principle.
//
// They are skipped anyway, because an interop binding surface is normally
// written complete on purpose and reporting the unused part of it is noise
// rather than a finding. That makes `@JS` the one entry in the skip list which
// rests on a judgement call instead of on reachability, which is exactly why it
// is worth pinning with a test.
//
// `@JS` comes from `dart:js_interop`, an SDK library, so no `package:js`
// dependency is involved.

import 'dart:js_interop';

@JS()
extension type JsConsole(String _handle) {
  // Bound to the JS property `log`. Nothing in Dart references it, and the
  // annotation is the only reason it is not reported.
  @JS('log')
  external void writeLine(String message);

  // Equally unreferenced, but carries no annotation of its own, so it is
  // reported. Control case: without it, a test asserting "nothing here is
  // reported" would also pass if members of this type were skipped wholesale.
  external void clear();
}

// Keeps the extension type itself referenced, so the top level check does not
// report it and muddy the member assertions.
JsConsole openConsole() => JsConsole('console');

void main() {
  openConsole();
}
