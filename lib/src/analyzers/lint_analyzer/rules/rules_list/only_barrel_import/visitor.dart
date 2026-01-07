part of 'only_barrel_import_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final List<String> allowedBarrels;
  final List<ImportDirective> _invalidImports = [];

  _Visitor(this.allowedBarrels);

  Iterable<ImportDirective> get invalidImports =>
      List.unmodifiable(_invalidImports);

  @override
  void visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);

    final importUri = node.uri.stringValue ?? '';

    if (importUri.startsWith('package:') &&
        allowedBarrels.any(
          (barrel) =>
              importUri.startsWith('package:$barrel/') &&
              !(importUri == 'package:$barrel/$barrel.dart'),
        )) {
      _invalidImports.add(node);
    }
  }
}
