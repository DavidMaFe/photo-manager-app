import 'dart:convert';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/features/two_factor/data/data_sources/two_factor_remote_data_source.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/two_factor_status.dart';
import 'package:photo_manager_app/features/two_factor/domain/repositories/two_factor_repository.dart';

class TwoFactorDataRepository implements TwoFactorRepository {
  final TwoFactorRemoteDataSource remoteDataSource;

  TwoFactorDataRepository({required this.remoteDataSource});

  @override
  Future<TwoFactorStatus> getStatus() => remoteDataSource.getStatus();

  @override
  Future<TotpSetUp> setUpTotp() => remoteDataSource.setUpTotp();

  @override
  Future<List<String>> enableTotp(String code) => remoteDataSource.enableTotp(code);

  @override
  Future<void> disableTotp({required CryptoKey authKey, required String code}) =>
      remoteDataSource.disableTotp(base64Encode(authKey.bytes), code);

  @override
  Future<List<String>> regenerateBackupCodes({required CryptoKey authKey, required String code}) =>
      remoteDataSource.regenerateBackupCodes(base64Encode(authKey.bytes), code);
}
