import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/entities/second_factor_challenge.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/services/pending_login.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/verify_login_second_factor_use_case.dart';

import '../../../../helpers/e2ee_test_kit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late E2eeTestKit kit;
  late MockAuthRepository repository;
  late PendingLogin pendingLogin;
  late VerifyLoginSecondFactorUseCase useCase;

  const password = 'correct horse battery';
  const challenge = SecondFactorChallenge(challengeToken: 'challenge-token', method: 'EMAIL', emailHint: 't***@x.com');
  final user = User(id: '1', email: 'test@example.com', name: 'Test User');
  final params = E2eeTestKit.cheapParams();

  ApiException apiError(String code) =>
      ApiException(ErrorResponseModel(code: code, message: 'message', timestamp: '2026-10-20T10:00:00'));

  setUp(() async {
    kit = await E2eeTestKit.create();
    repository = MockAuthRepository();
    pendingLogin = PendingLogin();
    useCase = VerifyLoginSecondFactorUseCase(repository, kit.keyring, pendingLogin);
  });

  Future<void> startPendingLogin() async {
    pendingLogin.start(challenge, await kit.passwordKeys(password, params));
  }

  group('VerifyLoginSecondFactorUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should send the code and keep the master key opened with the KEK of the pending login', () async {
      // Arrange
      await startPendingLogin();
      final kek = pendingLogin.keys!.kek;
      final material = await kit.material(password, params);
      when(() => repository.verifyLoginSecondFactor(challengeToken: any(named: 'challengeToken'),
          code: any(named: 'code'))).thenAnswer((_) async => LoginResult(user: user,
          keys: AccountKeys(accountLocked: false, versions: [E2eeTestKit.serverVersion(material)])));

      // Act
      final result = await useCase(' 482913 ');

      // Assert
      verify(() => repository.verifyLoginSecondFactor(challengeToken: 'challenge-token', code: '482913')).called(1);
      expect(result.user, user);
      expect((await kit.store.getMasterKey(1))!.bytes, material.masterKey.bytes);
      expect(pendingLogin.isActive, isFalse);
      expect(kek.bytes.every((b) => b == 0), isTrue);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    test('should keep the login pending after a wrong code', () async {
      await startPendingLogin();
      when(() => repository.verifyLoginSecondFactor(challengeToken: any(named: 'challengeToken'),
          code: any(named: 'code'))).thenThrow(apiError('INVALID_SECOND_FACTOR_CODE'));

      await expectLater(useCase('000000'), throwsA(isA<ApiException>()));

      expect(pendingLogin.isActive, isTrue);
    });

    test('should end the login when the challenge expired', () async {
      await startPendingLogin();
      when(() => repository.verifyLoginSecondFactor(challengeToken: any(named: 'challengeToken'),
          code: any(named: 'code'))).thenThrow(apiError('SECOND_FACTOR_CHALLENGE_EXPIRED'));

      await expectLater(useCase('482913'), throwsA(isA<ApiException>()));

      expect(pendingLogin.isActive, isFalse);
    });

    test('should throw SecondFactorExpiredFailure without a pending login', () async {
      await expectLater(useCase('482913'), throwsA(isA<SecondFactorExpiredFailure>()));

      verifyNever(() => repository.verifyLoginSecondFactor(challengeToken: any(named: 'challengeToken'),
          code: any(named: 'code')));
    });

    test('should accept a backup code when the challenge is of the authenticator app', () async {
      pendingLogin.start(const SecondFactorChallenge(challengeToken: 'challenge-token', method: 'TOTP',
          emailHint: 't***@x.com'), await kit.passwordKeys(password, params));
      final material = await kit.material(password, params);
      when(() => repository.verifyLoginSecondFactor(challengeToken: any(named: 'challengeToken'),
          code: any(named: 'code'))).thenAnswer((_) async => LoginResult(user: user,
          keys: AccountKeys(accountLocked: false, versions: [E2eeTestKit.serverVersion(material)])));

      await useCase(' ABCDE fghjk ');

      verify(() => repository.verifyLoginSecondFactor(challengeToken: 'challenge-token', code: 'ABCDE fghjk'))
          .called(1);
    });

    test('should not send a backup code for an emailed code', () async {
      await startPendingLogin();

      await expectLater(useCase('abcde-fghjk'), throwsException);

      verifyNever(() => repository.verifyLoginSecondFactor(challengeToken: any(named: 'challengeToken'),
          code: any(named: 'code')));
    });

    // ==================== VALIDATION ERROR TESTS ====================

    test('should not call the server with a code that is not 6 digits', () async {
      await startPendingLogin();

      await expectLater(useCase('12ab'), throwsException);

      verifyNever(() => repository.verifyLoginSecondFactor(challengeToken: any(named: 'challengeToken'),
          code: any(named: 'code')));
      expect(pendingLogin.isActive, isTrue);
    });
  });
}
