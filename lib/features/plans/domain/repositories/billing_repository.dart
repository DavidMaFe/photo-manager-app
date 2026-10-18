import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_purchase_update.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';

/// Buying plans in the store (Google Play) and registering the purchases in the server, which verifies them.
abstract class BillingRepository {
  /// The plans of the store with their prices; empty when the store is not available.
  Future<List<StoreOffer>> loadOffers();

  /// Starts the purchase in the store; the result arrives through [purchases]. [accountId] travels with the purchase
  /// and the server checks it. Changing from another plan replaces it.
  Future<void> buy(StoreOffer offer, {required String accountId});

  Stream<StorePurchaseUpdate> get purchases;

  /// The purchases of this store account arrive again through [purchases] (e.g. one paid while the app was closed).
  Future<void> restore();

  /// The server verifies the purchase with the store and answers the new plan.
  Future<UserPlan> register(String purchaseToken);

  /// Tells the store the purchase was delivered.
  Future<void> finish(String purchaseToken);
}
