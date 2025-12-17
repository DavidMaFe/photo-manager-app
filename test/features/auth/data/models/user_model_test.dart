import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    const testId = '1';
    const testEmail = 'test@example.com';
    const testName = 'John';
    const testSurname = 'Doe';

    group('fromJson', () {
      test('should create UserModel from JSON with all fields', () {
        // Arrange
        final json = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.id, testId);
        expect(result.email, testEmail);
        expect(result.name, testName);
        expect(result.surname, testSurname);
      });

      test('should create UserModel from JSON without surname', () {
        // Arrange
        final json = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': null,
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.id, testId);
        expect(result.email, testEmail);
        expect(result.name, testName);
        expect(result.surname, isNull);
      });

      test('should convert integer id to string', () {
        // Arrange
        final json = {
          'id': 123,
          'email': testEmail,
          'name': testName,
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.id, '123');
        expect(result.id, isA<String>());
      });

      test('should handle numeric string id', () {
        // Arrange
        final json = {
          'id': '456',
          'email': testEmail,
          'name': testName,
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.id, '456');
      });

      test('should be instance of User entity', () {
        // Arrange
        final json = {
          'id': testId,
          'email': testEmail,
          'name': testName,
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result, isA<User>());
      });
    });

    group('toJson', () {
      test('should convert UserModel to JSON with all fields', () {
        // Arrange
        final userModel = UserModel(
          id: testId,
          email: testEmail,
          name: testName,
          surname: testSurname,
        );

        // Act
        final result = userModel.toJson();

        // Assert
        expect(result['id'], testId);
        expect(result['email'], testEmail);
        expect(result['name'], testName);
        expect(result['surname'], testSurname);
      });

      test('should exclude null surname from JSON', () {
        // Arrange
        final userModel = UserModel(
          id: testId,
          email: testEmail,
          name: testName,
        );

        // Act
        final result = userModel.toJson();

        // Assert
        expect(result['id'], testId);
        expect(result['email'], testEmail);
        expect(result['name'], testName);
        expect(result.containsKey('surname'), isFalse);
      });

      test('should create valid JSON map', () {
        // Arrange
        final userModel = UserModel(
          id: testId,
          email: testEmail,
          name: testName,
          surname: testSurname,
        );

        // Act
        final result = userModel.toJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.keys, containsAll(['id', 'email', 'name', 'surname']));
      });
    });

    group('fromEntity', () {
      test('should create UserModel from User entity with all fields', () {
        // Arrange
        final user = User(
          id: testId,
          email: testEmail,
          name: testName,
          surname: testSurname,
        );

        // Act
        final result = UserModel.fromEntity(user);

        // Assert
        expect(result.id, user.id);
        expect(result.email, user.email);
        expect(result.name, user.name);
        expect(result.surname, user.surname);
        expect(result, isA<UserModel>());
      });

      test('should create UserModel from User entity without surname', () {
        // Arrange
        final user = User(
          id: testId,
          email: testEmail,
          name: testName,
        );

        // Act
        final result = UserModel.fromEntity(user);

        // Assert
        expect(result.id, user.id);
        expect(result.email, user.email);
        expect(result.name, user.name);
        expect(result.surname, isNull);
      });

      test('should preserve all entity properties', () {
        // Arrange
        final user = User(
          id: '999',
          email: 'different@example.com',
          name: 'Jane',
          surname: 'Smith',
        );

        // Act
        final result = UserModel.fromEntity(user);

        // Assert
        expect(result.id, '999');
        expect(result.email, 'different@example.com');
        expect(result.name, 'Jane');
        expect(result.surname, 'Smith');
      });
    });

    group('JSON serialization round-trip', () {
      test('should maintain data integrity through fromJson and toJson', () {
        // Arrange
        final originalJson = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': testSurname,
        };

        // Act
        final model = UserModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson['id'], originalJson['id']);
        expect(resultJson['email'], originalJson['email']);
        expect(resultJson['name'], originalJson['name']);
        expect(resultJson['surname'], originalJson['surname']);
      });

      test('should handle null surname in round-trip', () {
        // Arrange
        final originalJson = {
          'id': testId,
          'email': testEmail,
          'name': testName,
          'surname': null,
        };

        // Act
        final model = UserModel.fromJson(originalJson);
        final resultJson = model.toJson();

        // Assert
        expect(resultJson.containsKey('surname'), isFalse);
      });
    });

    group('inheritance', () {
      test('should inherit User entity methods', () {
        // Arrange
        final userModel = UserModel(
          id: testId,
          email: testEmail,
          name: testName,
        );

        // Assert
        expect(userModel.isValid, isTrue);
        expect(userModel, isA<User>());
      });

      test('should support User equality comparison', () {
        // Arrange
        final model1 = UserModel(
          id: testId,
          email: testEmail,
          name: testName,
        );
        final model2 = UserModel(
          id: testId,
          email: 'different@example.com',
          name: 'Different Name',
        );

        // Assert - equality based on id only
        expect(model1, equals(model2));
      });

      test('should support copyWith from User', () {
        // Arrange
        final userModel = UserModel(
          id: testId,
          email: testEmail,
          name: testName,
        );

        // Act
        final updated = userModel.copyWith(name: 'Updated Name');

        // Assert
        expect(updated.name, 'Updated Name');
        expect(updated.id, testId);
        expect(updated.email, testEmail);
      });
    });
  });
}
