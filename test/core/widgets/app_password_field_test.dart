import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/app_password_field.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  group('AppPasswordField', () {
    testWidgets('should obscure the text until the eye is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        body: AppPasswordField(label: 'Password', showTooltip: 'Show', hideTooltip: 'Hide'),
      )));
      bool obscured() => tester.widget<TextField>(find.byType(TextField)).obscureText;
      expect(obscured(), isTrue);

      // Act
      await tester.tap(find.byTooltip('Show'));
      await tester.pump();

      // Assert
      expect(obscured(), isFalse);
      expect(find.byIcon(Symbols.visibility_rounded), findsOneWidget);
    });
  });

  group('AppTextField labelNote', () {
    testWidgets('should render the note after the label', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        body: AppTextField(label: 'Last name', labelNote: '(optional)'),
      )));

      // Assert
      expect(find.text('Last name (optional)', findRichText: true), findsOneWidget);
    });
  });
}
