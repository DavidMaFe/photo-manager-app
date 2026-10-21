import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/features/two_factor/data/data_sources/two_factor_remote_data_source.dart';
import 'package:photo_manager_app/features/two_factor/data/models/totp_set_up_model.dart';
import 'package:photo_manager_app/features/two_factor/data/models/two_factor_status_model.dart';
import 'package:photo_manager_app/features/two_factor/data/repositories/two_factor_data_repository.dart';

class MockTwoFactorRemoteDataSource extends Mock implements TwoFactorRemoteDataSource {}

void main() {
  late MockTwoFactorRemoteDataSource remote;
  late TwoFactorDataRepository repository;
  final authKey = CryptoKey(Uint8List.fromList(List.generate(32, (i) => i)));

  setUp(() {
    remote = MockTwoFactorRemoteDataSource();
    repository = TwoFactorDataRepository(remoteDataSource: remote);
  });

  group('TwoFactorDataRepository', () {
    test('should delegate the status, the set-up and the activation', () async {
      const status = TwoFactorStatusModel(totpEnabled: false, backupCodesLeft: 0);
      const setUp = TotpSetUpModel(secret: 'GEZD', otpauthUri: 'otpauth://totp/x');
      when(() => remote.getStatus()).thenAnswer((_) async => status);
      when(() => remote.setUpTotp()).thenAnswer((_) async => setUp);
      when(() => remote.enableTotp(any())).thenAnswer((_) async => ['abcde-fghjk']);

      expect(await repository.getStatus(), status);
      expect(await repository.setUpTotp(), setUp);
      expect(await repository.enableTotp('123456'), ['abcde-fghjk']);
      verify(() => remote.enableTotp('123456')).called(1);
    });

    test('should send the authKey in Base64 to turn the app off and for new codes', () async {
      when(() => remote.disableTotp(any(), any())).thenAnswer((_) async {});
      when(() => remote.regenerateBackupCodes(any(), any())).thenAnswer((_) async => ['abcde-fghjk']);

      await repository.disableTotp(authKey: authKey, code: '123456');
      final codes = await repository.regenerateBackupCodes(authKey: authKey, code: '654321');

      verify(() => remote.disableTotp(base64Encode(authKey.bytes), '123456')).called(1);
      verify(() => remote.regenerateBackupCodes(base64Encode(authKey.bytes), '654321')).called(1);
      expect(codes, ['abcde-fghjk']);
    });
  });
}
