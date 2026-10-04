import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/theme_mode_sheet.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  group('ThemeModeSheet', () {
    testWidgets('should offer automatic, light and dark', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: ThemeModeSheet(selected: ThemeMode.system))));

      // Assert
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.byType(ListRow), findsNWidgets(3));
      expect(find.text('Automatic'), findsOneWidget);
      expect(find.text("Follows your phone's mode"), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('should mark the current mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(makeTestableWidget(const Scaffold(body: ThemeModeSheet(selected: ThemeMode.dark))));

      // Assert
      final darkRow = find.widgetWithText(ListRow, 'Dark');
      expect(find.descendant(of: darkRow, matching: find.byIcon(Symbols.check_circle_rounded)), findsOneWidget);
      expect(find.byIcon(Symbols.check_circle_rounded), findsOneWidget);
    });

    testWidgets('should return the chosen mode', (tester) async {
      // Arrange
      ThemeMode? chosen;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => chosen = await ThemeModeSheet.show(context, selected: ThemeMode.system),
            child: const Text('open'),
          ),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Assert
      expect(chosen, ThemeMode.dark);
    });

    test('should label every mode', () {
      // Arrange
      final l10n = lookupAppLocalizations(const Locale('en'));

      // Act & Assert
      expect(ThemeModeSheet.labelOf(ThemeMode.system, l10n), 'Automatic');
      expect(ThemeModeSheet.labelOf(ThemeMode.light, l10n), 'Light');
      expect(ThemeModeSheet.labelOf(ThemeMode.dark, l10n), 'Dark');
    });
  });
}
