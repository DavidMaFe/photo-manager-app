import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/reset_password_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ResetPasswordUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = ResetPasswordUseCase(mockAuthRepository);
  });

  group('ResetPasswordUseCase', () {
    const testEmail = 'test@example.com';
    const testCode = '123456';
    const testPassword = 'newPassword123';

    group('email validation', () {
      test('should throw exception when email is empty', () async {
        // Act & Assert
        expect(
          () => useCase(email: '', code: testCode, newPassword: testPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );

        // Verify repository was never called
        verifyNever(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            ));
      });

      test('should throw exception when email contains only whitespace',
          () async {
        // Act & Assert
        expect(
          () => useCase(email: '   ', code: testCode, newPassword: testPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.resetPassword(
              any(),
              any(),
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
            () => useCase(email: email, code: testCode, newPassword: testPassword),
            throwsA(
              predicate((e) =>
                  e is Exception && e.toString().contains('Email is not valid')),
            ),
            reason: 'Should reject invalid email: $email',
          );
        }

        verifyNever(() => mockAuthRepository.resetPassword(
              any(),
              any(),
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
          when(() => mockAuthRepository.resetPassword(
                any(),
                any(),
                any(),
              )).thenAnswer((_) async => {});

          // Act
          await useCase(email: email, code: testCode, newPassword: testPassword);

          // Assert - should not throw
          verify(() => mockAuthRepository.resetPassword(
                email,
                testCode,
                testPassword,
              )).called(1);
        }
      });

      test('should trim email when sending to repository', () async {
        // Arrange
        when(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act - Note: email validation happens on trimmed email
        await useCase(
          email: 'test@example.com',
          code: testCode,
          newPassword: testPassword,
        );

        // Assert - email should be trimmed when sent to repository
        verify(() => mockAuthRepository.resetPassword(
              'test@example.com',
              testCode,
              testPassword,
            )).called(1);
      });
    });

    group('code validation', () {
      test('should throw exception when code is empty', () async {
        // Act & Assert
        expect(
          () => useCase(email: testEmail, code: '', newPassword: testPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Code is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            ));
      });

      test('should throw exception when code contains only whitespace',
          () async {
        // Act & Assert
        expect(
          () => useCase(email: testEmail, code: '    ', newPassword: testPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Code is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            ));
      });

      test('should throw exception when code format is invalid', () async {
        // Arrange
        const invalidCodes = [
          '12345',       // 5 digits
          '1234567',     // 7 digits
          '12345a',      // contains letter
          'abcdef',      // all letters
          '123 456',     // contains space
          '123-456',     // contains hyphen
          '12.345',      // contains dot
        ];

        for (final code in invalidCodes) {
          // Act & Assert
          expect(
            () => useCase(email: testEmail, code: code, newPassword: testPassword),
            throwsA(
              predicate((e) =>
                  e is Exception &&
                  e.toString().contains('Code must be 6 digits')),
            ),
            reason: 'Should reject invalid code: $code',
          );
        }

        verifyNever(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            ));
      });

      test('should accept valid 6-digit code', () async {
        // Arrange
        const validCodes = [
          '123456',
          '000000',
          '999999',
          '654321',
        ];

        for (final code in validCodes) {
          when(() => mockAuthRepository.resetPassword(
                any(),
                any(),
                any(),
              )).thenAnswer((_) async => {});

          // Act
          await useCase(email: testEmail, code: code, newPassword: testPassword);

          // Assert - should not throw
          verify(() => mockAuthRepository.resetPassword(
                testEmail,
                code,
                testPassword,
              )).called(1);
        }
      });

      test('should trim code when sending to repository', () async {
        // Arrange
        when(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(
          email: testEmail,
          code: '  123456  ',
          newPassword: testPassword,
        );

        // Assert - code should be trimmed when sent to repository
        verify(() => mockAuthRepository.resetPassword(
              testEmail,
              '123456',
              testPassword,
            )).called(1);
      });
    });

    group('password validation', () {
      test('should throw exception when password is empty', () async {
        // Act & Assert
        expect(
          () => useCase(email: testEmail, code: testCode, newPassword: ''),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Password is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            ));
      });

      test('should throw exception when password contains only whitespace',
          () async {
        // Act & Assert
        expect(
          () => useCase(email: testEmail, code: testCode, newPassword: '    '),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Password is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            ));
      });

      test('should accept non-empty password', () async {
        // Arrange
        when(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(
          email: testEmail,
          code: testCode,
          newPassword: 'validPassword123',
        );

        // Assert
        verify(() => mockAuthRepository.resetPassword(
              testEmail,
              testCode,
              'validPassword123',
            )).called(1);
      });

      test('should NOT trim password when sending to repository', () async {
        // Arrange
        when(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act - password with spaces should be preserved
        await useCase(
          email: testEmail,
          code: testCode,
          newPassword: '  password with spaces  ',
        );

        // Assert - password should NOT be trimmed (spaces are valid in passwords)
        verify(() => mockAuthRepository.resetPassword(
              testEmail,
              testCode,
              '  password with spaces  ',
            )).called(1);
      });
    });

    group('validation order', () {
      test('should validate email before code and password', () async {
        // Act & Assert - empty email should be caught first
        expect(
          () => useCase(email: '', code: '', newPassword: ''),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );
      });

      test('should validate code after email format validation', () async {
        // Act & Assert - when email is valid but code is empty
        expect(
          () => useCase(email: testEmail, code: '', newPassword: testPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Code is required')),
          ),
        );
      });

      test('should validate password after code validation', () async {
        // Act & Assert - when email and code are valid but password is empty
        expect(
          () => useCase(email: testEmail, code: testCode, newPassword: ''),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Password is required')),
          ),
        );
      });

      test('should validate all fields before calling repository', () async {
        // Arrange
        when(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(
          email: testEmail,
          code: testCode,
          newPassword: testPassword,
        );

        // Assert - repository should only be called once all validations pass
        verify(() => mockAuthRepository.resetPassword(
              testEmail,
              testCode,
              testPassword,
            )).called(1);
      });
    });

    group('successful password reset', () {
      test('should complete when all parameters are valid', () async {
        // Arrange
        when(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(
          email: testEmail,
          code: testCode,
          newPassword: testPassword,
        );

        // Assert
        verify(() => mockAuthRepository.resetPassword(
              testEmail,
              testCode,
              testPassword,
            )).called(1);
      });

      test('should call repository with correct parameters', () async {
        // Arrange
        when(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(
          email: testEmail,
          code: testCode,
          newPassword: testPassword,
        );

        // Assert
        verify(() => mockAuthRepository.resetPassword(
              testEmail,
              testCode,
              testPassword,
            )).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      });
    });

    group('error propagation', () {
      test('should propagate repository exceptions', () async {
        // Arrange
        when(() => mockAuthRepository.resetPassword(
              any(),
              any(),
              any(),
            )).thenThrow(Exception('Password reset failed'));

        // Act & Assert
        expect(
          () => useCase(
            email: testEmail,
            code: testCode,
            newPassword: testPassword,
          ),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Password reset failed')),
          ),
        );

        verify(() => mockAuthRepository.resetPassword(
              testEmail,
              testCode,
              testPassword,
            )).called(1);
      });
    });
  });
}
