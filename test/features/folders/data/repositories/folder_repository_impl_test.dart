import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_file_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/folders/data/data_sources/folder_remote_data_source.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_content_model.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_model.dart';
import 'package:photo_manager_app/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_content.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import '../../../../helpers/recording_file_key_repository.dart';

class MockFolderRemoteDataSource extends Mock implements FolderRemoteDataSource {}

void main() {
  late FolderRepositoryImpl repository;
  late RecordingFileKeyRepository fileKeys;
  late MockFolderRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockFolderRemoteDataSource();
    fileKeys = RecordingFileKeyRepository();
    repository = FolderRepositoryImpl(remoteDataSource: mockRemoteDataSource, fileKeyRepository: fileKeys);
  });

  group('FolderRepositoryImpl', () {
    final testDate = DateTime(2024, 1, 15);

    group('getFolders', () {
      test('should delegate to remote data source', () async {
        // Arrange
        final folders = [
          FolderModel(
            id: 'folder-1',
            name: 'Vacation',
            parentFolderId: null,
            path: '/root/folder-1',
            createdAt: testDate,
            fileCount: 42,
            subfolderCount: 3,
          ),
        ];

        when(() => mockRemoteDataSource.getFolders(parentFolderId: null))
            .thenAnswer((_) async => folders);

        // Act
        final result = await repository.getFolders();

        // Assert
        expect(result, folders);
        verify(() => mockRemoteDataSource.getFolders(parentFolderId: null))
            .called(1);
      });

      test('should pass parentFolderId to remote data source', () async {
        // Arrange
        const parentId = 'parent-1';
        final folders = [
          FolderModel(
            id: 'subfolder-1',
            name: 'Summer',
            parentFolderId: parentId,
            path: '/root/parent-1/subfolder-1',
            createdAt: testDate,
            fileCount: 5,
            subfolderCount: 0,
          ),
        ];

        when(() => mockRemoteDataSource.getFolders(parentFolderId: parentId))
            .thenAnswer((_) async => folders);

        // Act
        final result = await repository.getFolders(parentFolderId: parentId);

        // Assert
        expect(result, folders);
        verify(() => mockRemoteDataSource.getFolders(parentFolderId: parentId))
            .called(1);
      });

      test('should return entities from models', () async {
        // Arrange
        final models = [
          FolderModel(
            id: 'folder-1',
            name: 'Vacation',
            parentFolderId: null,
            path: '/root/folder-1',
            createdAt: testDate,
            fileCount: 42,
            subfolderCount: 3,
          ),
        ];

        when(() => mockRemoteDataSource.getFolders(parentFolderId: null))
            .thenAnswer((_) async => models);

        // Act
        final result = await repository.getFolders();

        // Assert
        expect(result, isA<List<Folder>>());
        expect(result[0].id, models[0].id);
        expect(result[0].name, models[0].name);
      });

      test('should propagate exception from data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFolders(parentFolderId: null))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getFolders(),
          throwsException,
        );
      });
    });

    group('getFolderContent', () {
      test('should remember the keys of the files of the album', () async {
        final contentModel = FolderContentModel(
          folder: FolderModel(id: 'f', name: 'Album', parentFolderId: null, path: '/f', createdAt: testDate,
              fileCount: 1, subfolderCount: 0),
          subfolders: const [],
          files: [
            GalleryFileModel(id: 'file-9', type: FileType.image, status: FileStatus.managed, capturedAt: testDate,
                encryptedRef: RecordingFileKeyRepository.ref('file-9')),
          ],
          hasMoreFiles: false,
          totalFilesCount: 1,
        );
        when(() => mockRemoteDataSource.getFolderContent(
              folderId: any(named: 'folderId'),
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              fileType: any(named: 'fileType'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => contentModel);

        await repository.getFolderContent(folderId: 'f');

        expect(fileKeys.remembered.map((ref) => ref.fileId), ['file-9']);
      });

      test('should delegate to remote data source with default parameters', () async {
        // Arrange
        const folderId = 'folder-1';
        final folderModel = FolderModel(
          id: folderId,
          name: 'Vacation',
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 0,
          subfolderCount: 0,
        );

        final contentModel = FolderContentModel(
          folder: folderModel,
          subfolders: const [],
          files: const [],
          hasMoreFiles: false,
          totalFilesCount: 0,
        );

        when(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: 0,
              pageSize: 50,
              fileType: null,
              status: null,
            )).thenAnswer((_) async => contentModel);

        // Act
        final result = await repository.getFolderContent(folderId: folderId);

        // Assert
        expect(result, contentModel);
        verify(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: 0,
              pageSize: 50,
              fileType: null,
              status: null,
            )).called(1);
      });

      test('should pass custom page and pageSize parameters', () async {
        // Arrange
        const folderId = 'folder-1';
        const page = 2;
        const pageSize = 25;
        final folderModel = FolderModel(
          id: folderId,
          name: 'Vacation',
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 0,
          subfolderCount: 0,
        );

        final contentModel = FolderContentModel(
          folder: folderModel,
          subfolders: const [],
          files: const [],
          hasMoreFiles: false,
          totalFilesCount: 0,
        );

        when(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: page,
              pageSize: pageSize,
              fileType: null,
              status: null,
            )).thenAnswer((_) async => contentModel);

        // Act
        final result = await repository.getFolderContent(
          folderId: folderId,
          page: page,
          pageSize: pageSize,
        );

        // Assert
        expect(result, contentModel);
        verify(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: page,
              pageSize: pageSize,
              fileType: null,
              status: null,
            )).called(1);
      });

      test('should convert FileFilter.all to null parameters', () async {
        // Arrange
        const folderId = 'folder-1';
        final folderModel = FolderModel(
          id: folderId,
          name: 'Vacation',
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 0,
          subfolderCount: 0,
        );

        final contentModel = FolderContentModel(
          folder: folderModel,
          subfolders: const [],
          files: const [],
          hasMoreFiles: false,
          totalFilesCount: 0,
        );

        when(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              fileType: null,
              status: null,
            )).thenAnswer((_) async => contentModel);

        // Act
        await repository.getFolderContent(
          folderId: folderId,
          filter: FileFilter.all,
        );

        // Assert
        verify(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: 0,
              pageSize: 50,
              fileType: null,
              status: null,
            )).called(1);
      });

      test('should convert FileFilter.images to correct parameters', () async {
        // Arrange
        const folderId = 'folder-1';
        final folderModel = FolderModel(
          id: folderId,
          name: 'Vacation',
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 0,
          subfolderCount: 0,
        );

        final contentModel = FolderContentModel(
          folder: folderModel,
          subfolders: const [],
          files: const [],
          hasMoreFiles: false,
          totalFilesCount: 0,
        );

        when(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              fileType: 'IMAGE',
              status: any(named: 'status'),
            )).thenAnswer((_) async => contentModel);

        // Act
        await repository.getFolderContent(
          folderId: folderId,
          filter: FileFilter.images,
        );

        // Assert
        verify(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: 0,
              pageSize: 50,
              fileType: 'IMAGE',
              status: any(named: 'status'),
            )).called(1);
      });

      test('should convert FileFilter.videos to correct parameters', () async {
        // Arrange
        const folderId = 'folder-1';
        final folderModel = FolderModel(
          id: folderId,
          name: 'Vacation',
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 0,
          subfolderCount: 0,
        );

        final contentModel = FolderContentModel(
          folder: folderModel,
          subfolders: const [],
          files: const [],
          hasMoreFiles: false,
          totalFilesCount: 0,
        );

        when(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              fileType: 'VIDEO',
              status: any(named: 'status'),
            )).thenAnswer((_) async => contentModel);

        // Act
        await repository.getFolderContent(
          folderId: folderId,
          filter: FileFilter.videos,
        );

        // Assert
        verify(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: 0,
              pageSize: 50,
              fileType: 'VIDEO',
              status: any(named: 'status'),
            )).called(1);
      });

      test('should return entity from model', () async {
        // Arrange
        const folderId = 'folder-1';
        final folderModel = FolderModel(
          id: folderId,
          name: 'Vacation',
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 2,
          subfolderCount: 1,
        );

        final contentModel = FolderContentModel(
          folder: folderModel,
          subfolders: const [],
          files: const [],
          hasMoreFiles: false,
          totalFilesCount: 0,
        );

        when(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              fileType: any(named: 'fileType'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => contentModel);

        // Act
        final result = await repository.getFolderContent(folderId: folderId);

        // Assert
        expect(result, isA<FolderContent>());
        expect(result.folder.id, folderId);
        expect(result.folder.name, 'Vacation');
      });

      test('should propagate exception from data source', () async {
        // Arrange
        const folderId = 'folder-1';
        when(() => mockRemoteDataSource.getFolderContent(
              folderId: folderId,
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
              fileType: any(named: 'fileType'),
              status: any(named: 'status'),
            )).thenThrow(Exception('Folder not found'));

        // Act & Assert
        expect(
          () => repository.getFolderContent(folderId: folderId),
          throwsException,
        );
      });
    });

    group('createFolder', () {
      test('should delegate to remote data source', () async {
        // Arrange
        const folderName = 'Vacation';
        final createdFolder = FolderModel(
          id: 'folder-1',
          name: folderName,
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 0,
          subfolderCount: 0,
        );

        when(() => mockRemoteDataSource.createFolder(
              name: folderName,
              parentFolderId: null,
            )).thenAnswer((_) async => createdFolder);

        // Act
        final result = await repository.createFolder(name: folderName);

        // Assert
        expect(result, createdFolder);
        verify(() => mockRemoteDataSource.createFolder(
              name: folderName,
              parentFolderId: null,
            )).called(1);
      });

      test('should pass parentFolderId to remote data source', () async {
        // Arrange
        const folderName = 'Summer';
        const parentId = 'parent-1';
        final createdFolder = FolderModel(
          id: 'folder-1',
          name: folderName,
          parentFolderId: parentId,
          path: '/root/parent-1/folder-1',
          createdAt: testDate,
          fileCount: 0,
          subfolderCount: 0,
        );

        when(() => mockRemoteDataSource.createFolder(
              name: folderName,
              parentFolderId: parentId,
            )).thenAnswer((_) async => createdFolder);

        // Act
        final result = await repository.createFolder(
          name: folderName,
          parentFolderId: parentId,
        );

        // Assert
        expect(result.parentFolderId, parentId);
        verify(() => mockRemoteDataSource.createFolder(
              name: folderName,
              parentFolderId: parentId,
            )).called(1);
      });

      test('should return entity from model', () async {
        // Arrange
        const folderName = 'Vacation';
        final model = FolderModel(
          id: 'folder-1',
          name: folderName,
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 0,
          subfolderCount: 0,
        );

        when(() => mockRemoteDataSource.createFolder(
              name: folderName,
              parentFolderId: null,
            )).thenAnswer((_) async => model);

        // Act
        final result = await repository.createFolder(name: folderName);

        // Assert
        expect(result, isA<Folder>());
        expect(result.name, folderName);
      });

      test('should propagate exception from data source', () async {
        // Arrange
        const folderName = 'Vacation';
        when(() => mockRemoteDataSource.createFolder(
              name: folderName,
              parentFolderId: null,
            )).thenThrow(Exception('Folder already exists'));

        // Act & Assert
        expect(
          () => repository.createFolder(name: folderName),
          throwsException,
        );
      });
    });

    group('renameFolder', () {
      test('should delegate to remote data source', () async {
        // Arrange
        const folderId = 'folder-1';
        const newName = 'New Vacation';
        final renamedFolder = FolderModel(
          id: folderId,
          name: newName,
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 42,
          subfolderCount: 3,
        );

        when(() => mockRemoteDataSource.renameFolder(
              folderId: folderId,
              newName: newName,
            )).thenAnswer((_) async => renamedFolder);

        // Act
        final result = await repository.renameFolder(
          folderId: folderId,
          newName: newName,
        );

        // Assert
        expect(result, renamedFolder);
        verify(() => mockRemoteDataSource.renameFolder(
              folderId: folderId,
              newName: newName,
            )).called(1);
      });

      test('should return entity from model', () async {
        // Arrange
        const folderId = 'folder-1';
        const newName = 'New Vacation';
        final model = FolderModel(
          id: folderId,
          name: newName,
          parentFolderId: null,
          path: '/root/folder-1',
          createdAt: testDate,
          fileCount: 42,
          subfolderCount: 3,
        );

        when(() => mockRemoteDataSource.renameFolder(
              folderId: folderId,
              newName: newName,
            )).thenAnswer((_) async => model);

        // Act
        final result = await repository.renameFolder(
          folderId: folderId,
          newName: newName,
        );

        // Assert
        expect(result, isA<Folder>());
        expect(result.name, newName);
      });

      test('should propagate exception from data source', () async {
        // Arrange
        const folderId = 'folder-1';
        const newName = 'New Name';
        when(() => mockRemoteDataSource.renameFolder(
              folderId: folderId,
              newName: newName,
            )).thenThrow(Exception('Folder not found'));

        // Act & Assert
        expect(
          () => repository.renameFolder(folderId: folderId, newName: newName),
          throwsException,
        );
      });
    });

    group('deleteFolder', () {
      test('should delegate to remote data source', () async {
        // Arrange
        const folderId = 'folder-1';
        when(() => mockRemoteDataSource.deleteFolder(folderId: folderId))
            .thenAnswer((_) async => Future.value());

        // Act
        await repository.deleteFolder(folderId: folderId);

        // Assert
        verify(() => mockRemoteDataSource.deleteFolder(folderId: folderId))
            .called(1);
      });

      test('should complete successfully', () async {
        // Arrange
        const folderId = 'folder-1';
        when(() => mockRemoteDataSource.deleteFolder(folderId: folderId))
            .thenAnswer((_) async => Future.value());

        // Act & Assert
        expect(
          repository.deleteFolder(folderId: folderId),
          completes,
        );
      });

      test('should propagate exception from data source', () async {
        // Arrange
        const folderId = 'folder-1';
        when(() => mockRemoteDataSource.deleteFolder(folderId: folderId))
            .thenThrow(Exception('Folder not found'));

        // Act & Assert
        expect(
          () => repository.deleteFolder(folderId: folderId),
          throwsException,
        );
      });
    });
  });
}
