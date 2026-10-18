import 'dart:async';

import 'package:flutter/foundation.dart';

/// Keeps the native splash on screen until the router knows where the app opens, so a user with a stored session
/// never sees the login page while the session is checked.
///
/// The app defers the first Flutter frame before `runApp`; the native splash stays until [release] lets it through.
/// It is released when [isResolved] becomes true (checked on every change of [changes]) or after [timeout], so a
/// slow or broken check never leaves the splash on screen.
class StartupSplash {
  static const defaultTimeout = Duration(seconds: 5);

  final Listenable changes;
  final bool Function() isResolved;
  final VoidCallback release;
  final Duration timeout;

  Timer? _timer;
  bool _released = false;

  StartupSplash({
    required this.changes,
    required this.isResolved,
    required this.release,
    this.timeout = defaultTimeout,
  });

  bool get isReleased => _released;

  void start() {
    if (isResolved()) {
      _finish();
      return;
    }
    changes.addListener(_onChange);
    _timer = Timer(timeout, _finish);
  }

  void _onChange() {
    if (isResolved()) _finish();
  }

  void _finish() {
    if (_released) return;
    _released = true;
    _timer?.cancel();
    changes.removeListener(_onChange);
    release();
  }
}
