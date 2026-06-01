// Pattern 1: design-system factory with string-literal argument.
// AppTheme.of('compact') is flagged because the arg is a literal (not mutable).
class AppTheme {
  static AppTheme of(String variant) => AppTheme._();
  AppTheme._();
  String get headlineStyle => 'headline';
  String get bodyStyle => 'body';
}

// Pattern 2: service-locator with no regular arguments (type param only).
// ServiceLocator.instance.get<AuthService>() is flagged because
// argumentList is empty — _hasMutableArguments returns false.
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();
  T get<T extends Object>() => throw UnimplementedError();
}

class AuthService {
  bool get isLoggedIn => true;
  String get currentUserId => 'user-123';
}

void main() {
  final headline = AppTheme.of('compact').headlineStyle;
  final body = AppTheme.of('compact').bodyStyle;

  final isLoggedIn = ServiceLocator.instance.get<AuthService>().isLoggedIn;
  final userId = ServiceLocator.instance.get<AuthService>().currentUserId;
}
