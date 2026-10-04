import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/step_indicator.dart';

import '../../../../../helpers/widget_test_helper.dart';

void main() {
  group('StepIndicator', () {
    testWidgets('should paint completed steps in accent and pending ones in line', (tester) async {
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
        body: Center(child: StepIndicator(current: 2, total: 3, semanticLabel: 'Step 2 of 3')),
      )));

      // Act
      final colors = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((c) => (c.decoration as BoxDecoration).color)
          .toList();

      // Assert
      expect(colors, [AppPalette.light.accent, AppPalette.light.accent, AppPalette.light.line]);
      expect(find.bySemanticsLabel('Step 2 of 3'), findsOneWidget);
    });
  });
}
