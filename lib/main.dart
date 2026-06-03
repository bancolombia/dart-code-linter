import 'src/analysis_server_plugin/dart_code_linter_plugin.dart';

/// The top-level `plugin` variable required by the Dart Analysis Server's
/// new plugin protocol (Dart ≥ 3.9 / `analysis_server_plugin`).
///
/// The analysis server discovers this plugin via the `plugins:` key in
/// `analysis_options.yaml`:
///
/// ```yaml
/// plugins:
///   dart_code_linter:
///     diagnostics:
///       avoid-dynamic: true
///       prefer-trailing-comma: true
/// ```
// ignore: public_member_api_docs
final plugin = DartCodeLinterPlugin();
