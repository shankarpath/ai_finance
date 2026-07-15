import 'package:flutter/foundation.dart';

/// Tiny app-wide navigation signal bus. Notification taps land here (the
/// notification callback has no BuildContext); HomeShell listens and switches
/// tabs.
class NavBus {
  NavBus._();

  /// Incremented every time something asks to open the Coach tab.
  static final coachRequests = ValueNotifier<int>(0);

  static void openCoach() => coachRequests.value++;
}
