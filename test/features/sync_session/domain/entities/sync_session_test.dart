import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';

void main() {
  group('SyncSession Entity', () {
    test('should create sync session with all fields', () {
      // Arrange
      final id = 'session_123';
      final lastCompletedAt = DateTime(2024, 1, 15, 10, 30);

      // Act
      final syncSession = SyncSession(
        id: id,
        lastCompletedAt: lastCompletedAt,
      );

      // Assert
      expect(syncSession.id, id);
      expect(syncSession.lastCompletedAt, lastCompletedAt);
    });

    test('should create sync session with null lastCompletedAt', () {
      // Arrange & Act
      final syncSession = SyncSession(
        id: 'session_123',
        lastCompletedAt: null,
      );

      // Assert
      expect(syncSession.id, 'session_123');
      expect(syncSession.lastCompletedAt, null);
    });

    test('should create empty sync session', () {
      // Act
      final syncSession = SyncSession.empty();

      // Assert
      expect(syncSession.id, '');
      expect(syncSession.lastCompletedAt, null);
    });

    test('isValid should return true when id is not empty', () {
      // Arrange
      final syncSession = SyncSession(id: 'session_123');

      // Act & Assert
      expect(syncSession.isValid, true);
    });

    test('isValid should return false when id is empty', () {
      // Arrange
      final syncSession = SyncSession.empty();

      // Act & Assert
      expect(syncSession.isValid, false);
    });

    test('isFirstSync should return true when lastCompletedAt is null', () {
      // Arrange
      final syncSession = SyncSession(
        id: 'session_123',
        lastCompletedAt: null,
      );

      // Act & Assert
      expect(syncSession.isFirstSync, true);
    });

    test('isFirstSync should return false when lastCompletedAt is not null', () {
      // Arrange
      final syncSession = SyncSession(
        id: 'session_123',
        lastCompletedAt: DateTime(2024, 1, 15),
      );

      // Act & Assert
      expect(syncSession.isFirstSync, false);
    });

    test('copyWith should create new instance with updated id', () {
      // Arrange
      final syncSession = SyncSession(
        id: 'session_123',
        lastCompletedAt: DateTime(2024, 1, 15),
      );

      // Act
      final updated = syncSession.copyWith(id: 'session_456');

      // Assert
      expect(updated.id, 'session_456');
      expect(updated.lastCompletedAt, syncSession.lastCompletedAt);
      expect(updated, isNot(same(syncSession)));
    });

    test('copyWith should create new instance with updated lastCompletedAt', () {
      // Arrange
      final syncSession = SyncSession(
        id: 'session_123',
        lastCompletedAt: DateTime(2024, 1, 15),
      );
      final newDate = DateTime(2024, 1, 16);

      // Act
      final updated = syncSession.copyWith(lastCompletedAt: newDate);

      // Assert
      expect(updated.id, syncSession.id);
      expect(updated.lastCompletedAt, newDate);
      expect(updated, isNot(same(syncSession)));
    });

    test('copyWith should keep original values when no parameters provided', () {
      // Arrange
      final syncSession = SyncSession(
        id: 'session_123',
        lastCompletedAt: DateTime(2024, 1, 15),
      );

      // Act
      final updated = syncSession.copyWith();

      // Assert
      expect(updated.id, syncSession.id);
      expect(updated.lastCompletedAt, syncSession.lastCompletedAt);
      expect(updated, isNot(same(syncSession)));
    });

    test('equality should be true for same id', () {
      // Arrange
      final syncSession1 = SyncSession(
        id: 'session_123',
        lastCompletedAt: DateTime(2024, 1, 15),
      );
      final syncSession2 = SyncSession(
        id: 'session_123',
        lastCompletedAt: DateTime(2024, 1, 16),
      );

      // Act & Assert
      expect(syncSession1 == syncSession2, true);
      expect(syncSession1.hashCode, syncSession2.hashCode);
    });

    test('equality should be false for different ids', () {
      // Arrange
      final syncSession1 = SyncSession(id: 'session_123');
      final syncSession2 = SyncSession(id: 'session_456');

      // Act & Assert
      expect(syncSession1 == syncSession2, false);
      expect(syncSession1.hashCode, isNot(syncSession2.hashCode));
    });

    test('equality should be true for identical instances', () {
      // Arrange
      final syncSession = SyncSession(id: 'session_123');

      // Act & Assert
      expect(syncSession == syncSession, true);
    });
  });
}