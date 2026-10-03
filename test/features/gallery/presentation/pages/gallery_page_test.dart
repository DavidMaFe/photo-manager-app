import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/core/widgets/filter_pill.dart';
import 'package:photo_manager_app/core/widgets/media_grid.dart';
import 'package:photo_manager_app/core/widgets/media_grid_skeleton.dart';
import 'package:photo_manager_app/core/widgets/user_avatar.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_selection_bar.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:photo_manager_app/features/gallery/presentation/pages/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/backup_status_chip.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/gallery_top_bar.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/pending_review_card.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockGalleryBloc extends Mock implements GalleryBloc {}

class MockSyncSessionBloc extends Mock implements SyncSessionBloc {}

class MockAuthBloc extends Mock implements AuthBloc {}

class MockFileManagementBloc extends Mock implements FileManagementBloc {}

class MockManageFolderBloc extends Mock implements ManageFolderBloc {}

class FakeGalleryEvent extends Fake implements GalleryEvent {}

void main() {
  late MockGalleryBloc mockGalleryBloc;
  late MockSyncSessionBloc mockSyncSessionBloc;
  late MockAuthBloc mockAuthBloc;
  late MockFileManagementBloc mockFileManagementBloc;
  late MockManageFolderBloc mockManageFolderBloc;

  setUpAll(() => registerFallbackValue(FakeGalleryEvent()));

  setUp(() {
    mockGalleryBloc = MockGalleryBloc();
    when(() => mockGalleryBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockGalleryBloc.state).thenReturn(const GalleryStarting());

    mockSyncSessionBloc = MockSyncSessionBloc();
    when(() => mockSyncSessionBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSyncSessionBloc.state).thenReturn(const SyncSessionInitial());

    mockManageFolderBloc = MockManageFolderBloc();
    when(() => mockManageFolderBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockManageFolderBloc.state).thenReturn(const ManageFoldersLoaded(folders: []));

    mockFileManagementBloc = MockFileManagementBloc();
    when(() => mockFileManagementBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockFileManagementBloc.state).thenReturn(const FileManagementStarting());

    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.state).thenReturn(
      AuthSuccessful(User(id: '1', email: 'ana@example.com', name: 'Ana', surname: 'López')),
    );
  });

  Widget createWidgetUnderTest() {
    return makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<GalleryBloc>.value(value: mockGalleryBloc),
        BlocProvider<SyncSessionBloc>.value(value: mockSyncSessionBloc),
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<FileManagementBloc>.value(value: mockFileManagementBloc),
        BlocProvider<ManageFolderBloc>.value(value: mockManageFolderBloc),
      ],
      child: const GalleryPage(),
    );
  }

  final today = DateTime.now();

  final testFiles = [
    GalleryFile(id: 'file-1', type: FileType.image, status: FileStatus.managed, capturedAt: today),
    GalleryFile(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.pending,
      durationSeconds: 120,
      capturedAt: today,
    ),
  ];

  GalleryLoaded loaded({
    List<GalleryFile>? files,
    bool isSelectionMode = false,
    Set<String> selectedFileIds = const {},
    int pending = 1,
    FileFilter filter = FileFilter.all,
  }) {
    final list = files ?? testFiles;
    return GalleryLoaded(
      files: list,
      groupedFiles: DateGroupingUtil.groupFilesByDate(list),
      isSelectionMode: isSelectionMode,
      selectedFileIds: selectedFileIds,
      hasNext: false,
      currentPage: 0,
      totalFilesCount: list.length,
      totalPendingCount: pending,
      filter: filter,
    );
  }

  group('GalleryPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show the Photos header with backup status and avatar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Photos'), findsWidgets);
      expect(find.byType(BackupStatusChip), findsOneWidget);
      expect(find.text('Up to date'), findsOneWidget);
      expect(find.text('AL'), findsOneWidget);
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('should render the filter pills with the pending counter', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(loaded(pending: 7, filter: FileFilter.images));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FilterPill), findsNWidgets(4));
      final selected = tester.widgetList<FilterPill>(find.byType(FilterPill)).where((p) => p.selected);
      expect(selected.single.label, 'Photos');
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('should load the filter tapped in the pill bar', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(loaded());
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Videos'));

      // Assert
      final event = verify(() => mockGalleryBloc.add(captureAny())).captured.last;
      expect(event, isA<LoadGallery>().having((e) => e.filter, 'filter', FileFilter.videos));
    });

    testWidgets('should render the grouped grid for loaded files', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(loaded());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(MediaGrid), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Select'), findsOneWidget);
    });

    testWidgets('should enter selection mode from the group header', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(loaded());
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Select'));

      // Assert
      verify(() => mockGalleryBloc.add(const EnterSelectionMode())).called(1);
    });

    // ==================== PENDING REVIEW TESTS ====================

    testWidgets('should show the review card when there are pending files', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(loaded(pending: 3));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(PendingReviewCard), findsOneWidget);
      expect(find.text('3 items to review'), findsOneWidget);
    });

    testWidgets('should start the pending review when tapping review', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(loaded(pending: 3));
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.text('Review'));

      // Assert
      verify(() => mockGalleryBloc.add(const ReviewPendingFiles())).called(1);
    });

    testWidgets('should open the manage sheet with the pending files', (tester) async {
      // Arrange
      final review = GalleryLoaded(
        files: testFiles,
        groupedFiles: DateGroupingUtil.groupFilesByDate(testFiles),
        isSelectionMode: true,
        selectedFileIds: const {'file-2'},
        hasNext: false,
        currentPage: 0,
        totalFilesCount: 2,
        totalPendingCount: 1,
        filter: FileFilter.pending,
        reviewRequested: true,
      );
      when(() => mockGalleryBloc.state).thenReturn(loaded());
      when(() => mockGalleryBloc.stream).thenAnswer((_) => Stream.value(review));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert
      final sheet = tester.widget<ManageFileModal>(find.byType(ManageFileModal));
      expect(sheet.fileIds, ['file-2']);
    });

    testWidgets('should hide the review card without pending files', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(loaded(pending: 0));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Review'), findsNothing);
    });

    // ==================== LOADING & EMPTY STATE TESTS ====================

    testWidgets('should show the skeleton while starting', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(MediaGridSkeleton), findsOneWidget);
    });

    testWidgets('should show the skeleton while loading', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(const GalleryLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(MediaGridSkeleton), findsOneWidget);
    });

    testWidgets('should show the empty state with a backup action', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(loaded(files: const [], pending: 0));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No photos yet'), findsOneWidget);
      expect(find.text('Back up now'), findsOneWidget);
    });

    testWidgets('should show a plain empty state for empty filters', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state)
          .thenReturn(loaded(files: const [], pending: 0, filter: FileFilter.videos));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Back up now'), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('should handle GalleryLoadingMore state', (tester) async {
      // Arrange: tall screen so the bottom loader is built.
      setUpCustomScreenSize(tester, 390, 2000);
      when(() => mockGalleryBloc.state).thenReturn(GalleryLoadingMore(
        files: testFiles,
        groupedFiles: DateGroupingUtil.groupFilesByDate(testFiles),
        isSelectionMode: false,
        selectedFileIds: const {},
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(MediaGrid), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ==================== SELECTION MODE TESTS ====================

    testWidgets('should show the selection header with the selected count', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state)
          .thenReturn(loaded(isSelectionMode: true, selectedFileIds: const {'file-1', 'file-2'}));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final header = tester.widget<GalleryTopBar>(find.byType(GalleryTopBar));
      expect(header.isSelectionMode, true);
      expect(header.selectedCount, 2);
      expect(find.text('2 selected'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
      expect(find.text('Select'), findsNothing);
    });

    testWidgets('should exit selection mode from the close button', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state)
          .thenReturn(loaded(isSelectionMode: true, selectedFileIds: const {'file-1'}));
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.byTooltip('Exit selection'));

      // Assert
      verify(() => mockGalleryBloc.add(const ExitSelectionMode())).called(1);
    });

    testWidgets('should not show the action bar outside selection mode', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state).thenReturn(loaded());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(ManageSelectionBar), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('should show the action bar with the selected files', (tester) async {
      // Arrange
      when(() => mockGalleryBloc.state)
          .thenReturn(loaded(isSelectionMode: true, selectedFileIds: const {'file-1'}));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final bar = tester.widget<ManageSelectionBar>(find.byType(ManageSelectionBar));
      expect(bar.fileIds, ['file-1']);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('To album'), findsOneWidget);
      expect(find.text('Free up'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    // ==================== EDGE CASE TESTS ====================

    testWidgets('should handle many files', (tester) async {
      // Arrange
      final manyFiles = List.generate(
        100,
        (i) => GalleryFile(id: 'file-$i', type: FileType.image, status: FileStatus.managed, capturedAt: today),
      );
      when(() => mockGalleryBloc.state).thenReturn(loaded(files: manyFiles, pending: 0));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(MediaGrid), findsOneWidget);
    });
  });
}
