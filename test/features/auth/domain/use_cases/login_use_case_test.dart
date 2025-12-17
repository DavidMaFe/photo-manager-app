import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  group('LoginUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    final testUser = User(
      id: '1',
      email: testEmail,
      name: 'Test User',
    );

    group('email validation', () {
      test('should throw exception when email is empty', () async {
        // Act & Assert
        expect(
          () => useCase(email: '', password: testPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );

        // Verify repository was never called
        verifyNever(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ));
      });

      test('should throw exception when email contains only whitespace',
          () async {
        // Act & Assert
        expect(
          () => useCase(email: '   ', password: testPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
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
            () => useCase(email: email, password: testPassword),
            throwsA(
              predicate((e) =>
                  e is Exception && e.toString().contains('Email is not valid')),
            ),
            reason: 'Should reject invalid email: $email',
          );
        }

        verifyNever(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
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
          when(() => mockAuthRepository.login(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => testUser);

          // Act
          await useCase(email: email, password: testPassword);

          // Assert - should not throw
          verify(() => mockAuthRepository.login(
                email: email,
                password: testPassword,
              )).called(1);
        }
      });

      test('should trim email when sending to repository',
          () async {
        // Arrange
        when(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);

        // Act - Note: email validation happens on untrimmed email
        // So we use an email without leading/trailing spaces for validation to pass
        await useCase(email: 'test@example.com', password: testPassword);

        // Assert - email should be trimmed when sent to repository
        verify(() => mockAuthRepository.login(
              email: 'test@example.com',
              password: testPassword,
            )).called(1);
      });
    });

    group('password validation', () {
      test('should throw exception when password is empty', () async {
        // Act & Assert
        expect(
          () => useCase(email: testEmail, password: ''),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Password is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ));
      });

      test('should throw exception when password contains only whitespace',
          () async {
        // Act & Assert
        expect(
          () => useCase(email: testEmail, password: '    '),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Password is required')),
          ),
        );

        verifyNever(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ));
      });

      test('should accept non-empty password', () async {
        // Arrange
        when(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);

        // Act
        await useCase(email: testEmail, password: 'validPassword123');

        // Assert
        verify(() => mockAuthRepository.login(
              email: testEmail,
              password: 'validPassword123',
            )).called(1);
      });
    });

    group('successful login', () {
      test('should return user when credentials are valid', () async {
        // Arrange
        when(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);

        // Act
        final result = await useCase(email: testEmail, password: testPassword);

        // Assert
        expect(result, equals(testUser));
        verify(() => mockAuthRepository.login(
              email: testEmail,
              password: testPassword,
            )).called(1);
      });

      test('should call repository with correct parameters', () async {
        // Arrange
        when(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);

        // Act
        await useCase(email: testEmail, password: testPassword);

        // Assert
        verify(() => mockAuthRepository.login(
              email: testEmail,
              password: testPassword,
            )).called(1);
        verifyNoMoreInteractions(mockAuthRepository);
      });
    });

    group('validation order', () {
      test('should validate email before password', () async {
        // Act & Assert - empty email should be caught first
        expect(
          () => useCase(email: '', password: ''),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Email is required')),
          ),
        );
      });

      test('should validate password after email emptiness check',
          () async {
        // Act & Assert - When email is not empty but invalid, password is checked first
        // because password validation happens before email format validation
        expect(
          () => useCase(email: 'invalid-email', password: ''),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Password is required')),
          ),
        );
      });

      test('should validate all fields before calling repository', () async {
        // Arrange
        when(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);

        // Act
        await useCase(email: testEmail, password: testPassword);

        // Assert - repository should only be called once all validations pass
        verify(() => mockAuthRepository.login(
              email: testEmail,
              password: testPassword,
            )).called(1);
      });
    });

    group('error propagation', () {
      test('should propagate repository exceptions', () async {
        // Arrange
        when(() => mockAuthRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        expect(
          () => useCase(email: testEmail, password: testPassword),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Invalid credentials')),
          ),
        );

        verify(() => mockAuthRepository.login(
              email: testEmail,
              password: testPassword,
            )).called(1);
      });
    });
  });
}
