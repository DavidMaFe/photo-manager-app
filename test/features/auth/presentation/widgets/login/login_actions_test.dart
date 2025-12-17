import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_actions.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {

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
      home: Scaffold(
        body: Column(
          children: [child],
        ),
      ),
    );
  }

  group('LoginActions', () {
    testWidgets('should call onLogin when login button is tapped', (tester) async {
      // Arrange
      var loginCalled = false;
      await tester.pumpWidget(makeTestableWidget(
        LoginActions(
          onLogin: () => loginCalled = true,
          onForgotPassword: () {},
          onRegister: () {},
        ),
      ));

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(loginCalled, true);
    });

    testWidgets('should call onForgotPassword when button is tapped', (tester) async {
      // Arrange
      var forgotPasswordCalled = false;
      await tester.pumpWidget(makeTestableWidget(
        LoginActions(
          onLogin: () {},
          onForgotPassword: () => forgotPasswordCalled = true,
          onRegister: () {},
        ),
      ));

      // Act
      await tester.tap(find.text('Forgot your password?'));
      await tester.pump();

      // Assert
      expect(forgotPasswordCalled, true);
    });

    testWidgets('should call onRegister when register button is tapped', (tester) async {
      // Arrange
      var registerCalled = false;
      await tester.pumpWidget(makeTestableWidget(
        LoginActions(
          onLogin: () {},
          onForgotPassword: () {},
          onRegister: () => registerCalled = true,
        ),
      ));

      // Act
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Assert
      expect(registerCalled, true);
    });

    testWidgets('should show loading indicator when isLoading is true', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginActions(
          onLogin: () {},
          onForgotPassword: () {},
          onRegister: () {},
          isLoading: true,
        ),
      ));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('should disable login button when loading', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginActions(
          onLogin: () {},
          onForgotPassword: () {},
          onRegister: () {},
          isLoading: true,
        ),
      ));

      // Assert
      final loginButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(loginButton.onPressed, isNull);
    });

    testWidgets('should disable forgot password button when loading', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginActions(
          onLogin: () {},
          onForgotPassword: () {},
          onRegister: () {},
          isLoading: true,
        ),
      ));

      // Assert
      final forgotPasswordButtons = tester.widgetList<TextButton>(find.byType(TextButton));
      final forgotPasswordButton = forgotPasswordButtons.first;
      expect(forgotPasswordButton.onPressed, isNull);
    });

    testWidgets('should disable register button when loading', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginActions(
          onLogin: () {},
          onForgotPassword: () {},
          onRegister: () {},
          isLoading: true,
        ),
      ));

      // Assert
      final textButtons = tester.widgetList<TextButton>(find.byType(TextButton));
      final registerButton = textButtons.last;
      expect(registerButton.onPressed, isNull);
    });

    testWidgets('should enable all buttons when not loading', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginActions(
          onLogin: () {},
          onForgotPassword: () {},
          onRegister: () {},
          isLoading: false,
        ),
      ));

      // Assert
      final loginButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(loginButton.onPressed, isNotNull);

      final textButtons = tester.widgetList<TextButton>(find.byType(TextButton)).toList();
      expect(textButtons[0].onPressed, isNotNull); // Forgot password
      expect(textButtons[1].onPressed, isNotNull); // Register
    });

    testWidgets('should have Expanded as parent widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(
        LoginActions(
          onLogin: () {},
          onForgotPassword: () {},
          onRegister: () {},
        ),
      ));

      // Assert
      expect(find.byType(Expanded), findsOneWidget);
    });
  });
}
