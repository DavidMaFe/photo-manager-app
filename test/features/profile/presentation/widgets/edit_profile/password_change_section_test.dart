import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/password_change_section.dart';
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
        body: Form(
          child: child,
        ),
      ),
    );
  }

  group('PasswordChangeSection', () {
    late TextEditingController currentPasswordController;
    late TextEditingController newPasswordController;
    late TextEditingController confirmPasswordController;

    setUp(() {
      currentPasswordController = TextEditingController();
      newPasswordController = TextEditingController();
      confirmPasswordController = TextEditingController();
    });

    tearDown(() {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    });

    testWidgets('should display section title', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Assert
      expect(find.text('Change password'), findsOneWidget);
    });

    testWidgets('should display hint about leaving password empty',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Assert
      expect(
          find.text('Leave blank if you don\'t want to change the password'),
          findsOneWidget);
    });

    testWidgets('should display all password field labels', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Assert
      expect(find.text('Current password'), findsOneWidget);
      expect(find.text('New password'), findsOneWidget);
      expect(find.text('Confirm new password'), findsOneWidget);
    });

    testWidgets('should display three password fields', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('should obscure password text by default', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Assert - All fields should be obscured
      final textFields = tester.widgetList<TextField>(find.byType(TextField));
      for (final field in textFields) {
        expect(field.obscureText, true);
      }
    });

    testWidgets('should have visibility toggle icons for all fields',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Assert
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
    });

    testWidgets('should toggle current password visibility', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Get first visibility toggle icon (current password)
      final toggleButtons = find.byIcon(Icons.visibility_off);

      // Tap the first toggle button
      await tester.tap(toggleButtons.first);
      await tester.pump();

      // Assert - First field should now show visibility icon, others still visibility_off
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('should toggle new password visibility', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Get second visibility toggle icon (new password)
      final toggleButtons = find.byIcon(Icons.visibility_off);

      // Tap the second toggle button
      await tester.tap(toggleButtons.at(1));
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('should toggle confirm password visibility', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Get third visibility toggle icon (confirm password)
      final toggleButtons = find.byIcon(Icons.visibility_off);

      // Tap the third toggle button
      await tester.tap(toggleButtons.at(2));
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('should allow text input in all fields', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Enter text in current password field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Your current password').first,
        'oldPass123',
      );

      // Enter text in new password field
      final newPasswordFields = find.widgetWithText(TextFormField, '*********');
      await tester.enterText(newPasswordFields.first, 'newPass456');

      // Enter text in confirm password field
      await tester.enterText(newPasswordFields.last, 'newPass456');

      // Assert
      expect(currentPasswordController.text, 'oldPass123');
      expect(newPasswordController.text, 'newPass456');
      expect(confirmPasswordController.text, 'newPass456');
    });

    testWidgets('should not validate when all fields are empty', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Validate form
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      await tester.pump();

      // Assert - Should be valid when all empty (smart validation)
      expect(isValid, true);
      expect(find.text('Current password is required'), findsNothing);
    });

    testWidgets(
        'should validate current password required when new password entered',
        (tester) async {
      // Arrange
      newPasswordController.text = 'newPass123';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Validate form
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      await tester.pump();

      // Assert
      expect(isValid, false);
      expect(find.text('Current password is required'), findsOneWidget);
    });

    testWidgets(
        'should validate current password required when confirm password entered',
        (tester) async {
      // Arrange
      confirmPasswordController.text = 'newPass123';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Validate form
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      await tester.pump();

      // Assert
      expect(isValid, false);
      expect(find.text('Current password is required'), findsOneWidget);
    });

    testWidgets('should validate new password required when current password entered',
        (tester) async {
      // Arrange
      currentPasswordController.text = 'oldPass123';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Validate form
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      await tester.pump();

      // Assert
      expect(isValid, false);
      expect(find.text('New password is required'), findsOneWidget);
    });

    testWidgets('should validate confirm password required when new password entered',
        (tester) async {
      // Arrange
      currentPasswordController.text = 'oldPass123';
      newPasswordController.text = 'newPass456';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Validate form
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      await tester.pump();

      // Assert
      expect(isValid, false);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('should validate passwords match', (tester) async {
      // Arrange
      currentPasswordController.text = 'oldPass123';
      newPasswordController.text = 'newPass456';
      confirmPasswordController.text = 'differentPass';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Validate form
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      await tester.pump();

      // Assert
      expect(isValid, false);
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('should pass validation when all passwords are correct',
        (tester) async {
      // Arrange
      currentPasswordController.text = 'oldPass123';
      newPasswordController.text = 'newPass456';
      confirmPasswordController.text = 'newPass456';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Validate form
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();
      await tester.pump();

      // Assert
      expect(isValid, true);
      expect(find.text('Current password is required'), findsNothing);
      expect(find.text('New password is required'), findsNothing);
      expect(find.text('Confirm password is required'), findsNothing);
      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('should respect enabled parameter when true', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
          enabled: true,
        ),
      ));

      // Assert
      final textFormFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      for (final field in textFormFields) {
        expect(field.enabled, true);
      }
    });

    testWidgets('should respect enabled parameter when false', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
          enabled: false,
        ),
      ));

      // Assert
      final textFormFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      for (final field in textFormFields) {
        expect(field.enabled, false);
      }
    });

    testWidgets('should use provided controllers', (tester) async {
      // Arrange
      currentPasswordController.text = 'current';
      newPasswordController.text = 'new';
      confirmPasswordController.text = 'confirm';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Assert
      expect(currentPasswordController.text, 'current');
      expect(newPasswordController.text, 'new');
      expect(confirmPasswordController.text, 'confirm');
    });

    testWidgets('should toggle multiple password fields independently',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Toggle first field
      final toggleButtons = find.byIcon(Icons.visibility_off);
      await tester.tap(toggleButtons.first);
      await tester.pump();

      // Toggle second field
      await tester.tap(find.byIcon(Icons.visibility_off).first);
      await tester.pump();

      // Assert - Two fields should be visible now
      expect(find.byIcon(Icons.visibility), findsNWidgets(2));
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should toggle password visibility back to obscured',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        PasswordChangeSection(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
        ),
      ));

      // Toggle first field to visible
      final toggleButtons = find.byIcon(Icons.visibility_off);
      await tester.tap(toggleButtons.first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Toggle back to obscured
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Assert - Should be back to all obscured
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(3));
      expect(find.byIcon(Icons.visibility), findsNothing);
    });
  });
}
