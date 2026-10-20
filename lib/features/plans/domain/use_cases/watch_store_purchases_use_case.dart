import 'package:photo_manager_app/features/plans/domain/entities/store_purchase_update.dart';
import 'package:photo_manager_app/features/plans/domain/repositories/billing_repository.dart';

/// What the store says about the purchases: the ones started in the app and the ones that come back with a restore.
class WatchStorePurchasesUseCase {
  final BillingRepository _repository;

  WatchStorePurchasesUseCase(this._repository);

  Stream<StorePurchaseUpdate> call() => _repository.purchases;
}
