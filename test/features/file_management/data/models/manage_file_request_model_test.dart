import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_request_model.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';

void main() {
  group('ManageFileRequestModel', () {
    const fileIds = ['file-1', 'file-2', 'file-3'];

    group('fromDomain', () {
      test('should create model from save action', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(fileIds, action);

        // Assert
        expect(model.fileIds, fileIds);
        expect(model.serverAction, 'SAVE');
        expect(model.keepOnDevice, true);
        expect(model.folderId, null);
        expect(model.folderName, null);
      });

      test('should create model from delete action', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.delete,
          keepOnDevice: false,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(fileIds, action);

        // Assert
        expect(model.fileIds, fileIds);
        expect(model.serverAction, 'DELETE');
        expect(model.keepOnDevice, false);
      });

      test('should create model from folder action with folderId', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          keepOnDevice: true,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(fileIds, action);

        // Assert
        expect(model.fileIds, fileIds);
        expect(model.serverAction, 'SAVE');
        expect(model.folderId, 'folder-123');
        expect(model.keepOnDevice, true);
      });

      test('should create model from newFolder action with folderName', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.newFolder,
          folderName: 'New Folder',
          keepOnDevice: true,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(fileIds, action);

        // Assert
        expect(model.fileIds, fileIds);
        expect(model.serverAction, 'SAVE');
        expect(model.folderName, 'New Folder');
        expect(model.keepOnDevice, true);
      });
    });

    group('toJson', () {
      test('should convert model to JSON with required fields only', () {
        // Arrange
        const model = ManageFileRequestModel(
          fileIds: fileIds,
          serverAction: 'SAVE',
          keepOnDevice: true,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['filesToManage'], fileIds);
        expect(json['manageAction'], 'SAVE');
        expect(json['keepOnDevice'], true);
        expect(json.containsKey('folderId'), false);
        expect(json.containsKey('folderName'), false);
      });

      test('should include folderId when provided', () {
        // Arrange
        const model = ManageFileRequestModel(
          fileIds: fileIds,
          serverAction: 'SAVE',
          folderId: 'folder-123',
          keepOnDevice: true,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['folderId'], 'folder-123');
      });

      test('should include folderName when provided', () {
        // Arrange
        const model = ManageFileRequestModel(
          fileIds: fileIds,
          serverAction: 'SAVE',
          folderName: 'New Folder',
          keepOnDevice: true,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['folderName'], 'New Folder');
      });

      test('should include both folderId and folderName when provided', () {
        // Arrange
        const model = ManageFileRequestModel(
          fileIds: fileIds,
          serverAction: 'SAVE',
          folderId: 'folder-123',
          folderName: 'Folder Name',
          keepOnDevice: false,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['folderId'], 'folder-123');
        expect(json['folderName'], 'Folder Name');
        expect(json['keepOnDevice'], false);
      });

      test('should handle DELETE action', () {
        // Arrange
        const model = ManageFileRequestModel(
          fileIds: fileIds,
          serverAction: 'DELETE',
          keepOnDevice: false,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['manageAction'], 'DELETE');
        expect(json['keepOnDevice'], false);
      });
    });

    group('server action mapping', () {
      test('should map save action to SAVE', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(fileIds, action);

        // Assert
        expect(model.serverAction, 'SAVE');
      });

      test('should map folder action to SAVE', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          keepOnDevice: true,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(fileIds, action);

        // Assert
        expect(model.serverAction, 'SAVE');
      });

      test('should map newFolder action to SAVE', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.newFolder,
          folderName: 'New',
          keepOnDevice: true,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(fileIds, action);

        // Assert
        expect(model.serverAction, 'SAVE');
      });

      test('should map delete action to DELETE', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.delete,
          keepOnDevice: false,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(fileIds, action);

        // Assert
        expect(model.serverAction, 'DELETE');
      });
    });

    group('edge cases', () {
      test('should handle empty file IDs list', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain([], action);

        // Assert
        expect(model.fileIds, isEmpty);
      });

      test('should handle single file ID', () {
        // Arrange
        const singleFile = ['file-1'];
        const action = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(singleFile, action);

        // Assert
        expect(model.fileIds, singleFile);
        expect(model.fileIds.length, 1);
      });

      test('should handle many file IDs', () {
        // Arrange
        final manyFiles = List.generate(100, (i) => 'file-$i');
        const action = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );

        // Act
        final model = ManageFileRequestModel.fromDomain(manyFiles, action);

        // Assert
        expect(model.fileIds.length, 100);
      });
    });
  });
}
