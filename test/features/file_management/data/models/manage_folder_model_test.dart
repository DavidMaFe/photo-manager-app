import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_folder_model.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';

void main() {
  group('ManageFolderModel', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    group('inheritance', () {
      test('should be a subclass of ManageFolder entity', () {
        // Arrange & Act
        final model = ManageFolderModel(
          id: 'folder-123',
          name: 'Test Folder',
          fileCount: 10,
          createdAt: testDate,
        );

        // Assert
        expect(model, isA<ManageFolder>());
      });
    });

    group('fromJson', () {
      test('should create model from JSON with all fields', () {
        // Arrange
        final json = {
          'id': 'folder-123',
          'name': 'Vacation Photos',
          'filesQuantity': 42,
          'createdAt': '2024-01-15T10:30:00.000Z',
        };

        // Act
        final model = ManageFolderModel.fromJson(json);

        // Assert
        expect(model.id, 'folder-123');
        expect(model.name, 'Vacation Photos');
        expect(model.fileCount, 42);
        expect(model.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
      });

      test('should convert numeric id to string', () {
        // Arrange
        final json = {
          'id': 123,
          'name': 'Folder',
          'filesQuantity': 5,
          'createdAt': '2024-01-15T10:30:00.000Z',
        };

        // Act
        final model = ManageFolderModel.fromJson(json);

        // Assert
        expect(model.id, '123');
      });

      test('should handle zero file count', () {
        // Arrange
        final json = {
          'id': 'empty-folder',
          'name': 'Empty Folder',
          'filesQuantity': 0,
          'createdAt': '2024-01-15T10:30:00.000Z',
        };

        // Act
        final model = ManageFolderModel.fromJson(json);

        // Assert
        expect(model.fileCount, 0);
      });

      test('should parse ISO 8601 date string', () {
        // Arrange
        final json = {
          'id': 'folder-1',
          'name': 'Test',
          'filesQuantity': 1,
          'createdAt': '2024-03-20T14:25:30.500Z',
        };

        // Act
        final model = ManageFolderModel.fromJson(json);

        // Assert
        expect(model.createdAt.year, 2024);
        expect(model.createdAt.month, 3);
        expect(model.createdAt.day, 20);
        expect(model.createdAt.hour, 14);
        expect(model.createdAt.minute, 25);
        expect(model.createdAt.second, 30);
      });

      test('should handle large file count', () {
        // Arrange
        final json = {
          'id': 'large-folder',
          'name': 'Large',
          'filesQuantity': 10000,
          'createdAt': '2024-01-15T10:30:00.000Z',
        };

        // Act
        final model = ManageFolderModel.fromJson(json);

        // Assert
        expect(model.fileCount, 10000);
      });
    });

    group('toJson', () {
      test('should convert model to JSON with all fields', () {
        // Arrange
        final model = ManageFolderModel(
          id: 'folder-123',
          name: 'My Folder',
          fileCount: 15,
          createdAt: testDate,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 'folder-123');
        expect(json['name'], 'My Folder');
        expect(json['filesQuantity'], 15);
        expect(json['createdAt'], testDate);
      });

      test('should preserve DateTime object in JSON', () {
        // Arrange
        final exactTime = DateTime(2024, 3, 20, 14, 25, 30, 500);
        final model = ManageFolderModel(
          id: 'folder-1',
          name: 'Test',
          fileCount: 5,
          createdAt: exactTime,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['createdAt'], exactTime);
      });

      test('should handle zero file count', () {
        // Arrange
        final model = ManageFolderModel(
          id: 'empty',
          name: 'Empty',
          fileCount: 0,
          createdAt: testDate,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['filesQuantity'], 0);
      });
    });

    group('fromEntity', () {
      test('should create model from ManageFolder entity', () {
        // Arrange
        final entity = ManageFolder(
          id: 'folder-123',
          name: 'Test Folder',
          fileCount: 20,
          createdAt: testDate,
        );

        // Act
        final model = ManageFolderModel.fromEntity(entity);

        // Assert
        expect(model.id, entity.id);
        expect(model.name, entity.name);
        expect(model.fileCount, entity.fileCount);
        expect(model.createdAt, entity.createdAt);
      });

      test('should preserve all entity properties', () {
        // Arrange
        final entity = ManageFolder(
          id: 'folder-456',
          name: 'Work Files',
          fileCount: 100,
          createdAt: DateTime(2024, 2, 28),
        );

        // Act
        final model = ManageFolderModel.fromEntity(entity);

        // Assert
        expect(model.id, 'folder-456');
        expect(model.name, 'Work Files');
        expect(model.fileCount, 100);
        expect(model.createdAt.year, 2024);
        expect(model.createdAt.month, 2);
        expect(model.createdAt.day, 28);
      });
    });

    group('round-trip conversion', () {
      test('should maintain data integrity through JSON round-trip', () {
        // Arrange
        final originalModel = ManageFolderModel(
          id: 'folder-test',
          name: 'Round Trip Test',
          fileCount: 50,
          createdAt: testDate,
        );

        // Act
        final json = originalModel.toJson();
        // Note: toJson returns DateTime object, so we need to format it
        final jsonWithDateString = {
          ...json,
          'createdAt': json['createdAt'].toIso8601String(),
        };
        final reconstructedModel = ManageFolderModel.fromJson(jsonWithDateString);

        // Assert
        expect(reconstructedModel.id, originalModel.id);
        expect(reconstructedModel.name, originalModel.name);
        expect(reconstructedModel.fileCount, originalModel.fileCount);
      });

      test('should maintain data integrity through entity round-trip', () {
        // Arrange
        final originalEntity = ManageFolder(
          id: 'folder-entity',
          name: 'Entity Test',
          fileCount: 30,
          createdAt: testDate,
        );

        // Act
        final model = ManageFolderModel.fromEntity(originalEntity);

        // Assert
        expect(model.id, originalEntity.id);
        expect(model.name, originalEntity.name);
        expect(model.fileCount, originalEntity.fileCount);
        expect(model.createdAt, originalEntity.createdAt);
      });
    });

    group('Equatable', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final model1 = ManageFolderModel(
          id: 'folder-123',
          name: 'Test',
          fileCount: 10,
          createdAt: testDate,
        );
        final model2 = ManageFolderModel(
          id: 'folder-123',
          name: 'Test',
          fileCount: 10,
          createdAt: testDate,
        );

        // Act & Assert
        expect(model1, model2);
        expect(model1.hashCode, model2.hashCode);
      });

      test('should not be equal when id is different', () {
        // Arrange
        final model1 = ManageFolderModel(
          id: 'folder-123',
          name: 'Test',
          fileCount: 10,
          createdAt: testDate,
        );
        final model2 = ManageFolderModel(
          id: 'folder-456',
          name: 'Test',
          fileCount: 10,
          createdAt: testDate,
        );

        // Act & Assert
        expect(model1, isNot(model2));
      });
    });
  });
}
