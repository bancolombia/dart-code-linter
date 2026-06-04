part of 'prefer_match_file_name_rule.dart';

class _ConfigParser {
  static const _ignoreEnumsName = 'ignore-enums';
  static const _ignoreTypedefsName = 'ignore-typedefs';

  static bool parseIgnoreEnums(Map<String, Object> config) =>
      config[_ignoreEnumsName] == true;

  static bool parseIgnoreTypedefs(Map<String, Object> config) =>
      config[_ignoreTypedefsName] == true;
}
