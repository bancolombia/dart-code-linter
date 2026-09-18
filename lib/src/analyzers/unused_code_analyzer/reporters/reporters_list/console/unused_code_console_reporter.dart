import '../../../../../reporters/models/console_reporter.dart';
import '../../../models/unused_code_file_report.dart';
import '../../../models/unused_code_issue.dart';
import '../../unused_code_report_params.dart';

/// Unused code console reporter.
///
/// Use it to create reports in console format.
class UnusedCodeConsoleReporter
    extends ConsoleReporter<UnusedCodeFileReport, UnusedCodeReportParams> {
  UnusedCodeConsoleReporter(super.output);

  @override
  Future<void> report(
    Iterable<UnusedCodeFileReport> records, {
    UnusedCodeReportParams? additionalParams,
  }) async {
    if (records.isEmpty) {
      if (additionalParams?.congratulate ?? true) {
        output.writeln('${okPen('✔')} no unused code found!');
      }

      return;
    }

    final sortedRecords = records.toList()
      ..sort((a, b) => a.relativePath.compareTo(b.relativePath));

    var warnings = 0;
    var suggestions = 0;

    for (final analysisRecord in sortedRecords) {
      output.writeln('${analysisRecord.relativePath}:');

      for (final issue in analysisRecord.issues) {
        final line = issue.location.line;
        final column = issue.location.column;
        final path = analysisRecord.path;

        final offset = ''.padRight(3);
        final pathOffset = offset.padRight(5);

        final description = switch (issue.kind) {
          UnusedCodeIssueKind.unused =>
            'unused ${issue.declarationType} ${issue.declarationName}',
          UnusedCodeIssueKind.couldBePrivate =>
            '${issue.declarationType} ${issue.declarationName} could be private',
        };

        output
          ..writeln('$offset ${warningPen('⚠')} $description')
          ..writeln('$pathOffset at $path:$line:$column');

        if (issue.kind == UnusedCodeIssueKind.couldBePrivate) {
          suggestions++;
        } else {
          warnings++;
        }
      }

      output.writeln('');
    }

    if (warnings > 0 || suggestions == 0) {
      output.writeln(
        '${alarmPen('✖')} total unused code (classes, functions, variables, extensions, enums, mixins and type aliases) - ${alarmPen(warnings)}',
      );
    }

    if (suggestions > 0) {
      output.writeln(
        '${alarmPen('✖')} total declarations that could be private - ${alarmPen(suggestions)}',
      );
    }
  }
}
