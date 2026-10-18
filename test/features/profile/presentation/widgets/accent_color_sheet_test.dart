import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_accent.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/accent_color_sheet.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  late ValueNotifier<AppAccent> accent;

  setUp(() => accent = ValueNotifier(AppAccent.violet));
  tearDown(() => accent.dispose());

  Future<void> pump(WidgetTester tester, {ThemeMode themeMode = ThemeMode.light}) async {
    await tester.pumpWidget(makeTestableWidget(
      Scaffold(body: AccentColorSheet(accent: accent, onChanged: (value) => accent.value = value)),
      themeMode: themeMode,
    ));
    await tester.pumpAndSettle();
  }

  group('AccentColorSheet', () {
    testWidgets('should show the five colors with their names', (tester) async {
      await pump(tester);

      expect(find.text('App color'), findsOneWidget);
      for (final name in ['Violet', 'Blue', 'Teal', 'Terracotta', 'Graphite']) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('should mark the chosen color', (tester) async {
      await pump(tester);

      expect(find.byIcon(Symbols.check_rounded), findsOneWidget);
      expect(tester.getSemantics(find.bySemanticsLabel('Violet')), containsSemantics(isSelected: true));
    });

    testWidgets('should apply a color when it is tapped', (tester) async {
      // Arrange
      await pump(tester);

      // Act
      await tester.tap(find.text('Graphite'));
      await tester.pumpAndSettle();

      // Assert
      expect(accent.value, AppAccent.graphite);
      expect(tester.getSemantics(find.bySemanticsLabel('Graphite')), containsSemantics(isSelected: true));
    });

    testWidgets('should show each color as it looks in the dark theme', (tester) async {
      // Arrange
      await pump(tester, themeMode: ThemeMode.dark);

      // Act
      final context = tester.element(find.byType(AccentColorSheet));

      // Assert
      expect(AccentColorSheet.swatchOf(context, AppAccent.blue), AppAccent.blue.colors.darkAccent);
    });
  });
}
