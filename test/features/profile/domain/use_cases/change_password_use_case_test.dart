import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/change_password_use_case.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late ChangePasswordUseCase useCase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    useCase = ChangePasswordUseCase(mockProfileRepository);
  });

  group('ChangePasswordUseCase', () {
    test('should call repository changePassword method with correct parameters',
        () async {
      // Arrange
      when(() => mockProfileRepository.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => Future.value());

      // Act
      await useCase(
        currentPassword: 'oldPassword123',
        newPassword: 'newPassword456',
      );

      // Assert
      verify(() => mockProfileRepository.changePassword(
            currentPassword: 'oldPassword123',
            newPassword: 'newPassword456',
          )).called(1);
      verifyNoMoreInteractions(mockProfileRepository);
    });

    test('should complete successfully when repository succeeds', () async {
      // Arrange
      when(() => mockProfileRepository.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => Future.value());

      // Act
      await expectLater(
        useCase(
          currentPassword: 'oldPassword123',
          newPassword: 'newPassword456',
        ),
        completes,
      );

      // Assert
      verify(() => mockProfileRepository.changePassword(
            currentPassword: 'oldPassword123',
            newPassword: 'newPassword456',
          )).called(1);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(() => mockProfileRepository.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(Exception('Invalid current password'));

      // Act & Assert
      expect(
        () => useCase(
          currentPassword: 'wrongPassword',
          newPassword: 'newPassword456',
        ),
        throwsA(
          predicate((e) => e is Exception &&
              e.toString().contains('Invalid current password')),
        ),
      );

      verify(() => mockProfileRepository.changePassword(
            currentPassword: 'wrongPassword',
            newPassword: 'newPassword456',
          )).called(1);
    });

    test('should handle network errors from repository', () async {
      // Arrange
      when(() => mockProfileRepository.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase(
          currentPassword: 'oldPassword123',
          newPassword: 'newPassword456',
        ),
        throwsA(
          predicate((e) =>
              e is Exception && e.toString().contains('Network error')),
        ),
      );
    });

    test('should handle unauthorized errors from repository', () async {
      // Arrange
      when(() => mockProfileRepository.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(Exception('Invalid or expired token'));

      // Act & Assert
      expect(
        () => useCase(
          currentPassword: 'oldPassword123',
          newPassword: 'newPassword456',
        ),
        throwsA(
          predicate((e) => e is Exception &&
              e.toString().contains('Invalid or expired token')),
        ),
      );
    });

    test('should handle server errors from repository', () async {
      // Arrange
      when(() => mockProfileRepository.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(Exception('Server error'));

      // Act & Assert
      expect(
        () => useCase(
          currentPassword: 'oldPassword123',
          newPassword: 'newPassword456',
        ),
        throwsA(
          predicate((e) =>
              e is Exception && e.toString().contains('Server error')),
        ),
      );
    });

    test('should handle different password formats', () async {
      // Arrange
      when(() => mockProfileRepository.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => Future.value());

      // Act
      await useCase(
        currentPassword: 'Complex!Pass123',
        newPassword: 'NewComplex!Pass456',
      );

      // Assert
      verify(() => mockProfileRepository.changePassword(
            currentPassword: 'Complex!Pass123',
            newPassword: 'NewComplex!Pass456',
          )).called(1);
    });
  });
}
