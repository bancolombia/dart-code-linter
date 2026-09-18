// Another library. Every reference here rules its target out of a suggestion.

import 'could_be_private.dart';

int useForeignMembers() {
  final api = Api.foreignNamed()
    ..foreignSetter = 1
    ..foreignMethod();

  return api.foreignField + api.foreignGetter + Api.foreignStatic();
}

void main() {
  useForeignMembers();
}
