import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/domain/repositories/billing_repository.dart';

class LoadPlanOffersUseCase {
  final BillingRepository _repository;

  LoadPlanOffersUseCase(this._repository);

  Future<List<StoreOffer>> call() => _repository.loadOffers();
}
