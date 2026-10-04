import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/pending_files.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_files_use_case.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_pending_file_ids_use_case.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_state.dart';

class MockGetFilesUseCase extends Mock implements GetFilesUseCase {}
class MockGetPendingFileIdsUseCase extends Mock implements GetPendingFileIdsUseCase {}
class MockAppEventBus extends Mock implements AppEventBus {}
class FakeStreamSubscription<T> extends Fake implements StreamSubscription<T> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeStreamSubscription<FileUpdatedEvent>());
    registerFallbackValue(FakeStreamSubscription<FolderUpdatedEvent>());
    registerFallbackValue(FakeStreamSubscription<SyncCompletedEvent>());
    registerFallbackValue(FileFilter.all);
  });
  late GalleryBloc bloc;
  late MockGetFilesUseCase mockGetFilesUseCase;
  late MockGetPendingFileIdsUseCase mockGetPendingFileIdsUseCase;
  late MockAppEventBus mockEventBus;

  setUp(() {
    mockGetFilesUseCase = MockGetFilesUseCase();
    mockGetPendingFileIdsUseCase = MockGetPendingFileIdsUseCase();
    mockEventBus = MockAppEventBus();

    // Mock event bus streams
    when(() => mockEventBus.on<FileUpdatedEvent>())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockEventBus.on<FolderUpdatedEvent>())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockEventBus.on<SyncCompletedEvent>())
        .thenAnswer((_) => const Stream.empty());

    bloc = GalleryBloc(
      getFilesUseCase: mockGetFilesUseCase,
      getPendingFileIdsUseCase: mockGetPendingFileIdsUseCase,
      eventBus: mockEventBus,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testDate = DateTime(2024, 1, 15);

  final testFiles = [
    GalleryFile(
      id: 'file-1',
      type: FileType.image,
      status: FileStatus.managed,
      capturedAt: testDate,
    ),
    GalleryFile(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.pending,
      durationSeconds: 120,
      capturedAt: testDate,
    ),
  ];

  final testPage = GalleryPage(
    files: testFiles,
    currentPage: 0,
    pageSize: 50,
    hasNext: true,
    totalFilesCount: 100,
    totalPendingCount: 1,
  );

  // Helper to create grouped files for tests
  List<FileDateGroup> groupTestFiles(List<GalleryFile> files) {
    return DateGroupingUtil.groupFilesByDate(files);
  }

  group('GalleryBloc', () {
    test('initial state should be GalleryStarting', () {
      expect(bloc.state, equals(const GalleryStarting()));
    });

    blocTest<GalleryBloc, GalleryState>(
      'emits [GalleryLoading, GalleryLoaded] when LoadGallery succeeds',
      setUp: () {
        when(() => mockGetFilesUseCase.call(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => testPage);
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadGallery()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const GalleryLoading(filter: FileFilter.all),
        isA<GalleryLoaded>()
            .having((s) => s.files.length, 'files count', 2)
            .having((s) => s.isSelectionMode, 'selection mode', false)
            .having((s) => s.selectedFileIds, 'selected files', isEmpty)
            .having((s) => s.hasNext, 'has next', true)
            .having((s) => s.currentPage, 'current page', 0)
            .having((s) => s.filter, 'filter', FileFilter.all),
      ],
      verify: (_) {
        verify(() => mockGetFilesUseCase.call(
              page: 0,
              pageSize: 50,
              filter: FileFilter.all,
            )).called(1);
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits [GalleryLoading, GalleryLoaded] with images filter',
      setUp: () {
        when(() => mockGetFilesUseCase.call(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => testPage);
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadGallery(filter: FileFilter.images)),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const GalleryLoading(filter: FileFilter.images),
        isA<GalleryLoaded>()
            .having((s) => s.filter, 'filter', FileFilter.images),
      ],
      verify: (_) {
        verify(() => mockGetFilesUseCase.call(
              page: 0,
              pageSize: 50,
              filter: FileFilter.images,
            )).called(1);
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits [GalleryLoading, GalleryError] when LoadGallery fails',
      setUp: () {
        when(() => mockGetFilesUseCase.call(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filter: any(named: 'filter'),
            )).thenThrow(Exception('Network error'));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadGallery()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const GalleryLoading(filter: FileFilter.all),
        isA<GalleryError>().having((s) => s.failure, 'failure', isA<Failure>()),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'loads more files and appends to existing list',
      setUp: () {
        final nextPageFiles = [
          GalleryFile(
            id: 'file-3',
            type: FileType.image,
            status: FileStatus.managed,
            capturedAt: testDate,
          ),
        ];

        final nextPage = GalleryPage(
          files: nextPageFiles,
          currentPage: 1,
          pageSize: 50,
          hasNext: false,
          totalFilesCount: 100,
          totalPendingCount: 1,
        );

        when(() => mockGetFilesUseCase.call(
              page: 1,
              pageSize: 50,
              filter: FileFilter.all,
            )).thenAnswer((_) async => nextPage);
      },
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadMoreFiles()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        isA<GalleryLoadingMore>()
            .having((s) => s.files.length, 'files count', 2)
            .having((s) => s.currentPage, 'current page', 0)
            .having((s) => s.filter, 'filter', FileFilter.all),
        isA<GalleryLoaded>()
            .having((s) => s.files.length, 'files count', 3)
            .having((s) => s.currentPage, 'current page', 1)
            .having((s) => s.hasNext, 'has next', false),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'does not load more when hasNext is false',
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: false,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadMoreFiles()),
      expect: () => [],
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits error when LoadMoreFiles fails',
      setUp: () {
        when(() => mockGetFilesUseCase.call(
              page: 1,
              pageSize: 50,
              filter: FileFilter.all,
            )).thenThrow(Exception('Network error'));
      },
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadMoreFiles()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        isA<GalleryLoadingMore>(),
        isA<GalleryError>(),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'refreshes gallery and maintains filter',
      setUp: () {
        when(() => mockGetFilesUseCase.call(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => testPage);
      },
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 2,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.images,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const RefreshGallery()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        // Refresh keeps the grid visible (no GalleryLoading) to preserve scroll
        isA<GalleryLoaded>()
            .having((s) => s.isRefreshing, 'is refreshing', true)
            .having((s) => s.filter, 'filter', FileFilter.images),
        isA<GalleryLoaded>()
            .having((s) => s.isRefreshing, 'is refreshing', false)
            .having((s) => s.filter, 'filter', FileFilter.images)
            .having((s) => s.currentPage, 'current page', 0),
      ],
      verify: (_) {
        verify(() => mockGetFilesUseCase.call(
              page: 0,
              pageSize: 50,
              filter: FileFilter.images,
            )).called(1);
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'enters selection mode',
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const EnterSelectionMode()),
      expect: () => [
        isA<GalleryLoaded>()
            .having((s) => s.isSelectionMode, 'selection mode', true),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'exits selection mode and clears selection',
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: true,
        selectedFileIds: const {'file-1', 'file-2'},
        hasNext: true,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const ExitSelectionMode()),
      expect: () => [
        isA<GalleryLoaded>()
            .having((s) => s.isSelectionMode, 'selection mode', false)
            .having((s) => s.selectedFileIds, 'selected files', isEmpty),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'toggles file selection - adds file',
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: true,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const ToggleFileSelection('file-1')),
      expect: () => [
        isA<GalleryLoaded>()
            .having((s) => s.selectedFileIds, 'selected files', {'file-1'}),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'toggles file selection - removes file',
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: true,
        selectedFileIds: const {'file-1'},
        hasNext: true,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const ToggleFileSelection('file-1')),
      expect: () => [
        isA<GalleryLoaded>()
            .having((s) => s.selectedFileIds, 'selected files', isEmpty),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'selects all files',
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const SelectAllFiles()),
      expect: () => [
        isA<GalleryLoaded>()
            .having((s) => s.isSelectionMode, 'selection mode', true)
            .having((s) => s.selectedFileIds, 'selected files', {'file-1', 'file-2'}),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'clears selection',
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: true,
        selectedFileIds: const {'file-1', 'file-2'},
        hasNext: true,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const ClearSelection()),
      expect: () => [
        isA<GalleryLoaded>()
            .having((s) => s.selectedFileIds, 'selected files', isEmpty),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'maintains selection mode during refresh',
      setUp: () {
        when(() => mockGetFilesUseCase.call(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => testPage);
      },
      seed: () => GalleryLoaded(
        files: testFiles,
        groupedFiles: groupTestFiles(testFiles),
        isSelectionMode: true,
        selectedFileIds: const {'file-1'},
        hasNext: true,
        currentPage: 0,
        totalFilesCount: 100,
        totalPendingCount: 1,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const RefreshGallery()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        isA<GalleryLoaded>()
            .having((s) => s.isRefreshing, 'is refreshing', true)
            .having((s) => s.isSelectionMode, 'selection mode', true),
        isA<GalleryLoaded>()
            .having((s) => s.isRefreshing, 'is refreshing', false)
            .having((s) => s.isSelectionMode, 'selection mode', true)
            .having((s) => s.selectedFileIds, 'selected files', {'file-1'}),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'handles empty result',
      setUp: () {
        const emptyPage = GalleryPage(
          files: [],
          currentPage: 0,
          pageSize: 50,
          hasNext: false,
          totalFilesCount: 0,
          totalPendingCount: 0,
        );

        when(() => mockGetFilesUseCase.call(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              filter: any(named: 'filter'),
            )).thenAnswer((_) async => emptyPage);
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadGallery()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const GalleryLoading(filter: FileFilter.all),
        isA<GalleryLoaded>()
            .having((s) => s.files, 'files', isEmpty)
            .having((s) => s.isEmpty, 'isEmpty', true),
      ],
    );
      // ==================== REVIEW PENDING TESTS ====================

    GalleryFile pendingFile(int i) => GalleryFile(
          id: 'pending-$i',
          type: FileType.image,
          status: FileStatus.pending,
          capturedAt: DateTime(2024, 1, 15),
        );

    GalleryPage pendingPage(int page, int count, {required bool hasNext, int total = 0}) => GalleryPage(
          files: List.generate(count, (i) => pendingFile(page * 50 + i)),
          currentPage: page,
          pageSize: 50,
          hasNext: hasNext,
          totalFilesCount: total,
          totalPendingCount: total,
        );

    PendingFiles pendingIds(int count, {int size = 0}) => PendingFiles(
          fileIds: List.generate(count, (i) => 'pending-$i'),
          totalSizeBytes: size,
        );

    blocTest<GalleryBloc, GalleryState>(
      'selects every pending file and requests the review',
      setUp: () {
        when(() => mockGetPendingFileIdsUseCase.call()).thenAnswer((_) async => pendingIds(3, size: 3000));
        when(() => mockGetFilesUseCase.call(page: 0, pageSize: 50, filter: FileFilter.pending))
            .thenAnswer((_) async => pendingPage(0, 3, hasNext: false, total: 3));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const ReviewPendingFiles()),
      expect: () => [
        const GalleryLoading(filter: FileFilter.pending),
        isA<GalleryLoaded>()
            .having((s) => s.filter, 'filter', FileFilter.pending)
            .having((s) => s.isSelectionMode, 'selection mode', true)
            .having((s) => s.selectedFileIds, 'selected', {'pending-0', 'pending-1', 'pending-2'})
            .having((s) => s.reviewRequested, 'review requested', true)
            .having((s) => s.selectedSizeBytes, 'selected size', 3000)
            .having((s) => s.selectionLimitReached, 'limit', false),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'selects more than 100 pending files with one call and loads only the first page',
      setUp: () {
        when(() => mockGetPendingFileIdsUseCase.call())
            .thenAnswer((_) async => pendingIds(120, size: 48 * 1024 * 1024));
        when(() => mockGetFilesUseCase.call(page: 0, pageSize: 50, filter: FileFilter.pending))
            .thenAnswer((_) async => pendingPage(0, 50, hasNext: true, total: 120));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const ReviewPendingFiles()),
      expect: () => [
        const GalleryLoading(filter: FileFilter.pending),
        isA<GalleryLoaded>()
            .having((s) => s.files.length, 'files', 50)
            .having((s) => s.selectedFileIds.length, 'selected', 120)
            .having((s) => s.currentPage, 'current page', 0)
            .having((s) => s.hasNext, 'has next', true)
            .having((s) => s.selectedSizeBytes, 'selected size', 48 * 1024 * 1024)
            .having((s) => s.selectionLimitReached, 'limit', false),
      ],
      verify: (_) {
        verify(() => mockGetPendingFileIdsUseCase.call()).called(1);
        verify(() => mockGetFilesUseCase.call(page: 0, pageSize: 50, filter: FileFilter.pending)).called(1);
        verifyNoMoreInteractions(mockGetFilesUseCase);
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'does not request a review without pending files',
      setUp: () {
        when(() => mockGetPendingFileIdsUseCase.call()).thenAnswer((_) async => pendingIds(0));
        when(() => mockGetFilesUseCase.call(page: 0, pageSize: 50, filter: FileFilter.pending))
            .thenAnswer((_) async => pendingPage(0, 0, hasNext: false));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const ReviewPendingFiles()),
      expect: () => [
        const GalleryLoading(filter: FileFilter.pending),
        isA<GalleryLoaded>()
            .having((s) => s.reviewRequested, 'review requested', false)
            .having((s) => s.isSelectionMode, 'selection mode', false),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits an error when loading the pending IDs fails',
      setUp: () {
        when(() => mockGetPendingFileIdsUseCase.call()).thenThrow(Exception('Network error'));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const ReviewPendingFiles()),
      expect: () => [
        const GalleryLoading(filter: FileFilter.pending),
        isA<GalleryError>(),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits an error when loading the pending files fails',
      setUp: () {
        when(() => mockGetPendingFileIdsUseCase.call()).thenAnswer((_) async => pendingIds(3));
        when(() => mockGetFilesUseCase.call(page: 0, pageSize: 50, filter: FileFilter.pending))
            .thenThrow(Exception('Network error'));
      },
      build: () => bloc,
      act: (bloc) => bloc.add(const ReviewPendingFiles()),
      expect: () => [
        const GalleryLoading(filter: FileFilter.pending),
        isA<GalleryError>(),
      ],
    );

    // ==================== SELECTED SIZE TESTS ====================

    group('selectedSizeBytes', () {
      GalleryLoaded loaded({Set<String> selected = const {}, int? reviewSize}) => GalleryLoaded(
            files: [
              GalleryFile(id: 'a', type: FileType.image, status: FileStatus.pending, capturedAt: testDate, sizeBytes: 100),
              GalleryFile(id: 'b', type: FileType.image, status: FileStatus.pending, capturedAt: testDate, sizeBytes: 250),
              GalleryFile(id: 'c', type: FileType.image, status: FileStatus.pending, capturedAt: testDate, sizeBytes: 50),
            ],
            groupedFiles: const [],
            isSelectionMode: true,
            selectedFileIds: selected,
            hasNext: false,
            currentPage: 0,
            totalFilesCount: 3,
            totalPendingCount: 3,
            filter: FileFilter.all,
            reviewSizeBytes: reviewSize,
          );

      test('should add up the sizes of the selected files', () {
        expect(loaded(selected: {'a', 'b'}).selectedSizeBytes, 350);
      });

      test('should be 0 without selection', () {
        expect(loaded().selectedSizeBytes, 0);
      });

      test('should use the review total while the selection is unchanged', () {
        final state = loaded(selected: {'a'}, reviewSize: 9999);
        expect(state.selectedSizeBytes, 9999);
        expect(state.copyWith(isSelectionMode: true).selectedSizeBytes, 9999);
      });

      test('should drop the review total when the selection changes', () {
        final state = loaded(selected: {'a'}, reviewSize: 9999);
        expect(state.copyWith(selectedFileIds: {'a', 'c'}).selectedSizeBytes, 150);
      });
    });

    blocTest<GalleryBloc, GalleryState>(
      'should update the selected size when toggling files',
      build: () => bloc,
      seed: () => GalleryLoaded(
        files: [
          GalleryFile(id: 'a', type: FileType.image, status: FileStatus.pending, capturedAt: testDate, sizeBytes: 100),
          GalleryFile(id: 'b', type: FileType.image, status: FileStatus.pending, capturedAt: testDate, sizeBytes: 250),
        ],
        groupedFiles: const [],
        isSelectionMode: true,
        selectedFileIds: const {'a'},
        hasNext: false,
        currentPage: 0,
        totalFilesCount: 2,
        totalPendingCount: 2,
        filter: FileFilter.all,
      ),
      act: (bloc) => bloc.add(const ToggleFileSelection('b')),
      expect: () => [
        isA<GalleryLoaded>().having((s) => s.selectedSizeBytes, 'selected size', 350),
      ],
    );

    test('reviewRequested is a one-shot flag cleared by copyWith', () {
      const state = GalleryLoaded(
        files: [],
        groupedFiles: [],
        isSelectionMode: true,
        selectedFileIds: {'a'},
        hasNext: false,
        currentPage: 0,
        totalFilesCount: 0,
        totalPendingCount: 1,
        filter: FileFilter.pending,
        reviewRequested: true,
      );
      expect(state.copyWith().reviewRequested, isFalse);
    });

});
}
