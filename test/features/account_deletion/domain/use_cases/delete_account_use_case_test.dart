import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';
import 'package:photo_manager_app/features/account_deletion/domain/repositories/account_deletion_repository.dart';
import 'package:photo_manager_app/features/account_deletion/domain/use_cases/delete_account_use_case.dart';

import '../../../../helpers/e2ee_test_kit.dart';
import '../../../account_security/helpers/fake_account_security_server.dart';

/// Keeps the authKey it receives in Base64: the use case wipes the key after the call.
class FakeAccountDeletionRepository implements AccountDeletionRepository {
  String? receivedAuthKey;
  Object? error;

  @override
  Future<AccountDeletionSummary> getSummary() async =>
      const AccountDeletionSummary(files: 0, storedBytes: 0, albums: 0, devices: 0);

  @override
  Future<void> deleteAccount(CryptoKey authKey) async {
    receivedAuthKey = base64Encode(authKey.bytes);
    if (error != null) throw error!;
  }
}

void main() {
  late E2eeTestKit kit;
  late FakeAccountSecurityServer securityServer;
  late FakeAccountDeletionRepository repository;
  late List<String> cleanups;

  const password = 'the account password';
  final params = E2eeTestKit.cheapParams();

  DeleteAccountUseCase useCase({List<Future<void> Function()>? onDeleted}) => DeleteAccountUseCase(
        repository,
        securityServer,
        kit.engine,
        onDeleted: onDeleted ??
            [
              () async => cleanups.add('session'),
              () async => cleanups.add('mappings'),
            ],
      );

  setUp(() async {
    kit = await E2eeTestKit.create();
    securityServer = FakeAccountSecurityServer(kdfParams: params);
    repository = FakeAccountDeletionRepository();
    cleanups = [];
  });

  group('DeleteAccountUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should send the authKey derived from the password, as the login does', () async {
      // Act
      await useCase()(password: password);

      // Assert
      final keys = await kit.passwordKeys(password, params);
      expect(repository.receivedAuthKey, base64Encode(keys.authKey.bytes));
    });

    test('should remove what this device keeps for the account once it is deleted', () async {
      await useCase()(password: password);

      expect(cleanups, ['session', 'mappings']);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    test('should run every cleanup even when one fails', () async {
      // Arrange
      final failing = useCase(onDeleted: [
        () async => throw Exception('storage error'),
        () async => cleanups.add('mappings'),
      ]);

      // Act
      await failing(password: password);

      // Assert
      expect(cleanups, ['mappings']);
    });

    test('should keep everything on this device when the server rejects the password', () async {
      // Arrange
      repository.error = Exception('INCORRECT_PASSWORD');

      // Act / Assert
      await expectLater(useCase()(password: password), throwsException);
      expect(cleanups, isEmpty);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    test('should not call the server without a password', () async {
      await expectLater(useCase()(password: ''), throwsA(anything));

      expect(repository.receivedAuthKey, isNull);
      expect(cleanups, isEmpty);
    });
  });
}
