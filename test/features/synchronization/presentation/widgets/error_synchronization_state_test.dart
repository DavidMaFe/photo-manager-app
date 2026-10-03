import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/error_synchronization_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget buildTestWidget(String message, {VoidCallback? onRetry}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: Scaffold(
        body: ErrorSynchronizationState(
          message: message,
          onRetry: onRetry ?? () {},
        ),
      ),
    );
  }

  group('ErrorSynchronizationState', () {
    const testMessage = 'Test error message';

    testWidgets('should display error state', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

      expect(find.byType(ErrorSynchronizationState), findsOneWidget);
    });

    testWidgets('should display error icon', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('should display retry button', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));
      await tester.pump();

      // Check for button text instead of button type due to localization loading
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('should call onRetry when button tapped', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        buildTestWidget(testMessage, onRetry: () => retried = true),
      );
      await tester.pump();

      // Tap button via text finder due to localization loading
      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(retried, true);
    });

    testWidgets('should display refresh icon on button', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should display icon in circular container', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(ErrorSynchronizationState),
          matching: find.byType(Container),
        ),
      );

      final circularContainer = containers.firstWhere(
        (container) => (container.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(circularContainer, isNotNull);
    });

    testWidgets('should have red background for icon container', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(ErrorSynchronizationState),
          matching: find.byType(Container),
        ),
      );

      final circularContainer = containers.firstWhere(
        (container) => (container.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      expect(
        (circularContainer.decoration as BoxDecoration).color,
        AppPalette.light.dangerSoft,
      );
    });

    testWidgets('should display centered content', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

      final centerWidgets = find.descendant(
        of: find.byType(ErrorSynchronizationState),
        matching: find.byType(Center),
      );
      // Main Center widget + Center widgets from button implementation
      expect(centerWidgets, findsAtLeastNWidgets(1));
    });

    testWidgets('should display column with content', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

      final columnWidgets = find.descendant(
        of: find.byType(ErrorSynchronizationState),
        matching: find.byType(Column),
      );
      // Main Column widget
      expect(columnWidgets, findsAtLeastNWidgets(1));
    });

    testWidgets('should have proper spacing', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));
      await tester.pump();

      final sizedBoxes = find.descendant(
        of: find.byType(ErrorSynchronizationState),
        matching: find.byType(SizedBox),
      );
      // At least 3 for explicit spacing
      expect(sizedBoxes, findsAtLeastNWidgets(3));
    });

    testWidgets('should be centered in main axis', (tester) async {
      await tester.pumpWidget(buildTestWidget(testMessage));

      final columnFinder = find.descendant(
        of: find.byType(ErrorSynchronizationState),
        matching: find.byType(Column),
      );
      final column = tester.widget<Column>(columnFinder);

      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('should handle long error messages', (tester) async {
      const longMessage = 'This is a very long error message that should be displayed properly without causing any layout issues or overflow errors in the UI';

      await tester.pumpWidget(buildTestWidget(longMessage));

      expect(find.text(longMessage), findsOneWidget);
    });

    testWidgets('should handle empty error message', (tester) async {
      await tester.pumpWidget(buildTestWidget(''));

      expect(find.byType(ErrorSynchronizationState), findsOneWidget);
    });
  });
}
