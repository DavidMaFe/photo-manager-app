import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/recovery_reminder_repository.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/recovery_phrase_use_cases.dart';

import '../../../../helpers/e2ee_test_kit.dart';
import '../../helpers/fake_account_security_server.dart';

class InMemoryRecoveryReminderRepository implements RecoveryReminderRepository {
  DateTime? next;
  int completed = 0;

  @override
  Future<DateTime?> getNextReminder() async => next;

  @override
  Future<int> getCompletedVerifications() async => completed;

  @override
  Future<void> save({required DateTime nextReminder, required int completedVerifications}) async {
    next = nextReminder;
    completed = completedVerifications;
  }

  @override
  Future<void> clear() async {
    next = null;
    completed = 0;
  }
}

void main() {
  late E2eeTestKit kit;
  late FakeAccountSecurityServer server;
  late NewKeyMaterial material;

  const password = 'the password';
  final params = E2eeTestKit.cheapParams();

  setUp(() async {
    kit = await E2eeTestKit.create();
    server = FakeAccountSecurityServer(kdfParams: params);
    material = await kit.material(password, params);
    server.addVersion(material, version: 1);
  });

  List<String> wordsOf(NewKeyMaterial key, [RecoveryPhraseLanguage language = RecoveryPhraseLanguage.english]) =>
      RecoveryPhrase.encode(key.recoveryKey.bytes, language);

  group('GetRecoveryWordsUseCase', () {
    test('should give the words of the current version kept on this device', () async {
      await kit.keyring.storeNewKey(1, material);

      final words = await GetRecoveryWordsUseCase(kit.keyring)(RecoveryPhraseLanguage.english);

      expect(words, wordsOf(material));
    });

    test('should give null without keys on this device', () async {
      expect(await GetRecoveryWordsUseCase(kit.keyring)(RecoveryPhraseLanguage.english), isNull);
    });
  });

  group('VerifyRecoveryWordsUseCase', () {
    late VerifyRecoveryWordsUseCase useCase;

    setUp(() => useCase = VerifyRecoveryWordsUseCase(server, kit.engine, kit.keyring, random: Random(7)));

    test('should know whether this device keeps the recovery key', () async {
      expect(await useCase.hasLocalCopy(), isFalse);

      await kit.keyring.storeNewKey(1, material);

      expect(await useCase.hasLocalCopy(), isTrue);
    });

    test('should ask for 3 different positions in order', () {
      for (var i = 0; i < 50; i++) {
        final positions = useCase.positionsToAsk();

        expect(positions, hasLength(VerifyRecoveryWordsUseCase.wordsToAsk));
        expect(positions.toSet(), hasLength(3));
        expect(positions, orderedEquals([...positions]..sort()));
        expect(positions.every((position) => position >= 0 && position < RecoveryPhrase.wordCount), isTrue);
      }
    });

    test('should accept the right words ignoring case and accents', () async {
      // Arrange
      await kit.keyring.storeNewKey(1, material);
      final words = wordsOf(material, RecoveryPhraseLanguage.spanish);

      // Act
      final ok = await useCase.checkWords({
        0: RecoveryPhrase.normalizeWord(words[0]).toUpperCase(),
        11: ' ${words[11]} ',
        23: words[23],
      }, RecoveryPhraseLanguage.spanish);

      // Assert
      expect(ok, isTrue);
    });

    test('should reject a wrong word', () async {
      await kit.keyring.storeNewKey(1, material);
      final words = wordsOf(material);

      expect(await useCase.checkWords({0: words[0], 5: '${words[5]}x'}, RecoveryPhraseLanguage.english), isFalse);
    });

    test('should reject the check without a local copy', () async {
      expect(await useCase.checkWords({0: 'abandon'}, RecoveryPhraseLanguage.english), isFalse);
    });

    test('should check the full phrase against the server and keep the recovery key', () async {
      // Arrange: this device logged in, so it has the master key but not the recovery key
      await kit.store.saveMasterKey(1, material.masterKey);
      await kit.store.saveCurrentVersion(1);

      // Act
      await useCase.verifyFullPhrase(wordsOf(material));

      // Assert
      expect((await kit.store.getRecoveryKey(1))!.bytes, material.recoveryKey.bytes);
      expect(await useCase.hasLocalCopy(), isTrue);
    });

    test('should throw RecoveryPhraseMismatchFailure when the full phrase belongs to another key', () async {
      final other = await kit.material(password, params);

      await expectLater(useCase.verifyFullPhrase(wordsOf(other)), throwsA(isA<RecoveryPhraseMismatchFailure>()));
      expect(await kit.store.getRecoveryKey(1), isNull);
    });

    test('should throw InvalidRecoveryPhraseFailure on a typo in the full phrase', () async {
      await expectLater(useCase.verifyFullPhrase(wordsOf(material)..[0] = 'notaword'),
          throwsA(isA<InvalidRecoveryPhraseFailure>()));
    });
  });

  group('RecoveryReminderUseCase', () {
    late InMemoryRecoveryReminderRepository repository;
    late DateTime now;
    late RecoveryReminderUseCase useCase;

    setUp(() {
      repository = InMemoryRecoveryReminderRepository();
      now = DateTime(2026, 10, 7, 12);
      useCase = RecoveryReminderUseCase(repository, now: () => now);
    });

    test('should remind 2 days after the words are created', () async {
      await useCase.start();

      expect(repository.next, DateTime(2026, 10, 9, 12));
      expect(repository.completed, 0);
    });

    test('should be due only once the reminder date arrives', () async {
      expect(await useCase.isDue(), isFalse);

      await useCase.start();
      now = now.add(const Duration(days: 1));
      expect(await useCase.isDue(), isFalse);

      now = now.add(const Duration(days: 1));
      expect(await useCase.isDue(), isTrue);
    });

    test('should remind again after 2 weeks and then every 3 months', () async {
      await useCase.start();

      await useCase.completeVerification();
      expect(repository.next, now.add(const Duration(days: 14)));

      await useCase.completeVerification();
      expect(repository.next, now.add(const Duration(days: 90)));

      await useCase.completeVerification();
      expect(repository.next, now.add(const Duration(days: 90)));
      expect(repository.completed, 3);
    });

    test('should postpone one day without counting a check', () async {
      await useCase.start();
      await useCase.completeVerification();

      await useCase.postpone();

      expect(repository.next, now.add(const Duration(days: 1)));
      expect(repository.completed, 1);
    });
  });
}
