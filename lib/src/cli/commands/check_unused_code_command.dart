// ignore_for_file: public_member_api_docs

import 'dart:io';

import '../../analyzers/unused_code_analyzer/models/unused_code_file_report.dart';
import '../../analyzers/unused_code_analyzer/models/unused_code_issue.dart';
import '../../analyzers/unused_code_analyzer/reporters/unused_code_report_params.dart';
import '../../analyzers/unused_code_analyzer/unused_code_analyzer.dart';
import '../../config_builder/config_builder.dart';
import '../../logger/logger.dart';
import '../models/flag_names.dart';
import 'base_command.dart';

/// Whether an unused code run should fail the build.
///
/// The two kinds of finding have separate gates: a could be private
/// suggestion is about a declaration that *is* used, so it is not unused code
/// and must not be governed by `--fatal-unused`.
bool isFatalUnusedCodeResult(
  Iterable<UnusedCodeFileReport> reports, {
  required bool fatalOnUnused,
  required bool fatalOnCouldBePrivate,
}) =>
    reports.expand((report) => report.issues).any(
          (issue) => switch (issue.kind) {
            UnusedCodeIssueKind.unused => fatalOnUnused,
            UnusedCodeIssueKind.couldBePrivate => fatalOnCouldBePrivate,
          },
        );

class CheckUnusedCodeCommand extends BaseCommand {
  final UnusedCodeAnalyzer _analyzer;

  final Logger _logger;

  @override
  String get name => 'check-unused-code';

  @override
  String get description => 'Check unused code in *.dart files.';

  @override
  String get invocation =>
      '${runner?.executableName} $name [arguments] <directories>';

  CheckUnusedCodeCommand(this._logger)
      : _analyzer = UnusedCodeAnalyzer(_logger) {
    _addFlags();
  }

  @override
  Future<void> runCommand() async {
    _logger
      ..isSilent = isNoCongratulate
      ..isVerbose = isVerbose
      ..progress.start('Checking unused code');

    final rootFolder = argResults[FlagNames.rootFolder] as String;
    final folders = argResults.rest;
    final excludePath = argResults[FlagNames.exclude] as String;
    final reporterName = argResults[FlagNames.reporter] as String;
    final isMonorepo = _boolFlagOrNull(FlagNames.isMonorepo);
    final shouldPrintConfig = _boolFlagOrNull(FlagNames.printConfig);
    final analyzePrivateMembers =
        _boolFlagOrNull(FlagNames.analyzePrivateMembers);
    final analyzePublicMembers =
        _boolFlagOrNull(FlagNames.analyzePublicMembers);
    final suggestPrivateMembers =
        _boolFlagOrNull(FlagNames.suggestPrivateMembers);

    final config = ConfigBuilder.getUnusedCodeConfigFromArgs(
      [excludePath],
      isMonorepo: isMonorepo,
      shouldPrintConfig: shouldPrintConfig,
      analyzePrivateMembers: analyzePrivateMembers,
      analyzePublicMembers: analyzePublicMembers,
      suggestPrivateMembers: suggestPrivateMembers,
    );

    final unusedCodeResult = await _analyzer.runCliAnalysis(
      folders,
      rootFolder,
      config,
      sdkPath: findSdkPath(),
    );

    _logger.progress.complete('Analysis is completed. Preparing the results:');

    await _analyzer
        .getReporter(
          name: reporterName,
          output: stdout,
        )
        ?.report(
          unusedCodeResult,
          additionalParams:
              UnusedCodeReportParams(congratulate: !isNoCongratulate),
        );

    if (isFatalUnusedCodeResult(
      unusedCodeResult,
      fatalOnUnused: argResults[FlagNames.fatalOnUnused] as bool,
      fatalOnCouldBePrivate:
          argResults[FlagNames.fatalOnCouldBePrivate] as bool,
    )) {
      exit(1);
    }
  }

  /// `null` means not passed, distinct from an explicit `--no-...`.
  bool? _boolFlagOrNull(String name) =>
      argResults.wasParsed(name) ? argResults[name] as bool : null;

  void _addFlags() {
    _usesReporterOption();
    addCommonFlags();
    _usesIsMonorepoOption();
    _usesAnalyzePrivateMembersOption();
    _usesAnalyzePublicMembersOption();
    _usesSuggestPrivateMembersOption();
    _usesExitOption();
  }

  void _usesReporterOption() {
    argParser
      ..addSeparator('')
      ..addOption(
        FlagNames.reporter,
        abbr: 'r',
        help: 'The format of the output of the analysis.',
        valueHelp: FlagNames.consoleReporter,
        allowed: [
          FlagNames.consoleReporter,
          FlagNames.jsonReporter,
        ],
        defaultsTo: FlagNames.consoleReporter,
      );
  }

  void _usesIsMonorepoOption() {
    argParser
      ..addSeparator('')
      ..addFlag(
        FlagNames.isMonorepo,
        help: 'Treat all exported code as unused by default.',
      );
  }

  void _usesAnalyzePrivateMembersOption() {
    argParser
      ..addSeparator('')
      ..addFlag(
        FlagNames.analyzePrivateMembers,
        help: 'Also report unused private members in type declarations '
            '(methods, fields, getters, setters and named constructors).',
      );
  }

  void _usesAnalyzePublicMembersOption() {
    argParser
      ..addSeparator('')
      ..addFlag(
        FlagNames.analyzePublicMembers,
        help: 'Also report unused public members in type declarations. Less '
            'reliable than the private members check: members reached only '
            'through dynamic calls, reflection or code generation may be '
            'reported.',
      );
  }

  void _usesSuggestPrivateMembersOption() {
    argParser
      ..addSeparator('')
      ..addFlag(
        FlagNames.suggestPrivateMembers,
        help: 'Also report public declarations that are only referenced from '
            'within their own library, and so could be made private. Reports '
            'code that is used, not dead code, so it has its own fatal flag.',
      );
  }

  void _usesExitOption() {
    argParser
      ..addSeparator('')
      ..addFlag(
        FlagNames.fatalOnUnused,
        help: 'Treat find unused code as fatal.',
        defaultsTo: true,
      )
      ..addFlag(
        FlagNames.fatalOnCouldBePrivate,
        help: 'Treat finding declarations that could be private as fatal.',
        defaultsTo: true,
      );
  }
}
