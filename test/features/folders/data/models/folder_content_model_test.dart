import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_content_model.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_model.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_content.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

void main() {
  group('FolderContentModel', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should be a subclass of FolderContent entity', () {
      // Arrange
      final folder = FolderModel(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      final model = FolderContentModel(
        folder: folder,
        subfolders: const [],
        files: const [],
        hasMoreFiles: false,
      );

      // Assert
      expect(model, isA<FolderContent>());
    });

    test('should create model from JSON', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 2,
          'subfolderCount': 1,
        },
        'subfolders': [
          {
            'id': 'subfolder-1',
            'name': 'Summer',
            'parentFolderId': 'folder-1',
            'path': '/root/folder-1/subfolder-1',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 5,
            'subfolderCount': 0,
          },
        ],
        'files': {
          'files': [
            {
              'id': 'file-1',
              'type': 'IMAGE',
              'status': 'PENDING',
              'capturedAt': testDate.toIso8601String(),
            },
            {
              'id': 'file-2',
              'type': 'IMAGE',
              'status': 'PENDING',
              'capturedAt': testDate.toIso8601String(),
            },
          ],
          'hasNext': true,
        },
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.folder.id, 'folder-1');
      expect(model.folder.name, 'Vacation');
      expect(model.subfolders.length, 1);
      expect(model.subfolders[0].name, 'Summer');
      expect(model.files.length, 2);
      expect(model.files[0].id, 'file-1');
      expect(model.hasMoreFiles, true);
    });

    test('should handle empty subfolders list', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        },
        'subfolders': [],
        'files': {
          'files': [],
          'hasNext': false,
        },
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.subfolders, isEmpty);
    });

    test('should handle null subfolders as empty list', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        },
        'files': {
          'files': [],
          'hasNext': false,
        },
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.subfolders, isEmpty);
    });

    test('should handle empty files list', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        },
        'subfolders': [],
        'files': {
          'files': [],
          'hasNext': false,
        },
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.files, isEmpty);
      expect(model.isEmpty, true);
    });

    test('should handle null files object as empty list', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        },
        'subfolders': [],
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.files, isEmpty);
    });

    test('should handle null files array as empty list', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        },
        'subfolders': [],
        'files': {
          'hasNext': false,
        },
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.files, isEmpty);
    });

    test('should default hasNext to false when missing', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        },
        'subfolders': [],
        'files': {
          'files': [],
        },
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.hasMoreFiles, false);
    });

    test('should convert to entity', () {
      // Arrange
      final folder = FolderModel(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      final model = FolderContentModel(
        folder: folder,
        subfolders: const [],
        files: const [],
        hasMoreFiles: false,
      );

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<FolderContent>());
      expect(entity.folder.id, model.folder.id);
      expect(entity.subfolders, model.subfolders);
      expect(entity.files, model.files);
      expect(entity.hasMoreFiles, model.hasMoreFiles);
    });

    test('should create model from entity', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Vacation',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 2,
        subfolderCount: 1,
      );

      final subfolders = [
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

      final files = [
        GalleryFile(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      ];

      final entity = FolderContent(
        folder: folder,
        subfolders: subfolders,
        files: files,
        hasMoreFiles: true,
      );

      // Act
      final model = FolderContentModel.fromEntity(entity);

      // Assert
      expect(model.folder.id, entity.folder.id);
      expect(model.subfolders, entity.subfolders);
      expect(model.files, entity.files);
      expect(model.hasMoreFiles, entity.hasMoreFiles);
    });

    test('should parse multiple subfolders from JSON', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 3,
        },
        'subfolders': [
          {
            'id': 'subfolder-1',
            'name': 'Summer',
            'parentFolderId': 'folder-1',
            'path': '/root/folder-1/subfolder-1',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 5,
            'subfolderCount': 0,
          },
          {
            'id': 'subfolder-2',
            'name': 'Winter',
            'parentFolderId': 'folder-1',
            'path': '/root/folder-1/subfolder-2',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 3,
            'subfolderCount': 0,
          },
          {
            'id': 'subfolder-3',
            'name': 'Spring',
            'parentFolderId': 'folder-1',
            'path': '/root/folder-1/subfolder-3',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 8,
            'subfolderCount': 0,
          },
        ],
        'files': {
          'files': [],
          'hasNext': false,
        },
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.subfolders.length, 3);
      expect(model.subfolders[0].name, 'Summer');
      expect(model.subfolders[1].name, 'Winter');
      expect(model.subfolders[2].name, 'Spring');
    });

    test('should parse multiple files from JSON', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 3,
          'subfolderCount': 0,
        },
        'subfolders': [],
        'files': {
          'files': [
            {
              'id': 'file-1',
              'type': 'IMAGE',
              'status': 'PENDING',
              'capturedAt': testDate.toIso8601String(),
            },
            {
              'id': 'file-2',
              'type': 'IMAGE',
              'status': 'PENDING',
              'capturedAt': testDate.toIso8601String(),
            },
            {
              'id': 'file-3',
              'type': 'IMAGE',
              'status': 'PENDING',
              'capturedAt': testDate.toIso8601String(),
            },
          ],
          'hasNext': false,
        },
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.files.length, 3);
      expect(model.files[0].id, 'file-1');
      expect(model.files[1].id, 'file-2');
      expect(model.files[2].id, 'file-3');
    });

    test('should handle currentPage parameter', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        },
        'subfolders': [],
        'files': {
          'files': [],
          'hasNext': false,
        },
      };

      // Act
      final model1 = FolderContentModel.fromJson(json, currentPage: 0);
      final model2 = FolderContentModel.fromJson(json, currentPage: 5);

      // Assert - currentPage doesn't affect the model but is required parameter
      expect(model1.folder.id, model2.folder.id);
    });

    test('should preserve entity computed properties', () {
      // Arrange
      final folder = Folder(
        id: 'folder-1',
        name: 'Test',
        parentFolderId: null,
        path: '/root/folder-1',
        createdAt: testDate,
        fileCount: 0,
        subfolderCount: 0,
      );

      final entity = FolderContent(
        folder: folder,
        subfolders: const [],
        files: const [],
        hasMoreFiles: false,
      );

      // Act
      final model = FolderContentModel.fromEntity(entity);

      // Assert
      expect(model.isEmpty, entity.isEmpty);
      expect(model.hasSubfolders, entity.hasSubfolders);
      expect(model.hasFiles, entity.hasFiles);
    });

    test('should handle complex folder content', () {
      // Arrange
      final json = {
        'folderInfo': {
          'id': 'folder-1',
          'name': 'Vacation',
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 2,
          'subfolderCount': 2,
        },
        'subfolders': [
          {
            'id': 'subfolder-1',
            'name': 'Summer',
            'parentFolderId': 'folder-1',
            'path': '/root/folder-1/subfolder-1',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 5,
            'subfolderCount': 0,
          },
          {
            'id': 'subfolder-2',
            'name': 'Winter',
            'parentFolderId': 'folder-1',
            'path': '/root/folder-1/subfolder-2',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 3,
            'subfolderCount': 0,
          },
        ],
        'files': {
          'files': [
            {
              'id': 'file-1',
              'type': 'IMAGE',
              'status': 'PENDING',
              'capturedAt': testDate.toIso8601String(),
            },
            {
              'id': 'file-2',
              'type': 'VIDEO',
              'status': 'PENDING',
              'capturedAt': testDate.toIso8601String(),
            },
          ],
          'hasNext': true,
        },
      };

      // Act
      final model = FolderContentModel.fromJson(json, currentPage: 0);

      // Assert
      expect(model.folder.fileCount, 2);
      expect(model.folder.subfolderCount, 2);
      expect(model.subfolders.length, 2);
      expect(model.files.length, 2);
      expect(model.hasMoreFiles, true);
      expect(model.isEmpty, false);
      expect(model.hasSubfolders, true);
      expect(model.hasFiles, true);
    });
  });
}
