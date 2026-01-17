import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_files_use_case.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_state.dart';

class MockGetFilesUseCase extends Mock implements GetFilesUseCase {}
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
  late MockAppEventBus mockEventBus;

  setUp(() {
    mockGetFilesUseCase = MockGetFilesUseCase();
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
  );

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
        );

        when(() => mockGetFilesUseCase.call(
              page: 1,
              pageSize: 50,
              filter: FileFilter.all,
            )).thenAnswer((_) async => nextPage);
      },
      seed: () => GalleryLoaded(
        files: testFiles,
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadMoreFiles()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        GalleryLoadingMore(
          files: testFiles,
          isSelectionMode: false,
          selectedFileIds: const {},
          currentPage: 0,
          filter: FileFilter.all,
        ),
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
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: false,
        currentPage: 0,
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
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
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
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 2,
        filter: FileFilter.images,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const RefreshGallery()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const GalleryLoading(filter: FileFilter.images),
        isA<GalleryLoaded>()
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
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
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
        isSelectionMode: true,
        selectedFileIds: {'file-1', 'file-2'},
        hasNext: true,
        currentPage: 0,
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
        isSelectionMode: true,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
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
        isSelectionMode: true,
        selectedFileIds: {'file-1'},
        hasNext: true,
        currentPage: 0,
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
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: true,
        currentPage: 0,
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
        isSelectionMode: true,
        selectedFileIds: {'file-1', 'file-2'},
        hasNext: true,
        currentPage: 0,
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
        isSelectionMode: true,
        selectedFileIds: {'file-1'},
        hasNext: true,
        currentPage: 0,
        filter: FileFilter.all,
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(const RefreshGallery()),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        const GalleryLoading(filter: FileFilter.all),
        isA<GalleryLoaded>()
            .having((s) => s.isSelectionMode, 'selection mode', true)
            .having((s) => s.selectedFileIds, 'selected files', {'file-1'}),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'handles empty result',
      setUp: () {
        final emptyPage = GalleryPage(
          files: const [],
          currentPage: 0,
          pageSize: 50,
          hasNext: false,
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
  });
}
