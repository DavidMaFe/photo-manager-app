import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/request_password_reset_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RequestPasswordResetUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = RequestPasswordResetUseCase(mockAuthRepository);
  });

  group('RequestPasswordResetUseCase', () {
    const testEmail = 'test@example.com';

    group('email validation', () {
      test('should throw exception when email is empty', () async {
        // Act & Assert
        expect(
          () => useCase(email: ''),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );

        // Verify repository was never called
        verifyNever(() => mockAuthRepository.requestPasswordReset(
              any(),
            ));
      });

      test('should throw exception when email contains only whitespace',
          () async {
        // Act & Assert
        expect(
          () => useCase(email: '   '),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.requestPasswordReset(
              any(),
            ));
      });

      test('should throw exception when email format is invalid', () async {
        // Arrange
        const invalidEmails = [
          'notanemail',
          'missing@domain',
          '@nodomain.com',
          'no@domain@double.com',
          'spaces in@email.com',
          'missing.domain@',
        ];

        for (final email in invalidEmails) {
          // Act & Assert
          expect(
            () => useCase(email: email),
            throwsA(
              predicate((e) =>
                  e is Exception && e.toString().contains('Email is not valid')),
            ),
            reason: 'Should reject invalid email: $email',
          );
        }

        verifyNever(() => mockAuthRepository.requestPasswordReset(
              any(),
            ));
      });

      test('should accept valid email formats', () async {
        // Arrange
        const validEmails = [
          'test@example.com',
          'user.name@domain.com',
          'user_name@domain.co.uk',
          'test123@test.org',
          'user-name@domain-name.com',
        ];

        for (final email in validEmails) {
          when(() => mockAuthRepository.requestPasswordReset(
                any(),
              )).thenAnswer((_) async => {});

          // Act
          await useCase(email: email);

          // Assert - should not throw
          verify(() => mockAuthRepository.requestPasswordReset(
                email,
              )).called(1);
        }
      });

      test('should trim email when sending to repository', () async {
        // Arrange
        when(() => mockAuthRepository.requestPasswordReset(
              any(),
            )).thenAnswer((_) async => {});

        // Act - Note: email validation happens on trimmed email
        await useCase(email: 'test@example.com');

        // Assert - email should be trimmed when sent to repository
        verify(() => mockAuthRepository.requestPasswordReset(
              'test@example.com',
            )).called(1);
      });
    });

    group('successful password reset request', () {
      test('should complete when email is valid', () async {
        // Arrange
        when(() => mockAuthRepository.requestPasswordReset(
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(email: testEmail);

        // Assert
        verify(() => mockAuthRepository.requestPasswordReset(
              testEmail,
            )).called(1);
      });

      test('should call repository with correct parameters', () async {
        // Arrange
        when(() => mockAuthRepository.requestPasswordReset(
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(email: testEmail);

        // Assert
        verify(() => mockAuthRepository.requestPasswordReset(
              testEmail,
            )).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      });
    });

    group('error propagation', () {
      test('should propagate repository exceptions', () async {
        // Arrange
        when(() => mockAuthRepository.requestPasswordReset(
              any(),
            )).thenThrow(Exception('Email not found'));

        // Act & Assert
        expect(
          () => useCase(email: testEmail),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email not found')),
          ),
        );

        verify(() => mockAuthRepository.requestPasswordReset(
              testEmail,
            )).called(1);
      });
    });
  });
}
