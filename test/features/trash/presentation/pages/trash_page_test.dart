import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_state.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_action_buttons.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_empty_state.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_files_grid.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_header.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockTrashBloc extends Mock implements TrashBloc {}

/// Test widget that replicates TrashPage structure without GetIt dependency
class TestTrashPageContent extends StatelessWidget {
  const TestTrashPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrashBloc, TrashState>(
      listener: (context, state) {},
      builder: (context, state) {
        final isSelectionMode = state is TrashLoaded && state.isSelectionMode;
        final selectedCount = isSelectionMode ? state.selectedCount : 0;

        return Scaffold(
          appBar: TrashHeader(
            isSelectionMode: isSelectionMode,
            selectedCount: selectedCount,
            onCancelSelection: () {},
            onEmptyTrash: () {},
          ),
          body: _buildContent(context, state),
          floatingActionButton: _buildFAB(context, state),
        );
      },
    );
  }

  Widget? _buildFAB(BuildContext context, TrashState state) {
    if (state is! TrashLoaded || !state.isSelectionMode) {
      return null;
    }

    final selectedCount = state.selectedCount;

    if (selectedCount == 0) {
      return null;
    }

    return TrashActionButtons(
      selectedCount: selectedCount,
      onRestore: () {},
      onDelete: () {},
    );
  }

  Widget _buildContent(BuildContext context, TrashState state) {
    if (state is TrashInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TrashLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (state is TrashLoaded || state is TrashLoadingMore) {
      return _buildGrid(context, state);
    }

    if (state is TrashRestoring || state is TrashDeleting) {
      return _buildGrid(context, state);
    }

    if (state is TrashError) {
      return ErrorDisplay(
        failure: state.failure,
        onRetry: () {},
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGrid(BuildContext context, dynamic state) {
    List<TrashFile> files = [];
    bool hasNext = false;
    bool isLoadingMore = false;
    bool isSelectionMode = false;
    Set<String> selectedFileIds = {};
    bool isProcessing = false;

    // Check more specific types first since TrashLoadingMore/TrashRestoring/TrashDeleting extend TrashLoaded
    if (state is TrashRestoring || state is TrashDeleting) {
      final loadedState = state as TrashLoaded;
      files = loadedState.files;
      hasNext = loadedState.hasNext;
      isLoadingMore = false;
      isSelectionMode = loadedState.isSelectionMode;
      selectedFileIds = loadedState.selectedFileIds;
      isProcessing = true;
    } else if (state is TrashLoadingMore) {
      files = state.files;
      hasNext = true;
      isLoadingMore = true;
      isSelectionMode = state.isSelectionMode;
      selectedFileIds = state.selectedFileIds;
      isProcessing = false;
    } else if (state is TrashLoaded) {
      files = state.files;
      hasNext = state.hasNext;
      isLoadingMore = false;
      isSelectionMode = state.isSelectionMode;
      selectedFileIds = state.selectedFileIds;
      isProcessing = false;
    }

    // Show empty state if no files
    if (files.isEmpty && !isLoadingMore) {
      return const TrashEmptyState();
    }

    return TrashFilesGrid(
      files: files,
      hasNext: hasNext,
      isLoadingMore: isLoadingMore,
      isSelectionMode: isSelectionMode,
      selectedFileIds: selectedFileIds,
      isProcessing: isProcessing,
      onLoadMore: () {},
      onRefresh: () {},
      onFileTap: (file) {},
      onFileLongPress: (file) {},
    );
  }
}

void main() {
  late MockTrashBloc mockTrashBloc;

  setUp(() {
    mockTrashBloc = MockTrashBloc();
    when(() => mockTrashBloc.stream)
        .thenAnswer((_) => Stream.value(TrashInitial()));
    when(() => mockTrashBloc.state).thenReturn(TrashInitial());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<TrashBloc>.value(
        value: mockTrashBloc,
        child: const TestTrashPageContent(),
      ),
    );
  }

  final testDate = DateTime(2024, 1, 15);
  final testDeletedDate = DateTime(2024, 1, 25);

  final testFiles = [
    TrashFile(
      id: 'file-1',
      type: FileType.image,
      status: FileStatus.managed,
      capturedAt: testDate,
      deletedAt: testDeletedDate,
      sizeBytes: 1024,
    ),
    TrashFile(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.pending,
      capturedAt: testDate,
      deletedAt: testDeletedDate,
      sizeBytes: 2048,
      durationSeconds: 120,
    ),
  ];

  group('TrashPage', () {
    // ==================== STRUCTURE TESTS ====================

    testWidgets('should render Scaffold', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render TrashHeader as app bar', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashHeader), findsOneWidget);
    });

    testWidgets('should use BlocConsumer to listen to TrashBloc',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(BlocConsumer<TrashBloc, TrashState>), findsOneWidget);
    });

    // ==================== INITIAL STATE TESTS ====================

    testWidgets('should show loading indicator for TrashInitial state',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(TrashInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show loading indicator for TrashLoading state',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(const TrashLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // ==================== LOADED STATE TESTS ====================

    testWidgets('should render TrashFilesGrid when in TrashLoaded state',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashFilesGrid), findsOneWidget);
    });

    testWidgets('should show TrashEmptyState when files list is empty',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: const [],
          currentPage: 0,
          hasNext: false,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashEmptyState), findsOneWidget);
    });

    testWidgets('should pass correct data to TrashFilesGrid', (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final grid = tester.widget<TrashFilesGrid>(find.byType(TrashFilesGrid));
      expect(grid.files, testFiles);
      expect(grid.hasNext, true);
      expect(grid.isLoadingMore, false);
      expect(grid.isSelectionMode, false);
      expect(grid.selectedFileIds, const <String>{});
      expect(grid.isProcessing, false);
    });

    // ==================== LOADING MORE STATE TESTS ====================

    testWidgets('should render TrashFilesGrid for TrashLoadingMore state',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoadingMore(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashFilesGrid), findsOneWidget);
      final grid = tester.widget<TrashFilesGrid>(find.byType(TrashFilesGrid));
      expect(grid.isLoadingMore, true);
      expect(grid.hasNext, true);
    });

    // ==================== ERROR STATE TESTS ====================

    testWidgets('should show ErrorDisplay for TrashError state',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        const TrashError(
          NetworkFailure(messageKey: 'errorNetwork'),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(ErrorDisplay), findsOneWidget);
    });

    testWidgets('should pass failure to ErrorDisplay', (tester) async {
      // Arrange
      const failure = NetworkFailure(messageKey: 'errorNetwork');
      when(() => mockTrashBloc.state).thenReturn(
        const TrashError(failure),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final errorDisplay =
          tester.widget<ErrorDisplay>(find.byType(ErrorDisplay));
      expect(errorDisplay.failure, failure);
    });

    // ==================== SELECTION MODE TESTS ====================

    testWidgets('should not show FAB when not in selection mode',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashActionButtons), findsNothing);
    });

    testWidgets('should show FAB when in selection mode with files selected',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashActionButtons), findsOneWidget);
    });

    testWidgets(
        'should not show FAB when in selection mode but no files selected',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: true,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashActionButtons), findsNothing);
    });

    testWidgets('should pass correct selectedCount to FAB', (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: true,
          selectedFileIds: {'file-1', 'file-2'},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final fab =
          tester.widget<TrashActionButtons>(find.byType(TrashActionButtons));
      expect(fab.selectedCount, 2);
    });

    testWidgets('should pass selection mode state to TrashHeader',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: true,
          selectedFileIds: {'file-1', 'file-2'},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final header = tester.widget<TrashHeader>(find.byType(TrashHeader));
      expect(header.isSelectionMode, true);
      expect(header.selectedCount, 2);
    });

    testWidgets('should pass non-selection mode state to TrashHeader',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final header = tester.widget<TrashHeader>(find.byType(TrashHeader));
      expect(header.isSelectionMode, false);
      expect(header.selectedCount, 0);
    });

    // ==================== PROCESSING STATE TESTS ====================

    testWidgets('should render grid for TrashRestoring state', (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashRestoring(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashFilesGrid), findsOneWidget);
      final grid = tester.widget<TrashFilesGrid>(find.byType(TrashFilesGrid));
      expect(grid.isProcessing, true);
    });

    testWidgets('should render grid for TrashDeleting state', (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashDeleting(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashFilesGrid), findsOneWidget);
      final grid = tester.widget<TrashFilesGrid>(find.byType(TrashFilesGrid));
      expect(grid.isProcessing, true);
    });

    // ==================== EDGE CASE TESTS ====================

    testWidgets('should handle many files', (tester) async {
      // Arrange
      final manyFiles = List.generate(
        100,
        (index) => TrashFile(
          id: 'file-$index',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
          deletedAt: testDeletedDate,
          sizeBytes: 1024,
        ),
      );

      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: manyFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashFilesGrid), findsOneWidget);
      final grid = tester.widget<TrashFilesGrid>(find.byType(TrashFilesGrid));
      expect(grid.files.length, 100);
    });

    testWidgets('should handle single file', (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: [testFiles.first],
          currentPage: 0,
          hasNext: false,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashFilesGrid), findsOneWidget);
      final grid = tester.widget<TrashFilesGrid>(find.byType(TrashFilesGrid));
      expect(grid.files.length, 1);
    });

    testWidgets('should handle all files selected in selection mode',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
          selectedFileIds: {'file-1', 'file-2'},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashActionButtons), findsOneWidget);
      final fab =
          tester.widget<TrashActionButtons>(find.byType(TrashActionButtons));
      expect(fab.selectedCount, 2);
    });

    testWidgets('should handle large selection count', (tester) async {
      // Arrange
      final manyFiles = List.generate(
        50,
        (index) => TrashFile(
          id: 'file-$index',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
          deletedAt: testDeletedDate,
          sizeBytes: 1024,
        ),
      );

      final allFileIds = manyFiles.map((f) => f.id).toSet();

      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: manyFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
          selectedFileIds: allFileIds,
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashActionButtons), findsOneWidget);
      final fab =
          tester.widget<TrashActionButtons>(find.byType(TrashActionButtons));
      expect(fab.selectedCount, 50);
    });

    // ==================== STATE TRANSITION TESTS ====================

    testWidgets('should handle transition from loading to loaded',
        (tester) async {
      // Arrange
      final streamController = Stream<TrashState>.fromIterable([
        const TrashLoading(),
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      ]);

      when(() => mockTrashBloc.stream).thenAnswer((_) => streamController);
      when(() => mockTrashBloc.state).thenReturn(const TrashLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for state to update
      await tester.pump();

      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      await tester.pump();

      // Assert - should show grid after loading
      expect(find.byType(TrashFilesGrid), findsOneWidget);
    });

    testWidgets('should handle transition from loaded to error',
        (tester) async {
      // Arrange
      final streamController = Stream<TrashState>.fromIterable([
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
        const TrashError(
          NetworkFailure(messageKey: 'errorNetwork'),
        ),
      ]);

      when(() => mockTrashBloc.stream).thenAnswer((_) => streamController);
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Should show grid initially
      expect(find.byType(TrashFilesGrid), findsOneWidget);

      // Wait for state to update
      await tester.pump();

      when(() => mockTrashBloc.state).thenReturn(
        const TrashError(
          NetworkFailure(messageKey: 'errorNetwork'),
        ),
      );

      await tester.pump();

      // Assert - should show error after transition
      expect(find.byType(ErrorDisplay), findsOneWidget);
    });

    // ==================== MIXED FILE TYPES TESTS ====================

    testWidgets('should handle mixed image and video files', (tester) async {
      // Arrange
      final mixedFiles = [
        TrashFile(
          id: 'image-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
          deletedAt: testDeletedDate,
          sizeBytes: 1024,
        ),
        TrashFile(
          id: 'video-1',
          type: FileType.video,
          status: FileStatus.pending,
          capturedAt: testDate,
          deletedAt: testDeletedDate,
          sizeBytes: 2048,
          durationSeconds: 120,
        ),
        TrashFile(
          id: 'image-2',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
          deletedAt: testDeletedDate,
          sizeBytes: 1024,
        ),
      ];

      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: mixedFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TrashFilesGrid), findsOneWidget);
      final grid = tester.widget<TrashFilesGrid>(find.byType(TrashFilesGrid));
      expect(grid.files.length, 3);
      expect(grid.files.where((f) => f.type == FileType.image).length, 2);
      expect(grid.files.where((f) => f.type == FileType.video).length, 1);
    });

    // ==================== PAGINATION TESTS ====================

    testWidgets('should indicate hasNext when more pages available',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final grid = tester.widget<TrashFilesGrid>(find.byType(TrashFilesGrid));
      expect(grid.hasNext, true);
    });

    testWidgets('should indicate no more pages when on last page',
        (tester) async {
      // Arrange
      when(() => mockTrashBloc.state).thenReturn(
        TrashLoaded(
          files: testFiles,
          currentPage: 5,
          hasNext: false,
          isSelectionMode: false,
          selectedFileIds: const {},
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final grid = tester.widget<TrashFilesGrid>(find.byType(TrashFilesGrid));
      expect(grid.hasNext, false);
    });
  });
}
