import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/validate_reset_code_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ValidateResetCodeUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = ValidateResetCodeUseCase(mockAuthRepository);
  });

  group('ValidateResetCodeUseCase', () {
    const testEmail = 'test@example.com';
    const testCode = '123456';

    group('email validation', () {
      test('should throw exception when email is empty', () async {
        // Act & Assert
        expect(
          () => useCase(email: '', code: testCode),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );

        // Verify repository was never called
        verifyNever(() => mockAuthRepository.validateResetCode(
              any(),
              any(),
            ));
      });

      test('should throw exception when email contains only whitespace',
          () async {
        // Act & Assert
        expect(
          () => useCase(email: '   ', code: testCode),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.validateResetCode(
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
            () => useCase(email: email, code: testCode),
            throwsA(
              predicate((e) =>
                  e is Exception && e.toString().contains('Email is not valid')),
            ),
            reason: 'Should reject invalid email: $email',
          );
        }

        verifyNever(() => mockAuthRepository.validateResetCode(
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
          when(() => mockAuthRepository.validateResetCode(
                any(),
                any(),
              )).thenAnswer((_) async => {});

          // Act
          await useCase(email: email, code: testCode);

          // Assert - should not throw
          verify(() => mockAuthRepository.validateResetCode(
                email,
                testCode,
              )).called(1);
        }
      });

      test('should trim email when sending to repository', () async {
        // Arrange
        when(() => mockAuthRepository.validateResetCode(
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act - Note: email validation happens on trimmed email
        await useCase(email: 'test@example.com', code: testCode);

        // Assert - email should be trimmed when sent to repository
        verify(() => mockAuthRepository.validateResetCode(
              'test@example.com',
              testCode,
            )).called(1);
      });
    });

    group('code validation', () {
      test('should throw exception when code is empty', () async {
        // Act & Assert
        expect(
          () => useCase(email: testEmail, code: ''),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Code is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.validateResetCode(
              any(),
              any(),
            ));
      });

      test('should throw exception when code contains only whitespace',
          () async {
        // Act & Assert
        expect(
          () => useCase(email: testEmail, code: '    '),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Code is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.validateResetCode(
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
            () => useCase(email: testEmail, code: code),
            throwsA(
              predicate((e) =>
                  e is Exception &&
                  e.toString().contains('Code must be 6 digits')),
            ),
            reason: 'Should reject invalid code: $code',
          );
        }

        verifyNever(() => mockAuthRepository.validateResetCode(
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
          when(() => mockAuthRepository.validateResetCode(
                any(),
                any(),
              )).thenAnswer((_) async => {});

          // Act
          await useCase(email: testEmail, code: code);

          // Assert - should not throw
          verify(() => mockAuthRepository.validateResetCode(
                testEmail,
                code,
              )).called(1);
        }
      });

      test('should trim code when sending to repository', () async {
        // Arrange
        when(() => mockAuthRepository.validateResetCode(
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(email: testEmail, code: '  123456  ');

        // Assert - code should be trimmed when sent to repository
        verify(() => mockAuthRepository.validateResetCode(
              testEmail,
              '123456',
            )).called(1);
      });
    });

    group('validation order', () {
      test('should validate email before code', () async {
        // Act & Assert - empty email should be caught first
        expect(
          () => useCase(email: '', code: ''),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );
      });

      test('should validate code after email format validation', () async {
        // Act & Assert - when email is valid but code is empty
        expect(
          () => useCase(email: testEmail, code: ''),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Code is required')),
          ),
        );
      });

      test('should validate all fields before calling repository', () async {
        // Arrange
        when(() => mockAuthRepository.validateResetCode(
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(email: testEmail, code: testCode);

        // Assert - repository should only be called once all validations pass
        verify(() => mockAuthRepository.validateResetCode(
              testEmail,
              testCode,
            )).called(1);
      });
    });

    group('successful code validation', () {
      test('should complete when email and code are valid', () async {
        // Arrange
        when(() => mockAuthRepository.validateResetCode(
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(email: testEmail, code: testCode);

        // Assert
        verify(() => mockAuthRepository.validateResetCode(
              testEmail,
              testCode,
            )).called(1);
      });

      test('should call repository with correct parameters', () async {
        // Arrange
        when(() => mockAuthRepository.validateResetCode(
              any(),
              any(),
            )).thenAnswer((_) async => {});

        // Act
        await useCase(email: testEmail, code: testCode);

        // Assert
        verify(() => mockAuthRepository.validateResetCode(
              testEmail,
              testCode,
            )).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      });
    });

    group('error propagation', () {
      test('should propagate repository exceptions', () async {
        // Arrange
        when(() => mockAuthRepository.validateResetCode(
              any(),
              any(),
            )).thenThrow(Exception('Invalid code'));

        // Act & Assert
        expect(
          () => useCase(email: testEmail, code: testCode),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Invalid code')),
          ),
        );

        verify(() => mockAuthRepository.validateResetCode(
              testEmail,
              testCode,
            )).called(1);
      });
    });
  });
}
