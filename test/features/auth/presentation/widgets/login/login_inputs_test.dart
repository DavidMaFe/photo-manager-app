import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_inputs.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

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

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('LoginInputs', () {
    testWidgets('should use provided controllers', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginInputs(
          emailInputController: emailController,
          passwordInputController: passwordController,
        ),
      ));

      // Assert
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).last);

      expect(emailField.controller, emailController);
      expect(passwordField.controller, passwordController);
    });

    testWidgets('should obscure password by default', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginInputs(
          emailInputController: emailController,
          passwordInputController: passwordController,
        ),
      ));

      // Assert - visibility_off icon means password is obscured
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should toggle password visibility when icon is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        LoginInputs(
          emailInputController: emailController,
          passwordInputController: passwordController,
        ),
      ));

      // Act
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Assert - visibility icon means password is visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should toggle password visibility back to hidden', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        LoginInputs(
          emailInputController: emailController,
          passwordInputController: passwordController,
        ),
      ));

      // Act
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Assert - visibility_off icon means password is hidden
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should validate empty email', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        Form(
          child: LoginInputs(
            emailInputController: emailController,
            passwordInputController: passwordController,
          ),
        ),
      ));

      // Act
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final validationResult = emailField.validator!('');

      // Assert
      expect(validationResult, 'Please enter an email address');
    });

    testWidgets('should validate email without @', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        Form(
          child: LoginInputs(
            emailInputController: emailController,
            passwordInputController: passwordController,
          ),
        ),
      ));

      // Act
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final validationResult = emailField.validator!('testexample.com');

      // Assert
      expect(validationResult, 'The email format is invalid.');
    });

    testWidgets('should validate email without dot', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        Form(
          child: LoginInputs(
            emailInputController: emailController,
            passwordInputController: passwordController,
          ),
        ),
      ));

      // Act
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final validationResult = emailField.validator!('test@examplecom');

      // Assert
      expect(validationResult, 'The email format is invalid.');
    });

    testWidgets('should accept valid email', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        Form(
          child: LoginInputs(
            emailInputController: emailController,
            passwordInputController: passwordController,
          ),
        ),
      ));

      // Act
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final validationResult = emailField.validator!('test@example.com');

      // Assert
      expect(validationResult, isNull);
    });

    testWidgets('should validate empty password', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        Form(
          child: LoginInputs(
            emailInputController: emailController,
            passwordInputController: passwordController,
          ),
        ),
      ));

      // Act
      final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).last);
      final validationResult = passwordField.validator!('');

      // Assert
      expect(validationResult, 'Please enter a password');
    });

    testWidgets('should accept non-empty password', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(
        Form(
          child: LoginInputs(
            emailInputController: emailController,
            passwordInputController: passwordController,
          ),
        ),
      ));

      // Act
      final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).last);
      final validationResult = passwordField.validator!('password123');

      // Assert
      expect(validationResult, isNull);
    });

    testWidgets('should disable fields when enabled is false', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginInputs(
          emailInputController: emailController,
          passwordInputController: passwordController,
          enabled: false,
        ),
      ));

      // Assert
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).last);

      expect(emailField.enabled, false);
      expect(passwordField.enabled, false);
    });

    testWidgets('should enable fields by default', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginInputs(
          emailInputController: emailController,
          passwordInputController: passwordController,
        ),
      ));

      // Assert
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).last);

      expect(emailField.enabled, true);
      expect(passwordField.enabled, true);
    });

  });
}
