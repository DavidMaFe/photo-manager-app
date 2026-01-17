import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_file_result.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/manage_files_use_case.dart';

class MockFileManagementRepository extends Mock implements FileManagementRepository {}

void main() {

  setUpAll(() {
    registerFallbackValue(
        ManageAction(
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

      test('should throw exception when fileIds list has more than 100 items', () async {
        // Arrange
        final tooManyFiles = List.generate(101, (index) => 'file-$index');

        // Act & Assert
        expect(
          () => useCase.call(tooManyFiles, action),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Too many files'),
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

      test('should delete local files when keepOnDevice is false and operation succeeded', () async {
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

        // Assert
        verify(() => mockRepository.deleteLocalFiles(successfulIds)).called(1);
      });

      test('should NOT delete local files when keepOnDevice is false but all files failed', () async {
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

        // Assert
        verifyNever(() => mockRepository.deleteLocalFiles(any()));
      });

      test('should delete only successful files when keepOnDevice is false', () async {
        // Arrange
        const actionWithoutKeep = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          keepOnDevice: false,
        );
        const successfulIds = ['file-1', 'file-3'];
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

        // Assert
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

      test('should propagate exception from deleteLocalFiles', () async {
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

        // Act & Assert
        expect(
          () => useCase.call(fileIds, actionWithoutKeep),
          throwsA(isA<Exception>()),
        );
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

      test('should work with delete action', () async {
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

        // Assert
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
  });
}
