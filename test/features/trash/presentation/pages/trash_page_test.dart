import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/media_grid_skeleton.dart';
import 'package:photo_manager_app/core/widgets/selection_action_bar.dart';
import 'package:photo_manager_app/core/widgets/selection_header.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_event.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_state.dart';
import 'package:photo_manager_app/features/trash/presentation/pages/trash_page.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_empty_state.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_file_card.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockTrashBloc extends Mock implements TrashBloc {}

class FakeTrashEvent extends Fake implements TrashEvent {}

void main() {
  late MockTrashBloc bloc;

  setUpAll(() => registerFallbackValue(FakeTrashEvent()));

  setUp(() {
    bloc = MockTrashBloc();
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  });

  /// A file deleted [daysAgo] days ago (30-day retention).
  TrashFile trashFile(String id, int daysAgo) => TrashFile(
        id: id,
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: DateTime(2024, 1, 1),
        deletedAt: DateTime.now().subtract(Duration(days: daysAgo, hours: 1)),
        sizeBytes: 1024,
      );

  final files = [trashFile('soon', 28), trashFile('later-1', 10), trashFile('later-2', 2)];

  Future<void> pump(WidgetTester tester, TrashState state) async {
    setUpCustomScreenSize(tester, 390, 1200);
    when(() => bloc.state).thenReturn(state);
    await tester.pumpWidget(makeTestableWidgetWithBloc<TrashBloc>(bloc: bloc, child: const TrashPageView()));
  }

  group('TrashPageView', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show the title, empty action and retention notice', (tester) async {
      // Arrange & Act
      await pump(tester, TrashLoaded(files: files, currentPage: 0, hasNext: false));

      // Assert
      expect(find.text('Trash'), findsOneWidget);
      expect(find.text('Empty'), findsOneWidget);
      expect(find.textContaining('30 days'), findsOneWidget);
    });

    testWidgets('should split files into "deleted soon" and "this month"', (tester) async {
      // Arrange & Act
      await pump(tester, TrashLoaded(files: files, currentPage: 0, hasNext: false));

      // Assert
      expect(find.text('Deleted soon'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
      expect(find.byType(TrashFileCard), findsNWidgets(3));
      expect(find.text('2 days'), findsOneWidget);
      expect(find.text('20 days'), findsOneWidget);
    });

    testWidgets('should confirm before emptying the trash', (tester) async {
      // Arrange
      await pump(tester, TrashLoaded(files: files, currentPage: 0, hasNext: false));

      // Act
      await tester.tap(find.text('Empty'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppDialog), findsOneWidget);
    });

    // ==================== SELECTION TESTS ====================

    testWidgets('should show the selection header and action bar', (tester) async {
      // Arrange & Act
      await pump(tester, TrashLoaded(files: files, currentPage: 0, hasNext: false, isSelectionMode: true, selectedFileIds: const {'soon'}));

      // Assert
      expect(find.byType(SelectionHeader), findsOneWidget);
      expect(find.byType(SelectionActionBar), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
      expect(find.text('Delete forever'), findsOneWidget);
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('should hide the action bar without selected files', (tester) async {
      // Arrange & Act
      await pump(tester, TrashLoaded(files: files, currentPage: 0, hasNext: false, isSelectionMode: true));

      // Assert
      expect(find.byType(SelectionActionBar), findsNothing);
    });

    testWidgets('should restore the selection after confirming', (tester) async {
      // Arrange
      await pump(tester, TrashLoaded(files: files, currentPage: 0, hasNext: false, isSelectionMode: true, selectedFileIds: const {'soon'}));

      // Act
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();
      await tester.tap(find.descendant(of: find.byType(AppDialog), matching: find.text('Restore')).last);
      await tester.pumpAndSettle();

      // Assert
      verify(() => bloc.add(const RestoreSelectedFiles())).called(1);
    });

    testWidgets('should select all from the header', (tester) async {
      // Arrange
      await pump(tester, TrashLoaded(files: files, currentPage: 0, hasNext: false, isSelectionMode: true, selectedFileIds: const {'soon'}));

      // Act
      await tester.tap(find.text('All'));

      // Assert
      verify(() => bloc.add(const SelectAllFiles())).called(1);
    });

    // ==================== LOADING, EMPTY & ERROR TESTS ====================

    testWidgets('should show the skeleton while loading', (tester) async {
      // Arrange & Act
      await pump(tester, const TrashLoading());

      // Assert
      expect(find.byType(MediaGridSkeleton), findsOneWidget);
    });

    testWidgets('should show the empty state and hide the empty action', (tester) async {
      // Arrange & Act
      await pump(tester, const TrashLoaded(files: [], currentPage: 0, hasNext: false));

      // Assert
      expect(find.byType(TrashEmptyState), findsOneWidget);
      expect(find.text('Empty'), findsNothing);
    });

    testWidgets('should show the error display', (tester) async {
      // Arrange & Act
      await pump(tester, const TrashError(NetworkFailure()));

      // Assert
      expect(find.byType(ErrorDisplay), findsOneWidget);
    });
  });
}
