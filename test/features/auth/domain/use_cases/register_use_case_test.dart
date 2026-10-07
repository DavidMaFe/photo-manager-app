import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/register_use_case.dart';

import '../../../../fixtures/e2ee_test_data.dart';
import '../../../../helpers/e2ee_test_kit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

/// What the server received in the registration.
class _Received {
  late String authKey;
  late KdfParams kdfParams;
  late NewKeyMaterial key;
  late String name;
  String? surname;
}

void main() {
  late E2eeTestKit kit;
  late MockAuthRepository repository;
  late RegisterUseCase useCase;
  late _Received received;

  const email = 'test@example.com';
  const password = 'correct horse battery';
  final user = User(id: '1', email: email, name: 'John');

  setUpAll(() {
    registerFallbackValue(CryptoKey(Uint8List(32)));
    registerFallbackValue(E2eeTestData.kdfParams());
    registerFallbackValue(E2eeTestData.newKeyMaterial());
  });

  setUp(() async {
    kit = await E2eeTestKit.create();
    repository = MockAuthRepository();
    useCase = RegisterUseCase(repository, kit.engine, kit.keyring);
    received = _Received();

    when(() => repository.register(
          email: any(named: 'email'),
          authKey: any(named: 'authKey'),
          name: any(named: 'name'),
          surname: any(named: 'surname'),
          kdfParams: any(named: 'kdfParams'),
          key: any(named: 'key'),
        )).thenAnswer((invocation) async {
      final args = invocation.namedArguments;
      received
        ..authKey = base64Encode((args[#authKey] as CryptoKey).bytes)
        ..kdfParams = args[#kdfParams] as KdfParams
        ..key = args[#key] as NewKeyMaterial
        ..name = args[#name] as String
        ..surname = args[#surname] as String?;
      return LoginResult(user: user,
          keys: AccountKeys(accountLocked: false, versions: [E2eeTestKit.serverVersion(received.key)]));
    });
  });

  Future<void> register({String name = 'John', String? surname, String userEmail = email,
      RecoveryPhraseLanguage language = RecoveryPhraseLanguage.english}) {
    return useCase(email: userEmail, password: password, name: name, surname: surname, language: language);
  }

  group('RegisterUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should return the 24 words of the recovery key that keep the account', () async {
      // Act
      final result = await useCase(email: email, password: password, name: 'John',
          language: RecoveryPhraseLanguage.english);

      // Assert
      expect(result.user, user);
      expect(result.recoveryWords, hasLength(RecoveryPhrase.wordCount));
      expect(RecoveryPhrase.decode(result.recoveryWords), received.key.recoveryKey.bytes);
      expect(result.recoveryWords.every(RecoveryPhraseLanguage.english.words.contains), isTrue);
    });

    test('should give the words in Spanish when asked', () async {
      final result = await useCase(email: email, password: password, name: 'John',
          language: RecoveryPhraseLanguage.spanish);

      final spanish = RecoveryPhraseLanguage.spanish.words.map(RecoveryPhrase.normalizeWord).toSet();
      expect(result.recoveryWords.map(RecoveryPhrase.normalizeWord).every(spanish.contains), isTrue);
      expect(RecoveryPhrase.decode(result.recoveryWords), received.key.recoveryKey.bytes);
    });

    test('should send the authKey and a master key that only the password opens', () async {
      await register();

      // A new random salt with the default parameters of new passwords
      expect(received.kdfParams.salt, hasLength(KdfParams.saltLength));
      expect(received.kdfParams.ops, KdfParams.defaultOps);
      expect(received.kdfParams.memBytes, KdfParams.defaultMemBytes);

      final keys = await kit.passwordKeys(password, received.kdfParams);
      expect(received.authKey, base64Encode(keys.authKey.bytes));
      expect(kit.unwrapWithPassword(keys.kek, received.key.encryptedMasterKey), received.key.masterKey.bytes);
    });

    test('should keep the master key and the recovery key on the device as the current version', () async {
      await register();

      expect(await kit.store.getCurrentVersion(), 1);
      expect((await kit.store.getMasterKey(1))!.bytes, received.key.masterKey.bytes);
      expect((await kit.store.getRecoveryKey(1))!.bytes, received.key.recoveryKey.bytes);
    });

    test('should trim the name and the surname and drop a blank surname', () async {
      await register(name: '  John  ', surname: '  Doe ');
      expect(received.name, 'John');
      expect(received.surname, 'Doe');

      await register(surname: '   ');
      expect(received.surname, isNull);
    });

    test('should register with the trimmed email', () async {
      await register(userEmail: '  $email ');

      verify(() => repository.register(
            email: email,
            authKey: any(named: 'authKey'),
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            kdfParams: any(named: 'kdfParams'),
            key: any(named: 'key'),
          )).called(1);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    test('should not keep any key when the server rejects the registration', () async {
      when(() => repository.register(
            email: any(named: 'email'),
            authKey: any(named: 'authKey'),
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            kdfParams: any(named: 'kdfParams'),
            key: any(named: 'key'),
          )).thenThrow(Exception('Email already exists'));

      await expectLater(register(), throwsException);
      expect(await kit.store.getVersions(), isEmpty);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    test('should throw WeakPasswordFailure with fewer than 10 characters', () async {
      await expectLater(useCase(email: email, password: 'short', name: 'John',
          language: RecoveryPhraseLanguage.english), throwsA(isA<WeakPasswordFailure>()));
    });

    for (final (description, badEmail, badName) in [
      ('the email is empty', ' ', 'John'),
      ('the email is not valid', 'not-an-email', 'John'),
      ('the name is empty', email, '   '),
    ]) {
      test('should throw without calling the server when $description', () async {
        await expectLater(useCase(email: badEmail, password: password, name: badName,
            language: RecoveryPhraseLanguage.english), throwsException);

        verifyNever(() => repository.register(
              email: any(named: 'email'),
              authKey: any(named: 'authKey'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              kdfParams: any(named: 'kdfParams'),
              key: any(named: 'key'),
            ));
      });
    }
  });
}
