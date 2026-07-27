// Flagged: NavigationDelegate configured on a widget-supplied controller,
// but none of its named callbacks reference any field of `widget` — the
// behavior is fully hardcoded, with no way for callers of this widget to
// customize it.
class BcWebviewTemplate extends StatefulWidget {
  const BcWebviewTemplate({required this.webviewController});

  final WebViewController webviewController;

  @override
  State<BcWebviewTemplate> createState() => _BcWebviewTemplateState();
}

class _BcWebviewTemplateState extends State<BcWebviewTemplate> {
  @override
  void initState() {
    super.initState();

    widget.webviewController.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (error) {},
        onNavigationRequest: (request) => NavigationDecision.navigate,
      ),
    );
  }
}

// Not flagged: at least one callback references a widget field, so callers
// have some way to customize the behavior.
class PartiallyConfigurableWebview extends StatefulWidget {
  const PartiallyConfigurableWebview({
    required this.webviewController,
    this.onError,
  });

  final WebViewController webviewController;
  final Function? onError;

  @override
  State<PartiallyConfigurableWebview> createState() =>
      _PartiallyConfigurableWebviewState();
}

class _PartiallyConfigurableWebviewState
    extends State<PartiallyConfigurableWebview> {
  @override
  void initState() {
    super.initState();

    widget.webviewController.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (error) => widget.onError?.call(),
        onNavigationRequest: (request) => NavigationDecision.navigate,
      ),
    );
  }
}

// Not flagged: the configured object isn't a field of `widget`.
class LocalControllerWebview extends StatefulWidget {
  @override
  State<LocalControllerWebview> createState() =>
      _LocalControllerWebviewState();
}

class _LocalControllerWebviewState extends State<LocalControllerWebview> {
  final controller = WebViewController();

  @override
  void initState() {
    super.initState();

    controller.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (error) {},
        onNavigationRequest: (request) => NavigationDecision.navigate,
      ),
    );
  }
}

// Not flagged: the hardcoded configuration happens outside initState.
class BuildTimeConfigurationWebview extends StatefulWidget {
  const BuildTimeConfigurationWebview({required this.webviewController});

  final WebViewController webviewController;

  @override
  State<BuildTimeConfigurationWebview> createState() =>
      _BuildTimeConfigurationWebviewState();
}

class _BuildTimeConfigurationWebviewState
    extends State<BuildTimeConfigurationWebview> {
  void configure() {
    widget.webviewController.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (error) {},
        onNavigationRequest: (request) => NavigationDecision.navigate,
      ),
    );
  }

  @override
  Widget build() => Widget();
}

class State<T> {}

class Widget {}

class WebViewController {
  void setNavigationDelegate(NavigationDelegate delegate) {}
}

class NavigationDelegate {
  const NavigationDelegate({this.onWebResourceError, this.onNavigationRequest});

  final Function? onWebResourceError;
  final Function? onNavigationRequest;
}

class NavigationDecision {
  static const navigate = NavigationDecision();
  const NavigationDecision();
}

// Flagged twice: two widget-supplied controllers are each configured with a
// fully hardcoded callback object in the same initState.
class DoubleConfigurationWebview extends StatefulWidget {
  const DoubleConfigurationWebview({
    required this.firstController,
    required this.secondController,
  });

  final WebViewController firstController;
  final WebViewController secondController;

  @override
  State<DoubleConfigurationWebview> createState() =>
      _DoubleConfigurationWebviewState();
}

class _DoubleConfigurationWebviewState
    extends State<DoubleConfigurationWebview> {
  @override
  void initState() {
    super.initState();

    widget.firstController.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (error) {},
      ),
    );
    widget.secondController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) => NavigationDecision.navigate,
      ),
    );
  }
}

// Not flagged: the named arguments are plain values, not callbacks, so this
// is not a hardcoded callback configuration.
class ValueConfigurationWebview extends StatefulWidget {
  const ValueConfigurationWebview({required this.controller});

  final ConfigurableController controller;

  @override
  State<ValueConfigurationWebview> createState() =>
      _ValueConfigurationWebviewState();
}

class _ValueConfigurationWebviewState
    extends State<ValueConfigurationWebview> {
  @override
  void initState() {
    super.initState();

    widget.controller.configure(Options(timeout: 5));
  }
}

class ConfigurableController {
  void configure(Options options) {}
}

class Options {
  const Options({this.timeout});

  final int? timeout;
}

// Not flagged: the callback is a tear-off of a State method whose body reads
// a widget field, so callers can customize the behavior.
class TearOffWebview extends StatefulWidget {
  const TearOffWebview({required this.webviewController, this.onError});

  final WebViewController webviewController;
  final Function? onError;

  @override
  State<TearOffWebview> createState() => _TearOffWebviewState();
}

class _TearOffWebviewState extends State<TearOffWebview> {
  @override
  void initState() {
    super.initState();

    widget.webviewController.setNavigationDelegate(
      NavigationDelegate(onWebResourceError: _handleError),
    );
  }

  void _handleError(Object error) {
    widget.onError?.call();
  }
}

// Flagged: the tear-off method is itself fully hardcoded; nothing in the
// configuration reaches the widget's fields.
class HardcodedTearOffWebview extends StatefulWidget {
  const HardcodedTearOffWebview({required this.webviewController});

  final WebViewController webviewController;

  @override
  State<HardcodedTearOffWebview> createState() =>
      _HardcodedTearOffWebviewState();
}

class _HardcodedTearOffWebviewState extends State<HardcodedTearOffWebview> {
  @override
  void initState() {
    super.initState();

    widget.webviewController.setNavigationDelegate(
      NavigationDelegate(onWebResourceError: _logError),
    );
  }

  void _logError(Object error) {
    print(error);
  }
}

// Not flagged: the tear-off reaches a widget field transitively through
// another method of the same State class.
class TransitiveTearOffWebview extends StatefulWidget {
  const TransitiveTearOffWebview({
    required this.webviewController,
    this.onError,
  });

  final WebViewController webviewController;
  final Function? onError;

  @override
  State<TransitiveTearOffWebview> createState() =>
      _TransitiveTearOffWebviewState();
}

class _TransitiveTearOffWebviewState extends State<TransitiveTearOffWebview> {
  @override
  void initState() {
    super.initState();

    widget.webviewController.setNavigationDelegate(
      NavigationDelegate(onWebResourceError: _handleError),
    );
  }

  void _handleError(Object error) {
    _notify();
  }

  void _notify() {
    widget.onError?.call();
  }
}

// Not flagged (conservative): the callback resolves outside this State class,
// so its body cannot be inspected within this rule.
class ExternalTearOffWebview extends StatefulWidget {
  const ExternalTearOffWebview({required this.webviewController});

  final WebViewController webviewController;

  @override
  State<ExternalTearOffWebview> createState() =>
      _ExternalTearOffWebviewState();
}

class _ExternalTearOffWebviewState extends State<ExternalTearOffWebview> {
  @override
  void initState() {
    super.initState();

    widget.webviewController.setNavigationDelegate(
      NavigationDelegate(onWebResourceError: logGlobalError),
    );
  }
}

void logGlobalError(Object error) {}
