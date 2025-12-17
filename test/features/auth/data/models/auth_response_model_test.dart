import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/auth/data/models/auth_response_model.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';

void main() {
  group('AuthResponseModel', () {
    const testToken = 'test_token_123';
    const testRefreshToken = 'refresh_token_456';
    const testId = '1';
    const testEmail = 'test@example.com';
    const testName = 'John';
    const testSurname = 'Doe';

    group('fromJson', () {
      test('should create AuthResponseModel from JSON with required fields', () {
        // Arrange
        final json = {
          'token': testToken,
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
        };

        // Act
        final result = AuthResponseModel.fromJson(json);

        // Assert
        expect(result.token, testToken);
        expect(result.user.id, testId);
        expect(result.user.email, testEmail);
        expect(result.user.name, testName);
        expect(result.user.surname, testSurname);
        expect(result.refreshToken, isNull);
        expect(result.expiresAt, isNull);
      });

      test('should create AuthResponseModel with refreshToken', () {
        // Arrange
        final json = {
          'token': testToken,
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
          'refreshToken': testRefreshToken,
        };

        // Act
        final result = AuthResponseModel.fromJson(json);

        // Assert
        expect(result.refreshToken, testRefreshToken);
      });

      test('should parse expiresAt from ISO 8601 string', () {
        // Arrange
        final expiryDate = DateTime(2025, 12, 31, 23, 59, 59);
        final json = {
          'token': testToken,
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
          'expiresAt': expiryDate.toIso8601String(),
        };

        // Act
        final result = AuthResponseModel.fromJson(json);

        // Assert
        expect(result.expiresAt, isNotNull);
        expect(result.expiresAt!.year, expiryDate.year);
        expect(result.expiresAt!.month, expiryDate.month);
        expect(result.expiresAt!.day, expiryDate.day);
      });

      test('should handle null expiresAt', () {
        // Arrange
        final json = {
          'token': testToken,
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
          'expiresAt': null,
        };

        // Act
        final result = AuthResponseModel.fromJson(json);

        // Assert
        expect(result.expiresAt, isNull);
      });

      test('should create model with all optional fields', () {
        // Arrange
        final expiryDate = DateTime.now().add(const Duration(hours: 1));
        final json = {
          'token': testToken,
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
          'refreshToken': testRefreshToken,
          'expiresAt': expiryDate.toIso8601String(),
        };

        // Act
        final result = AuthResponseModel.fromJson(json);

        // Assert
        expect(result.token, testToken);
        expect(result.refreshToken, testRefreshToken);
        expect(result.expiresAt, isNotNull);
      });

      test('should handle integer user id', () {
        // Arrange
        final json = {
          'token': testToken,
          'id': 123,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
        };

        // Act
        final result = AuthResponseModel.fromJson(json);

        // Assert
        expect(result.user.id, '123');
      });
    });

    group('toJson', () {
      test('should convert model to JSON with required fields only', () {
        // Arrange
        final model = AuthResponseModel(
          token: testToken,
          user: _createTestUserModel(),
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['token'], testToken);
        expect(result['user'], isNotNull);
        expect(result.containsKey('refreshToken'), isFalse);
        expect(result.containsKey('expiresAt'), isFalse);
      });

      test('should include refreshToken when present', () {
        // Arrange
        final model = AuthResponseModel(
          token: testToken,
          user: _createTestUserModel(),
          refreshToken: testRefreshToken,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['refreshToken'], testRefreshToken);
      });

      test('should include expiresAt as ISO 8601 string when present', () {
        // Arrange
        final expiryDate = DateTime(2025, 12, 31, 23, 59, 59);
        final model = AuthResponseModel(
          token: testToken,
          user: _createTestUserModel(),
          expiresAt: expiryDate,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['expiresAt'], isNotNull);
        expect(result['expiresAt'], expiryDate.toIso8601String());
      });

      test('should include all fields when all are present', () {
        // Arrange
        final expiryDate = DateTime.now().add(const Duration(hours: 1));
        final model = AuthResponseModel(
          token: testToken,
          user: _createTestUserModel(),
          refreshToken: testRefreshToken,
          expiresAt: expiryDate,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result.keys, containsAll(['token', 'user', 'refreshToken', 'expiresAt']));
      });
    });

    group('isExpired getter', () {
      test('should return false when expiresAt is null', () {
        // Arrange
        final model = AuthResponseModel(
          token: testToken,
          user: _createTestUserModel(),
        );

        // Act & Assert
        expect(model.isExpired, isFalse);
      });

      test('should return false when token has not expired yet', () {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(hours: 1));
        final model = AuthResponseModel(
          token: testToken,
          user: _createTestUserModel(),
          expiresAt: futureDate,
        );

        // Act & Assert
        expect(model.isExpired, isFalse);
      });

      test('should return true when token has expired', () {
        // Arrange
        final pastDate = DateTime.now().subtract(const Duration(hours: 1));
        final model = AuthResponseModel(
          token: testToken,
          user: _createTestUserModel(),
          expiresAt: pastDate,
        );

        // Act & Assert
        expect(model.isExpired, isTrue);
      });

      test('should return true when token expires exactly now', () {
        // Arrange - set expiry to a very recent past moment
        final justExpired = DateTime.now().subtract(const Duration(milliseconds: 1));
        final model = AuthResponseModel(
          token: testToken,
          user: _createTestUserModel(),
          expiresAt: justExpired,
        );

        // Act & Assert
        expect(model.isExpired, isTrue);
      });

      test('should return false for token expiring far in the future', () {
        // Arrange
        final farFuture = DateTime.now().add(const Duration(days: 365));
        final model = AuthResponseModel(
          token: testToken,
          user: _createTestUserModel(),
          expiresAt: farFuture,
        );

        // Act & Assert
        expect(model.isExpired, isFalse);
      });
    });

    group('JSON serialization round-trip', () {
      test('should maintain data through fromJson and toJson', () {
        // Arrange
        final originalJson = {
          'token': testToken,
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
          'refreshToken': testRefreshToken,
        };

        // Act
        final model = AuthResponseModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['token'], originalJson['token']);
        expect(resultJson['refreshToken'], originalJson['refreshToken']);
      });
    });
  });
}

// Helper function to create test UserModel
UserModel _createTestUserModel() {
  return UserModel(
    id: '1',
    email: 'test@example.com',
    name: 'John',
    surname: 'Doe',
  );
}
