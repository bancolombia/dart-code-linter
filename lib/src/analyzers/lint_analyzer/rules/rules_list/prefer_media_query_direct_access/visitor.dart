part of 'prefer_media_query_direct_access_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _mediaQueryUsages = <PropertyAccess>[];

  Iterable<PropertyAccess> get mediaQueryUsages => _mediaQueryUsages;

  @override
  void visitPropertyAccess(PropertyAccess node) {
    super.visitPropertyAccess(node);

    if (_isMediaQueryPropertyAccess(node)) {
      _mediaQueryUsages.add(node);
    }
  }

  bool _isMediaQueryPropertyAccess(PropertyAccess node) {
    final target = node.target;
    final propertyName = node.propertyName.name;

    if (target is MethodInvocation &&
        target.target is SimpleIdentifier &&
        (target.target as SimpleIdentifier).name == 'MediaQuery' &&
        target.methodName.name == 'of') {
      return _hasDirectAccessMethod(propertyName);
    }

    return false;
  }

  bool _hasDirectAccessMethod(String propertyName) {
    const availableProperties = {
      'size',
      'padding',
      'viewInsets',
      'viewPadding',
      'orientation',
      'devicePixelRatio',
      'textScaleFactor',
      'platformBrightness',
      'systemGestureInsets',
      'accessibleNavigation',
      'invertColors',
      'highContrast',
      'disableAnimations',
      'boldText',
    };

    return availableProperties.contains(propertyName);
  }
}
