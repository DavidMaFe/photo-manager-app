import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_top_bar.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_properties_sheet.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_event.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_state.dart';
import 'package:photo_manager_app/features/trash/presentation/pages/trash_file_detail_page.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockTrashBloc extends Mock implements TrashBloc {}

class FakeTrashEvent extends Fake implements TrashEvent {}

class MockFileInfoBloc extends MockBloc<FileInfoEvent, FileInfoState> implements FileInfoBloc {}

void main() {
  late MockTrashBloc bloc;

  late MockFileInfoBloc fileInfoBloc;

  setUpAll(() => registerFallbackValue(FakeTrashEvent()));

  // The properties sheet takes its bloc from the service locator.
  setUp(() {
    fileInfoBloc = MockFileInfoBloc();
    when(() => fileInfoBloc.state).thenReturn(const FileInfoLoading());
    sl.registerFactory<FileInfoBloc>(() => fileInfoBloc);
  });

  tearDown(() => sl.unregister<FileInfoBloc>());

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

    testWidgets('should show "No date" in the top bar when the file has no capture date', (tester) async {
      // Arrange & Act
      await pump(tester, [
        TrashFile(
          id: 'undated',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: null,
          deletedAt: DateTime.now(),
          sizeBytes: 10,
        ),
      ]);

      // Assert
      expect(tester.widget<MediaViewerTopBar>(find.byType(MediaViewerTopBar)).title, 'No date');
    });

    testWidgets('should load the file details from the info button', (tester) async {
      // Arrange
      await pump(tester, [file('a', 18)]);

      // Act
      await tester.tap(find.byTooltip('Info'));
      await settle(tester);

      // Assert
      expect(find.byType(FilePropertiesSheet), findsOneWidget);
      verify(() => fileInfoBloc.add(const LoadFileInfo('a'))).called(1);
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
