import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_page.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/empty_trash_use_case.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/get_trash_files_use_case.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/permanently_delete_files_use_case.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/restore_files_use_case.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_event.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_state.dart';

class MockGetTrashFilesUseCase extends Mock implements GetTrashFilesUseCase {}
class MockRestoreFilesUseCase extends Mock implements RestoreFilesUseCase {}
class MockPermanentlyDeleteFilesUseCase extends Mock implements PermanentlyDeleteFilesUseCase {}
class MockEmptyTrashUseCase extends Mock implements EmptyTrashUseCase {}
class MockAppEventBus extends Mock implements AppEventBus {}

class FakeAppEvent extends Fake implements AppEvent {}

class FakeFileUpdatedEvent extends Fake implements FileUpdatedEvent {}

void main() {
  late TrashBloc bloc;
  late MockGetTrashFilesUseCase mockGetTrashFilesUseCase;
  late MockRestoreFilesUseCase mockRestoreFilesUseCase;
  late MockPermanentlyDeleteFilesUseCase mockPermanentlyDeleteFilesUseCase;
  late MockEmptyTrashUseCase mockEmptyTrashUseCase;
  late MockAppEventBus mockEventBus;

  final now = DateTime.now();
  final testDate = DateTime(2024, 1, 15);
  final deletedDate = now.subtract(const Duration(days: 5));

  final testFiles = [
    TrashFile(
      id: 'file-1',
      type: FileType.image,
      status: FileStatus.managed,
      capturedAt: testDate,
      deletedAt: deletedDate,
      sizeBytes: 1024,
    ),
    TrashFile(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.managed,
      capturedAt: testDate,
      deletedAt: deletedDate,
      sizeBytes: 2048,
      durationSeconds: 120,
    ),
  ];

  final testPage = TrashPage(
    files: testFiles,
    currentPage: 0,
    pageSize: 50,
    hasNext: true,
  );

  setUpAll(() {
    registerFallbackValue(FakeAppEvent());
    registerFallbackValue(FakeFileUpdatedEvent());
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    mockGetTrashFilesUseCase = MockGetTrashFilesUseCase();
    mockRestoreFilesUseCase = MockRestoreFilesUseCase();
    mockPermanentlyDeleteFilesUseCase = MockPermanentlyDeleteFilesUseCase();
    mockEmptyTrashUseCase = MockEmptyTrashUseCase();
    mockEventBus = MockAppEventBus();

    when(() => mockEventBus.on<FileUpdatedEvent>())
        .thenAnswer((_) => const Stream.empty());
    when(() => mockEventBus.fire(any())).thenReturn(null);
  });

  TrashBloc buildBloc() {
    return TrashBloc(
      getTrashFilesUseCase: mockGetTrashFilesUseCase,
      restoreFilesUseCase: mockRestoreFilesUseCase,
      permanentlyDeleteFilesUseCase: mockPermanentlyDeleteFilesUseCase,
      emptyTrashUseCase: mockEmptyTrashUseCase,
      eventBus: mockEventBus,
    );
  }

  group('TrashBloc', () {
    test('initial state is TrashInitial', () {
      bloc = buildBloc();
      expect(bloc.state, const TrashInitial());
      bloc.close();
    });

    group('LoadTrash', () {
      blocTest<TrashBloc, TrashState>(
        'emits [TrashLoading, TrashLoaded] when load succeeds',
        setUp: () {
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => testPage);
        },
        build: () => buildBloc(),
        act: (bloc) => bloc.add(const LoadTrash()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          const TrashLoading(),
          isA<TrashLoaded>()
              .having((s) => s.files.length, 'files length', 2)
              .having((s) => s.currentPage, 'currentPage', 0)
              .having((s) => s.hasNext, 'hasNext', true)
              .having((s) => s.isSelectionMode, 'isSelectionMode', false),
        ],
        verify: (_) {
          verify(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50)).called(1);
        },
      );

      blocTest<TrashBloc, TrashState>(
        'emits [TrashLoading, TrashError] when load fails',
        setUp: () {
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenThrow(Exception('Network error'));
        },
        build: () => buildBloc(),
        act: (bloc) => bloc.add(const LoadTrash()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          const TrashLoading(),
          isA<TrashError>(),
        ],
      );

      blocTest<TrashBloc, TrashState>(
        'returns empty list when no files',
        setUp: () {
          final emptyPage = TrashPage.empty();
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => emptyPage);
        },
        build: () => buildBloc(),
        act: (bloc) => bloc.add(const LoadTrash()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          const TrashLoading(),
          isA<TrashLoaded>()
              .having((s) => s.files, 'files', isEmpty)
              .having((s) => s.hasNext, 'hasNext', false),
        ],
      );
    });

    group('LoadMoreTrash', () {
      blocTest<TrashBloc, TrashState>(
        'loads next page and appends files',
        setUp: () {
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => testPage);
          when(() => mockGetTrashFilesUseCase(page: 1, pageSize: 50))
              .thenAnswer((_) async => TrashPage(
                    files: [
                      TrashFile(
                        id: 'file-3',
                        type: FileType.image,
                        status: FileStatus.managed,
                        capturedAt: testDate,
                        deletedAt: deletedDate,
                        sizeBytes: 512,
                      ),
                    ],
                    currentPage: 1,
                    pageSize: 50,
                    hasNext: false,
                  ));
        },
        build: () => buildBloc(),
        act: (bloc) async {
          bloc.add(const LoadTrash());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(const LoadMoreTrash());
        },
        wait: const Duration(milliseconds: 600),
        expect: () => [
          const TrashLoading(),
          isA<TrashLoaded>().having((s) => s.files.length, 'initial files', 2),
          isA<TrashLoadingMore>(),
          isA<TrashLoaded>()
              .having((s) => s.files.length, 'files length', 3)
              .having((s) => s.currentPage, 'currentPage', 1)
              .having((s) => s.hasNext, 'hasNext', false),
        ],
      );

      blocTest<TrashBloc, TrashState>(
        'does nothing when state is not TrashLoaded',
        build: () => buildBloc(),
        act: (bloc) => bloc.add(const LoadMoreTrash()),
        expect: () => [],
      );

      blocTest<TrashBloc, TrashState>(
        'does nothing when hasNext is false',
        setUp: () {
          final lastPage = TrashPage(
            files: testFiles,
            currentPage: 0,
            pageSize: 50,
            hasNext: false,
          );
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => lastPage);
        },
        build: () => buildBloc(),
        act: (bloc) async {
          bloc.add(const LoadTrash());
          await Future.delayed(const Duration(milliseconds: 900));
          bloc.add(const LoadMoreTrash());
        },
        wait: const Duration(milliseconds: 600),
        expect: () => [
          const TrashLoading(),
          isA<TrashLoaded>().having((s) => s.hasNext, 'hasNext', false),
        ],
        verify: (_) {
          verifyNever(() => mockGetTrashFilesUseCase(page: 1, pageSize: 50));
        },
      );
    });

    group('RefreshTrash', () {
      blocTest<TrashBloc, TrashState>(
        'refreshes trash and maintains selection mode',
        setUp: () {
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => testPage);
        },
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: true,
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
        ),
        act: (bloc) => bloc.add(const RefreshTrash()),
        wait: const Duration(milliseconds: 500),
        expect: () => [
          const TrashLoading(),
          isA<TrashLoaded>()
              .having((s) => s.isSelectionMode, 'isSelectionMode', true)
              .having((s) => s.selectedFileIds, 'selectedFileIds', {'file-1'}),
        ],
      );
    });

    group('Selection Mode', () {
      blocTest<TrashBloc, TrashState>(
        'EnterSelectionMode sets isSelectionMode to true',
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
        ),
        act: (bloc) => bloc.add(const EnterSelectionMode()),
        expect: () => [
          isA<TrashLoaded>()
              .having((s) => s.isSelectionMode, 'isSelectionMode', true),
        ],
      );

      blocTest<TrashBloc, TrashState>(
        'ExitSelectionMode sets isSelectionMode to false and clears selection',
        build: () => buildBloc(),
        seed: () => const TrashLoaded(
          files: [],
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
          selectedFileIds: {'file-1', 'file-2'},
        ),
        act: (bloc) => bloc.add(const ExitSelectionMode()),
        expect: () => [
          isA<TrashLoaded>()
              .having((s) => s.isSelectionMode, 'isSelectionMode', false)
              .having((s) => s.selectedFileIds, 'selectedFileIds', <String>{}),
        ],
      );

      blocTest<TrashBloc, TrashState>(
        'ToggleFileSelection adds file to selection',
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
        ),
        act: (bloc) => bloc.add(const ToggleFileSelection('file-1')),
        expect: () => [
          isA<TrashLoaded>()
              .having((s) => s.selectedFileIds, 'selectedFileIds', {'file-1'}),
        ],
      );

      blocTest<TrashBloc, TrashState>(
        'ToggleFileSelection removes file from selection',
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
        ),
        act: (bloc) => bloc.add(const ToggleFileSelection('file-1')),
        expect: () => [
          isA<TrashLoaded>()
              .having((s) => s.selectedFileIds, 'selectedFileIds', <String>{}),
        ],
      );

      blocTest<TrashBloc, TrashState>(
        'SelectAllFiles selects all files',
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
        ),
        act: (bloc) => bloc.add(const SelectAllFiles()),
        expect: () => [
          isA<TrashLoaded>()
              .having((s) => s.isSelectionMode, 'isSelectionMode', true)
              .having((s) => s.selectedFileIds, 'selectedFileIds',
                  {'file-1', 'file-2'}),
        ],
      );

      blocTest<TrashBloc, TrashState>(
        'ClearSelection clears all selections',
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
          selectedFileIds: {'file-1', 'file-2'},
        ),
        act: (bloc) => bloc.add(const ClearSelection()),
        expect: () => [
          isA<TrashLoaded>()
              .having((s) => s.selectedFileIds, 'selectedFileIds', <String>{}),
        ],
      );
    });

    group('RestoreSelectedFiles', () {
      blocTest<TrashBloc, TrashState>(
        'emits success states and fires event',
        setUp: () {
          when(() => mockRestoreFilesUseCase(any()))
              .thenAnswer((_) async => {});
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => TrashPage.empty());
        },
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
        ),
        act: (bloc) => bloc.add(const RestoreSelectedFiles()),
        wait: const Duration(milliseconds: 2000),
        expect: () => [
          isA<TrashRestoring>(),
          isA<TrashRestoreSuccess>()
              .having((s) => s.restoredCount, 'restoredCount', 1),
          const TrashLoading(),
          isA<TrashLoaded>(),
        ],
        verify: (_) {
          verify(() => mockRestoreFilesUseCase(['file-1'])).called(1);
          verify(() => mockEventBus.fire(any<FileUpdatedEvent>())).called(1);
        },
      );

      blocTest<TrashBloc, TrashState>(
        'emits error state when restore fails',
        setUp: () {
          when(() => mockRestoreFilesUseCase(any()))
              .thenThrow(Exception('Network error'));
        },
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
        ),
        act: (bloc) => bloc.add(const RestoreSelectedFiles()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<TrashRestoring>(),
          isA<TrashRestoreError>(),
        ],
      );

      blocTest<TrashBloc, TrashState>(
        'does nothing when no files selected',
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
        ),
        act: (bloc) => bloc.add(const RestoreSelectedFiles()),
        expect: () => [],
      );
    });

    group('RestoreFiles', () {
      blocTest<TrashBloc, TrashState>(
        'restores specific files',
        setUp: () {
          when(() => mockRestoreFilesUseCase(any()))
              .thenAnswer((_) async => {});
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => TrashPage.empty());
        },
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
        ),
        act: (bloc) => bloc.add(const RestoreFiles(['file-1', 'file-2'])),
        wait: const Duration(milliseconds: 2000),
        expect: () => [
          isA<TrashRestoring>(),
          isA<TrashRestoreSuccess>()
              .having((s) => s.restoredCount, 'restoredCount', 2),
          const TrashLoading(),
          isA<TrashLoaded>(),
        ],
        verify: (_) {
          verify(() => mockRestoreFilesUseCase(['file-1', 'file-2'])).called(1);
        },
      );
    });

    group('PermanentlyDeleteSelectedFiles', () {
      blocTest<TrashBloc, TrashState>(
        'emits success states and fires event',
        setUp: () {
          when(() => mockPermanentlyDeleteFilesUseCase(any()))
              .thenAnswer((_) async => {});
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => TrashPage.empty());
        },
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
        ),
        act: (bloc) => bloc.add(const PermanentlyDeleteSelectedFiles()),
        wait: const Duration(milliseconds: 2000),
        expect: () => [
          isA<TrashDeleting>(),
          isA<TrashDeleteSuccess>()
              .having((s) => s.deletedCount, 'deletedCount', 1),
          const TrashLoading(),
          isA<TrashLoaded>(),
        ],
        verify: (_) {
          verify(() => mockPermanentlyDeleteFilesUseCase(['file-1'])).called(1);
          verify(() => mockEventBus.fire(any<FileUpdatedEvent>())).called(1);
        },
      );

      blocTest<TrashBloc, TrashState>(
        'emits error state when delete fails',
        setUp: () {
          when(() => mockPermanentlyDeleteFilesUseCase(any()))
              .thenThrow(Exception('Network error'));
        },
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
          isSelectionMode: true,
          selectedFileIds: {'file-1'},
        ),
        act: (bloc) => bloc.add(const PermanentlyDeleteSelectedFiles()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<TrashDeleting>(),
          isA<TrashDeleteError>(),
        ],
      );
    });

    group('PermanentlyDeleteFiles', () {
      blocTest<TrashBloc, TrashState>(
        'deletes specific files',
        setUp: () {
          when(() => mockPermanentlyDeleteFilesUseCase(any()))
              .thenAnswer((_) async => {});
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => TrashPage.empty());
        },
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
        ),
        act: (bloc) => bloc.add(const PermanentlyDeleteFiles(['file-1'])),
        wait: const Duration(milliseconds: 2000),
        expect: () => [
          isA<TrashDeleting>(),
          isA<TrashDeleteSuccess>()
              .having((s) => s.deletedCount, 'deletedCount', 1),
          const TrashLoading(),
          isA<TrashLoaded>(),
        ],
      );
    });

    group('EmptyTrashRequested', () {
      blocTest<TrashBloc, TrashState>(
        'empties entire trash successfully',
        setUp: () {
          when(() => mockEmptyTrashUseCase()).thenAnswer((_) async => {});
          when(() => mockGetTrashFilesUseCase(page: 0, pageSize: 50))
              .thenAnswer((_) async => TrashPage.empty());
        },
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
        ),
        act: (bloc) => bloc.add(const EmptyTrashRequested()),
        wait: const Duration(milliseconds: 2000),
        expect: () => [
          isA<TrashDeleting>(),
          isA<TrashDeleteSuccess>()
              .having((s) => s.deletedCount, 'deletedCount', 2),
          const TrashLoading(),
          isA<TrashLoaded>(),
        ],
        verify: (_) {
          verify(() => mockEmptyTrashUseCase()).called(1);
          verify(() => mockEventBus.fire(any<FileUpdatedEvent>())).called(1);
        },
      );

      blocTest<TrashBloc, TrashState>(
        'emits error state when empty trash fails',
        setUp: () {
          when(() => mockEmptyTrashUseCase())
              .thenThrow(Exception('Network error'));
        },
        build: () => buildBloc(),
        seed: () => TrashLoaded(
          files: testFiles,
          currentPage: 0,
          hasNext: false,
        ),
        act: (bloc) => bloc.add(const EmptyTrashRequested()),
        wait: const Duration(milliseconds: 900),
        expect: () => [
          isA<TrashDeleting>(),
          isA<TrashDeleteError>(),
        ],
      );
    });
  });
}
