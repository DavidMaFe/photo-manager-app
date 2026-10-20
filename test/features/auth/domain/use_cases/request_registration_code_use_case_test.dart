import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/request_registration_code_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late RequestRegistrationCodeUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = RequestRegistrationCodeUseCase(repository);
    when(() => repository.requestRegistrationCode(any())).thenAnswer((_) async {});
  });

  group('RequestRegistrationCodeUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should request the code for the trimmed email', () async {
      await useCase('  ana@example.com ');

      verify(() => repository.requestRegistrationCode('ana@example.com')).called(1);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    for (final (description, email) in [('empty', '  '), ('not valid', 'not-an-email')]) {
      test('should throw without calling the server when the email is $description', () async {
        await expectLater(useCase(email), throwsException);

        verifyNever(() => repository.requestRegistrationCode(any()));
      });
    }

    // ==================== ERROR TESTS ====================

    test('should pass on the error of the server (an email with an account)', () async {
      when(() => repository.requestRegistrationCode(any())).thenThrow(Exception('EMAIL_ALREADY_USED'));

      await expectLater(useCase('ana@example.com'), throwsException);
    });
  });
}
