import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/file_management/data/data_sources/file_deletion_local_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/data_sources/file_management_remote_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/models/file_info_model.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_request_model.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_response_model.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_folder_model.dart';
import 'package:photo_manager_app/features/file_management/data/repositories/file_management_repository_impl.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import '../../../../helpers/recording_file_key_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/file_metadata.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_failures.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/get_file_metadata_use_case.dart';

class MockFileManagementRemoteDataSource extends Mock implements FileManagementRemoteDataSource {}
class MockFileDeletionLocalDataSource extends Mock implements FileDeletionLocalDataSource {}
class MockAppDatabase extends Mock implements AppDatabase {}
class MockGetFileMetadataUseCase extends Mock implements GetFileMetadataUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ManageFileRequestModel(
        fileIds: [],
        serverAction: 'SAVE',
        keepOnDevice: true,
      ),
    );
  });

  late FileManagementRepositoryImpl repository;
  late RecordingFileKeyRepository fileKeys;
  late MockGetFileMetadataUseCase getFileMetadata;
  late MockFileManagementRemoteDataSource mockRemoteDataSource;
  late MockFileDeletionLocalDataSource mockDeletionDataSource;
  late MockAppDatabase mockDatabase;

  setUp(() {
    mockRemoteDataSource = MockFileManagementRemoteDataSource();
    mockDeletionDataSource = MockFileDeletionLocalDataSource();
    mockDatabase = MockAppDatabase();
    fileKeys = RecordingFileKeyRepository();
    getFileMetadata = MockGetFileMetadataUseCase();
    repository = FileManagementRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      deletionLocalDataSource: mockDeletionDataSource,
      database: mockDatabase,
      fileKeyRepository: fileKeys,
      getFileMetadata: getFileMetadata,
    );
  });

  group('FileManagementRepositoryImpl', () {
    group('manageFiles', () {
      const fileIds = ['file-1', 'file-2', 'file-3'];
      const action = ManageAction(
        serverAction: ServerAction.save,
        keepOnDevice: true,
      );

      test('should call remote data source with request model', () async {
        // Arrange
        final response = ManageFileResponseModel(
          successfulIds: fileIds,
          failedIds: [],
        );

        when(() => mockRemoteDataSource.manageFiles(any()))
            .thenAnswer((_) async => response);

        // Act
        await repository.manageFiles(fileIds, action);

        // Assert
        verify(() => mockRemoteDataSource.manageFiles(any())).called(1);
      });

      test('should return ManageFileResult entity from response model', () async {
        // Arrange
        final response = ManageFileResponseModel(
          successfulIds: ['file-1', 'file-2'],
          failedIds: ['file-3'],
        );

        when(() => mockRemoteDataSource.manageFiles(any()))
            .thenAnswer((_) async => response);

        // Act
        final result = await repository.manageFiles(fileIds, action);

        // Assert
        expect(result.successfulIds, ['file-1', 'file-2']);
        expect(result.failedIds, ['file-3']);
      });

      test('should handle all successful response', () async {
        // Arrange
        final response = ManageFileResponseModel(
          successfulIds: fileIds,
          failedIds: [],
        );

        when(() => mockRemoteDataSource.manageFiles(any()))
            .thenAnswer((_) async => response);

        // Act
        final result = await repository.manageFiles(fileIds, action);

        // Assert
        expect(result.allSuccessful, true);
        expect(result.hasFailures, false);
      });

      test('should handle all failed response', () async {
        // Arrange
        final response = ManageFileResponseModel(
          successfulIds: [],
          failedIds: fileIds,
        );

        when(() => mockRemoteDataSource.manageFiles(any()))
            .thenAnswer((_) async => response);

        // Act
        final result = await repository.manageFiles(fileIds, action);

        // Assert
        expect(result.allFailures, true);
      });

      test('should propagate exception from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.manageFiles(any()))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.manageFiles(fileIds, action),
          throwsA(isA<Exception>()),
        );
      });

      test('should work with delete action', () async {
        // Arrange
        const deleteAction = ManageAction(
          serverAction: ServerAction.delete,
          keepOnDevice: false,
        );
        final response = ManageFileResponseModel(
          successfulIds: fileIds,
          failedIds: [],
        );

        when(() => mockRemoteDataSource.manageFiles(any()))
            .thenAnswer((_) async => response);

        // Act
        final result = await repository.manageFiles(fileIds, deleteAction);

        // Assert
        expect(result.successfulIds, fileIds);
      });

      test('should work with folder action', () async {
        // Arrange
        const folderAction = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          keepOnDevice: true,
        );
        final response = ManageFileResponseModel(
          successfulIds: fileIds,
          failedIds: [],
        );

        when(() => mockRemoteDataSource.manageFiles(any()))
            .thenAnswer((_) async => response);

        // Act
        final result = await repository.manageFiles(fileIds, folderAction);

        // Assert
        expect(result.successfulIds, fileIds);
      });
    });

    group('getFolders', () {
      final testDate = DateTime(2024, 1, 15);
      final folderModels = [
        ManageFolderModel(
          id: 'folder-1',
          name: 'Vacation',
          fileCount: 42,
          createdAt: testDate,
        ),
        ManageFolderModel(
          id: 'folder-2',
          name: 'Work',
          fileCount: 15,
          createdAt: testDate.add(const Duration(days: 1)),
        ),
      ];

      test('should call remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFolders())
            .thenAnswer((_) async => folderModels);

        // Act
        await repository.getFolders();

        // Assert
        verify(() => mockRemoteDataSource.getFolders()).called(1);
      });

      test('should return list of ManageFolder entities', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFolders())
            .thenAnswer((_) async => folderModels);

        // Act
        final result = await repository.getFolders();

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 'folder-1');
        expect(result[0].name, 'Vacation');
        expect(result[1].id, 'folder-2');
        expect(result[1].name, 'Work');
      });

      test('should return empty list when no folders', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFolders())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getFolders();

        // Assert
        expect(result, isEmpty);
      });

      test('should propagate exception from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.getFolders())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getFolders(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteLocalFiles', () {
      const serverIds = ['server-1', 'server-2', 'server-3'];
      final mappings = [
        {'server_id': 'server-1', 'local_id': 'local-1'},
        {'server_id': 'server-2', 'local_id': 'local-2'},
        {'server_id': 'server-3', 'local_id': 'local-3'},
      ];

      test('should get file mappings from database', () async {
        // Arrange
        when(() => mockDatabase.getFileMappings(any()))
            .thenAnswer((_) async => mappings);
        when(() => mockDeletionDataSource.deleteFiles(any()))
            .thenAnswer((_) async => ['local-1', 'local-2', 'local-3']);
        when(() => mockDatabase.deleteMapping(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.deleteLocalFiles(serverIds);

        // Assert
        verify(() => mockDatabase.getFileMappings(serverIds)).called(1);
      });

      test('should delete local files using deletion data source', () async {
        // Arrange
        when(() => mockDatabase.getFileMappings(any()))
            .thenAnswer((_) async => mappings);
        when(() => mockDeletionDataSource.deleteFiles(any()))
            .thenAnswer((_) async => ['local-1', 'local-2', 'local-3']);
        when(() => mockDatabase.deleteMapping(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.deleteLocalFiles(serverIds);

        // Assert
        verify(() => mockDeletionDataSource.deleteFiles(['local-1', 'local-2', 'local-3']))
            .called(1);
      });

      test('should delete database mappings for successfully deleted files', () async {
        // Arrange
        when(() => mockDatabase.getFileMappings(any()))
            .thenAnswer((_) async => mappings);
        when(() => mockDeletionDataSource.deleteFiles(any()))
            .thenAnswer((_) async => ['local-1', 'local-2']);
        when(() => mockDatabase.deleteMapping(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.deleteLocalFiles(serverIds);

        // Assert
        verify(() => mockDatabase.deleteMapping('server-1')).called(1);
        verify(() => mockDatabase.deleteMapping('server-2')).called(1);
        verifyNever(() => mockDatabase.deleteMapping('server-3'));
      });

      test('should return list of successfully deleted server IDs', () async {
        // Arrange
        when(() => mockDatabase.getFileMappings(any()))
            .thenAnswer((_) async => mappings);
        when(() => mockDeletionDataSource.deleteFiles(any()))
            .thenAnswer((_) async => ['local-1', 'local-3']);
        when(() => mockDatabase.deleteMapping(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.deleteLocalFiles(serverIds);

        // Assert
        expect(result, ['server-1', 'server-3']);
      });

      test('should return empty list when no mappings found', () async {
        // Arrange
        when(() => mockDatabase.getFileMappings(any()))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.deleteLocalFiles(serverIds);

        // Assert
        expect(result, isEmpty);
        verifyNever(() => mockDeletionDataSource.deleteFiles(any()));
        verifyNever(() => mockDatabase.deleteMapping(any()));
      });

      test('should return empty list when all deletions fail', () async {
        // Arrange
        when(() => mockDatabase.getFileMappings(any()))
            .thenAnswer((_) async => mappings);
        when(() => mockDeletionDataSource.deleteFiles(any()))
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.deleteLocalFiles(serverIds);

        // Assert
        expect(result, isEmpty);
        verifyNever(() => mockDatabase.deleteMapping(any()));
      });

      test('should handle partial deletion success', () async {
        // Arrange
        when(() => mockDatabase.getFileMappings(any()))
            .thenAnswer((_) async => mappings);
        when(() => mockDeletionDataSource.deleteFiles(any()))
            .thenAnswer((_) async => ['local-2']);
        when(() => mockDatabase.deleteMapping(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.deleteLocalFiles(serverIds);

        // Assert
        expect(result, ['server-2']);
        verify(() => mockDatabase.deleteMapping('server-2')).called(1);
        verifyNever(() => mockDatabase.deleteMapping('server-1'));
        verifyNever(() => mockDatabase.deleteMapping('server-3'));
      });

      test('should return empty list on exception', () async {
        // Arrange
        when(() => mockDatabase.getFileMappings(any()))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.deleteLocalFiles(serverIds);

        // Assert
        expect(result, isEmpty);
      });

      test('should handle exception from deletion data source', () async {
        // Arrange
        when(() => mockDatabase.getFileMappings(any()))
            .thenAnswer((_) async => mappings);
        when(() => mockDeletionDataSource.deleteFiles(any()))
            .thenThrow(Exception('Deletion failed'));

        // Act
        final result = await repository.deleteLocalFiles(serverIds);

        // Assert
        expect(result, isEmpty);
      });
    });
  });

  group('createFolder', () {
    test('should delegate to the remote data source', () async {
      // Arrange
      final model = ManageFolderModel(id: '42', name: 'Viaje', fileCount: 0, createdAt: DateTime(2026, 10, 4));
      when(() => mockRemoteDataSource.createFolder(any())).thenAnswer((_) async => model);

      // Act
      final result = await repository.createFolder('Viaje');

      // Assert
      expect(result, model);
      verify(() => mockRemoteDataSource.createFolder('Viaje')).called(1);
    });
  });

  group('getFileInfo', () {
    test('should delegate to the remote data source', () async {
      // Arrange
      const model = FileInfoModel(id: '42', type: FileType.image, status: FileStatus.managed);
      when(() => mockRemoteDataSource.getFileInfo(any())).thenAnswer((_) async => model);

      // Act
      final result = await repository.getFileInfo('42');

      // Assert
      expect(result, model);
      verify(() => mockRemoteDataSource.getFileInfo('42')).called(1);
      verifyNever(() => getFileMetadata(any()));
    });

    test('should decrypt the original name and MIME type of an encrypted file', () async {
      final model = FileInfoModel(id: '42', type: FileType.image, status: FileStatus.managed, sizeBytes: 99,
          encryptedRef: RecordingFileKeyRepository.ref('42'));
      when(() => mockRemoteDataSource.getFileInfo(any())).thenAnswer((_) async => model);
      when(() => getFileMetadata('42'))
          .thenAnswer((_) async => const FileMetadata(name: 'IMG_0001.HEIC', mimeType: 'image/heic'));

      final result = await repository.getFileInfo('42');

      expect(result.originalFilename, 'IMG_0001.HEIC');
      expect(result.mimeType, 'image/heic');
      expect(result.sizeBytes, 99);
      expect(fileKeys.remembered.single.fileId, '42');
    });

    test('should keep the rest of the info when the file is locked', () async {
      final model = FileInfoModel(id: '42', type: FileType.image, status: FileStatus.managed,
          encryptedRef: RecordingFileKeyRepository.ref('42'));
      when(() => mockRemoteDataSource.getFileInfo(any())).thenAnswer((_) async => model);
      when(() => getFileMetadata('42')).thenThrow(const LockedFileFailure());

      final result = await repository.getFileInfo('42');

      expect(result.id, '42');
      expect(result.originalFilename, isNull);
    });
  });
}
