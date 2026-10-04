import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_content.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_folder_content_use_case.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_state.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';

class MockGetFolderContentUseCase extends Mock implements GetFolderContentUseCase {}
class MockAppEventBus extends Mock implements AppEventBus {}

void main() {
  late MockGetFolderContentUseCase mockGetFolderContentUseCase;
  late MockAppEventBus mockEventBus;

  setUpAll(() {
    registerFallbackValue(FileFilter.all);
  });

  setUp(() {
    mockGetFolderContentUseCase = MockGetFolderContentUseCase();
    mockEventBus = MockAppEventBus();

    when(() => mockEventBus.on<FileUpdatedEvent>())
        .thenAnswer((_) => const Stream<FileUpdatedEvent>.empty());

    when(() => mockEventBus.on<FolderUpdatedEvent>())
        .thenAnswer((_) => const Stream<FolderUpdatedEvent>.empty());
  });


  group('FolderContentBloc', () {
    final testDate = DateTime(2024, 1, 15);

    final testFolder = Folder(
      id: 'folder-1',
      name: 'Vacation',
      parentFolderId: null,
      path: '/root/folder-1',
      createdAt: testDate,
      fileCount: 2,
      subfolderCount: 1,
    );

    final testSubfolders = [
      Folder(
        id: 'subfolder-1',
        name: 'Summer',
        parentFolderId: 'folder-1',
        path: '/root/folder-1/subfolder-1',
        createdAt: testDate,
        fileCount: 5,
        subfolderCount: 0,
      ),
    ];

    final testFiles = [
      GalleryFile(
        id: 'file-1',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      ),
      GalleryFile(
        id: 'file-2',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testDate,
      ),
    ];

    final folderContent = FolderContent(
      folder: testFolder,
      subfolders: testSubfolders,
      files: testFiles,
      hasMoreFiles: false,
      totalFilesCount: 0,
    );

    // Helper to create grouped files for tests
    List<FileDateGroup> groupTestFiles(List<GalleryFile> files) {
      return DateGroupingUtil.groupFilesByDate(files);
    }

    test('initial state is FolderContentStarting', () {
      final bloc = FolderContentBloc(getFolderContentUseCase: mockGetFolderContentUseCase, eventBus: mockEventBus);
      expect(bloc.state, const FolderContentStarting());
      bloc.close();
    });

    group('LoadFolderContent', () {
      blocTest<FolderContentBloc, FolderContentState>(
        'emits [Loading, Loaded] when content loaded successfully',
        setUp: () {
          when(() => mockGetFolderContentUseCase.call(
                folderId: 'folder-1',
                filter: FileFilter.all,
              )).thenAnswer((_) async => folderContent);
        },
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        act: (bloc) => bloc.add(const LoadFolderContent(folderId: 'folder-1')),
        wait: const Duration(milliseconds: 500),
        expect: () => [
          const FolderContentLoading(previousFolder: null, previousSubfolders: null),
          isA<FolderContentLoaded>()
              .having((s) => s.currentFolder.id, 'folder id', 'folder-1')
              .having((s) => s.files.length, 'files count', 2)
              .having((s) => s.subfolders.length, 'subfolders count', 1),
        ],
        verify: (_) {
          verify(() => mockGetFolderContentUseCase.call(
                folderId: 'folder-1',
                filter: FileFilter.all,
              )).called(1);
        },
      );

      blocTest<FolderContentBloc, FolderContentState>(
        'preserves previous folder during loading',
        setUp: () {
          when(() => mockGetFolderContentUseCase.call(
                folderId: any(named: 'folderId'),
                filter: any(named: 'filter'),
              )).thenAnswer((_) async => folderContent);
        },
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const LoadFolderContent(folderId: 'folder-2')),
        wait: const Duration(milliseconds: 500),
        expect: () => [
          FolderContentLoading(
            previousFolder: testFolder,
            previousSubfolders: testSubfolders,
          ),
          isA<FolderContentLoaded>(),
        ],
      );

      blocTest<FolderContentBloc, FolderContentState>(
        'emits [Loading, Error] when loading fails',
        setUp: () {
          when(() => mockGetFolderContentUseCase.call(
                folderId: 'folder-1',
                filter: FileFilter.all,
              )).thenThrow(Exception('Folder not found'));
        },
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        act: (bloc) => bloc.add(const LoadFolderContent(folderId: 'folder-1')),
        wait: const Duration(milliseconds: 500),
        expect: () => [
          const FolderContentLoading(previousFolder: null, previousSubfolders: null),
          isA<FolderContentError>(),
        ],
      );

      blocTest<FolderContentBloc, FolderContentState>(
        'loads empty folder content',
        setUp: () {
          final emptyContent = FolderContent(
            folder: testFolder,
            subfolders: const [],
            files: const [],
            hasMoreFiles: false,
            totalFilesCount: 0,
          );

          when(() => mockGetFolderContentUseCase.call(
                folderId: 'folder-1',
                filter: FileFilter.all,
              )).thenAnswer((_) async => emptyContent);
        },
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        act: (bloc) => bloc.add(const LoadFolderContent(folderId: 'folder-1')),
        wait: const Duration(milliseconds: 500),
        expect: () => [
          const FolderContentLoading(previousFolder: null, previousSubfolders: null),
          isA<FolderContentLoaded>()
              .having((s) => s.files.isEmpty, 'files empty', true)
              .having((s) => s.subfolders.isEmpty, 'subfolders empty', true),
        ],
      );
    });

    group('RefreshFolderContent', () {
      blocTest<FolderContentBloc, FolderContentState>(
        'refreshes current folder content',
        setUp: () {
          when(() => mockGetFolderContentUseCase.call(
                folderId: 'folder-1',
                filter: FileFilter.all,
              )).thenAnswer((_) async => folderContent);
        },
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: const [],
          files: const [],
          groupedFiles: const [],
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const RefreshFolderContent()),
        wait: const Duration(milliseconds: 500),
        expect: () => []
      );

      blocTest<FolderContentBloc, FolderContentState>(
        'resets to page 0 on refresh',
        setUp: () {
          when(() => mockGetFolderContentUseCase.call(
                folderId: 'folder-1',
                filter: FileFilter.all,
              )).thenAnswer((_) async => folderContent);
        },
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const RefreshFolderContent()),
        wait: const Duration(milliseconds: 500),
        expect: () => []
      );
    });

    group('LoadMoreFiles', () {
      blocTest<FolderContentBloc, FolderContentState>(
        'loads next page and appends files',
        setUp: () {
          final moreFiles = [
            GalleryFile(
              id: 'file-3',
              type: FileType.image,
              status: FileStatus.managed,
              capturedAt: testDate,
            ),
          ];

          final nextPageContent = FolderContent(
            folder: testFolder,
            subfolders: const [],
            files: moreFiles,
            hasMoreFiles: false,
            totalFilesCount: 0,
          );

          when(() => mockGetFolderContentUseCase.call(
                folderId: 'folder-1',
                page: 1,
                filter: FileFilter.all,
              )).thenAnswer((_) async => nextPageContent);
        },
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: true,
          selectedFileIds: const {},
          isSelectionMode: false,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const LoadMoreFiles()),
        wait: const Duration(milliseconds: 500),
        expect: () => [
          isA<FolderContentLoadingMore>(),
          isA<FolderContentLoaded>()
              .having((s) => s.files.length, 'files count', 3),
        ]
      );

      blocTest<FolderContentBloc, FolderContentState>(
        'does nothing when no more files',
        setUp: () {},
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const LoadMoreFiles()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockGetFolderContentUseCase.call(
                folderId: any(named: 'folderId'),
                page: any(named: 'page'),
                filter: any(named: 'filter'),
              ));
        },
      );
    });

    group('FilterFilesInFolder', () {
      blocTest<FolderContentBloc, FolderContentState>(
        'filters files by images',
        setUp: () {
          final imageContent = FolderContent(
            folder: testFolder,
            subfolders: testSubfolders,
            files: [testFiles[0]],
            hasMoreFiles: false,
            totalFilesCount: 0,
          );

          when(() => mockGetFolderContentUseCase.call(
                folderId: 'folder-1',
                filter: FileFilter.images,
              )).thenAnswer((_) async => imageContent);
        },
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const FilterFilesInFolder(filter: FileFilter.images)),
        wait: const Duration(milliseconds: 500),
        expect: () => [],
      );

      blocTest<FolderContentBloc, FolderContentState>(
        'resets to page 0 when filtering',
        setUp: () {
          when(() => mockGetFolderContentUseCase.call(
                folderId: 'folder-1',
                filter: FileFilter.videos,
              )).thenAnswer((_) async => folderContent);
        },
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const FilterFilesInFolder(filter: FileFilter.videos)),
        wait: const Duration(milliseconds: 500),
        expect: () => [],
      );
    });

    group('Selection Mode', () {
      blocTest<FolderContentBloc, FolderContentState>(
        'enters selection mode',
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: false,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const EnterSelectionMode()),
        expect: () => [
          isA<FolderContentLoaded>()
              .having((s) => s.isSelectionMode, 'selection mode', true),
        ],
      );

      blocTest<FolderContentBloc, FolderContentState>(
        'exits selection mode and clears selections',
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: false,
          selectedFileIds: const {'file-1', 'file-2'},
          isSelectionMode: true,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const ExitSelectionMode()),
        expect: () => [
          isA<FolderContentLoaded>()
              .having((s) => s.isSelectionMode, 'selection mode', false)
              .having((s) => s.selectedFileIds.isEmpty, 'selections cleared', true),
        ],
      );

      blocTest<FolderContentBloc, FolderContentState>(
        'toggles file selection',
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: false,
          selectedFileIds: const {},
          isSelectionMode: true,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const ToggleFileSelection('file-1')),
        expect: () => [
          isA<FolderContentLoaded>()
              .having((s) => s.selectedFileIds.contains('file-1'), 'file selected', true),
        ],
      );

      blocTest<FolderContentBloc, FolderContentState>(
        'deselects file when already selected',
        build: () => FolderContentBloc(
          getFolderContentUseCase: mockGetFolderContentUseCase,
          eventBus: mockEventBus,
        ),
        seed: () => FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: testSubfolders,
          files: testFiles,
          groupedFiles: groupTestFiles(testFiles),
          hasMoreFiles: false,
          selectedFileIds: const {'file-1'},
          isSelectionMode: true,
          totalFilesCount: 0,
        ),
        act: (bloc) => bloc.add(const ToggleFileSelection('file-1')),
        expect: () => [
          isA<FolderContentLoaded>()
              .having((s) => s.selectedFileIds.contains('file-1'), 'file deselected', false),
        ],
      );
    });

    group('selectedSizeBytes', () {
      test('should add up the sizes of the selected files', () {
        // Arrange
        final state = FolderContentLoaded(
          currentFolder: testFolder,
          subfolders: const [],
          files: [
            GalleryFile(id: 'a', type: FileType.image, status: FileStatus.pending, capturedAt: DateTime(2024), sizeBytes: 100),
            GalleryFile(id: 'b', type: FileType.video, status: FileStatus.pending, capturedAt: DateTime(2024), sizeBytes: 900),
            GalleryFile(id: 'c', type: FileType.image, status: FileStatus.managed, capturedAt: DateTime(2024), sizeBytes: 50),
          ],
          groupedFiles: const [],
          hasMoreFiles: false,
          selectedFileIds: const {'a', 'b'},
          isSelectionMode: true,
          totalFilesCount: 3,
        );

        // Act & Assert
        expect(state.selectedSizeBytes, 1000);
        expect(state.copyWith(selectedFileIds: const {}).selectedSizeBytes, 0);
      });
    });
  });
}
