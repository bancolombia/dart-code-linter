part of 'prefer_named_record_fields_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _recordTypeAnnotations = <RecordTypeAnnotation>[];
  final _recordLiterals = <RecordLiteral>[];

  Iterable<RecordTypeAnnotation> get recordTypeAnnotations =>
      _recordTypeAnnotations;
  Iterable<RecordLiteral> get recordLiterals => _recordLiterals;

  @override
  void visitRecordTypeAnnotation(RecordTypeAnnotation node) {
    super.visitRecordTypeAnnotation(node);

    if (_shouldReportRecordType(node)) {
      _recordTypeAnnotations.add(node);
    }
  }

  @override
  void visitRecordLiteral(RecordLiteral node) {
    super.visitRecordLiteral(node);

    if (_shouldReportRecordLiteral(node)) {
      _recordLiterals.add(node);
    }
  }

  bool _shouldReportRecordType(RecordTypeAnnotation recordType) {
    final positionalCount = recordType.positionalFields.length;
    final namedCount = recordType.namedFields?.fields.length ?? 0;

    return (positionalCount > 1 && namedCount == 0) ||
        (positionalCount >= 2 && positionalCount > namedCount);
  }

  bool _shouldReportRecordLiteral(RecordLiteral recordLiteral) {
    var positionalCount = 0;
    var namedCount = 0;

    for (final field in recordLiteral.fields) {
      if (field is NamedExpression) {
        namedCount++;
      } else {
        positionalCount++;
      }
    }

    return (positionalCount > 1 && namedCount == 0) ||
        (positionalCount >= 2 && positionalCount > namedCount);
  }
}
