import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/edit_profile/password_change_section.dart';

import '../../../../../helpers/widget_test_helper.dart';

void main() {
  late TextEditingController current;
  late TextEditingController next;
  late TextEditingController confirm;

  setUp(() {
    current = TextEditingController();
    next = TextEditingController();
    confirm = TextEditingController();
  });

  tearDown(() {
    current.dispose();
    next.dispose();
    confirm.dispose();
  });

  Future<void> pump(WidgetTester tester) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(
      body: SingleChildScrollView(
        child: Form(
          child: PasswordChangeSection(
            currentPasswordController: current,
            newPasswordController: next,
            confirmPasswordController: confirm,
          ),
        ),
      ),
    )));
  }

  FormFieldValidator<String> validatorAt(WidgetTester tester, int index) =>
      tester.widget<TextFormField>(find.byType(TextFormField).at(index)).validator!;

  group('PasswordChangeSection', () {
    testWidgets('should explain that the fields are optional', (tester) async {
      // Arrange & Act
      await pump(tester);

      // Assert
      expect(find.text("Leave it blank if you don't want to change it"), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('should accept everything empty', (tester) async {
      // Arrange
      await pump(tester);

      // Assert
      for (var i = 0; i < 3; i++) {
        expect(validatorAt(tester, i)(''), isNull);
      }
    });

    testWidgets('should require the current password once a new one is typed', (tester) async {
      // Arrange
      await pump(tester);

      // Act
      next.text = 'newpass';

      // Assert
      expect(validatorAt(tester, 0)(''), isNotNull);
      expect(validatorAt(tester, 2)(''), isNotNull);
      expect(validatorAt(tester, 2)('other'), 'Passwords do not match');
      expect(validatorAt(tester, 2)('newpass'), isNull);
    });

    testWidgets('should require the new password once the current one is typed', (tester) async {
      // Arrange
      await pump(tester);

      // Act
      current.text = 'oldpass';

      // Assert
      expect(validatorAt(tester, 1)(''), isNotNull);
    });

    testWidgets('should toggle each field visibility independently', (tester) async {
      // Arrange
      await pump(tester);
      expect(find.byIcon(Symbols.visibility_off_rounded), findsNWidgets(3));

      // Act
      await tester.tap(find.byIcon(Symbols.visibility_off_rounded).first);
      await tester.pump();

      // Assert
      expect(find.byIcon(Symbols.visibility_rounded), findsOneWidget);
      expect(find.byIcon(Symbols.visibility_off_rounded), findsNWidgets(2));
    });
  });
}
