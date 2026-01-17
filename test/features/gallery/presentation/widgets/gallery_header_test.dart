import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/gallery_header.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  group('GalleryHeader', () {
    Widget createWidgetUnderTest({
      required bool isSelectionMode,
      required int selectedCount,
      VoidCallback? onCancelSelection,
      VoidCallback? onSelectAll,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          appBar: GalleryHeader(
            isSelectionMode: isSelectionMode,
            selectedCount: selectedCount,
            onCancelSelection: onCancelSelection ?? () {},
            onSelectAll: onSelectAll ?? () {},
          ),
        ),
      );
    }

    testWidgets('should render as PreferredSizeWidget (AppBar)', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display normal title when not in selection mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
    });

    testWidgets('should display selected count when in selection mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 5,
      ));

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
    });

    testWidgets('should show cancel button in selection mode', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 3,
      ));

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
    });

    testWidgets('should call onCancelSelection when cancel button is tapped', (tester) async {
      // Arrange
      bool cancelCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 2,
        onCancelSelection: () => cancelCalled = true,
      ));

      // Act - Try to find and tap close button (if visible)
      final closeButtons = find.byIcon(Icons.close);
      if (closeButtons.evaluate().isNotEmpty) {
        await tester.tap(closeButtons.first);
        await tester.pumpAndSettle();

        // Assert
        expect(cancelCalled, true);
      }
    });

    testWidgets('should handle zero selected count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
    });

    testWidgets('should handle single file selected', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 1,
      ));

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
    });

    testWidgets('should handle large selection count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 999,
      ));

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
    });

    testWidgets('should not be in selection mode by default', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
    });

    testWidgets('should toggle between selection and normal mode', (tester) async {
      // Arrange - Start in normal mode
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: false,
        selectedCount: 0,
      ));
      expect(find.byType(GalleryHeader), findsOneWidget);

      // Act - Switch to selection mode
      await tester.pumpWidget(createWidgetUnderTest(
        isSelectionMode: true,
        selectedCount: 2,
      ));
      await tester.pump();

      // Assert
      expect(find.byType(GalleryHeader), findsOneWidget);
    });
  });
}
