import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/domain/repositories/billing_repository.dart';

/// Registers a paid purchase in the server (which verifies it with the store and applies its plan) and then tells the
/// store it was delivered. If the server fails, the store is not told: the purchase comes back with the next restore.
class RegisterStorePurchaseUseCase {
  final BillingRepository _repository;

  RegisterStorePurchaseUseCase(this._repository);

  Future<UserPlan> call(String purchaseToken) async {
    final plan = await _repository.register(purchaseToken);
    await _repository.finish(purchaseToken);
    return plan;
  }
}
