import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/password_keys.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/auth/domain/entities/second_factor_challenge.dart';
import 'package:photo_manager_app/features/auth/domain/services/pending_login.dart';

void main() {
  const challenge = SecondFactorChallenge(challengeToken: 'token', method: 'EMAIL', emailHint: 't***@example.com');

  PasswordKeys keys(int seed) => PasswordKeys(
      authKey: CryptoKey(Uint8List.fromList(List.filled(32, seed))),
      kek: CryptoKey(Uint8List.fromList(List.filled(32, seed + 1))));

  bool wiped(CryptoKey key) => key.bytes.every((b) => b == 0);

  ApiException apiError(String code) =>
      ApiException(ErrorResponseModel(code: code, message: 'message', timestamp: '2026-10-20T10:00:00'));

  group('PendingLogin', () {
    test('should start empty', () {
      final pending = PendingLogin();

      expect(pending.isActive, isFalse);
      expect(pending.challenge, isNull);
      expect(pending.keys, isNull);
    });

    test('should keep the challenge and the keys until it is cleared, and then wipe the keys', () {
      final pending = PendingLogin();
      final passwordKeys = keys(1);

      pending.start(challenge, passwordKeys);
      expect(pending.isActive, isTrue);
      expect(pending.challenge, challenge);
      expect(pending.keys, passwordKeys);

      pending.clear();
      expect(pending.isActive, isFalse);
      expect(wiped(passwordKeys.kek), isTrue);
      expect(wiped(passwordKeys.authKey), isTrue);
    });

    test('should wipe the keys of the previous login when another one starts', () {
      final pending = PendingLogin();
      final first = keys(1);
      final second = keys(5);

      pending.start(challenge, first);
      pending.start(challenge, second);

      expect(wiped(first.kek), isTrue);
      expect(wiped(second.kek), isFalse);
      expect(pending.keys, second);
    });
  });

  group('isSecondFactorExpired', () {
    test('should be true for the expired failure and the expired API error only', () {
      expect(isSecondFactorExpired(const SecondFactorExpiredFailure()), isTrue);
      expect(isSecondFactorExpired(apiError('SECOND_FACTOR_CHALLENGE_EXPIRED')), isTrue);
      expect(isSecondFactorExpired(apiError('INVALID_SECOND_FACTOR_CODE')), isFalse);
      expect(isSecondFactorExpired(const ValidationFailure()), isFalse);
      expect(isSecondFactorExpired(Exception('offline')), isFalse);
    });
  });
}
