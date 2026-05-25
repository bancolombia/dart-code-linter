part of 'prefer_moving_to_variable_rule.dart';

class _ConfigParser {
  static const _allowedDuplicatedChains = 'allowed-duplicated-chains';
  static const _ignoredInvocations = 'ignored-invocations';
  static const _ignoredTargets = 'ignored-targets';

  static int? parseAllowedDuplicatedChains(Map<String, Object> config) {
    final raw = config[_allowedDuplicatedChains];

    return raw is int? ? raw : null;
  }

  static Iterable<String> parseIgnoredInvocations(Map<String, Object> config) =>
      config.containsKey(_ignoredInvocations) &&
              config[_ignoredInvocations] is Iterable
          ? List<String>.from(config[_ignoredInvocations] as Iterable)
          : <String>[];

  static Iterable<String> parseIgnoredTargets(Map<String, Object> config) =>
      config.containsKey(_ignoredTargets) && config[_ignoredTargets] is Iterable
          ? List<String>.from(config[_ignoredTargets] as Iterable)
          : <String>[];
}
