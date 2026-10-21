import 'dart:math';

import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/decryption_failure.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/crypto/domain/wrap_purpose.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/recovery_reminder_repository.dart';
import 'package:photo_manager_app/features/account_security/domain/services/device_authenticator.dart';

/// The 24 words of the current key version, if this device keeps a copy of the recovery key.
///
/// They open the photos for good, so whoever holds the phone must prove they are its owner first: the device lock
/// (fingerprint, face or PIN) or, on a phone without a screen lock, the password, checked on this device against the
/// current key (docs/security-audit-2026-10.md, A1).
class GetRecoveryWordsUseCase {
  final KeyringService _keyringService;
  final DeviceAuthenticator _deviceAuthenticator;
  final AccountSecurityRepository _repository;
  final CryptoEngine _cryptoEngine;

  GetRecoveryWordsUseCase(this._keyringService, this._deviceAuthenticator, this._repository, this._cryptoEngine);

  /// Whether this device keeps the words: a copy of the recovery key of the current version, kept by the device that
  /// created the key or verified the words. A device that only logged in has the master key but not the words; then
  /// there is nothing to show (nor to ask the device lock for).
  Future<bool> hasWords() async {
    final version = await _keyringService.store.getCurrentVersion();
    return version != null && await _keyringService.store.getRecoveryKey(version) != null;
  }

  /// Whether [call] needs the password: the phone has no screen lock.
  Future<bool> needsPassword() async => !await _deviceAuthenticator.isAvailable();

  /// [reason] is the translated text of the fingerprint or PIN prompt; [password] is only used when [needsPassword].
  ///
  /// Throws [DeviceAuthenticationFailure] if the device lock is not passed and [WrongPasswordFailure] with a wrong
  /// password. Returns null if this device does not keep the words.
  Future<List<String>?> call(RecoveryPhraseLanguage language, {required String reason, String? password}) async {
    if (!await hasWords()) {
      return null;
    }
    final version = (await _keyringService.store.getCurrentVersion())!;

    if (await _deviceAuthenticator.isAvailable()) {
      if (!await _deviceAuthenticator.authenticate(reason)) {
        throw const DeviceAuthenticationFailure();
      }
    } else {
      await _checkPassword(password);
    }
    return _keyringService.recoveryWords(version, language);
  }

  Future<void> _checkPassword(String? password) async {
    if (password == null || password.isEmpty) {
      throw const WrongPasswordFailure();
    }
    final keys = await _cryptoEngine.deriveFromPassword(password, await _repository.getKdfParams());
    try {
      if (!_keyringService.opensCurrentKey(await _repository.getAccountKeys(), keys.kek)) {
        throw const WrongPasswordFailure();
      }
    } finally {
      keys.dispose();
    }
  }
}

/// Checks that the user still has the 24 words.
///
/// With the local copy of the recovery key it asks for 3 words at random positions. Without it (this device did not
/// create the key) the user types the 24 words, which are checked against the recovery wrap of the server and then
/// kept on this device.
class VerifyRecoveryWordsUseCase {
  static const int wordsToAsk = 3;

  final AccountSecurityRepository _repository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;
  final Random _random;

  VerifyRecoveryWordsUseCase(this._repository, this._cryptoEngine, this._keyringService, {Random? random})
      : _random = random ?? Random.secure();

  /// Whether this device keeps the recovery key of the current version (then [positionsToAsk] can be used).
  Future<bool> hasLocalCopy() async {
    final version = await _keyringService.store.getCurrentVersion();
    return version != null && await _keyringService.store.getRecoveryKey(version) != null;
  }

  /// Three different positions (0-based), in order.
  List<int> positionsToAsk() {
    final positions = <int>{};
    while (positions.length < wordsToAsk) {
      positions.add(_random.nextInt(RecoveryPhrase.wordCount));
    }
    return positions.toList()..sort();
  }

  /// Compares the typed words with the local copy, ignoring case and accents.
  Future<bool> checkWords(Map<int, String> typedByPosition, RecoveryPhraseLanguage language) async {
    final version = await _keyringService.store.getCurrentVersion();
    final words = version == null ? null : await _keyringService.recoveryWords(version, language);
    if (words == null) {
      return false;
    }
    return typedByPosition.entries.every((entry) => _same(entry.value, words[entry.key]));
  }

  /// Checks the full phrase against the server and keeps the recovery key on this device.
  /// Throws [InvalidRecoveryPhraseFailure] on a typo and [RecoveryPhraseMismatchFailure] if it belongs to another key.
  Future<void> verifyFullPhrase(List<String> words) async {
    final recoveryKey = _keyringService.recoveryKeyFromWords(words);
    final keys = await _repository.getAccountKeys();
    final current = keys.versions.where((version) => version.state.isAvailable).toList();
    final wrapKey = _cryptoEngine.recoveryWrapKey(recoveryKey);
    try {
      for (final version in current) {
        try {
          _cryptoEngine.unwrapKey(wrapKey, version.masterKeyByRecovery, WrapPurpose.masterKeyByRecovery);
          await _keyringService.store.saveRecoveryKey(version.version, recoveryKey);
          return;
        } on DecryptionFailure {
          continue;
        }
      }
      throw const RecoveryPhraseMismatchFailure();
    } finally {
      wrapKey.dispose();
    }
  }

  static bool _same(String typed, String expected) =>
      RecoveryPhrase.normalizeWord(typed) == RecoveryPhrase.normalizeWord(expected);
}

/// Reminders to check the 24 words: 2 days after creating them, 2 weeks after the first check and then every 3 months
/// (ROADMAP-e2e-encryption.md, Phase 3).
class RecoveryReminderUseCase {
  static const List<Duration> intervals = [Duration(days: 2), Duration(days: 14), Duration(days: 90)];
  static const Duration postponement = Duration(days: 1);

  final RecoveryReminderRepository _repository;
  final DateTime Function() _now;

  RecoveryReminderUseCase(this._repository, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// Starts the reminders when a recovery key is created (registration or new key version).
  Future<void> start() => _repository.save(nextReminder: _now().add(intervals.first), completedVerifications: 0);

  Future<bool> isDue() async {
    final next = await _repository.getNextReminder();
    return next != null && !_now().isBefore(next);
  }

  Future<void> postpone() async {
    final completed = await _repository.getCompletedVerifications();
    await _repository.save(nextReminder: _now().add(postponement), completedVerifications: completed);
  }

  /// After a successful check: the next interval of the sequence.
  Future<void> completeVerification() async {
    final completed = await _repository.getCompletedVerifications() + 1;
    final interval = intervals[min(completed, intervals.length - 1)];
    await _repository.save(nextReminder: _now().add(interval), completedVerifications: completed);
  }
}
