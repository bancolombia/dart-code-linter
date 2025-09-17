import 'package:flutter/material.dart';

class MediaQueryExamples extends StatelessWidget {
  const MediaQueryExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ❌ Bad: Using MediaQuery.of(context).property
    final size = MediaQuery.of(context).size; // LINT
    final padding = MediaQuery.of(context).padding; // LINT
    final orientation = MediaQuery.of(context).orientation; // LINT
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio; // LINT
    final textScaleFactor = MediaQuery.of(context).textScaleFactor; // LINT
    final platformBrightness =
        MediaQuery.of(context).platformBrightness; // LINT
    final viewInsets = MediaQuery.of(context).viewInsets; // LINT
    final viewPadding = MediaQuery.of(context).viewPadding; // LINT
    final systemGestureInsets =
        MediaQuery.of(context).systemGestureInsets; // LINT
    final accessibleNavigation =
        MediaQuery.of(context).accessibleNavigation; // LINT
    final highContrast = MediaQuery.of(context).highContrast; // LINT
    final disableAnimations = MediaQuery.of(context).disableAnimations; // LINT
    final invertColors = MediaQuery.of(context).invertColors; // LINT
    final boldText = MediaQuery.of(context).boldText; // LINT

    // ❌ Bad: Nested property access
    final width = MediaQuery.of(context).size.width; // LINT
    final height = MediaQuery.of(context).size.height; // LINT
    final topPadding = MediaQuery.of(context).padding.top; // LINT

    // ✅ Good: Using direct access methods (should not trigger lint)
    final goodSize = MediaQuery.sizeOf(context);
    final goodPadding = MediaQuery.paddingOf(context);
    final goodOrientation = MediaQuery.orientationOf(context);
    final goodDevicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final goodTextScaleFactor = MediaQuery.textScaleFactorOf(context);
    final goodPlatformBrightness = MediaQuery.platformBrightnessOf(context);
    final goodViewInsets = MediaQuery.viewInsetsOf(context);
    final goodViewPadding = MediaQuery.viewPaddingOf(context);
    final goodSystemGestureInsets = MediaQuery.systemGestureInsetsOf(context);
    final goodAccessibleNavigation = MediaQuery.accessibleNavigationOf(context);
    final goodHighContrast = MediaQuery.highContrastOf(context);
    final goodDisableAnimations = MediaQuery.disableAnimationsOf(context);
    final goodInvertColors = MediaQuery.invertColorsOf(context);
    final goodBoldText = MediaQuery.boldTextOf(context);

    // ✅ Good: Direct property access from already obtained MediaQuery
    final mediaQuery = MediaQuery.of(context);
    final indirectSize = mediaQuery.size; // Should not trigger lint
    final indirectPadding = mediaQuery.padding; // Should not trigger lint

    // ❌ Bad: Chained calls
    final chainedWidth = MediaQuery.of(context).size.width; // LINT
    final chainedHeight = MediaQuery.of(context).size.height; // LINT

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text('Screen size: ${size.width} x ${size.height}'),
          Text('Orientation: $orientation'),
          Text('Device pixel ratio: $devicePixelRatio'),
          Text('Platform brightness: $platformBrightness'),
        ],
      ),
    );
  }

  void otherMethod(BuildContext context) {
    // ❌ Bad: Various patterns that should trigger lint
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      // LINT
      print('Portrait mode');
    }

    switch (MediaQuery.of(context).platformBrightness) {
      // LINT
      case Brightness.light:
        print('Light theme');
        break;
      case Brightness.dark:
        print('Dark theme');
        break;
    }

    // ❌ Bad: In expressions
    final isSmallScreen = MediaQuery.of(context).size.width < 600; // LINT
    final hasNotch = MediaQuery.of(context).viewPadding.top > 20; // LINT

    // ✅ Good: Using direct methods
    final goodIsSmallScreen = MediaQuery.sizeOf(context).width < 600;
    final goodHasNotch = MediaQuery.viewPaddingOf(context).top > 20;
  }
}
