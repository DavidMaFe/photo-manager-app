import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_action_buttons.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockVoidCallback extends Mock {
  void call();
}

void main() {
  late MockVoidCallback mockOnRestore;
  late MockVoidCallback mockOnDelete;

  setUp(() {
    mockOnRestore = MockVoidCallback();
    mockOnDelete = MockVoidCallback();
  });

  Widget createWidgetUnderTest({int selectedCount = 5}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        floatingActionButton: TrashActionButtons(
          selectedCount: selectedCount,
          onRestore: mockOnRestore,
          onDelete: mockOnDelete,
        ),
      ),
    );
  }

  group('TrashActionButtons', () {
    testWidgets('should render two FloatingActionButtons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(FloatingActionButton), findsNWidgets(2));
    });

    testWidgets('should display restore button with correct icon',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byIcon(Icons.restore), findsOneWidget);
    });

    testWidgets('should display delete button with correct icon',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('should display restore label', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Restore'), findsOneWidget);
    });

    testWidgets('should display delete label', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should call onRestore when restore button is tapped',
        (tester) async {
      when(() => mockOnRestore()).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Restore'));
      await tester.pump();

      verify(() => mockOnRestore()).called(1);
    });

    testWidgets('should call onDelete when delete button is tapped',
        (tester) async {
      when(() => mockOnDelete()).thenReturn(null);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Delete'));
      await tester.pump();

      verify(() => mockOnDelete()).called(1);
    });

    testWidgets('should have correct restore button color', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final restoreButton = tester.widgetList<FloatingActionButton>(
        find.byType(FloatingActionButton),
      ).firstWhere((fab) => fab.heroTag == 'restore_button');

      expect(restoreButton.backgroundColor, PhotoManagerColors.primary);
    });

    testWidgets('should have correct delete button color', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final deleteButton = tester.widgetList<FloatingActionButton>(
        find.byType(FloatingActionButton),
      ).firstWhere((fab) => fab.heroTag == 'delete_button');

      expect(deleteButton.backgroundColor, Colors.white);
    });

    testWidgets('should have unique hero tags', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final fabs = tester.widgetList<FloatingActionButton>(
        find.byType(FloatingActionButton),
      ).toList();

      expect(fabs[0].heroTag, 'restore_button');
      expect(fabs[1].heroTag, 'delete_button');
    });

    testWidgets('should be aligned to bottom right', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final align = tester.widget<Align>(find.byType(Align));
      expect(align.alignment, Alignment.bottomRight);
    });

    testWidgets('should render with different selected counts', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(selectedCount: 1));
      expect(find.byType(TrashActionButtons), findsOneWidget);

      await tester.pumpWidget(createWidgetUnderTest(selectedCount: 100));
      expect(find.byType(TrashActionButtons), findsOneWidget);
    });
  });
}
