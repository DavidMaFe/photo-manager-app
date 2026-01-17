import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_model.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';

void main() {
  group('FolderModel', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should be a subclass of Folder entity', () {
      // Arrange
      final model = FolderModel(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Assert
      expect(model, isA<Folder>());
    });

    test('should create model from JSON', () {
      // Arrange
      final json = {
        'id': 'folder-1',
        'name': 'Vacation',
        'parentFolderId': 'parent-1',
        'path': '/root/parent-1/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 42,
        'subfolderCount': 3,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.id, 'folder-1');
      expect(model.name, 'Vacation');
      expect(model.parentFolderId, 'parent-1');
      expect(model.path, '/root/parent-1/folder-1');
      expect(model.createdAt, testDate);
      expect(model.fileCount, 42);
      expect(model.subfolderCount, 3);
    });

    test('should create model from JSON with null parentFolderId', () {
      // Arrange
      final json = {
        'id': 'folder-1',
        'name': 'Vacation',
        'parentFolderId': null,
        'path': '/root/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 42,
        'subfolderCount': 3,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.parentFolderId, isNull);
      expect(model.isRoot, true);
    });

    test('should handle numeric ID from JSON', () {
      // Arrange
      final json = {
        'id': 123,
        'name': 'Vacation',
        'parentFolderId': null,
        'path': '/root/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 42,
        'subfolderCount': 3,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.id, '123');
    });

    test('should handle numeric parentFolderId from JSON', () {
      // Arrange
      final json = {
        'id': 'folder-1',
        'name': 'Vacation',
        'parentFolderId': 456,
        'path': '/root/parent-1/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 42,
        'subfolderCount': 3,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.parentFolderId, '456');
    });

    test('should default to 0 when filesQuantity is missing', () {
      // Arrange
      final json = {
        'id': 'folder-1',
        'name': 'Vacation',
        'parentFolderId': null,
        'path': '/root/folder-1',
        'createdAt': testDate.toIso8601String(),
        'subfolderCount': 3,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.fileCount, 0);
    });

    test('should default to 0 when subfolderCount is missing', () {
      // Arrange
      final json = {
        'id': 'folder-1',
        'name': 'Vacation',
        'parentFolderId': null,
        'path': '/root/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 42,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.subfolderCount, 0);
    });

    test('should convert model to JSON', () {
      // Arrange
      final model = FolderModel(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: 'parent-1',
        path: '/root/parent-1/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 'folder-1');
      expect(json['name'], 'Vacation');
      expect(json['parentFolderId'], 'parent-1');
      expect(json['path'], '/root/parent-1/folder-1');
      expect(json['createdAt'], testDate);
      expect(json['filesQuantity'], 42);
      expect(json['subfolderCount'], 3);
    });

    test('should maintain filesQuantity field name in JSON', () {
      // Arrange
      final model = FolderModel(
        id: 'folder-1',
        name: 'Test',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 10,
        subfolderCount: 0,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json.containsKey('filesQuantity'), true);
      expect(json.containsKey('fileCount'), false);
    });

    test('should support round-trip JSON conversion', () {
      // Arrange
      final originalJson = {
        'id': 'folder-1',
        'name': 'Vacation',
        'parentFolderId': 'parent-1',
        'path': '/root/parent-1/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 42,
        'subfolderCount': 3,
      };

      // Act
      final model = FolderModel.fromJson(originalJson);
      final json = model.toJson();

      // Assert
      expect(json['id'], originalJson['id']);
      expect(json['name'], originalJson['name']);
      expect(json['parentFolderId'], originalJson['parentFolderId']);
      expect(json['path'], originalJson['path']);
      expect(json['filesQuantity'], originalJson['filesQuantity']);
      expect(json['subfolderCount'], originalJson['subfolderCount']);
    });

    test('should convert to entity', () {
      // Arrange
      final model = FolderModel(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<Folder>());
      expect(entity.id, model.id);
      expect(entity.name, model.name);
      expect(entity.parentFolderId, model.parentFolderId);
      expect(entity.path, model.path);
      expect(entity.createdAt, model.createdAt);
      expect(entity.fileCount, model.fileCount);
      expect(entity.subfolderCount, model.subfolderCount);
    });

    test('should create model from entity', () {
      // Arrange
      final entity = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: 'parent-1',
        path: '/root/parent-1/folder-1',
        createdAt: testDate,
        fileCount: 42,
        subfolderCount: 3,
      );

      // Act
      final model = FolderModel.fromEntity(entity);

      // Assert
      expect(model.id, entity.id);
      expect(model.name, entity.name);
      expect(model.parentFolderId, entity.parentFolderId);
      expect(model.path, entity.path);
      expect(model.createdAt, entity.createdAt);
      expect(model.fileCount, entity.fileCount);
      expect(model.subfolderCount, entity.subfolderCount);
    });

    test('should preserve all entity properties in fromEntity', () {
      // Arrange
      final entity = Folder(
        id: 'folder-1',
        name: 'Test',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      // Act
      final model = FolderModel.fromEntity(entity);

      // Assert
      expect(model.isRoot, entity.isRoot);
      expect(model.hasSubfolders, entity.hasSubfolders);
      expect(model.hasFiles, entity.hasFiles);
      expect(model.isEmpty, entity.isEmpty);
    });

    test('should handle special characters in name', () {
      // Arrange
      final json = {
        'id': 'folder-1',
        'name': 'Folder @#\$%^&*()',
        'parentFolderId': null,
        'path': '/root/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 0,
        'subfolderCount': 0,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.name, 'Folder @#\$%^&*()');
    });

    test('should handle unicode characters in name', () {
      // Arrange
      final json = {
        'id': 'folder-1',
        'name': 'Vacaciones 🏖️ 日本',
        'parentFolderId': null,
        'path': '/root/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 0,
        'subfolderCount': 0,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.name, 'Vacaciones 🏖️ 日本');
    });

    test('should handle deep folder path', () {
      // Arrange
      const deepPath = '/root/a/b/c/d/e/f/g/h/folder-1';
      final json = {
        'id': 'folder-1',
        'name': 'Deep',
        'parentFolderId': 'parent-h',
        'path': deepPath,
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 0,
        'subfolderCount': 0,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.path, deepPath);
    });

    test('should handle null filesQuantity as 0', () {
      // Arrange
      final json = {
        'id': 'folder-1',
        'name': 'Test',
        'parentFolderId': null,
        'path': '/root/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': null,
        'subfolderCount': 0,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.fileCount, 0);
    });

    test('should handle null subfolderCount as 0', () {
      // Arrange
      final json = {
        'id': 'folder-1',
        'name': 'Test',
        'parentFolderId': null,
        'path': '/root/folder-1',
        'createdAt': testDate.toIso8601String(),
        'filesQuantity': 0,
        'subfolderCount': null,
      };

      // Act
      final model = FolderModel.fromJson(json);

      // Assert
      expect(model.subfolderCount, 0);
    });
  });
}
