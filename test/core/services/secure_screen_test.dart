import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/services/secure_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(SecureScreen.channelName);
  late List<String> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return null;
    });
  });

  tearDown(() =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

  group('SecureScreen', () {
    test('should ask the platform to protect the window and to stop', () async {
      final secureScreen = SecureScreen(enabled: true);

      await secureScreen.enable();
      await secureScreen.disable();

      expect(calls, ['enable', 'disable']);
    });

    test('should do nothing where it is not enabled', () async {
      final secureScreen = SecureScreen(enabled: false);

      await secureScreen.enable();
      await secureScreen.disable();

      expect(calls, isEmpty);
    });

    test('should not fail when the platform has no channel', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);

      await expectLater(SecureScreen(enabled: true).enable(), completes);
    });

    test('should not fail when the platform answers an error', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
          channel, (_) async => throw PlatformException(code: 'error'));

      await expectLater(SecureScreen(enabled: true).enable(), completes);
    });
  });
}
