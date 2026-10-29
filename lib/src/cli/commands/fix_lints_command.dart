// ignore_for_file: public_member_api_docs

import '../../../config.dart';
import '../../../lint_analyzer.dart';
import '../../logger/logger.dart';
import '../models/flag_names.dart';
import 'base_command.dart';

class FixCommand extends BaseCommand {
  final LintAnalyzer _analyzer;
  final Logger _logger;

  @override
  String get name => 'fix';

  @override
  String get description =>
      'Automatically fix code issues based on lint rules and metrics.';

  @override
  String get invocation =>
      '${runner?.executableName} $name [arguments] [<directories>]';

  FixCommand(this._logger) : _analyzer = LintAnalyzer(_logger) {
    _addFlags();
  }

  @override
  Future<void> runCommand() async {
    _logger
      ..isSilent = isNoCongratulate
      ..isVerbose = isVerbose
      ..progress.start('Applying fixes');

    final parsedArgs = ParsedArguments.fromArgsNoMetrics(argResults);
    final config = ConfigBuilder.getLintConfigFromArgs(parsedArgs);

    // Run the analysis and apply fixes
    await _analyzer.runCliFix(
      targetDirectories,
      parsedArgs.rootFolder,
      config,
      sdkPath: findSdkPath(),
    );

    _logger.progress
        .complete('Fixes have been applied. Preparing the results:');
  }

  void _addFlags() {
    _usesReporterOption();
    addCommonFlags();
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
          FlagNames.consoleVerboseReporter,
          FlagNames.checkstyleReporter,
          FlagNames.codeClimateReporter,
          FlagNames.githubReporter,
          FlagNames.gitlabCodeClimateReporter,
          FlagNames.htmlReporter,
          FlagNames.jsonReporter,
        ],
        defaultsTo: FlagNames.consoleReporter,
      )
      ..addOption(
        FlagNames.reportFolder,
        abbr: 'o',
        help: 'Write HTML output to OUTPUT.',
        valueHelp: 'OUTPUT',
        defaultsTo: 'metrics',
      )
      ..addOption(
        FlagNames.jsonReportPath,
        help: 'Path to the JSON file with the output of the analysis.',
        valueHelp: 'path/to/file.json',
        defaultsTo: null,
      );
  }

  void _usesExitOption() {
    argParser
      ..addSeparator('')
      ..addOption(
        FlagNames.setExitOnViolationLevel,
        allowed: ['noted', 'warning', 'alarm'],
        valueHelp: 'warning',
        help:
            'Set exit code 2 if code violations same or higher level than selected are detected.',
      )
      ..addFlag(
        FlagNames.fatalStyle,
        help: 'Treat style level issues as fatal.',
      )
      ..addFlag(
        FlagNames.fatalPerformance,
        help: 'Treat performance level issues as fatal.',
      )
      ..addFlag(
        FlagNames.fatalWarnings,
        help: 'Treat warning level issues as fatal.',
        defaultsTo: true,
      );
  }
}
