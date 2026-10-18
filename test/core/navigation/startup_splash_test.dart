import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/navigation/startup_splash.dart';

/// What the splash listens to: whether the router already knows where the app opens.
class _StartRoute extends ChangeNotifier {
  bool resolved = false;

  void resolve(bool value) {
    resolved = value;
    notifyListeners();
  }
}

void main() {
  group('StartupSplash', () {
    late _StartRoute startRoute;
    late int releases;

    StartupSplash build({Duration timeout = StartupSplash.defaultTimeout}) => StartupSplash(
          changes: startRoute,
          isResolved: () => startRoute.resolved,
          release: () => releases++,
          timeout: timeout,
        );

    setUp(() {
      startRoute = _StartRoute();
      releases = 0;
    });

    tearDown(() => startRoute.dispose());

    test('should release the splash at once when the start route is already known', () {
      startRoute.resolved = true;
      final splash = build()..start();

      expect(releases, 1);
      expect(splash.isReleased, isTrue);
    });

    test('should keep the splash while the session is being checked', () async {
      final splash = build()..start();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(releases, 0);
      expect(splash.isReleased, isFalse);
    });

    test('should release the splash when the session check finishes', () {
      final splash = build()..start();

      startRoute.resolve(true);

      expect(releases, 1);
      expect(splash.isReleased, isTrue);
    });

    test('should ignore changes that do not resolve the start route', () {
      build().start();

      startRoute.resolve(false);

      expect(releases, 0);
    });

    test('should release the splash after the timeout when the check never finishes', () async {
      final splash = build(timeout: const Duration(milliseconds: 50))..start();

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(releases, 1);
      expect(splash.isReleased, isTrue);
    });

    test('should release the splash only once', () async {
      build(timeout: const Duration(milliseconds: 50)).start();

      startRoute
        ..resolve(true)
        ..resolve(false)
        ..resolve(true);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(releases, 1);
    });
  });
}
