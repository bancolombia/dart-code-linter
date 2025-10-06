part of 'use_design_system_item_rule.dart';

class _ConfigParser {
  static Map<String, _ReplacementSuggestion> parseConfig(
    Map<String, Object> config,
  ) {
    final result = <String, _ReplacementSuggestion>{};

    config.forEach((key, value) {
      if (value is List) {
        for (final item in value) {
          if (item is Map<String, Object>) {
            final insteadOf = item['instead_of'] as String?;
            final fromPackage = item['from_package'] as String?;

            if (insteadOf != null && fromPackage != null) {
              result[insteadOf] = _ReplacementSuggestion(
                designSystemWidget: key,
                insteadOf: insteadOf,
                fromPackage: fromPackage,
              );
            }
          }
        }
      }
    });

    return result;
  }
}
