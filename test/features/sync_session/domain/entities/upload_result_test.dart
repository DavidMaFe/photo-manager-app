import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/upload_result.dart';

void main() {
  group('UploadResult Entity', () {
    test('should create upload result with server file id', () {
      // Arrange & Act
      const uploadResult = UploadResult(serverFileId: 'file_123');

      // Assert
      expect(uploadResult.serverFileId, 'file_123');
    });

    test('should create upload result without server file id', () {
      // Arrange & Act
      const uploadResult = UploadResult(serverFileId: null);

      // Assert
      expect(uploadResult.serverFileId, null);
    });

    test('should create upload result with default null id', () {
      // Arrange & Act
      const uploadResult = UploadResult();

      // Assert
      expect(uploadResult.serverFileId, null);
    });

    test('Equatable props should include serverFileId', () {
      // Arrange
      const uploadResult = UploadResult(serverFileId: 'file_123');

      // Act
      final props = uploadResult.props;

      // Assert
      expect(props, ['file_123']);
    });

    test('Equatable props should include null serverFileId', () {
      // Arrange
      const uploadResult = UploadResult(serverFileId: null);

      // Act
      final props = uploadResult.props;

      // Assert
      expect(props, [null]);
    });

    test('equality should be true for same server file id', () {
      // Arrange
      const uploadResult1 = UploadResult(serverFileId: 'file_123');
      const uploadResult2 = UploadResult(serverFileId: 'file_123');

      // Act & Assert
      expect(uploadResult1, uploadResult2);
      expect(uploadResult1.hashCode, uploadResult2.hashCode);
    });

    test('equality should be false for different server file ids', () {
      // Arrange
      const uploadResult1 = UploadResult(serverFileId: 'file_123');
      const uploadResult2 = UploadResult(serverFileId: 'file_456');

      // Act & Assert
      expect(uploadResult1, isNot(uploadResult2));
    });

    test('equality should be true for both null server file ids', () {
      // Arrange
      const uploadResult1 = UploadResult(serverFileId: null);
      const uploadResult2 = UploadResult();

      // Act & Assert
      expect(uploadResult1, uploadResult2);
    });

    test('equality should be false for null vs non-null server file id', () {
      // Arrange
      const uploadResult1 = UploadResult(serverFileId: null);
      const uploadResult2 = UploadResult(serverFileId: 'file_123');

      // Act & Assert
      expect(uploadResult1, isNot(uploadResult2));
    });

    test('equality should be true for identical instances', () {
      // Arrange
      const uploadResult = UploadResult(serverFileId: 'file_123');

      // Act & Assert
      expect(uploadResult, uploadResult);
    });
  });
}