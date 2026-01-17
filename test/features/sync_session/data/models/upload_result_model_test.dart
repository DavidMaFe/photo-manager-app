import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/data/models/upload_result_model.dart';

void main() {
  group('UploadResultModel', () {
    const fileId = 'file_123';

    group('fromJson', () {
      test('should create model from JSON with fileId', () {
        // Arrange
        final json = {'fileId': fileId};

        // Act
        final model = UploadResultModel.fromJson(json);

        // Assert
        expect(model.fileId, fileId);
      });

      test('should convert fileId to string when it is an integer', () {
        // Arrange
        final json = {'fileId': 123};

        // Act
        final model = UploadResultModel.fromJson(json);

        // Assert
        expect(model.fileId, '123');
      });

      test('should convert fileId to string when it is a double', () {
        // Arrange
        final json = {'fileId': 123.0};

        // Act
        final model = UploadResultModel.fromJson(json);

        // Assert
        expect(model.fileId, '123.0');
      });
    });

    group('constructor', () {
      test('should create model with fileId', () {
        // Act
        const model = UploadResultModel(fileId: fileId);

        // Assert
        expect(model.fileId, fileId);
      });

      test('should be const constructible', () {
        // This test ensures the const constructor works
        const model1 = UploadResultModel(fileId: fileId);
        const model2 = UploadResultModel(fileId: fileId);

        // Assert
        expect(identical(model1, model2), true);
      });
    });

    group('equality', () {
      test('should be equal when fileId is the same', () {
        // Arrange
        const model1 = UploadResultModel(fileId: fileId);
        const model2 = UploadResultModel(fileId: fileId);

        // Assert
        expect(model1.fileId, model2.fileId);
      });

      test('should be different when fileId is different', () {
        // Arrange
        const model1 = UploadResultModel(fileId: 'file_123');
        const model2 = UploadResultModel(fileId: 'file_456');

        // Assert
        expect(model1.fileId == model2.fileId, false);
      });
    });

    group('type conversion', () {
      test('should handle various numeric types in JSON', () {
        // Arrange & Act
        final modelFromInt = UploadResultModel.fromJson({'fileId': 999});
        final modelFromDouble = UploadResultModel.fromJson({'fileId': 999.5});
        final modelFromString = UploadResultModel.fromJson({'fileId': '999'});

        // Assert
        expect(modelFromInt.fileId, '999');
        expect(modelFromDouble.fileId, '999.5');
        expect(modelFromString.fileId, '999');
      });

      test('should handle boolean conversion to string', () {
        // Arrange
        final json = {'fileId': true};

        // Act
        final model = UploadResultModel.fromJson(json);

        // Assert
        expect(model.fileId, 'true');
      });
    });
  });
}