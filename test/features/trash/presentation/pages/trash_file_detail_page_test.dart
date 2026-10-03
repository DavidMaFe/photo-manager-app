import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_event.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_state.dart';
import 'package:photo_manager_app/features/trash/presentation/pages/trash_file_detail_page.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockTrashBloc extends Mock implements TrashBloc {}

class FakeTrashEvent extends Fake implements TrashEvent {}

void main() {
  late MockTrashBloc bloc;

  setUpAll(() => registerFallbackValue(FakeTrashEvent()));

  setUp(() {
    bloc = MockTrashBloc();
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => bloc.state).thenReturn(const TrashLoading());
  });

  TrashFile file(String id, int daysAgo) => TrashFile(
        id: id,
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: DateTime(2024, 1, 15, 10, 42),
        deletedAt: DateTime.now().subtract(Duration(days: daysAgo, hours: 1)),
        sizeBytes: 10,
      );

  /// Viewer images keep loading in tests, so pumpAndSettle never settles.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pump(WidgetTester tester, List<TrashFile> files) async {
    await tester.pumpWidget(makeTestableWidgetWithBloc<TrashBloc>(
      bloc: bloc,
      child: TrashFileDetailPage(files: files, initialIndex: 0),
    ));
  }

  group('TrashFileDetailPage', () {
    testWidgets('should show the deletion countdown and both actions', (tester) async {
      // Arrange & Act
      await pump(tester, [file('a', 18), file('b', 2)]);

      // Assert
      expect(find.text('Deleted in 12 days'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
      expect(find.text('Delete forever'), findsOneWidget);
    });

    testWidgets('should confirm and restore the current file', (tester) async {
      // Arrange
      await pump(tester, [file('a', 18)]);

      // Act
      await tester.tap(find.text('Restore'));
      await settle(tester);
      expect(find.byType(AppDialog), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(AppDialog), matching: find.text('Restore')).last);
      await settle(tester);

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<RestoreFiles>());
    });

    testWidgets('should confirm and delete the current file forever', (tester) async {
      // Arrange
      await pump(tester, [file('a', 18)]);

      // Act
      await tester.tap(find.text('Delete forever'));
      await settle(tester);
      expect(find.byType(AppDialog), findsOneWidget);
      // The primary (destructive) action is the last button of the dialog.
      await tester.tap(find.descendant(of: find.byType(AppDialog), matching: find.byType(AppButton)).last);
      await settle(tester);

      // Assert
      final event = verify(() => bloc.add(captureAny())).captured.single;
      expect(event, isA<PermanentlyDeleteFiles>());
    });
  });
}
