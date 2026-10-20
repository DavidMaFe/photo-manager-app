import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/verify_registration_code_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late VerifyRegistrationCodeUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = VerifyRegistrationCodeUseCase(repository);
    when(() => repository.verifyRegistrationCode(any(), any())).thenAnswer((_) async {});
  });

  group('VerifyRegistrationCodeUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should verify the trimmed code of the trimmed email', () async {
      await useCase(email: ' ana@example.com ', code: ' 482913 ');

      verify(() => repository.verifyRegistrationCode('ana@example.com', '482913')).called(1);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    for (final (description, code) in [('empty', ''), ('5 digits', '12345'), ('7 digits', '1234567'),
        ('not only digits', '12a456')]) {
      test('should throw without calling the server when the code is $description', () async {
        await expectLater(useCase(email: 'ana@example.com', code: code), throwsException);

        verifyNever(() => repository.verifyRegistrationCode(any(), any()));
      });
    }

    test('should throw without calling the server when the email is not valid', () async {
      await expectLater(useCase(email: 'not-an-email', code: '482913'), throwsException);

      verifyNever(() => repository.verifyRegistrationCode(any(), any()));
    });
  });
}
