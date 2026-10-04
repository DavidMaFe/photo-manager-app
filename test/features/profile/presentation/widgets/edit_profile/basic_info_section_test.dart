import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/basic_info_section.dart';

import '../../../../../helpers/widget_test_helper.dart';

void main() {
  late TextEditingController name;
  late TextEditingController surname;

  setUp(() {
    name = TextEditingController(text: 'Ana');
    surname = TextEditingController();
  });

  tearDown(() {
    name.dispose();
    surname.dispose();
  });

  Future<void> pump(WidgetTester tester, {bool enabled = true}) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(
      body: Form(child: BasicInfoSection(nameController: name, surnameController: surname, enabled: enabled)),
    )));
  }

  group('BasicInfoSection', () {
    testWidgets('should show the name and optional last name fields', (tester) async {
      // Arrange & Act
      await pump(tester);

      // Assert
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Last name (optional)', findRichText: true), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should require the name', (tester) async {
      // Arrange
      await pump(tester);
      final field = tester.widget<TextFormField>(find.byType(TextFormField).first);

      // Act & Assert
      expect(field.validator!('  '), 'Name is required');
      expect(field.validator!('Ana'), isNull);
    });

    testWidgets('should not require the last name', (tester) async {
      // Arrange
      await pump(tester);

      // Act
      final field = tester.widget<TextFormField>(find.byType(TextFormField).last);

      // Assert
      expect(field.validator, isNull);
    });

    testWidgets('should disable fields while saving', (tester) async {
      // Arrange & Act
      await pump(tester, enabled: false);

      // Assert
      final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      expect(fields.every((f) => f.enabled == false), isTrue);
    });
  });
}
