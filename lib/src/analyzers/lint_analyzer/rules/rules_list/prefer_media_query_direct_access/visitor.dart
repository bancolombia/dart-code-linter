part of 'prefer_media_query_direct_access_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final _mediaQueryUsages = <MethodInvocation>[];

  Iterable<MethodInvocation> get mediaQueryUsages => _mediaQueryUsages;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    if (_isMediaQueryUsage(node)) {
      _mediaQueryUsages.add(node);
    }
  }

  bool _isMediaQueryUsage(MethodInvocation node) {
    final target = node.target;
    final methodName = node.methodName.name;

    return target is SimpleIdentifier &&
        target.name == 'MediaQuery' &&
        (methodName == 'of' ||
            methodName == 'size' ||
            methodName == 'padding' ||
            methodName == 'viewInsets' ||
            methodName == 'viewPadding' ||
            methodName == 'orientation' ||
            methodName == 'devicePixelRatio' ||
            methodName == 'textScaleFactor' ||
            methodName == 'platformBrightness' ||
            methodName == 'accessibleNavigation' ||
            methodName == 'invertColors' ||
            methodName == 'highContrast' ||
            methodName == 'disableAnimations');
  }
}
