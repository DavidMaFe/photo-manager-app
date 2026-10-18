import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';
import 'package:photo_manager_app/features/account_deletion/domain/repositories/account_deletion_repository.dart';

class GetAccountDeletionSummaryUseCase {
  final AccountDeletionRepository _repository;

  GetAccountDeletionSummaryUseCase(this._repository);

  Future<AccountDeletionSummary> call() => _repository.getSummary();
}
