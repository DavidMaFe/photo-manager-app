import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_session_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';

void main() {
  group('SyncSessionModel', () {
    const sessionId = 'session_123';
    final lastCompletedAt = DateTime(2024, 1, 15, 10, 30);

    test('should be a subclass of SyncSession entity', () {
      // Arrange
      final model = SyncSessionModel(id: sessionId);

      // Assert
      expect(model, isA<SyncSession>());
    });

    group('fromJson', () {
      test('should create model from JSON with all fields', () {
        // Arrange
        final json = {
          'sessionId': sessionId,
          'lastSyncCompletedAt': lastCompletedAt.toIso8601String(),
        };

        // Act
        final model = SyncSessionModel.fromJson(json);

        // Assert
        expect(model.id, sessionId);
        expect(model.lastCompletedAt, lastCompletedAt);
      });

      test('should create model from JSON with null lastSyncCompletedAt', () {
        // Arrange
        final json = {
          'sessionId': sessionId,
          'lastSyncCompletedAt': null,
        };

        // Act
        final model = SyncSessionModel.fromJson(json);

        // Assert
        expect(model.id, sessionId);
        expect(model.lastCompletedAt, null);
        expect(model.isFirstSync, true);
      });

      test('should create model from JSON without lastSyncCompletedAt field', () {
        // Arrange
        final json = {
          'sessionId': sessionId,
        };

        // Act
        final model = SyncSessionModel.fromJson(json);

        // Assert
        expect(model.id, sessionId);
        expect(model.lastCompletedAt, null);
      });

      test('should convert sessionId to string when it is an integer', () {
        // Arrange
        final json = {
          'sessionId': 123,
          'lastSyncCompletedAt': null,
        };

        // Act
        final model = SyncSessionModel.fromJson(json);

        // Assert
        expect(model.id, '123');
      });

      test('should parse ISO 8601 date string correctly', () {
        // Arrange
        final dateString = '2024-01-15T10:30:00.000Z';
        final json = {
          'sessionId': sessionId,
          'lastSyncCompletedAt': dateString,
        };

        // Act
        final model = SyncSessionModel.fromJson(json);

        // Assert
        expect(model.lastCompletedAt, DateTime.parse(dateString));
      });
    });

    group('toJson', () {
      test('should convert model to JSON with all fields', () {
        // Arrange
        final model = SyncSessionModel(
          id: sessionId,
          lastCompletedAt: lastCompletedAt,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['sessionId'], sessionId);
        expect(json['lastSyncCompletedAt'], lastCompletedAt.toIso8601String());
      });

      test('should convert model to JSON with null lastCompletedAt', () {
        // Arrange
        final model = SyncSessionModel(id: sessionId);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['sessionId'], sessionId);
        expect(json['lastSyncCompletedAt'], null);
      });

      test('should use ISO 8601 format for date', () {
        // Arrange
        final model = SyncSessionModel(
          id: sessionId,
          lastCompletedAt: lastCompletedAt,
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['lastSyncCompletedAt'], contains('T'));
        expect(DateTime.parse(json['lastSyncCompletedAt']), lastCompletedAt);
      });
    });

    group('fromEntity', () {
      test('should create model from SyncSession entity', () {
        // Arrange
        final entity = SyncSession(
          id: sessionId,
          lastCompletedAt: lastCompletedAt,
        );

        // Act
        final model = SyncSessionModel.fromEntity(entity);

        // Assert
        expect(model.id, entity.id);
        expect(model.lastCompletedAt, entity.lastCompletedAt);
        expect(model, isA<SyncSessionModel>());
      });

      test('should create model from entity with null lastCompletedAt', () {
        // Arrange
        final entity = SyncSession(id: sessionId);

        // Act
        final model = SyncSessionModel.fromEntity(entity);

        // Assert
        expect(model.id, entity.id);
        expect(model.lastCompletedAt, null);
      });
    });

    group('JSON round-trip', () {
      test('should maintain data integrity through serialization cycle', () {
        // Arrange
        final originalModel = SyncSessionModel(
          id: sessionId,
          lastCompletedAt: lastCompletedAt,
        );

        // Act
        final json = originalModel.toJson();
        final deserializedModel = SyncSessionModel.fromJson(json);

        // Assert
        expect(deserializedModel.id, originalModel.id);
        expect(deserializedModel.lastCompletedAt, originalModel.lastCompletedAt);
      });

      test('should handle null values through serialization cycle', () {
        // Arrange
        final originalModel = SyncSessionModel(id: sessionId);

        // Act
        final json = originalModel.toJson();
        final deserializedModel = SyncSessionModel.fromJson(json);

        // Assert
        expect(deserializedModel.id, originalModel.id);
        expect(deserializedModel.lastCompletedAt, null);
      });
    });
  });
}