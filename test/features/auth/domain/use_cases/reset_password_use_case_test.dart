import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/reset_password_use_case.dart';

import '../../../../fixtures/e2ee_test_data.dart';
import '../../../../helpers/e2ee_test_kit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late E2eeTestKit kit;
  late MockAuthRepository repository;
  late ResetPasswordUseCase useCase;
  late NewKeyMaterial material;

  const email = 'test@example.com';
  const code = '123456';
  const newPassword = 'a brand new password';

  // What the server received in the reset
  late String receivedAuthKey;
  late KdfParams receivedParams;
  late List<RecoveredKey> receivedKeys;

  setUpAll(() {
    registerFallbackValue(CryptoKey(Uint8List(32)));
    registerFallbackValue(E2eeTestData.kdfParams());
    registerFallbackValue(<RecoveredKey>[]);
  });

  setUp(() async {
    kit = await E2eeTestKit.create();
    repository = MockAuthRepository();
    useCase = ResetPasswordUseCase(repository, kit.engine, kit.keyring);
    material = await kit.material('the forgotten password', E2eeTestKit.cheapParams());

    when(() => repository.getRecoveryWraps(any(), any())).thenAnswer(
        (_) async => [RecoveryWrap(version: 1, masterKeyByRecovery: material.masterKeyByRecovery)]);
    when(() => repository.resetPassword(
          email: any(named: 'email'),
          code: any(named: 'code'),
          newAuthKey: any(named: 'newAuthKey'),
          kdfParams: any(named: 'kdfParams'),
          recoveredKeys: any(named: 'recoveredKeys'),
        )).thenAnswer((invocation) async {
      final args = invocation.namedArguments;
      receivedAuthKey = base64Encode((args[#newAuthKey] as CryptoKey).bytes);
      receivedParams = args[#kdfParams] as KdfParams;
      receivedKeys = args[#recoveredKeys] as List<RecoveredKey>;
      return receivedKeys.isEmpty;
    });
  });

  List<String> wordsOf(CryptoKey recoveryKey) => RecoveryPhrase.encode(recoveryKey.bytes, RecoveryPhraseLanguage.english);

  void verifyNoReset() => verifyNever(() => repository.resetPassword(
        email: any(named: 'email'),
        code: any(named: 'code'),
        newAuthKey: any(named: 'newAuthKey'),
        kdfParams: any(named: 'kdfParams'),
        recoveredKeys: any(named: 'recoveredKeys'),
      ));

  group('ResetPasswordUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should keep the photos with the 24 words: the key is wrapped again with the new password', () async {
      // Act
      final locked = await useCase(email: email, code: code, newPassword: newPassword,
          recoveryWords: wordsOf(material.recoveryKey));

      // Assert
      expect(locked, isFalse);
      final keys = await kit.passwordKeys(newPassword, receivedParams);
      expect(receivedAuthKey, base64Encode(keys.authKey.bytes));
      final recovered = receivedKeys.single;
      expect(recovered.version, 1);
      expect(recovered.recoveryAuthKey, material.recoveryAuthKey);
      expect(kit.unwrapWithPassword(keys.kek, recovered.encryptedMasterKey), material.masterKey.bytes);
    });

    test('should accept the words in Spanish, without accents and in capitals', () async {
      final words = RecoveryPhrase.encode(material.recoveryKey.bytes, RecoveryPhraseLanguage.spanish)
          .map((word) => RecoveryPhrase.normalizeWord(word).toUpperCase())
          .toList();

      final locked = await useCase(email: email, code: code, newPassword: newPassword, recoveryWords: words);

      expect(locked, isFalse);
      expect(receivedKeys.single.version, 1);
    });

    test('should lock the account without the 24 words, without asking for the recovery wraps', () async {
      final locked = await useCase(email: email, code: code, newPassword: newPassword);

      expect(locked, isTrue);
      expect(receivedKeys, isEmpty);
      expect(receivedParams.ops, KdfParams.defaultOps);
      verifyNever(() => repository.getRecoveryWraps(any(), any()));
    });

    test('should send the trimmed email and code', () async {
      await useCase(email: ' $email ', code: ' $code ', newPassword: newPassword,
          recoveryWords: wordsOf(material.recoveryKey));

      verify(() => repository.getRecoveryWraps(email, code)).called(1);
      verify(() => repository.resetPassword(
            email: email,
            code: code,
            newAuthKey: any(named: 'newAuthKey'),
            kdfParams: any(named: 'kdfParams'),
            recoveredKeys: any(named: 'recoveredKeys'),
          )).called(1);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    test('should throw InvalidRecoveryPhraseFailure on a typo before calling the server', () async {
      final words = wordsOf(material.recoveryKey);
      words[5] = 'notaword';

      await expectLater(useCase(email: email, code: code, newPassword: newPassword, recoveryWords: words),
          throwsA(isA<InvalidRecoveryPhraseFailure>()));
      verifyNever(() => repository.getRecoveryWraps(any(), any()));
      verifyNoReset();
    });

    test('should throw RecoveryPhraseMismatchFailure with the words of another key and not reset', () async {
      final otherWords = wordsOf(kit.engine.generateKey());

      await expectLater(useCase(email: email, code: code, newPassword: newPassword, recoveryWords: otherWords),
          throwsA(isA<RecoveryPhraseMismatchFailure>()));
      verifyNoReset();
    });

    test('should propagate the errors of the server', () async {
      when(() => repository.getRecoveryWraps(any(), any())).thenThrow(Exception('Invalid code'));

      await expectLater(useCase(email: email, code: code, newPassword: newPassword,
          recoveryWords: wordsOf(material.recoveryKey)), throwsException);
      verifyNoReset();
    });

    // ==================== VALIDATION ERROR TESTS ====================

    test('should throw WeakPasswordFailure with fewer than 10 characters', () async {
      await expectLater(useCase(email: email, code: code, newPassword: 'short'), throwsA(isA<WeakPasswordFailure>()));
      verifyNoReset();
    });

    for (final (description, badEmail, badCode) in [
      ('the email is empty', ' ', code),
      ('the email is not valid', 'not-an-email', code),
      ('the code is empty', email, '  '),
      ('the code is not 6 digits', email, '12ab56'),
    ]) {
      test('should throw without calling the server when $description', () async {
        await expectLater(useCase(email: badEmail, code: badCode, newPassword: newPassword), throwsException);
        verifyNoReset();
      });
    }
  });
}
