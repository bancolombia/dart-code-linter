import 'cross_library_base.dart';

class TimerPoller extends Poller {
  // Overrides `Poller.poll` from another library, without the annotation. Only
  // the supertype walk can tell that dispatch reaches this declaration through
  // `Poller.poll`.
  // ignore: annotate_overrides
  void poll() {}

  void unusedInSubclass() {}
}

void main() {
  final Poller poller = TimerPoller();

  poller.poll();
}
