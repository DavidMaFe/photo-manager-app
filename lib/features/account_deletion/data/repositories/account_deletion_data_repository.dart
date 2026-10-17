import 'dart:convert';

import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/features/account_deletion/data/data_sources/account_deletion_remote_data_source.dart';
import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';
import 'package:photo_manager_app/features/account_deletion/domain/repositories/account_deletion_repository.dart';

class AccountDeletionDataRepository implements AccountDeletionRepository {
  final AccountDeletionRemoteDataSource remoteDataSource;

  AccountDeletionDataRepository({required this.remoteDataSource});

  @override
  Future<AccountDeletionSummary> getSummary() => remoteDataSource.getSummary();

  @override
  Future<void> deleteAccount(CryptoKey authKey) => remoteDataSource.deleteAccount(base64Encode(authKey.bytes));
}
