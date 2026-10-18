import 'package:photo_manager_app/features/plans/data/data_sources/billing_remote_data_source.dart';
import 'package:photo_manager_app/features/plans/data/data_sources/billing_store_data_source.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_purchase_update.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/domain/repositories/billing_repository.dart';

class BillingDataRepository implements BillingRepository {
  final BillingStoreDataSource storeDataSource;
  final BillingRemoteDataSource remoteDataSource;

  BillingDataRepository({required this.storeDataSource, required this.remoteDataSource});

  @override
  Future<List<StoreOffer>> loadOffers() => storeDataSource.loadOffers();

  @override
  Future<void> buy(StoreOffer offer, {required String accountId}) => storeDataSource.buy(offer, accountId: accountId);

  @override
  Stream<StorePurchaseUpdate> get purchases => storeDataSource.purchases;

  @override
  Future<void> restore() => storeDataSource.restore();

  @override
  Future<UserPlan> register(String purchaseToken) => remoteDataSource.registerGooglePurchase(purchaseToken);

  @override
  Future<void> finish(String purchaseToken) => storeDataSource.finish(purchaseToken);
}
