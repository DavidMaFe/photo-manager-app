import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_file_result.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/manage_files_use_case.dart';

class MockFileManagementRepository extends Mock implements FileManagementRepository {}

void main() {

  setUpAll(() {
    registerFallbackValue(
        const ManageAction(
            serverAction: ServerAction.save,
            keepOnDevice: true)
        );
  });

  late ManageFilesUseCase useCase;
  late MockFileManagementRepository mockRepository;

  setUp(() {
    mockRepository = MockFileManagementRepository();
    useCase = ManageFilesUseCase(mockRepository);
  });

  group('ManageFilesUseCase', () {
    const fileIds = ['file-1', 'file-2', 'file-3'];
    const action = ManageAction(
      serverAction: ServerAction.save,
      keepOnDevice: true,
    );

    group('validation', () {
      test('should throw exception when fileIds list is empty', () async {
        // Arrange
        const emptyList = <String>[];

        // Act & Assert
        expect(
          () => useCase.call(emptyList, action),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('at least one file selected'),
            ),
          ),
        );
      });

      test('should accept exactly 100 files', () async {
        // Arrange
        final maxFiles = List.generate(100, (index) => 'file-$index');
        const result = ManageFileResult(successfulIds: [], failedIds: []);

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        await useCase.call(maxFiles, action);

        // Assert
        verify(() => mockRepository.manageFiles(maxFiles, action)).called(1);
      });

      test('should accept 1 file', () async {
        // Arrange
        const singleFile = ['file-1'];
        const result = ManageFileResult(successfulIds: [], failedIds: []);

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        await useCase.call(singleFile, action);

        // Assert
        verify(() => mockRepository.manageFiles(singleFile, action)).called(1);
      });
    });

    group('successful operations', () {
      test('should call repository with file IDs and action', () async {
        // Arrange
        const result = ManageFileResult(
          successfulIds: fileIds,
          failedIds: [],
        );

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        await useCase.call(fileIds, action);

        // Assert
        verify(() => mockRepository.manageFiles(fileIds, action)).called(1);
      });

      test('should return failed IDs from result', () async {
        // Arrange
        const failedIds = ['file-2'];
        const result = ManageFileResult(
          successfulIds: ['file-1', 'file-3'],
          failedIds: failedIds,
        );

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        final returnedFailedIds = await useCase.call(fileIds, action);

        // Assert
        expect(returnedFailedIds, failedIds);
      });

      test('should return empty list when all files succeeded', () async {
        // Arrange
        const result = ManageFileResult(
          successfulIds: fileIds,
          failedIds: [],
        );

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        final failedIds = await useCase.call(fileIds, action);

        // Assert
        expect(failedIds, isEmpty);
      });
    });

    group('keepOnDevice handling', () {
      test('should NOT delete local files when keepOnDevice is true', () async {
        // Arrange
        const actionWithKeep = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );
        const result = ManageFileResult(
          successfulIds: ['file-1', 'file-2'],
          failedIds: [],
        );

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        await useCase.call(fileIds, actionWithKeep);

        // Assert
        verifyNever(() => mockRepository.deleteLocalFiles(any()));
      });

      test('should delete local files AFTER server operation when keepOnDevice is false', () async {
        // Arrange
        const actionWithoutKeep = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: false,
        );
        const successfulIds = ['file-1', 'file-2'];
        const result = ManageFileResult(
          successfulIds: successfulIds,
          failedIds: ['file-3'],
        );

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);
        when(() => mockRepository.deleteLocalFiles(any()))
            .thenAnswer((_) async => successfulIds);

        // Act
        await useCase.call(fileIds, actionWithoutKeep);

        // Assert - verify server operation happens first
        verify(() => mockRepository.manageFiles(fileIds, actionWithoutKeep)).called(1);
        // Then verify local deletion happens only for successful server deletions
        verify(() => mockRepository.deleteLocalFiles(successfulIds)).called(1);
      });

      test('should NOT delete local files when keepOnDevice is false but all server operations failed', () async {
        // Arrange
        const actionWithoutKeep = ManageAction(
          serverAction: ServerAction.delete,
          keepOnDevice: false,
        );
        const result = ManageFileResult(
          successfulIds: [],
          failedIds: fileIds,
        );

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        await useCase.call(fileIds, actionWithoutKeep);

        // Assert - local deletion should not be attempted since server failed
        verifyNever(() => mockRepository.deleteLocalFiles(any()));
      });

      test('should delete only successful server files locally when keepOnDevice is false', () async {
        // Arrange
        const actionWithoutKeep = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          keepOnDevice: false,
        );
        const successfulIds = ['file-1', 'file-3']; // Only 2 out of 3 succeeded on server
        const result = ManageFileResult(
          successfulIds: successfulIds,
          failedIds: ['file-2'],
        );

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);
        when(() => mockRepository.deleteLocalFiles(any()))
            .thenAnswer((_) async => successfulIds);

        // Act
        await useCase.call(fileIds, actionWithoutKeep);

        // Assert - server operation happens with all files
        verify(() => mockRepository.manageFiles(fileIds, actionWithoutKeep)).called(1);
        // But local deletion only for files that succeeded on server
        verify(() => mockRepository.deleteLocalFiles(successfulIds)).called(1);
      });
    });

    group('error handling', () {
      test('should propagate exception from repository', () async {
        // Arrange
        when(() => mockRepository.manageFiles(any(), any()))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => useCase.call(fileIds, action),
          throwsA(isA<Exception>()),
        );
      });

      test('should not propagate exception from deleteLocalFiles when it throws', () async {
        // Arrange
        const actionWithoutKeep = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: false,
        );
        const result = ManageFileResult(
          successfulIds: fileIds,
          failedIds: [],
        );

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);
        when(() => mockRepository.deleteLocalFiles(any()))
            .thenThrow(Exception('Deletion failed'));

        // Act - should not throw even if local deletion fails
        final failedIds = await useCase.call(fileIds, actionWithoutKeep);

        // Assert - server operation should complete successfully
        expect(failedIds, isEmpty);
        verify(() => mockRepository.manageFiles(fileIds, actionWithoutKeep)).called(1);
        verify(() => mockRepository.deleteLocalFiles(fileIds)).called(1);
      });
    });

    group('different action types', () {
      test('should work with save action', () async {
        // Arrange
        const saveAction = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );
        const result = ManageFileResult(successfulIds: fileIds, failedIds: []);

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        await useCase.call(fileIds, saveAction);

        // Assert
        verify(() => mockRepository.manageFiles(fileIds, saveAction)).called(1);
      });

      test('should work with delete action and delete local files after server', () async {
        // Arrange
        const deleteAction = ManageAction(
          serverAction: ServerAction.delete,
          keepOnDevice: false,
        );
        const result = ManageFileResult(successfulIds: fileIds, failedIds: []);

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);
        when(() => mockRepository.deleteLocalFiles(any()))
            .thenAnswer((_) async => fileIds);

        // Act
        await useCase.call(fileIds, deleteAction);

        // Assert - server deletion happens first
        verify(() => mockRepository.manageFiles(fileIds, deleteAction)).called(1);
        verify(() => mockRepository.deleteLocalFiles(fileIds)).called(1);
      });

      test('should work with folder action', () async {
        // Arrange
        const folderAction = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          keepOnDevice: true,
        );
        const result = ManageFileResult(successfulIds: fileIds, failedIds: []);

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        await useCase.call(fileIds, folderAction);

        // Assert
        verify(() => mockRepository.manageFiles(fileIds, folderAction)).called(1);
      });

      test('should work with newFolder action', () async {
        // Arrange
        const newFolderAction = ManageAction(
          serverAction: ServerAction.newFolder,
          folderName: 'New Folder',
          keepOnDevice: true,
        );
        const result = ManageFileResult(successfulIds: fileIds, failedIds: []);

        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => result);

        // Act
        await useCase.call(fileIds, newFolderAction);

        // Assert
        verify(() => mockRepository.manageFiles(fileIds, newFolderAction)).called(1);
      });
    });

    group('batches', () {
      List<String> ids(int count) => List.generate(count, (i) => 'file-$i');

      test('should send more than 100 files in batches of 100', () async {
        // Arrange
        final files = ids(230);
        when(() => mockRepository.manageFiles(any(), any())).thenAnswer((invocation) async {
          final batch = invocation.positionalArguments[0] as List<String>;
          return ManageFileResult(successfulIds: batch, failedIds: const []);
        });

        // Act
        await useCase.call(files, action);

        // Assert
        verify(() => mockRepository.manageFiles(files.sublist(0, 100), action)).called(1);
        verify(() => mockRepository.manageFiles(files.sublist(100, 200), action)).called(1);
        verify(() => mockRepository.manageFiles(files.sublist(200, 230), action)).called(1);
      });

      test('should return the failed IDs of every batch', () async {
        // Arrange
        final files = ids(150);
        when(() => mockRepository.manageFiles(any(), any())).thenAnswer((invocation) async {
          final batch = invocation.positionalArguments[0] as List<String>;
          return ManageFileResult(successfulIds: batch.skip(1).toList(), failedIds: [batch.first]);
        });

        // Act
        final failed = await useCase.call(files, action);

        // Assert
        expect(failed, ['file-0', 'file-100']);
      });

      test('should delete local files of every batch once, after all server batches', () async {
        // Arrange
        final files = ids(120);
        const freeUp = ManageAction(serverAction: ServerAction.save, keepOnDevice: false);
        when(() => mockRepository.manageFiles(any(), any())).thenAnswer((invocation) async {
          final batch = invocation.positionalArguments[0] as List<String>;
          return ManageFileResult(successfulIds: batch, failedIds: const []);
        });
        when(() => mockRepository.deleteLocalFiles(any())).thenAnswer((_) async => []);

        // Act
        await useCase.call(files, freeUp);

        // Assert
        verify(() => mockRepository.deleteLocalFiles(files)).called(1);
      });

      test('should stop and propagate the error of a failing batch', () async {
        // Arrange
        final files = ids(250);
        var calls = 0;
        when(() => mockRepository.manageFiles(any(), any())).thenAnswer((invocation) async {
          calls++;
          if (calls == 2) throw Exception('Network error');
          return const ManageFileResult(successfulIds: [], failedIds: []);
        });

        // Act & Assert
        await expectLater(useCase.call(files, action), throwsException);
        expect(calls, 2);
      });

      test('should create a new album once and send every batch to it', () async {
        // Arrange
        final files = ids(150);
        const newAlbum = ManageAction(serverAction: ServerAction.newFolder, folderName: ' Viaje ', keepOnDevice: true);
        const toAlbum = ManageAction(serverAction: ServerAction.folder, folderId: '42', keepOnDevice: true);
        when(() => mockRepository.createFolder(any())).thenAnswer(
          (_) async => ManageFolder(id: '42', name: 'Viaje', fileCount: 0, createdAt: DateTime(2026, 10, 4)),
        );
        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => const ManageFileResult(successfulIds: [], failedIds: []));

        // Act
        await useCase.call(files, newAlbum);

        // Assert
        verify(() => mockRepository.createFolder('Viaje')).called(1);
        verify(() => mockRepository.manageFiles(files.sublist(0, 100), toAlbum)).called(1);
        verify(() => mockRepository.manageFiles(files.sublist(100, 150), toAlbum)).called(1);
      });

      test('should let the server create the album when everything fits in one batch', () async {
        // Arrange
        final files = ids(100);
        const newAlbum = ManageAction(serverAction: ServerAction.newFolder, folderName: 'Viaje', keepOnDevice: true);
        when(() => mockRepository.manageFiles(any(), any()))
            .thenAnswer((_) async => const ManageFileResult(successfulIds: [], failedIds: []));

        // Act
        await useCase.call(files, newAlbum);

        // Assert
        verify(() => mockRepository.manageFiles(files, newAlbum)).called(1);
        verifyNever(() => mockRepository.createFolder(any()));
      });
    });
  });
}
