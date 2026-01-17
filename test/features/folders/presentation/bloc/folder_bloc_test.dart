import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/create_folder_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/delete_folder_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_folders_list_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/rename_folder_use_case.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_bloc.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';

class MockGetFoldersListUseCase extends Mock implements GetFoldersListUseCase {}
class MockCreateFolderUseCase extends Mock implements CreateFolderUseCase {}
class MockRenameFolderUseCase extends Mock implements RenameFolderUseCase {}
class MockDeleteFolderUseCase extends Mock implements DeleteFolderUseCase {}
class MockAppEventBus extends Mock implements AppEventBus {}

void main() {
  late FolderBloc bloc;
  late MockGetFoldersListUseCase mockGetFoldersUseCase;
  late MockCreateFolderUseCase mockCreateFolderUseCase;
  late MockRenameFolderUseCase mockRenameFolderUseCase;
  late MockDeleteFolderUseCase mockDeleteFolderUseCase;
  late MockAppEventBus mockEventBus;

  setUp(() {
    mockGetFoldersUseCase = MockGetFoldersListUseCase();
    mockCreateFolderUseCase = MockCreateFolderUseCase();
    mockRenameFolderUseCase = MockRenameFolderUseCase();
    mockDeleteFolderUseCase = MockDeleteFolderUseCase();
    mockEventBus = MockAppEventBus();

    when(() => mockEventBus.on<FolderUpdatedEvent>()).thenAnswer((_) => const Stream.empty());

    bloc = FolderBloc(
      getFoldersUseCase: mockGetFoldersUseCase,
      createFolderUseCase: mockCreateFolderUseCase,
      renameFolderUseCase: mockRenameFolderUseCase,
      deleteFolderUseCase: mockDeleteFolderUseCase,
      eventBus: mockEventBus,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('FolderBloc', () {
    final testDate = DateTime(2024, 1, 15);
    final folders = [
      Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      ),
      Folder(
        id: 'folder-2',
        name: 'Work',
        parentFolderId: null,
        path: '/root/folder-2',
        createdAt: testDate,
        fileCount: 15,
        subfolderCount: 0,
      ),
    ];

    test('initial state is FolderStarting', () {
      expect(bloc.state, const FolderStarting());
    });

    group('LoadFolders', () {
      blocTest<FolderBloc, FolderState>(
        'emits [FolderLoaded] when folders loaded successfully',
        setUp: () {
          when(() => mockGetFoldersUseCase.call(parentFolderId: null))
              .thenAnswer((_) async => folders);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [
          FolderLoaded(folders: folders, currentParentId: null),
        ],
        verify: (_) {
          verify(() => mockGetFoldersUseCase.call(parentFolderId: null)).called(1);
        },
      );

      blocTest<FolderBloc, FolderState>(
        'emits [FolderLoaded] with parentId when loading subfolders',
        setUp: () {
          const parentId = 'parent-1';
          final subfolders = [
            Folder(
              id: 'subfolder-1',
              name: 'Summer',
              parentFolderId: parentId,
              path: '/root/parent-1/subfolder-1',
              createdAt: testDate,
              fileCount: 5,
              subfolderCount: 0,
            ),
          ];
          when(() => mockGetFoldersUseCase.call(parentFolderId: parentId))
              .thenAnswer((_) async => subfolders);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const LoadFolders(parentFolderId: 'parent-1')),
        expect: () => [
          isA<FolderLoaded>()
              .having((s) => s.currentParentId, 'currentParentId', 'parent-1'),
        ],
      );

      blocTest<FolderBloc, FolderState>(
        'emits [FolderLoaded] with empty list when no folders',
        setUp: () {
          when(() => mockGetFoldersUseCase.call(parentFolderId: null))
              .thenAnswer((_) async => []);
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [
          const FolderLoaded(folders: [], currentParentId: null),
        ],
      );

      blocTest<FolderBloc, FolderState>(
        'emits [FolderError] when use case throws exception',
        setUp: () {
          when(() => mockGetFoldersUseCase.call(parentFolderId: null))
              .thenThrow(Exception('Network error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [
          isA<FolderError>(),
        ],
      );

      blocTest<FolderBloc, FolderState>(
        'emits error with Failure object',
        setUp: () {
          when(() => mockGetFoldersUseCase.call(parentFolderId: null))
              .thenThrow(Exception('Test error'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(const LoadFolders()),
        expect: () => [
          isA<FolderError>().having((s) => s.failure, 'failure', isA<Failure>()),
        ],
      );
    });

    group('RefreshFolders', () {
      blocTest<FolderBloc, FolderState>(
        'refreshes current folder list without loading state',
        setUp: () {
          when(() => mockGetFoldersUseCase.call(parentFolderId: null))
              .thenAnswer((_) async => folders);
        },
        build: () => bloc,
        seed: () => FolderLoaded(folders: folders, currentParentId: null),
        act: (bloc) => bloc.add(const RefreshFolders()),
        expect: () => [],
      );

      blocTest<FolderBloc, FolderState>(
        'maintains currentParentId during refresh',
        setUp: () {
          const parentId = 'parent-1';
          final subfolders = [
            Folder(
              id: 'subfolder-1',
              name: 'Summer',
              parentFolderId: parentId,
              path: '/root/parent-1/subfolder-1',
              createdAt: testDate,
              fileCount: 5,
              subfolderCount: 0,
            ),
          ];
          when(() => mockGetFoldersUseCase.call(parentFolderId: parentId))
              .thenAnswer((_) async => subfolders);
        },
        build: () => bloc,
        seed: () => FolderLoaded(folders: const [], currentParentId: 'parent-1'),
        act: (bloc) => bloc.add(const RefreshFolders()),
        expect: () => [
          isA<FolderLoaded>()
              .having((s) => s.currentParentId, 'currentParentId', 'parent-1'),
        ],
      );

      blocTest<FolderBloc, FolderState>(
        'emits [FolderError] when refresh fails',
        setUp: () {
          when(() => mockGetFoldersUseCase.call(parentFolderId: null))
              .thenThrow(Exception('Network error'));
        },
        build: () => bloc,
        seed: () => FolderLoaded(folders: folders, currentParentId: null),
        act: (bloc) => bloc.add(const RefreshFolders()),
        expect: () => [
          isA<FolderError>(),
        ],
      );
    });

    group('CreateFolderRequested', () {
      blocTest<FolderBloc, FolderState>(
        'emits [FolderLoaded] with new folder after successful creation',
        setUp: () {
          final newFolder = Folder(
            id: 'folder-3',
            name: 'New Folder',
            parentFolderId: null,
            path: '/root/folder-3',
            createdAt: testDate,
            fileCount: 0,
            subfolderCount: 0,
          );

          when(() => mockCreateFolderUseCase.call(
                name: 'New Folder',
                parentFolderId: null,
              )).thenAnswer((_) async => newFolder);

          when(() => mockGetFoldersUseCase.call(parentFolderId: null))
              .thenAnswer((_) async => [...folders, newFolder]);
        },
        build: () => bloc,
        seed: () => FolderLoaded(folders: folders, currentParentId: null),
        act: (bloc) => bloc.add(const CreateFolderRequested(name: 'New Folder')),
        skip: 2,
        expect: () => [
          isA<FolderLoaded>().having((s) => s.folders.length, 'folder count', 3),
        ],
        verify: (_) {
          verify(() => mockCreateFolderUseCase.call(
                name: 'New Folder',
                parentFolderId: null,
              )).called(1);
        },
      );

      blocTest<FolderBloc, FolderState>(
        'creates subfolder with parent ID',
        setUp: () {
          const parentId = 'parent-1';
          final newSubfolder = Folder(
            id: 'subfolder-1',
            name: 'New Subfolder',
            parentFolderId: parentId,
            path: '/root/parent-1/subfolder-1',
            createdAt: testDate,
            fileCount: 0,
            subfolderCount: 0,
          );

          when(() => mockCreateFolderUseCase.call(
                name: 'New Subfolder',
                parentFolderId: parentId,
              )).thenAnswer((_) async => newSubfolder);

          when(() => mockGetFoldersUseCase.call(parentFolderId: parentId))
              .thenAnswer((_) async => [newSubfolder]);
        },
        build: () => bloc,
        seed: () => const FolderLoaded(folders: [], currentParentId: 'parent-1'),
        act: (bloc) => bloc.add(const CreateFolderRequested(
          name: 'New Subfolder',
          parentFolderId: 'parent-1',
        )),
        skip: 2,
        expect: () => [
          isA<FolderLoaded>(),
        ],
      );

      blocTest<FolderBloc, FolderState>(
        'emits [FolderError] when creation fails',
        setUp: () {
          when(() => mockCreateFolderUseCase.call(
                name: 'New Folder',
                parentFolderId: null,
              )).thenThrow(Exception('Folder already exists'));
        },
        build: () => bloc,
        seed: () => FolderLoaded(folders: folders, currentParentId: null),
        act: (bloc) => bloc.add(const CreateFolderRequested(name: 'New Folder')),
        skip: 1,
        expect: () => [
          isA<FolderError>(),
        ],
      );
    });

    group('RenameFolderRequested', () {
      blocTest<FolderBloc, FolderState>(
        'emits [FolderLoaded] with renamed folder after successful rename',
        setUp: () {
          final renamedFolder = Folder(
            id: 'folder-1',
            name: 'Renamed Vacation',
            parentFolderId: null,
            path: '/root/folder-1',
            createdAt: testDate,
            fileCount: 42,
            subfolderCount: 3,
          );

          when(() => mockRenameFolderUseCase.call(
                folderId: 'folder-1',
                newName: 'Renamed Vacation',
              )).thenAnswer((_) async => renamedFolder);

          when(() => mockGetFoldersUseCase.call(parentFolderId: null))
              .thenAnswer((_) async => [renamedFolder, folders[1]]);
        },
        build: () => bloc,
        seed: () => FolderLoaded(folders: folders, currentParentId: null),
        act: (bloc) => bloc.add(const RenameFolderRequested(
          folderId: 'folder-1',
          newName: 'Renamed Vacation',
        )),
        skip: 2,
        expect: () => [
          isA<FolderLoaded>(),
        ],
        verify: (_) {
          verify(() => mockRenameFolderUseCase.call(
                folderId: 'folder-1',
                newName: 'Renamed Vacation',
              )).called(1);
        },
      );

      blocTest<FolderBloc, FolderState>(
        'emits [FolderError] when rename fails',
        setUp: () {
          when(() => mockRenameFolderUseCase.call(
                folderId: 'folder-1',
                newName: 'New Name',
              )).thenThrow(Exception('Folder not found'));
        },
        build: () => bloc,
        seed: () => FolderLoaded(folders: folders, currentParentId: null),
        act: (bloc) => bloc.add(const RenameFolderRequested(
          folderId: 'folder-1',
          newName: 'New Name',
        )),
        skip: 1,
        expect: () => [
          isA<FolderError>(),
        ],
      );
    });

    group('DeleteFolderRequested', () {
      blocTest<FolderBloc, FolderState>(
        'emits [FolderLoaded] with folder removed after successful deletion',
        setUp: () {
          when(() => mockDeleteFolderUseCase.call(folderId: 'folder-1'))
              .thenAnswer((_) async => Future.value());

          when(() => mockGetFoldersUseCase.call(parentFolderId: null))
              .thenAnswer((_) async => [folders[1]]);
        },
        build: () => bloc,
        seed: () => FolderLoaded(folders: folders, currentParentId: null),
        act: (bloc) => bloc.add(const DeleteFolderRequested(folderId: 'folder-1')),
        skip: 2,
        expect: () => [
          isA<FolderLoaded>().having((s) => s.folders.length, 'folder count', 1),
        ],
        verify: (_) {
          verify(() => mockDeleteFolderUseCase.call(folderId: 'folder-1')).called(1);
        },
      );

      blocTest<FolderBloc, FolderState>(
        'emits [FolderError] when deletion fails',
        setUp: () {
          when(() => mockDeleteFolderUseCase.call(folderId: 'folder-1'))
              .thenThrow(Exception('Folder is not empty'));
        },
        build: () => bloc,
        seed: () => FolderLoaded(folders: folders, currentParentId: null),
        act: (bloc) => bloc.add(const DeleteFolderRequested(folderId: 'folder-1')),
        skip: 1,
        expect: () => [
          isA<FolderError>(),
        ],
      );
    });
  });
}
