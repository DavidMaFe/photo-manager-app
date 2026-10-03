import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  const p = AppPalette.light;

  Material buttonMaterial(WidgetTester tester) => tester.widget<Material>(
        find.descendant(of: find.byType(AppButton), matching: find.byType(Material)).first,
      );

  group('AppButton', () {
    group('variants', () {
      final cases = {
        AppButtonVariant.primary: p.accent,
        AppButtonVariant.secondary: p.accentSoft,
        AppButtonVariant.neutral: p.surface2,
        AppButtonVariant.inverse: p.ink,
        AppButtonVariant.danger: p.dangerSoft,
      };
      cases.forEach((variant, background) {
        testWidgets('should paint the $variant background from the palette', (tester) async {
          // Arrange
          await tester.pumpWidget(makeTestableWidget(Scaffold(
            body: AppButton(label: 'Go', variant: variant, onPressed: () {}),
          )));

          // Act
          final material = buttonMaterial(tester);

          // Assert
          expect(material.color, background);
        });
      });
    });

    group('size', () {
      testWidgets('should be 54 high and full width when large', (tester) async {
        // Arrange
        await tester.pumpWidget(makeTestableWidget(Scaffold(
          body: Center(child: AppButton.primary(label: 'Go', onPressed: () {})),
        )));

        // Act
        final size = tester.getSize(find.byType(AppButton));

        // Assert
        expect(size.height, AppButton.largeHeight);
        expect(size.width, 800);
      });

      testWidgets('should be 36 high and wrap content when small', (tester) async {
        // Arrange
        await tester.pumpWidget(makeTestableWidget(Scaffold(
          body: Center(
            child: AppButton.neutral(label: 'Go', size: AppButtonSize.small, onPressed: () {}),
          ),
        )));

        // Act
        final size = tester.getSize(find.byType(AppButton));

        // Assert
        expect(size.height, AppButton.smallHeight);
        expect(size.width, lessThan(200));
      });
    });

    group('interaction', () {
      testWidgets('should call onPressed when tapped', (tester) async {
        // Arrange
        var taps = 0;
        await tester.pumpWidget(makeTestableWidget(Scaffold(
          body: AppButton.primary(label: 'Go', onPressed: () => taps++),
        )));

        // Act
        await tester.tap(find.text('Go'));

        // Assert
        expect(taps, 1);
      });

      testWidgets('should show a spinner and ignore taps while loading', (tester) async {
        // Arrange
        var taps = 0;
        await tester.pumpWidget(makeTestableWidget(Scaffold(
          body: AppButton.primary(label: 'Go', loading: true, onPressed: () => taps++),
        )));

        // Act
        await tester.tap(find.byType(AppButton));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Go'), findsNothing);
        expect(taps, 0);
      });

      testWidgets('should be dimmed when disabled', (tester) async {
        // Arrange
        await tester.pumpWidget(makeTestableWidget(const Scaffold(
          body: AppButton.primary(label: 'Go', onPressed: null),
        )));

        // Act
        final opacity = tester.widget<Opacity>(
          find.descendant(of: find.byType(AppButton), matching: find.byType(Opacity)),
        );

        // Assert
        expect(opacity.opacity, AppButton.disabledOpacity);
      });

      testWidgets('should render the leading icon', (tester) async {
        // Arrange
        await tester.pumpWidget(makeTestableWidget(Scaffold(
          body: AppButton.primary(label: 'Sync', icon: Icons.sync, onPressed: () {}),
        )));

        // Assert
        expect(find.byIcon(Icons.sync), findsOneWidget);
      });
    });
  });
}
