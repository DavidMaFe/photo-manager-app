import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('should create a valid user with all fields', () {
      // Arrange & Act
      final user = User(
        id: '1',
        email: 'test@example.com',
        name: 'John',
        surname: 'Doe',
      );

      // Assert
      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.name, 'John');
      expect(user.surname, 'Doe');
    });

    test('should create a valid user without surname', () {
      // Arrange & Act
      final user = User(
        id: '1',
        email: 'test@example.com',
        name: 'John',
      );

      // Assert
      expect(user.id, '1');
      expect(user.email, 'test@example.com');
      expect(user.name, 'John');
      expect(user.surname, isNull);
    });

    test('should create an empty user using factory', () {
      // Act
      final user = User.empty();

      // Assert
      expect(user.id, '');
      expect(user.email, '');
      expect(user.name, '');
      expect(user.surname, isNull);
    });

    group('isValid getter', () {
      test('should return true when all required fields are non-empty', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );

        // Assert
        expect(user.isValid, isTrue);
      });

      test('should return false when id is empty', () {
        // Arrange
        final user = User(
          id: '',
          email: 'test@example.com',
          name: 'John',
        );

        // Assert
        expect(user.isValid, isFalse);
      });

      test('should return false when email is empty', () {
        // Arrange
        final user = User(
          id: '1',
          email: '',
          name: 'John',
        );

        // Assert
        expect(user.isValid, isFalse);
      });

      test('should return false when name is empty', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: '',
        );

        // Assert
        expect(user.isValid, isFalse);
      });

      test('should return false for empty user', () {
        // Arrange
        final user = User.empty();

        // Assert
        expect(user.isValid, isFalse);
      });

      test('should return true even when surname is null', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          surname: null,
        );

        // Assert
        expect(user.isValid, isTrue);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated id', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          surname: 'Doe',
        );

        // Act
        final updatedUser = user.copyWith(id: '2');

        // Assert
        expect(updatedUser.id, '2');
        expect(updatedUser.email, 'test@example.com');
        expect(updatedUser.name, 'John');
        expect(updatedUser.surname, 'Doe');
      });

      test('should create a copy with updated email', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );

        // Act
        final updatedUser = user.copyWith(email: 'newemail@example.com');

        // Assert
        expect(updatedUser.email, 'newemail@example.com');
        expect(updatedUser.id, '1');
        expect(updatedUser.name, 'John');
      });

      test('should create a copy with updated name', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );

        // Act
        final updatedUser = user.copyWith(name: 'Jane');

        // Assert
        expect(updatedUser.name, 'Jane');
        expect(updatedUser.id, '1');
        expect(updatedUser.email, 'test@example.com');
      });

      test('should create a copy with updated surname', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );

        // Act
        final updatedUser = user.copyWith(surname: 'Smith');

        // Assert
        expect(updatedUser.surname, 'Smith');
        expect(updatedUser.id, '1');
      });

      test('should preserve existing values when no parameters provided', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
          surname: 'Doe',
        );

        // Act
        final updatedUser = user.copyWith();

        // Assert
        expect(updatedUser.id, '1');
        expect(updatedUser.email, 'test@example.com');
        expect(updatedUser.name, 'John');
        expect(updatedUser.surname, 'Doe');
      });

      test('should update multiple fields at once', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );

        // Act
        final updatedUser = user.copyWith(
          name: 'Jane',
          surname: 'Smith',
        );

        // Assert
        expect(updatedUser.name, 'Jane');
        expect(updatedUser.surname, 'Smith');
        expect(updatedUser.id, '1');
        expect(updatedUser.email, 'test@example.com');
      });
    });

    group('equality', () {
      test('should be equal when users have the same id', () {
        // Arrange
        final user1 = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );
        final user2 = User(
          id: '1',
          email: 'different@example.com',
          name: 'Jane',
        );

        // Assert
        expect(user1, equals(user2));
      });

      test('should not be equal when users have different ids', () {
        // Arrange
        final user1 = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );
        final user2 = User(
          id: '2',
          email: 'test@example.com',
          name: 'John',
        );

        // Assert
        expect(user1, isNot(equals(user2)));
      });

      test('should be equal to itself', () {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );

        // Assert
        expect(user, equals(user));
      });
    });

    group('hashCode', () {
      test('should have the same hashCode for users with same id', () {
        // Arrange
        final user1 = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );
        final user2 = User(
          id: '1',
          email: 'different@example.com',
          name: 'Jane',
        );

        // Assert
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should have different hashCode for users with different ids', () {
        // Arrange
        final user1 = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );
        final user2 = User(
          id: '2',
          email: 'test@example.com',
          name: 'John',
        );

        // Assert
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });

      test('should be consistent with equality operator', () {
        // Arrange
        final user1 = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );
        final user2 = User(
          id: '1',
          email: 'test@example.com',
          name: 'John',
        );

        // Assert
        if (user1 == user2) {
          expect(user1.hashCode, equals(user2.hashCode));
        }
      });
    });
  });
}
