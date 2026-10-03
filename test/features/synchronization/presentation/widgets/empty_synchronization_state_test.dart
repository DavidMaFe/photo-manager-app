import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/empty_synchronization_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget buildTestWidget() {
    return const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('es'),
      ],
      home: Scaffold(
        body: EmptySynchronizationState(),
      ),
    );
  }

  group('EmptySynchronizationState', () {
    testWidgets('should display empty state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(EmptySynchronizationState), findsOneWidget);
    });

    testWidgets('should display sync disabled icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byIcon(Icons.sync_disabled), findsOneWidget);
    });

    testWidgets('should display icon in circular container', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(EmptySynchronizationState),
          matching: find.byType(Container),
        ),
      );

      final circularContainer = containers.firstWhere(
        (container) => (container.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(circularContainer, isNotNull);
    });

    testWidgets('should have gray background for icon container', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(EmptySynchronizationState),
          matching: find.byType(Container),
        ),
      );

      final circularContainer = containers.firstWhere(
        (container) => (container.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(
        (circularContainer.decoration as BoxDecoration).color,
        AppPalette.light.surface2,
      );
    });

    testWidgets('should display centered content', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final centerWidgets = find.descendant(
        of: find.byType(EmptySynchronizationState),
        matching: find.byType(Center),
      );
      expect(centerWidgets, findsAtLeastNWidgets(1));
    });

    testWidgets('should display column with content', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final columnWidgets = find.descendant(
        of: find.byType(EmptySynchronizationState),
        matching: find.byType(Column),
      );
      expect(columnWidgets, findsAtLeastNWidgets(1));
    });

    testWidgets('should have proper spacing', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final sizedBoxes = find.descendant(
        of: find.byType(EmptySynchronizationState),
        matching: find.byType(SizedBox),
      );
      // At least 2 for spacing
      expect(sizedBoxes, findsAtLeastNWidgets(2));
    });

    testWidgets('should be centered in main axis', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final columnFinder = find.descendant(
        of: find.byType(EmptySynchronizationState),
        matching: find.byType(Column),
      );
      final column = tester.widget<Column>(columnFinder);

      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });
  });
}
