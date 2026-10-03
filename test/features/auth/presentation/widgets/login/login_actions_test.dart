import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_actions.dart';

import '../../../../../helpers/widget_test_helper.dart';

void main() {
  Widget build({
    VoidCallback? onLogin,
    VoidCallback? onRegister,
    bool isLoading = false,
  }) {
    return makeTestableWidget(Scaffold(
      body: LoginActions(
        onLogin: onLogin ?? () {},
        onRegister: onRegister ?? () {},
        isLoading: isLoading,
      ),
    ));
  }

  group('LoginActions', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should call onLogin when login button is tapped', (tester) async {
      // Arrange
      var loginCalled = false;
      await tester.pumpWidget(build(onLogin: () => loginCalled = true));

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(loginCalled, true);
    });

    testWidgets('should call onRegister when create account is tapped', (tester) async {
      // Arrange
      var registerCalled = false;
      await tester.pumpWidget(build(onRegister: () => registerCalled = true));

      // Act
      await tester.tap(find.text('Create account'));
      await tester.pump();

      // Assert
      expect(registerCalled, true);
    });

    testWidgets('should show the sign in label and the no-account prompt', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Assert
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text("Don't have an account yet?"), findsOneWidget);
    });

    // ==================== LOADING STATE TESTS ====================

    testWidgets('should show loading indicator when isLoading is true', (tester) async {
      // Arrange
      await tester.pumpWidget(build(isLoading: true));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('should ignore login taps while loading', (tester) async {
      // Arrange
      var loginCalled = false;
      await tester.pumpWidget(build(isLoading: true, onLogin: () => loginCalled = true));

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isTrue);
      expect(loginCalled, false);
    });

    testWidgets('should disable register button when loading', (tester) async {
      // Arrange
      await tester.pumpWidget(build(isLoading: true));

      // Act
      final registerButton = tester.widget<TextButton>(find.byType(TextButton));

      // Assert
      expect(registerButton.onPressed, isNull);
    });

    testWidgets('should enable all buttons when not loading', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Act
      final loginButton = tester.widget<AppButton>(find.byType(AppButton));
      final registerButton = tester.widget<TextButton>(find.byType(TextButton));

      // Assert
      expect(loginButton.onPressed, isNotNull);
      expect(loginButton.loading, isFalse);
      expect(registerButton.onPressed, isNotNull);
    });
  });
}
