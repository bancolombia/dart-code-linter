part of 'require_trailing_commas_rule.dart';

class _ConfigParser {
  static const _minParametersConfigName = 'min-parameters';

  static int? parseMinParameters(Map<String, Object> config) {
    final breakpoint = config[_minParametersConfigName];

    return breakpoint != null ? int.tryParse(breakpoint.toString()) : null;
  }

}
