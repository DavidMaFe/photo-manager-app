import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/filter_chips.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

void main() {
  group('FilterChips', () {
    Widget createWidgetUnderTest({
      required FileFilter selectedFilter,
      required ValueChanged<FileFilter> onFilterSelected,
    }) {
      return MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: FilterChips(
            selectedFilter: selectedFilter,
            onFilterSelected: onFilterSelected,
          ),
        ),
      );
    }

    testWidgets('should render filter chips widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: FileFilter.all,
        onFilterSelected: (_) {},
      ));

      // Assert
      expect(find.byType(FilterChips), findsOneWidget);
    });

    testWidgets('should display all filter options', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: FileFilter.all,
        onFilterSelected: (_) {},
      ));

      // Assert - Should have 4 filter chips (all, images, videos, pending)
      expect(find.byType(FilterChip), findsNWidgets(4));
    });

    testWidgets('should show "all" filter as selected by default', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: FileFilter.all,
        onFilterSelected: (_) {},
      ));

      // Assert
      final allChip = tester.widget<FilterChip>(
        find.byType(FilterChip).at(0),
      );
      expect(allChip.selected, true);
    });

    testWidgets('should show "images" filter as selected', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: FileFilter.images,
        onFilterSelected: (_) {},
      ));
      await tester.pump();

      // Assert
      final imagesChip = tester.widget<FilterChip>(
        find.byType(FilterChip).at(1),
      );
      expect(imagesChip.selected, true);
    });

    testWidgets('should show "videos" filter as selected', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: FileFilter.videos,
        onFilterSelected: (_) {},
      ));
      await tester.pump();

      // Assert
      final videosChip = tester.widget<FilterChip>(
        find.byType(FilterChip).at(2),
      );
      expect(videosChip.selected, true);
    });

    testWidgets('should show "pending" filter as selected', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: FileFilter.pending,
        onFilterSelected: (_) {},
      ));
      await tester.pump();

      // Assert
      final pendingChip = tester.widget<FilterChip>(
        find.byType(FilterChip).at(3),
      );
      expect(pendingChip.selected, true);
    });

    testWidgets('should call onFilterSelected when tapping a chip', (tester) async {
      // Arrange
      FileFilter? selectedFilter;
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: FileFilter.all,
        onFilterSelected: (filter) => selectedFilter = filter,
      ));

      // Act
      await tester.tap(find.byType(FilterChip).at(1)); // Tap images filter
      await tester.pumpAndSettle();

      // Assert
      expect(selectedFilter, FileFilter.images);
    });

    testWidgets('should handle multiple filter selections', (tester) async {
      // Arrange
      FileFilter currentFilter = FileFilter.all;
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: currentFilter,
        onFilterSelected: (filter) {
          currentFilter = filter;
        },
      ));

      // Act - Tap images
      await tester.tap(find.byType(FilterChip).at(1));
      await tester.pump();
      expect(currentFilter, FileFilter.images);

      // Rebuild widget with new filter
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: currentFilter,
        onFilterSelected: (filter) {
          currentFilter = filter;
        },
      ));

      // Act - Tap videos
      await tester.tap(find.byType(FilterChip).at(2));
      await tester.pump();
      expect(currentFilter, FileFilter.videos);
    });

    testWidgets('should display filter labels', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(
        selectedFilter: FileFilter.all,
        onFilterSelected: (_) {},
      ));

      // Assert - Localized filter labels are shown
      expect(find.text('Todo'), findsOneWidget);
      expect(find.text('Fotos'), findsOneWidget);
      expect(find.text('Vídeos'), findsOneWidget);
      expect(find.text('Por revisar'), findsOneWidget);
    });
  });
}
