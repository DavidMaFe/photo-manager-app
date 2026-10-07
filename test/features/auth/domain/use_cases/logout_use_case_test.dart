import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/logout_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockAuthRepository);
  });

  group('LogoutUseCase', () {
    test('should call repository logout method', () async {
      // Arrange
      when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});

      // Act
      await useCase();

      // Assert
      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should complete successfully when repository logout succeeds',
        () async {
      // Arrange
      when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});

      // Act & Assert - should not throw
      await expectLater(useCase(), completes);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      final exception = Exception('Logout failed');
      when(() => mockAuthRepository.logout()).thenThrow(exception);

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(
          predicate((e) =>
              e is Exception && e.toString().contains('Logout failed')),
        ),
      );

      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('should run every cleanup after logging out, even if one of them fails', () async {
      // Arrange
      final calls = <String>[];
      when(() => mockAuthRepository.logout()).thenAnswer((_) async => calls.add('logout'));
      useCase = LogoutUseCase(mockAuthRepository, onLogout: [
        () async => calls.add('reminders'),
        () async => throw Exception('file system error'),
        () async => calls.add('exported files'),
      ]);

      // Act
      await useCase();

      // Assert
      expect(calls, ['logout', 'reminders', 'exported files']);
    });

    test('should handle network errors from repository', () async {
      // Arrange
      when(() => mockAuthRepository.logout())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(
          predicate((e) =>
              e is Exception && e.toString().contains('Network error')),
        ),
      );
    });
  });
}
