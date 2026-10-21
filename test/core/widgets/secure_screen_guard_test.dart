import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/services/secure_screen.dart';
import 'package:photo_manager_app/core/widgets/secure_screen_guard.dart';

class MockSecureScreen extends Mock implements SecureScreen {}

void main() {
  late MockSecureScreen secureScreen;

  setUp(() {
    secureScreen = MockSecureScreen();
    when(() => secureScreen.enable()).thenAnswer((_) async {});
    when(() => secureScreen.disable()).thenAnswer((_) async {});
  });

  group('SecureScreenGuard', () {
    testWidgets('should protect the screen while its child is shown', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SecureScreenGuard(secureScreen: secureScreen, child: const Text('the 24 words')),
      ));

      expect(find.text('the 24 words'), findsOneWidget);
      verify(() => secureScreen.enable()).called(1);
      verifyNever(() => secureScreen.disable());

      await tester.pumpWidget(const MaterialApp(home: Text('another page')));

      verify(() => secureScreen.disable()).called(1);
    });
  });
}
