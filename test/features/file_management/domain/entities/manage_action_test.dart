import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';

void main() {
  group('ManageAction', () {
    group('constructor', () {
      test('should create instance with required fields', () {
        // Arrange & Act
        const action = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );

        // Assert
        expect(action.serverAction, ServerAction.save);
        expect(action.keepOnDevice, true);
        expect(action.folderId, null);
        expect(action.folderName, null);
      });

      test('should create instance with all fields', () {
        // Arrange & Act
        const action = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          folderName: 'My Folder',
          keepOnDevice: false,
        );

        // Assert
        expect(action.serverAction, ServerAction.folder);
        expect(action.folderId, 'folder-123');
        expect(action.folderName, 'My Folder');
        expect(action.keepOnDevice, false);
      });
    });

    group('isValid', () {
      test('should return true for save action without folder', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action.isValid(), true);
      });

      test('should return true for delete action without folder', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.delete,
          keepOnDevice: false,
        );

        // Act & Assert
        expect(action.isValid(), true);
      });

      test('should return true for folder action with folderId', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action.isValid(), true);
      });

      test('should return false for folder action without folderId', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.folder,
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action.isValid(), false);
      });

      test('should return true for newFolder action with folderName', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.newFolder,
          folderName: 'New Folder',
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action.isValid(), true);
      });

      test('should return false for newFolder action without folderName', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.newFolder,
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action.isValid(), false);
      });

      test('should return false for newFolder action with empty folderName', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.newFolder,
          folderName: '',
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action.isValid(), false);
      });

      test('should return false for newFolder action with whitespace-only folderName', () {
        // Arrange
        const action = ManageAction(
          serverAction: ServerAction.newFolder,
          folderName: '   ',
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action.isValid(), false);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        const action1 = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          folderName: 'My Folder',
          keepOnDevice: true,
        );
        const action2 = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          folderName: 'My Folder',
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action1, action2);
        expect(action1.hashCode, action2.hashCode);
      });

      test('should not be equal when serverAction is different', () {
        // Arrange
        const action1 = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );
        const action2 = ManageAction(
          serverAction: ServerAction.delete,
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action1, isNot(action2));
      });

      test('should not be equal when folderId is different', () {
        // Arrange
        const action1 = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-123',
          keepOnDevice: true,
        );
        const action2 = ManageAction(
          serverAction: ServerAction.folder,
          folderId: 'folder-456',
          keepOnDevice: true,
        );

        // Act & Assert
        expect(action1, isNot(action2));
      });

      test('should not be equal when keepOnDevice is different', () {
        // Arrange
        const action1 = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: true,
        );
        const action2 = ManageAction(
          serverAction: ServerAction.save,
          keepOnDevice: false,
        );

        // Act & Assert
        expect(action1, isNot(action2));
      });
    });
  });
}
