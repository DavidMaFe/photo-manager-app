import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_empty_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: TrashEmptyState(),
      ),
    );
  }

  group('TrashEmptyState', () {
    // ==================== STRUCTURE TESTS ====================

    testWidgets('should render Center widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Find the specific Center in TrashEmptyState
      final centers = find.byType(Center);
      expect(centers, findsWidgets);
    });

    testWidgets('should render Column widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should have centered column alignment', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final column = tester.widget<Column>(find.byType(Column));

      // Assert
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    // ==================== ICON TESTS ====================

    testWidgets('should display delete outline icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should have correct icon size', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final icon = tester.widget<Icon>(find.byIcon(Icons.delete_outline));

      // Assert
      expect(icon.size, 80);
    });

    testWidgets('should have correct icon color', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final icon = tester.widget<Icon>(find.byIcon(Icons.delete_outline));

      // Assert
      expect(icon.color, Colors.grey[400]);
    });

    // ==================== TEXT TESTS ====================

    testWidgets('should display trash is empty title', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Trash is empty'), findsOneWidget);
    });

    testWidgets('should display trash empty description', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(
        find.text(
            'Deleted files will appear here and be permanently deleted after 30 days'),
        findsOneWidget,
      );
    });

    testWidgets('should have exactly 2 Text widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Text), findsNWidgets(2));
    });

    // ==================== TEXT STYLE TESTS ====================

    testWidgets('should apply correct style to title', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final titleText = tester.widget<Text>(find.text('Trash is empty'));

      // Assert
      expect(titleText.style?.fontSize, 20);
      expect(titleText.style?.color, Colors.grey[800]);
      expect(titleText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('should apply correct style to description', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final descriptionText = tester.widget<Text>(
        find.text(
            'Deleted files will appear here and be permanently deleted after 30 days'),
      );

      // Assert
      expect(descriptionText.style?.fontSize, 14);
      expect(descriptionText.style?.color, Colors.grey[600]);
      expect(descriptionText.style?.height, 1.5);
      expect(descriptionText.textAlign, TextAlign.center);
    });

    // ==================== SPACING TESTS ====================

    testWidgets('should have SizedBox between icon and title', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));

      // Assert - Should find at least one SizedBox with height 24
      expect(
        sizedBoxes.any((box) => box.height == 24),
        true,
      );
    });

    testWidgets('should have SizedBox between title and description',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));

      // Assert - Should find at least one SizedBox with height 12
      expect(
        sizedBoxes.any((box) => box.height == 12),
        true,
      );
    });

    testWidgets('should have at least 2 SizedBox widgets', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Scaffold may add extra SizedBoxes
      expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
    });

    // ==================== PADDING TESTS ====================

    testWidgets('should wrap description in Padding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('should have correct horizontal padding on description',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final padding = tester.widget<Padding>(find.byType(Padding));

      // Assert
      expect(
        padding.padding,
        const EdgeInsets.symmetric(horizontal: 48),
      );
    });

    // ==================== LAYOUT TESTS ====================

    testWidgets('should render all elements in correct order', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final column = tester.widget<Column>(find.byType(Column));

      // Assert - Verify order of children
      expect(column.children.length, 5);
      expect(column.children[0], isA<Icon>());
      expect(column.children[1], isA<SizedBox>());
      expect(column.children[2], isA<Text>());
      expect(column.children[3], isA<SizedBox>());
      expect(column.children[4], isA<Padding>());
    });

    // ==================== VISUAL TESTS ====================

    testWidgets('should be visible in the widget tree', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashEmptyState), findsOneWidget);
    });

    testWidgets('should render without errors', (tester) async {
      // Arrange & Act & Assert
      await tester.pumpWidget(createWidgetUnderTest());
      // If we reach here without exceptions, the test passes
    });

    // ==================== WIDGET COUNT TESTS ====================

    testWidgets('should have exactly 1 Icon widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('should have exactly 1 Column widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should have Center widget in TrashEmptyState', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Scaffold may also use Center
      expect(find.byType(Center), findsWidgets);
    });

    // ==================== ACCESSIBILITY TESTS ====================

    testWidgets('should have center aligned text for accessibility',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final descriptionText = tester.widget<Text>(
        find.text(
            'Deleted files will appear here and be permanently deleted after 30 days'),
      );

      // Assert
      expect(descriptionText.textAlign, TextAlign.center);
    });

    testWidgets('should have readable font sizes', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final titleText = tester.widget<Text>(find.text('Trash is empty'));
      final descriptionText = tester.widget<Text>(
        find.text(
            'Deleted files will appear here and be permanently deleted after 30 days'),
      );

      // Assert - Both should be readable sizes
      expect(titleText.style?.fontSize, greaterThanOrEqualTo(14));
      expect(descriptionText.style?.fontSize, greaterThanOrEqualTo(12));
    });

    // ==================== COLOR TESTS ====================

    testWidgets('should use grey color scheme', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final icon = tester.widget<Icon>(find.byIcon(Icons.delete_outline));
      final titleText = tester.widget<Text>(find.text('Trash is empty'));
      final descriptionText = tester.widget<Text>(
        find.text(
            'Deleted files will appear here and be permanently deleted after 30 days'),
      );

      // Assert - All colors should be grey variants
      expect(icon.color, Colors.grey[400]);
      expect(titleText.style?.color, Colors.grey[800]);
      expect(descriptionText.style?.color, Colors.grey[600]);
    });

    // ==================== CONST CONSTRUCTOR TEST ====================

    testWidgets('should use const constructor', (tester) async {
      // Arrange & Act
      const widget = TrashEmptyState();

      // Assert - If it compiles with const, test passes
      expect(widget, isA<TrashEmptyState>());
    });
  });
}
