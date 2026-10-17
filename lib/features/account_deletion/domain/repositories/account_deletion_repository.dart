import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';

abstract class AccountDeletionRepository {
  Future<AccountDeletionSummary> getSummary();

  /// Deletes the account on the server at once. Throws an [ApiException] with `INCORRECT_PASSWORD` when [authKey]
  /// does not match the password.
  Future<void> deleteAccount(CryptoKey authKey);
}
