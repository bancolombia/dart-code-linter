import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/element.dart';
import 'package:path/path.dart';
import 'package:source_span/source_span.dart';

import '../../config_builder/config_builder.dart';
import '../../config_builder/models/analysis_options.dart';
import '../../logger/logger.dart';
import '../../reporters/models/reporter.dart';
import '../../utils/analyzer_utils.dart';
import '../../utils/path_utils.dart';
import '../../utils/suppression.dart';
import 'element_utils.dart';
import 'models/file_elements_usage.dart';
import 'models/unused_code_file_report.dart';
import 'models/unused_code_issue.dart';
import 'public_code_visitor.dart';
import 'reporters/reporter_factory.dart';
import 'reporters/unused_code_report_params.dart';
import 'unused_code_analysis_config.dart';
import 'unused_code_config.dart';
import 'used_code_visitor.dart';

/// The analyzer responsible for collecting unused code reports.
class UnusedCodeAnalyzer {
  static const _ignoreName = 'unused-code';

  final Logger? _logger;

  const UnusedCodeAnalyzer([this._logger]);

  /// Returns a reporter for the given [name]. Use the reporter
  /// to convert analysis reports to console, JSON or other supported format.
  Reporter<UnusedCodeFileReport, UnusedCodeReportParams>? getReporter({
    required String name,
    required IOSink output,
  }) =>
      reporter(
        name: name,
        output: output,
      );

  /// Returns a list of unused code reports
  /// for analyzing all files in the given [folders].
  /// The analysis is configured with the [config].
  Future<Iterable<UnusedCodeFileReport>> runCliAnalysis(
    Iterable<String> folders,
    String rootFolder,
    UnusedCodeConfig config, {
    String? sdkPath,
  }) async {
    final collection =
        createAnalysisContextCollection(folders, rootFolder, sdkPath);

    final codeUsages = FileElementsUsage();
    final publicCode = <String, _FileCandidates>{};

    // Files any consumer of their package can import directly. Collected
    // during the walk, where each unit's resolved library URI says whether it
    // sits in some package's `lib/`, outside `lib/src`.
    final packageImportSurface = <String>{};

    for (final context in collection.contexts) {
      final unusedCodeAnalysisConfig =
          _getAnalysisConfig(context, rootFolder, config);

      if (config.shouldPrintConfig ?? false) {
        _logger?.printConfig(unusedCodeAnalysisConfig.toJson());
      }

      final filePaths = getFilePaths(
        folders,
        context,
        rootFolder,
        unusedCodeAnalysisConfig.globalExcludes,
      );

      final analyzedFiles =
          filePaths.intersection(context.contextRoot.analyzedFiles().toSet());

      final contextsLength = collection.contexts.length;
      final filesLength = analyzedFiles.length;
      final updateMessage = contextsLength == 1
          ? 'Checking unused code for $filesLength file(s)'
          : 'Checking unused code for ${collection.contexts.indexOf(context) + 1}/$contextsLength contexts with $filesLength file(s)';
      _logger?.progress.update(updateMessage);

      for (final filePath in analyzedFiles) {
        _logger?.infoVerbose('Analyzing $filePath');

        final unit = await context.currentSession.getResolvedUnit(filePath);

        final codeUsage = _analyzeFileCodeUsages(
          unit,
          unusedCodeAnalysisConfig,
        );
        if (codeUsage != null) {
          codeUsages.merge(codeUsage);
        }

        if (!unusedCodeAnalysisConfig.analyzerExcludedPatterns
            .any((pattern) => pattern.matches(filePath))) {
          publicCode[filePath] = _analyzeFilePublicCode(
            unit,
            unusedCodeAnalysisConfig,
          );

          if (unusedCodeAnalysisConfig.suggestPrivateMembers &&
              unit is ResolvedUnitResult &&
              isOnPackageImportSurface(unit.libraryElement.uri)) {
            packageImportSurface.add(filePath);
          }
        }
      }
    }

    if (!(config.isMonorepo ?? false)) {
      _logger?.infoVerbose(
        'Removing globally exported files with code usages from the analysis: ${codeUsages.exports.length}',
      );
      // Only top level declarations are part of the package's exported
      // surface here: a member is reachable from outside only through a
      // reference to its enclosing type, which the type's own top level
      // exemption already covers, so exporting a file must not excuse the
      // dead members of the types it declares.
      //
      // The same cut applies to the could be private suggestions, which is
      // what keeps them off a package's export surface: an exported top level
      // declaration can be imported by any consumer, seen or unseen, so it is
      // never suggested, while the members of its types still are.
      for (final exportedPath in codeUsages.exports) {
        final candidates = publicCode[exportedPath];
        if (candidates == null) {
          continue;
        }

        final members = candidates.membersOnly();
        if (members.isEmpty) {
          publicCode.remove(exportedPath);
        } else {
          publicCode[exportedPath] = members;
        }
      }

      // Being re-exported is not the only way onto a package's import
      // surface: a library under `lib/` outside `lib/src` is importable
      // directly, with nothing exporting it, so its top level declarations
      // are just as unsafe to suggest privatizing.
      //
      // Unlike the loop above, this drops the suggestions alone and leaves
      // the unused candidates in place. The two verdicts want different
      // things here: whether anything in the analyzed code references a
      // declaration is a fact about that code, which is what the unused
      // check has always reported for these files, while a suggestion to
      // rename one is a claim about every library that could reach it,
      // including the ones outside the analysis.
      for (final publicPath in packageImportSurface) {
        final candidates = publicCode[publicPath];
        if (candidates == null) {
          continue;
        }

        final kept = candidates.withoutTopLevelSuggestions();
        if (kept.isEmpty) {
          publicCode.remove(publicPath);
        } else {
          publicCode[publicPath] = kept;
        }
      }
    }

    return _getReports(codeUsages, publicCode, rootFolder);
  }

  UnusedCodeAnalysisConfig _getAnalysisConfig(
    AnalysisContext context,
    String rootFolder,
    UnusedCodeConfig config,
  ) {
    final analysisOptions = analysisOptionsFromContext(context) ??
        analysisOptionsFromFilePath(rootFolder, context);

    final contextConfig =
        ConfigBuilder.getUnusedCodeConfigFromOption(analysisOptions)
            .merge(config);

    return ConfigBuilder.getUnusedCodeConfig(contextConfig, rootFolder);
  }

  FileElementsUsage? _analyzeFileCodeUsages(
    SomeResolvedUnitResult unit,
    UnusedCodeAnalysisConfig config,
  ) {
    if (unit is ResolvedUnitResult) {
      final visitor = UsedCodeVisitor(
        recordClassMembers: config.analyzeMembers,
        recordPrivatizationBlockers: config.suggestPrivateMembers,
        library: unit.libraryElement,
      );
      unit.unit.visitChildren(visitor);

      return visitor.fileElementsUsage;
    }

    return null;
  }

  _FileCandidates _analyzeFilePublicCode(
    SomeResolvedUnitResult unit,
    UnusedCodeAnalysisConfig config,
  ) {
    if (unit is ResolvedUnitResult) {
      final suppression = Suppression(unit.content, unit.lineInfo);
      final isSuppressed = suppression.isSuppressed(_ignoreName);
      if (isSuppressed) {
        return const _FileCandidates.empty();
      }

      final visitor = PublicCodeVisitor(
        suppression,
        _ignoreName,
        analyzePrivateMembers: config.analyzePrivateMembers,
        analyzePublicMembers: config.analyzePublicMembers,
        suggestPrivateMembers: config.suggestPrivateMembers,
      );
      unit.unit.visitChildren(visitor);

      return _FileCandidates(
        visitor.topLevelElements,
        visitor.privatizableElements,
      );
    }

    return const _FileCandidates.empty();
  }

  Iterable<UnusedCodeFileReport> _getReports(
    FileElementsUsage codeUsages,
    Map<String, _FileCandidates> publicCodeElements,
    String rootFolder,
  ) {
    final unusedCodeReports = <UnusedCodeFileReport>[];

    publicCodeElements.forEach((path, candidates) {
      final issues = <UnusedCodeIssue>[];

      void report(Element element, UnusedCodeIssueKind kind) {
        final unit = element.firstFragment.libraryFragment;
        if (unit != null) {
          issues.add(
            _createUnusedCodeIssue(element as ElementImpl, unit, kind),
          );
        }
      }

      // The declarations this file is reporting as dead code, so a member of
      // one of them can be left out of the suggestions below.
      final deadDeclarations = <Element>{};

      for (final element in candidates.unused) {
        if (_isUnused(codeUsages, path, element)) {
          deadDeclarations.add(element);
          report(element, UnusedCodeIssueKind.unused);
        }
      }

      // The two verdicts cannot collide: [_couldBePrivate] requires the
      // declaration to be used, which is the opposite of what the loop above
      // reports, so an element in both candidate sets yields at most one
      // issue.
      //
      // A member of a type that *is* being reported dead is dropped all the
      // same. Nothing can reach such a member except through the loose same
      // library name fallback for dart-lang/sdk#49182, which matches any
      // same-named member of the library and is what makes it look used at
      // all, and the answer for the whole type is to delete it rather than to
      // privatize its members one at a time.
      for (final element in candidates.privatizable) {
        if (_couldBePrivate(codeUsages, path, element) &&
            !deadDeclarations.contains(element.enclosingElement)) {
          report(element, UnusedCodeIssueKind.couldBePrivate);
        }
      }

      final relativePath = relative(path, from: rootFolder);

      if (issues.isNotEmpty) {
        unusedCodeReports.add(UnusedCodeFileReport(
          path: path,
          relativePath: relativePath,
          issues: issues,
        ));
      }
    });

    return unusedCodeReports;
  }

  bool _isUsed(Element usedElement, Element element, bool elementIsMember) =>
      _isEqualElements(usedElement, element, elementIsMember) ||
      element is PropertyInducingElement &&
          _isEqualElements(usedElement, element.getter, elementIsMember);

  bool _isEqualElements(Element left, Element? right, bool rightIsMember) {
    if (left == right) {
      return true;
    }

    final usedLibrary = left.library;
    final declaredSource = right?.firstFragment.libraryFragment?.source;

    // This is a hack to fix incorrect libraries resolution.
    // Should be removed after new analyzer version is available.
    // see: https://github.com/dart-lang/sdk/issues/49182
    //
    // The name based fallback below is deliberately loose, and with member
    // analysis enabled a used member would otherwise mark a dead library
    // level declaration of the same name as used (a class calling its own
    // `dispose` hiding an unused top level `dispose` function). Requiring
    // both sides to agree on member-ness cannot introduce false positives:
    // member dispatch never resolves to a library level declaration, so the
    // fallback was never needed across that boundary. Member to member
    // matching stays loose, since that is what keeps overrides from being
    // reported. `_isUnused`'s conditional import fallback carries the same
    // member-ness guard for the same reason.
    return usedLibrary != null &&
        declaredSource != null &&
        isMemberElement(left) == rightIsMember &&
        left.name == right?.name &&
        usedLibrary.fragments
            .map((fragment) => fragment.source.fullName)
            .contains(declaredSource.fullName);
  }

  /// Whether [element] is a member that some invocation on an unknown type
  /// could reach.
  ///
  /// Only members are considered: a reference on a target, dynamic or not, can
  /// never resolve to a library level declaration.
  bool _isUsedDynamically(FileElementsUsage codeUsages, Element element) {
    final name = element.name;

    return name != null &&
        isMemberElement(element) &&
        codeUsages.dynamicallyUsedNames.contains(name);
  }

  bool _isUnused(FileElementsUsage codeUsages, String path, Element element) {
    final elementIsMember = isMemberElement(element);

    return !_isUsedDynamically(codeUsages, element) &&
        !codeUsages.conditionalElements.entries.any((entry) =>
            entry.key.contains(path) &&
            entry.value.any((usedElement) =>
                _isUsed(usedElement, element, elementIsMember) ||
                (isMemberElement(usedElement) == elementIsMember &&
                    usedElement.name == element.name &&
                    usedElement.kind == element.kind))) &&
        !codeUsages.elements.any(
            (usedElement) => _isUsed(usedElement, element, elementIsMember)) &&
        !codeUsages.usedExtensions.any(
            (usedElement) => _isUsed(usedElement, element, elementIsMember));
  }

  /// Whether [element] is used, but only ever from inside the library that
  /// declares it, so it could carry a private name instead.
  bool _couldBePrivate(
    FileElementsUsage codeUsages,
    String path,
    Element element,
  ) =>
      // A declaration nothing references at all is dead code rather than a
      // rename candidate, and is reported as such by the unused verdict when
      // that check is enabled.
      !_isUnused(codeUsages, path, element) &&
      // An invocation on an unknown type can come from anywhere, including
      // another library, so locality cannot be established.
      !_isUsedDynamically(codeUsages, element) &&
      !_isUsedOutsideDeclaringLibrary(codeUsages, element) &&
      !_isRedeclaredOutsideDeclaringLibrary(codeUsages, element);

  /// Whether any reference to [element] sits in a library other than the one
  /// declaring it.
  ///
  /// Matched with the same loose comparison the unused verdict uses, so the
  /// name based fallback for dart-lang/sdk#49182 cannot turn a foreign
  /// reference it failed to resolve into a suggestion.
  bool _isUsedOutsideDeclaringLibrary(
    FileElementsUsage codeUsages,
    Element element,
  ) {
    final elementIsMember = isMemberElement(element);

    return codeUsages.externallyUsedElements
        .any((usedElement) => _isUsed(usedElement, element, elementIsMember));
  }

  /// Whether a type in another library redeclares [element] somewhere in its
  /// own hierarchy, which a private name would silently stop lining up with.
  ///
  /// Only instance members can be reached this way. A static, a constructor
  /// and a top level declaration are never inherited, so no subtype can
  /// redeclare one, and an extension has no subtypes at all.
  bool _isRedeclaredOutsideDeclaringLibrary(
    FileElementsUsage codeUsages,
    Element element,
  ) {
    final enclosingElement = element.enclosingElement;
    if (enclosingElement is! InterfaceElement ||
        element is ConstructorElement ||
        _isStaticMember(element)) {
      return false;
    }

    final key = memberKey(enclosingElement, element.name);

    return key != null && codeUsages.externallyRedeclaredMembers.contains(key);
  }

  bool _isStaticMember(Element element) => switch (element) {
        ExecutableElement() => element.isStatic,
        VariableElement() => element.isStatic,
        _ => false,
      };

  UnusedCodeIssue _createUnusedCodeIssue(
    ElementImpl element,
    LibraryFragment unit,
    UnusedCodeIssueKind kind,
  ) {
    final offset = element.firstFragment.codeOffset!;
    final lineInfo = unit.lineInfo;
    final offsetLocation = lineInfo.getLocation(offset);

    final sourceUrl = element.firstFragment.libraryFragment?.source.uri;

    return UnusedCodeIssue(
      declarationName: element.displayName,
      declarationType: element.kind.displayName,
      kind: kind,
      location: SourceLocation(
        offset,
        sourceUrl: sourceUrl,
        line: offsetLocation.lineNumber,
        column: offsetLocation.columnNumber,
      ),
    );
  }
}

/// The declarations of one file that the analysis has to reach a verdict on.
///
/// The two sets are collected independently and overlap only partially: a
/// public member is in both when both checks are on, a private one or one that
/// cannot be renamed only in [unused], and one collected while the unused
/// checks are off only in [privatizable]. Which sets are populated at all
/// depends on the options of the context the file belongs to, which is why
/// they travel with the file rather than being re-derived at report time.
class _FileCandidates {
  /// Declarations that are reported when nothing references them.
  final Set<Element> unused;

  /// Declarations that are reported when only their own library does.
  final Set<Element> privatizable;

  const _FileCandidates(this.unused, this.privatizable);

  const _FileCandidates.empty()
      : unused = const {},
        privatizable = const {};

  bool get isEmpty => unused.isEmpty && privatizable.isEmpty;

  /// The same candidates with every top level declaration dropped.
  _FileCandidates membersOnly() => _FileCandidates(
        unused.where(isMemberElement).toSet(),
        privatizable.where(isMemberElement).toSet(),
      );

  /// The same candidates with only the top level *suggestions* dropped, so
  /// the unused verdict keeps seeing every declaration of the file.
  _FileCandidates withoutTopLevelSuggestions() => _FileCandidates(
        unused,
        privatizable.where(isMemberElement).toSet(),
      );
}
