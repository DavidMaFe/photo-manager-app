import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_outcome.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/entities/second_factor_challenge.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/services/pending_login.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/login_use_case.dart';

import '../../../../helpers/e2ee_test_kit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late E2eeTestKit kit;
  late MockAuthRepository repository;
  late LoginUseCase useCase;
  late PendingLogin pendingLogin;

  const email = 'test@example.com';
  const password = 'correct horse battery';
  final user = User(id: '1', email: email, name: 'Test User');
  final params = E2eeTestKit.cheapParams();

  setUpAll(() {
    registerFallbackValue(CryptoKey(Uint8List(32)));
  });

  setUp(() async {
    kit = await E2eeTestKit.create();
    repository = MockAuthRepository();
    pendingLogin = PendingLogin();
    useCase = LoginUseCase(repository, kit.engine, kit.keyring, pendingLogin);
    when(() => repository.getKdfParams(any())).thenAnswer((_) async => params);
  });

  /// The server answers the login with [keys] and remembers the authKey it received.
  List<String> serverAnswers(AccountKeys keys) {
    final receivedAuthKeys = <String>[];
    when(() => repository.login(email: any(named: 'email'), authKey: any(named: 'authKey'))).thenAnswer((invocation) async {
      // Copied now: the use case wipes the key once the login is done
      receivedAuthKeys.add(base64Encode((invocation.namedArguments[#authKey] as CryptoKey).bytes));
      return LoginCompleted(LoginResult(user: user, keys: keys));
    });
    return receivedAuthKeys;
  }

  LoginResult completed(LoginOutcome outcome) => (outcome as LoginCompleted).result;

  const challenge = SecondFactorChallenge(challengeToken: 'challenge-token', method: 'EMAIL', emailHint: 't***@example.com');

  group('LoginUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should log in with the authKey derived from the password and keep the master key on the device', () async {
      // Arrange
      final material = await kit.material(password, params);
      final received = serverAnswers(AccountKeys(accountLocked: false, versions: [E2eeTestKit.serverVersion(material)]));

      // Act
      final result = completed(await useCase(email: email, password: password));

      // Assert
      final expected = await kit.passwordKeys(password, params);
      expect(received, [base64Encode(expected.authKey.bytes)]);
      expect(result.user, user);
      expect(result.accountLocked, isFalse);
      expect((await kit.store.getMasterKey(1))!.bytes, material.masterKey.bytes);
      expect(await kit.store.getCurrentVersion(), 1);
    });

    test('should keep every available version and mark the current one', () async {
      final old = await kit.material(password, params);
      final current = await kit.material(password, params);
      serverAnswers(AccountKeys(accountLocked: false, versions: [
        E2eeTestKit.serverVersion(old, version: 1, state: KeyState.unlocked),
        E2eeTestKit.serverVersion(current, version: 2),
      ]));

      await useCase(email: email, password: password);

      expect(await kit.store.getVersions(), unorderedEquals([1, 2]));
      expect(await kit.store.getCurrentVersion(), 2);
      expect((await kit.store.getMasterKey(1))!.bytes, old.masterKey.bytes);
    });

    test('should ask for the parameters and log in with the trimmed email', () async {
      final material = await kit.material(password, params);
      serverAnswers(AccountKeys(accountLocked: false, versions: [E2eeTestKit.serverVersion(material)]));

      await useCase(email: '  $email  ', password: password);

      verify(() => repository.getKdfParams(email)).called(1);
      verify(() => repository.login(email: email, authKey: any(named: 'authKey'))).called(1);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    test('should return a locked account without keeping locked versions', () async {
      final material = await kit.material('a forgotten password', params);
      serverAnswers(AccountKeys(accountLocked: true,
          versions: [E2eeTestKit.serverVersion(material, state: KeyState.locked)]));

      final result = completed(await useCase(email: email, password: password));

      expect(result.accountLocked, isTrue);
      expect(await kit.store.getVersions(), isEmpty);
    });

    test('should throw KeyUnlockFailure when the password does not open the key', () async {
      final material = await kit.material('another password', params);
      serverAnswers(AccountKeys(accountLocked: false, versions: [E2eeTestKit.serverVersion(material)]));

      await expectLater(useCase(email: email, password: password), throwsA(isA<KeyUnlockFailure>()));
      expect(await kit.store.getVersions(), isEmpty);
    });

    test('should propagate the errors of the server', () async {
      when(() => repository.login(email: any(named: 'email'), authKey: any(named: 'authKey')))
          .thenThrow(Exception('Invalid credentials'));

      await expectLater(useCase(email: email, password: password), throwsException);
      expect(await kit.store.getVersions(), isEmpty);
    });

    // ==================== SECOND FACTOR TESTS ====================

    test('should keep the keys of the password in memory, not on the device, until the second factor', () async {
      // Arrange
      when(() => repository.login(email: any(named: 'email'), authKey: any(named: 'authKey')))
          .thenAnswer((_) async => const LoginSecondFactorRequired(challenge));

      // Act
      final outcome = await useCase(email: email, password: password);

      // Assert
      expect(outcome, isA<LoginSecondFactorRequired>());
      expect(pendingLogin.challenge, challenge);
      final expected = await kit.passwordKeys(password, params);
      expect(pendingLogin.keys!.kek.bytes, expected.kek.bytes);
      expect(await kit.store.getVersions(), isEmpty);
    });

    test('should drop a previous pending login when logging in again', () async {
      when(() => repository.login(email: any(named: 'email'), authKey: any(named: 'authKey')))
          .thenAnswer((_) async => const LoginSecondFactorRequired(challenge));
      await useCase(email: email, password: password);
      final previousKek = pendingLogin.keys!.kek;

      final material = await kit.material(password, params);
      serverAnswers(AccountKeys(accountLocked: false, versions: [E2eeTestKit.serverVersion(material)]));
      await useCase(email: email, password: password);

      expect(pendingLogin.isActive, isFalse);
      expect(previousKek.bytes.every((b) => b == 0), isTrue);
    });

    test('should not keep the keys when the login fails', () async {
      when(() => repository.login(email: any(named: 'email'), authKey: any(named: 'authKey')))
          .thenThrow(Exception('Invalid credentials'));

      await expectLater(useCase(email: email, password: password), throwsException);

      expect(pendingLogin.isActive, isFalse);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    for (final (description, badEmail, badPassword) in [
      ('the email is empty', '   ', password),
      ('the email is not valid', 'not-an-email', password),
      ('the password is empty', email, '   '),
    ]) {
      test('should throw without calling the server when $description', () async {
        await expectLater(useCase(email: badEmail, password: badPassword), throwsException);

        verifyNever(() => repository.getKdfParams(any()));
        verifyNever(() => repository.login(email: any(named: 'email'), authKey: any(named: 'authKey')));
      });
    }
  });
}
