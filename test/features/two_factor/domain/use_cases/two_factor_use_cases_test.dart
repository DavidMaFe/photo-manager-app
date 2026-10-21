import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/two_factor_status.dart';
import 'package:photo_manager_app/features/two_factor/domain/repositories/two_factor_repository.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/disable_totp_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/enable_totp_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/get_two_factor_status_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/regenerate_backup_codes_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/set_up_totp_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/two_factor_code_validator.dart';

import '../../../../helpers/e2ee_test_kit.dart';
import '../../../account_security/helpers/fake_account_security_server.dart';

/// Keeps what it receives; the authKey in Base64, because the use cases wipe the key after the call.
class FakeTwoFactorRepository implements TwoFactorRepository {
  final calls = <String>[];
  String? receivedAuthKey;
  String? receivedCode;
  CryptoKey? receivedKey;
  Object? error;

  @override
  Future<TwoFactorStatus> getStatus() async => const TwoFactorStatus(totpEnabled: true, backupCodesLeft: 4);

  @override
  Future<TotpSetUp> setUpTotp() async => const TotpSetUp(secret: 'GEZD', otpauthUri: 'otpauth://totp/x');

  @override
  Future<List<String>> enableTotp(String code) async {
    receivedCode = code;
    return ['abcde-fghjk'];
  }

  @override
  Future<void> disableTotp({required CryptoKey authKey, required String code}) async {
    _receive(authKey, code);
    if (error != null) throw error!;
  }

  @override
  Future<List<String>> regenerateBackupCodes({required CryptoKey authKey, required String code}) async {
    _receive(authKey, code);
    if (error != null) throw error!;
    return ['new01-codes'];
  }

  void _receive(CryptoKey authKey, String code) {
    receivedAuthKey = base64Encode(authKey.bytes);
    receivedKey = authKey;
    receivedCode = code;
  }
}

void main() {
  late E2eeTestKit kit;
  late FakeAccountSecurityServer securityServer;
  late FakeTwoFactorRepository repository;

  const password = 'the account password';
  final params = E2eeTestKit.cheapParams();

  setUp(() async {
    kit = await E2eeTestKit.create();
    securityServer = FakeAccountSecurityServer(kdfParams: params);
    repository = FakeTwoFactorRepository();
  });

  Future<String> expectedAuthKey() async => base64Encode((await kit.passwordKeys(password, params)).authKey.bytes);

  group('GetTwoFactorStatusUseCase and SetUpTotpUseCase', () {
    test('should delegate to the repository', () async {
      expect(await GetTwoFactorStatusUseCase(repository)(),
          const TwoFactorStatus(totpEnabled: true, backupCodesLeft: 4));
      expect((await SetUpTotpUseCase(repository)()).secret, 'GEZD');
    });
  });

  group('EnableTotpUseCase', () {
    test('should send the trimmed code and return the backup codes', () async {
      expect(await EnableTotpUseCase(repository)(' 123456 '), ['abcde-fghjk']);
      expect(repository.receivedCode, '123456');
    });

    test('should not call the server with a code that is not 6 digits', () async {
      await expectLater(EnableTotpUseCase(repository)('12345'), throwsException);
      await expectLater(EnableTotpUseCase(repository)('abcde-fghjk'), throwsException);
      expect(repository.receivedCode, isNull);
    });
  });

  group('DisableTotpUseCase', () {
    DisableTotpUseCase useCase() => DisableTotpUseCase(repository, securityServer, kit.engine);

    test('should send the authKey derived from the password, as the login does, and wipe it', () async {
      await useCase()(password: password, code: ' abcde-fghjk ');

      expect(repository.receivedAuthKey, await expectedAuthKey());
      expect(repository.receivedCode, 'abcde-fghjk');
      expect(repository.receivedKey!.bytes.every((b) => b == 0), isTrue);
    });

    test('should wipe the key when the server rejects it', () async {
      repository.error = Exception('INVALID_TOTP_CODE');

      await expectLater(useCase()(password: password, code: '123456'), throwsException);
      expect(repository.receivedKey!.bytes.every((b) => b == 0), isTrue);
    });

    test('should not call the server without a password or with a code of no known format', () async {
      await expectLater(useCase()(password: ' ', code: '123456'), throwsException);
      await expectLater(useCase()(password: password, code: '12'), throwsException);
      expect(repository.receivedCode, isNull);
    });
  });

  group('RegenerateBackupCodesUseCase', () {
    test('should send the authKey derived from the password and return the new codes', () async {
      final codes = await RegenerateBackupCodesUseCase(repository, securityServer, kit.engine)(
          password: password, code: '123456');

      expect(codes, ['new01-codes']);
      expect(repository.receivedAuthKey, await expectedAuthKey());
      expect(repository.receivedKey!.bytes.every((b) => b == 0), isTrue);
    });
  });

  group('TwoFactorCodeValidator', () {
    test('should tell the codes of the app from the backup codes', () {
      expect(TwoFactorCodeValidator.isAppCode('123456'), isTrue);
      expect(TwoFactorCodeValidator.isAppCode('12345a'), isFalse);
      expect(TwoFactorCodeValidator.isBackupCode('abcde-fghjk'), isTrue);
      expect(TwoFactorCodeValidator.isBackupCode('ABCDE FGHJK'), isTrue);
      expect(TwoFactorCodeValidator.isBackupCode('abcdefghjk'), isTrue);
      expect(TwoFactorCodeValidator.isBackupCode('abcd-efgh'), isFalse);
    });
  });
}
