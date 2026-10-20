import 'package:photo_manager_app/features/plans/domain/repositories/billing_repository.dart';

class RestorePurchasesUseCase {
  final BillingRepository _repository;

  RestorePurchasesUseCase(this._repository);

  Future<void> call() => _repository.restore();
}
