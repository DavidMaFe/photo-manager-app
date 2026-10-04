import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_file_model.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_page_model.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';

void main() {
  group('GalleryPageModel', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    test('should be a subclass of GalleryPage entity', () {
      // Arrange
      const model = GalleryPageModel(
        files: [],
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
        totalFilesCount: 0,
        totalPendingCount: 0,
      );

      // Assert
      expect(model, isA<GalleryPage>());
    });

    test('should create model from JSON with files', () {
      // Arrange
      final json = {
        'files': [
          {
            'id': 123,
            'type': 'IMAGE',
            'status': 'MANAGED',
            'capturedAt': '2024-01-15T10:30:00.000Z',
          },
          {
            'id': 456,
            'type': 'VIDEO',
            'status': 'PENDING',
            'durationSeconds': 120,
            'capturedAt': '2024-01-15T10:30:00.000Z',
          },
        ],
        'hasNext': true,
        'totalCount': 100,
        'totalPendingCount': 25,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 0,
        pageSize: 50,
      );

      // Assert
      expect(model.files.length, 2);
      expect(model.files[0].id, '123');
      expect(model.files[0].type, FileType.image);
      expect(model.files[1].id, '456');
      expect(model.files[1].type, FileType.video);
      expect(model.currentPage, 0);
      expect(model.pageSize, 50);
      expect(model.hasNext, true);
      expect(model.totalFilesCount, 100);
      expect(model.totalPendingCount, 25);
    });

    test('should handle empty files list in JSON', () {
      // Arrange
      final json = {
        'files': [],
        'hasNext': false,
        'totalCount': 0,
        'totalPendingCount': 0,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 0,
        pageSize: 50,
      );

      // Assert
      expect(model.files, isEmpty);
      expect(model.currentPage, 0);
      expect(model.pageSize, 50);
      expect(model.hasNext, false);
    });

    test('should parse page parameters from constructor', () {
      // Arrange
      final json = {
        'files': [],
        'hasNext': false,
        'totalCount': 0,
        'totalPendingCount': 0,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 3,
        pageSize: 100,
      );

      // Assert
      expect(model.currentPage, 3);
      expect(model.pageSize, 100);
    });

    test('should handle hasNext true', () {
      // Arrange
      final json = {
        'files': [],
        'hasNext': true,
        'totalCount': 0,
        'totalPendingCount': 0,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 0,
        pageSize: 50,
      );

      // Assert
      expect(model.hasNext, true);
    });

    test('should handle hasNext false', () {
      // Arrange
      final json = {
        'files': [],
        'hasNext': false,
        'totalCount': 0,
        'totalPendingCount': 0,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 0,
        pageSize: 50,
      );

      // Assert
      expect(model.hasNext, false);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final files = [
        GalleryFileModel(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
        GalleryFileModel(
          id: 'file-2',
          type: FileType.video,
          status: FileStatus.pending,
          durationSeconds: 120,
          capturedAt: testDate,
        ),
      ];

      final model = GalleryPageModel(
        files: files,
        currentPage: 2,
        pageSize: 50,
        hasNext: true,
        totalFilesCount: 100,
        totalPendingCount: 1,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['files'], isA<List>());
      expect((json['files'] as List).length, 2);
      expect(json['currentPage'], 2);
      expect(json['pageSize'], 50);
      expect(json['hasNext'], true);
    });

    test('should serialize empty files list to JSON', () {
      // Arrange
      const model = GalleryPageModel(
        files: [],
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
        totalFilesCount: 0,
        totalPendingCount: 0,
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['files'], isEmpty);
      expect(json['currentPage'], 0);
      expect(json['pageSize'], 50);
      expect(json['hasNext'], false);
    });

    test('should handle multiple files in JSON', () {
      // Arrange
      final filesJson = List.generate(
        10,
        (index) => {
          'id': index,
          'type': 'IMAGE',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
        },
      );

      final json = {
        'files': filesJson,
        'hasNext': true,
        'totalCount': 100,
        'totalPendingCount': 0,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 0,
        pageSize: 50,
      );

      // Assert
      expect(model.files.length, 10);
      expect(model.files[0].id, '0');
      expect(model.files[9].id, '9');
    });

    test('should perform round-trip conversion with files', () {
      // Arrange
      final files = [
        GalleryFileModel(
          id: 'file-1',
          type: FileType.image,
          status: FileStatus.managed,
          capturedAt: testDate,
        ),
      ];

      final original = GalleryPageModel(
        files: files,
        currentPage: 1,
        pageSize: 50,
        hasNext: true,
        totalFilesCount: 100,
        totalPendingCount: 0,
      );

      // Act
      final json = original.toJson();
      final restored = GalleryPageModel.fromJson(
        json,
        currentPage: json['currentPage'] as int,
        pageSize: json['pageSize'] as int,
      );

      // Assert
      expect(restored.files.length, original.files.length);
      expect(restored.files[0].id, original.files[0].id);
      expect(restored.currentPage, original.currentPage);
      expect(restored.pageSize, original.pageSize);
      expect(restored.hasNext, original.hasNext);
    });

    test('should perform round-trip conversion with empty files', () {
      // Arrange
      const original = GalleryPageModel(
        files: [],
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
        totalFilesCount: 0,
        totalPendingCount: 0,
      );

      // Act
      final json = original.toJson();
      final restored = GalleryPageModel.fromJson(
        json,
        currentPage: json['currentPage'] as int,
        pageSize: json['pageSize'] as int,
      );

      // Assert
      expect(restored.files, isEmpty);
      expect(restored.currentPage, original.currentPage);
      expect(restored.pageSize, original.pageSize);
      expect(restored.hasNext, original.hasNext);
    });

    test('should handle page with single file', () {
      // Arrange
      final json = {
        'files': [
          {
            'id': '1',
            'type': 'IMAGE',
            'status': 'MANAGED',
            'capturedAt': '2024-01-15T10:30:00.000Z',
          },
        ],
        'hasNext': false,
        'totalCount': 1,
        'totalPendingCount': 0,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 0,
        pageSize: 50,
      );

      // Assert
      expect(model.files.length, 1);
      expect(model.hasNext, false);
    });

    test('should handle large page numbers', () {
      // Arrange
      final json = {
        'files': [],
        'hasNext': false,
        'totalCount': 0,
        'totalPendingCount': 0,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 999,
        pageSize: 50,
      );

      // Assert
      expect(model.currentPage, 999);
    });

    test('should handle large page sizes', () {
      // Arrange
      final json = {
        'files': [],
        'hasNext': false,
        'totalCount': 0,
        'totalPendingCount': 0,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 0,
        pageSize: 1000,
      );

      // Assert
      expect(model.pageSize, 1000);
    });

    test('should handle full page of files', () {
      // Arrange
      final filesJson = List.generate(
        50,
        (index) => {
          'id': 'file-$index',
          'type': 'IMAGE',
          'status': 'MANAGED',
          'capturedAt': '2024-01-15T10:30:00.000Z',
        },
      );

      final json = {
        'files': filesJson,
        'hasNext': true,
        'totalCount': 200,
        'totalPendingCount': 0,
      };

      // Act
      final model = GalleryPageModel.fromJson(
        json,
        currentPage: 0,
        pageSize: 50,
      );

      // Assert
      expect(model.files.length, 50);
      expect(model.hasNext, true);
    });

    test('should convert file entities to models in toJson', () {
      // Arrange
      final files = [
        GalleryFileModel(
          id: 'file-1',
          type: FileType.video,
          status: FileStatus.pending,
          durationSeconds: 180,
          capturedAt: testDate,
        ),
      ];

      final model = GalleryPageModel(
        files: files,
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
        totalFilesCount: 1,
        totalPendingCount: 1,
      );

      // Act
      final json = model.toJson();
      final fileJson = (json['files'] as List).first as Map<String, dynamic>;

      // Assert
      expect(fileJson['id'], 'file-1');
      expect(fileJson['type'], 'VIDEO');
      expect(fileJson['status'], 'PENDING');
      expect(fileJson['durationSeconds'], 180);
    });
  });
}
