import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_inputs.dart';

import '../../../../../helpers/widget_test_helper.dart';

void main() {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  setUp(() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
  });

  tearDown(() {
    emailController.dispose();
    passwordController.dispose();
  });

  Widget build({bool enabled = true, VoidCallback? onForgotPassword}) {
    return makeTestableWidget(Scaffold(
      body: Form(
        child: LoginInputs(
          emailInputController: emailController,
          passwordInputController: passwordController,
          onForgotPassword: onForgotPassword ?? () {},
          enabled: enabled,
        ),
      ),
    ));
  }

  TextFormField emailField(WidgetTester tester) =>
      tester.widget<TextFormField>(find.byType(TextFormField).first);
  TextFormField passwordField(WidgetTester tester) =>
      tester.widget<TextFormField>(find.byType(TextFormField).last);

  group('LoginInputs', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should use provided controllers', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Assert
      expect(emailField(tester).controller, emailController);
      expect(passwordField(tester).controller, passwordController);
    });

    testWidgets('should show the labels', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should show forgot password next to the password label', (tester) async {
      // Arrange
      var forgotCalled = false;
      await tester.pumpWidget(build(onForgotPassword: () => forgotCalled = true));

      // Act
      final labelY = tester.getCenter(find.text('Password')).dy;
      final linkY = tester.getCenter(find.text('Forgot it?')).dy;
      await tester.tap(find.text('Forgot it?'));

      // Assert
      expect((labelY - linkY).abs(), lessThan(8));
      expect(forgotCalled, true);
    });

    // ==================== PASSWORD VISIBILITY TESTS ====================

    testWidgets('should obscure password by default', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Assert
      expect(find.byIcon(Symbols.visibility_off_rounded), findsOneWidget);
      expect(find.byTooltip('Show password'), findsOneWidget);
    });

    testWidgets('should toggle password visibility when icon is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Act
      await tester.tap(find.byIcon(Symbols.visibility_off_rounded));
      await tester.pump();

      // Assert
      expect(find.byIcon(Symbols.visibility_rounded), findsOneWidget);
      expect(find.byTooltip('Hide password'), findsOneWidget);
    });

    testWidgets('should toggle password visibility back to hidden', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Act
      await tester.tap(find.byIcon(Symbols.visibility_off_rounded));
      await tester.pump();
      await tester.tap(find.byIcon(Symbols.visibility_rounded));
      await tester.pump();

      // Assert
      expect(find.byIcon(Symbols.visibility_off_rounded), findsOneWidget);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    testWidgets('should validate empty email', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Act
      final result = emailField(tester).validator!('');

      // Assert
      expect(result, 'Please enter an email address');
    });

    testWidgets('should validate email without @', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Act
      final result = emailField(tester).validator!('test.example.com');

      // Assert
      expect(result, 'The email format is invalid.');
    });

    testWidgets('should validate email without dot', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Act
      final result = emailField(tester).validator!('test@example');

      // Assert
      expect(result, 'The email format is invalid.');
    });

    testWidgets('should accept valid email', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Act
      final result = emailField(tester).validator!('test@example.com');

      // Assert
      expect(result, isNull);
    });

    testWidgets('should validate empty password', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Act
      final result = passwordField(tester).validator!('');

      // Assert
      expect(result, 'Please enter a password');
    });

    testWidgets('should accept non-empty password', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Act
      final result = passwordField(tester).validator!('password123');

      // Assert
      expect(result, isNull);
    });

    // ==================== EDGE CASE TESTS ====================

    testWidgets('should disable fields and the forgot link when enabled is false', (tester) async {
      // Arrange
      await tester.pumpWidget(build(enabled: false));

      // Act
      final forgot = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Forgot it?'));

      // Assert
      expect(emailField(tester).enabled, false);
      expect(passwordField(tester).enabled, false);
      expect(forgot.onPressed, isNull);
    });

    testWidgets('should enable fields by default', (tester) async {
      // Arrange
      await tester.pumpWidget(build());

      // Assert
      expect(emailField(tester).enabled, true);
      expect(passwordField(tester).enabled, true);
    });
  });
}
