import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/basic_info_section.dart';
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

  group('BasicInfoSection', () {
    late TextEditingController nameController;
    late TextEditingController surnameController;

    setUp(() {
      nameController = TextEditingController();
      surnameController = TextEditingController();
    });

    tearDown(() {
      nameController.dispose();
      surnameController.dispose();
    });

    testWidgets('should display section title', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      expect(find.text('Basic information'), findsOneWidget);
    });

    testWidgets('should display name label and field', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      expect(find.text('Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'John'), findsOneWidget);
    });

    testWidgets('should display surname label and field', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      expect(find.text('Last Name (optional)'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Doe'), findsOneWidget);
    });

    testWidgets('should use provided name controller', (tester) async {
      // Arrange
      nameController.text = 'Jane';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'John'),
      );
      expect(nameField.controller?.text, 'Jane');
    });

    testWidgets('should use provided surname controller', (tester) async {
      // Arrange
      surnameController.text = 'Smith';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      final surnameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Doe'),
      );
      expect(surnameField.controller?.text, 'Smith');
    });

    testWidgets('should allow text input in name field', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Enter text in name field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'John'),
        'Jane',
      );

      // Assert
      expect(nameController.text, 'Jane');
    });

    testWidgets('should allow text input in surname field', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Enter text in surname field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Doe'),
        'Smith',
      );

      // Assert
      expect(surnameController.text, 'Smith');
    });

    testWidgets('should validate empty name field', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Get the form and validate
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();

      await tester.pump();

      // Assert
      expect(isValid, false);
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('should validate whitespace-only name', (tester) async {
      // Arrange
      nameController.text = '   ';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Get the form and validate
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();

      await tester.pump();

      // Assert
      expect(isValid, false);
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('should pass validation with valid name', (tester) async {
      // Arrange
      nameController.text = 'John';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Get the form and validate
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();

      await tester.pump();

      // Assert
      expect(isValid, true);
      expect(find.text('Name is required'), findsNothing);
    });

    testWidgets('surname field should not be required', (tester) async {
      // Arrange
      nameController.text = 'John';
      surnameController.text = '';

      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Get the form and validate
      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();

      await tester.pump();

      // Assert
      expect(isValid, true);
    });

    testWidgets('should have name field with text capitalization',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'John'),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.textCapitalization, TextCapitalization.words);
    });

    testWidgets('should have surname field with text capitalization',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Doe'),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.textCapitalization, TextCapitalization.words);
    });

    testWidgets('should have name field with name keyboard type',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'John'),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.keyboardType, TextInputType.name);
    });

    testWidgets('should have surname field with name keyboard type',
        (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      final textField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Doe'),
          matching: find.byType(TextField),
        ),
      );
      expect(textField.keyboardType, TextInputType.name);
    });

    testWidgets('should respect enabled parameter when true', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
          enabled: true,
        ),
      ));

      // Assert
      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'John'),
      );
      final surnameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Doe'),
      );

      expect(nameField.enabled, true);
      expect(surnameField.enabled, true);
    });

    testWidgets('should respect enabled parameter when false', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
          enabled: false,
        ),
      ));

      // Assert
      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'John'),
      );
      final surnameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Doe'),
      );

      expect(nameField.enabled, false);
      expect(surnameField.enabled, false);
    });

    testWidgets('should have two TextFormField widgets', (tester) async {
      // Act
      await tester.pumpWidget(makeTestableWidget(
        BasicInfoSection(
          nameController: nameController,
          surnameController: surnameController,
        ),
      ));

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });
}
