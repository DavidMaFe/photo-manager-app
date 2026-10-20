import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/domain/repositories/billing_repository.dart';

/// Starts the purchase of a plan. Without the account id of the server (billing is off there) nothing is bought: the
/// server would reject the purchase.
class BuyPlanUseCase {
  final BillingRepository _repository;

  BuyPlanUseCase(this._repository);

  Future<void> call(StoreOffer offer, {required String? accountId}) {
    if (accountId == null || accountId.isEmpty) {
      throw StateError('Buying is not available: the server gave no billing account id');
    }
    return _repository.buy(offer, accountId: accountId);
  }
}
