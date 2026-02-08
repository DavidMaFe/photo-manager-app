import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_header.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  late MockVoidCallback mockOnCancelSelection;
  late MockVoidCallback mockOnEmptyTrash;

  setUp(() {
    mockOnCancelSelection = MockVoidCallback();
    mockOnEmptyTrash = MockVoidCallback();
  });

  Widget createWidgetUnderTest({
    required bool isSelectionMode,
    required int selectedCount,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: TrashHeader(
          isSelectionMode: isSelectionMode,
          selectedCount: selectedCount,
          onCancelSelection: mockOnCancelSelection,
          onEmptyTrash: mockOnEmptyTrash,
        ),
      ),
    );
  }

  group('TrashHeader', () {
    // ==================== NORMAL MODE TESTS ====================

    testWidgets('should render AppBar in normal mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should show back button in normal mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should show trash title in normal mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.text('Trash'), findsOneWidget);
    });

    testWidgets('should show empty trash button in normal mode',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byIcon(Icons.delete_sweep_outlined), findsOneWidget);
    });

    testWidgets('should call onEmptyTrash when empty trash button is tapped',
        (tester) async {
      // Arrange
      when(() => mockOnEmptyTrash()).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Act
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pump();

      // Assert
      verify(() => mockOnEmptyTrash()).called(1);
    });

    testWidgets('should not show close button in normal mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('should not show select all button in normal mode',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byIcon(Icons.select_all), findsNothing);
    });

    // ==================== SELECTION MODE TESTS ====================

    testWidgets('should render AppBar in selection mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should show close button in selection mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should show select all button in selection mode',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Assert
      expect(find.byIcon(Icons.select_all), findsOneWidget);
    });

    testWidgets('should display selected count with singular text',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 1,
      ));

      // Assert
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('should display selected count with plural text',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Assert
      expect(find.text('5 selected'), findsOneWidget);
    });

    testWidgets('should display zero selected count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 0,
      ));

      // Assert
      expect(find.text('0 selected'), findsOneWidget);
    });

    testWidgets('should display large selected count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 999,
      ));

      // Assert
      expect(find.text('999 selected'), findsOneWidget);
    });

    testWidgets('should call onCancelSelection when close button is tapped',
        (tester) async {
      // Arrange
      when(() => mockOnCancelSelection()).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Act
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Assert
      verify(() => mockOnCancelSelection()).called(1);
    });

    testWidgets('should not show back button in selection mode',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Assert
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('should not show empty trash button in selection mode',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Assert
      expect(find.byIcon(Icons.delete_sweep_outlined), findsNothing);
    });

    testWidgets('should not show trash title in selection mode',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Assert
      expect(find.text('Trash'), findsNothing);
    });

    // ==================== TOOLTIP TESTS ====================

    testWidgets('should have cancel tooltip on close button', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Act
      final closeButton = find.ancestor(
        of: find.byIcon(Icons.close),
        matching: find.byType(IconButton),
      );

      // Assert
      expect(closeButton, findsOneWidget);
      final iconButton = tester.widget<IconButton>(closeButton);
      expect(iconButton.tooltip, 'Cancel');
    });

    testWidgets('should have select all tooltip on select all button',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Act
      final selectAllButton = find.ancestor(
        of: find.byIcon(Icons.select_all),
        matching: find.byType(IconButton),
      );

      // Assert
      expect(selectAllButton, findsOneWidget);
      final iconButton = tester.widget<IconButton>(selectAllButton);
      expect(iconButton.tooltip, 'Select all');
    });

    testWidgets('should have empty trash tooltip on empty trash button',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Act
      final emptyTrashButton = find.ancestor(
        of: find.byIcon(Icons.delete_sweep_outlined),
        matching: find.byType(IconButton),
      );

      // Assert
      expect(emptyTrashButton, findsOneWidget);
      final iconButton = tester.widget<IconButton>(emptyTrashButton);
      expect(iconButton.tooltip, 'Empty');
    });

    // ==================== PREFERRED SIZE TESTS ====================

    testWidgets('should have correct preferred size', (tester) async {
      // Arrange
      final header = TrashHeader(
        isSelectionMode: false,
        selectedCount: 0,
        onCancelSelection: mockOnCancelSelection,
        onEmptyTrash: mockOnEmptyTrash,
      );

      // Assert
      expect(header.preferredSize, const Size.fromHeight(kToolbarHeight));
    });

    // ==================== MODE TRANSITION TESTS ====================

    testWidgets('should transition from normal to selection mode',
        (tester) async {
      // Arrange - Start in normal mode
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Verify normal mode
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Trash'), findsOneWidget);

      // Act - Switch to selection mode
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 3,
      ));
      await tester.pump();

      // Assert - Verify selection mode
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('3 selected'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('Trash'), findsNothing);
    });

    testWidgets('should transition from selection to normal mode',
        (tester) async {
      // Arrange - Start in selection mode
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Verify selection mode
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('5 selected'), findsOneWidget);

      // Act - Switch to normal mode
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));
      await tester.pump();

      // Assert - Verify normal mode
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Trash'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.text('5 selected'), findsNothing);
    });

    // ==================== EDGE CASE TESTS ====================

    testWidgets('should handle multiple taps on empty trash button',
        (tester) async {
      // Arrange
      when(() => mockOnEmptyTrash()).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Act
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pump();

      // Assert
      verify(() => mockOnEmptyTrash()).called(3);
    });

    testWidgets('should handle multiple taps on cancel button',
        (tester) async {
      // Arrange
      when(() => mockOnCancelSelection()).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Act
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // Assert
      verify(() => mockOnCancelSelection()).called(2);
    });

    testWidgets('should update selected count dynamically', (tester) async {
      // Arrange - Start with 1 selected
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 1,
      ));
      expect(find.text('1 selected'), findsOneWidget);

      // Act - Update to 5 selected
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));
      await tester.pump();

      // Assert
      expect(find.text('5 selected'), findsOneWidget);
      expect(find.text('1 selected'), findsNothing);

      // Act - Update to 10 selected
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 10,
      ));
      await tester.pump();

      // Assert
      expect(find.text('10 selected'), findsOneWidget);
      expect(find.text('5 selected'), findsNothing);
    });

    // ==================== TEXT STYLE TESTS ====================

    testWidgets('should apply correct text style to selected count',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Act
      final titleText = tester.widget<Text>(find.text('5 selected'));

      // Assert
      expect(titleText.style?.fontSize, 18);
    });

    // ==================== ICON BUTTON COUNT TESTS ====================

    testWidgets('should have exactly 2 icon buttons in normal mode',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byType(IconButton), findsNWidgets(2)); // back + empty trash
    });

    testWidgets('should have exactly 2 icon buttons in selection mode',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Assert
      expect(
          find.byType(IconButton), findsNWidgets(2)); // close + select all
    });
  });
}
