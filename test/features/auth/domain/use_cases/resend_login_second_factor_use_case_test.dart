import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/password_keys.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/auth/domain/entities/second_factor_challenge.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/services/pending_login.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/cancel_login_second_factor_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/resend_login_second_factor_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late PendingLogin pendingLogin;

  const challenge = SecondFactorChallenge(challengeToken: 'challenge-token', method: 'EMAIL', emailHint: 't***@x.com');

  PasswordKeys keys() => PasswordKeys(authKey: CryptoKey(Uint8List.fromList(List.filled(32, 1))),
      kek: CryptoKey(Uint8List.fromList(List.filled(32, 2))));

  ApiException apiError(String code) =>
      ApiException(ErrorResponseModel(code: code, message: 'message', timestamp: '2026-10-20T10:00:00'));

  setUp(() {
    repository = MockAuthRepository();
    pendingLogin = PendingLogin();
  });

  group('ResendLoginSecondFactorUseCase', () {
    test('should ask for another code for the pending login', () async {
      pendingLogin.start(challenge, keys());
      when(() => repository.resendLoginSecondFactor(any())).thenAnswer((_) async {});

      await ResendLoginSecondFactorUseCase(repository, pendingLogin)();

      verify(() => repository.resendLoginSecondFactor('challenge-token')).called(1);
      expect(pendingLogin.isActive, isTrue);
    });

    test('should keep the login pending when it is too soon', () async {
      pendingLogin.start(challenge, keys());
      when(() => repository.resendLoginSecondFactor(any())).thenThrow(apiError('SECOND_FACTOR_RESEND_TOO_SOON'));

      await expectLater(ResendLoginSecondFactorUseCase(repository, pendingLogin)(), throwsA(isA<ApiException>()));

      expect(pendingLogin.isActive, isTrue);
    });

    test('should end the login when the challenge expired', () async {
      pendingLogin.start(challenge, keys());
      when(() => repository.resendLoginSecondFactor(any())).thenThrow(apiError('SECOND_FACTOR_CHALLENGE_EXPIRED'));

      await expectLater(ResendLoginSecondFactorUseCase(repository, pendingLogin)(), throwsA(isA<ApiException>()));

      expect(pendingLogin.isActive, isFalse);
    });

    test('should throw SecondFactorExpiredFailure without a pending login', () async {
      await expectLater(ResendLoginSecondFactorUseCase(repository, pendingLogin)(),
          throwsA(isA<SecondFactorExpiredFailure>()));

      verifyNever(() => repository.resendLoginSecondFactor(any()));
    });
  });

  group('CancelLoginSecondFactorUseCase', () {
    test('should drop the pending login and wipe its keys', () {
      final passwordKeys = keys();
      pendingLogin.start(challenge, passwordKeys);

      CancelLoginSecondFactorUseCase(pendingLogin)();

      expect(pendingLogin.isActive, isFalse);
      expect(passwordKeys.kek.bytes.every((b) => b == 0), isTrue);
    });
  });
}
