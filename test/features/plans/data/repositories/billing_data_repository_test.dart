import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/plans/data/data_sources/billing_remote_data_source.dart';
import 'package:photo_manager_app/features/plans/data/data_sources/billing_store_data_source.dart';
import 'package:photo_manager_app/features/plans/data/models/user_plan_model.dart';
import 'package:photo_manager_app/features/plans/data/repositories/billing_data_repository.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_purchase_update.dart';

import '../../../../helpers/plan_test_providers.dart';

class MockBillingStoreDataSource extends Mock implements BillingStoreDataSource {}

class MockBillingRemoteDataSource extends Mock implements BillingRemoteDataSource {}

void main() {
  late MockBillingStoreDataSource store;
  late MockBillingRemoteDataSource remote;
  late BillingDataRepository repository;

  setUp(() {
    store = MockBillingStoreDataSource();
    remote = MockBillingRemoteDataSource();
    repository = BillingDataRepository(storeDataSource: store, remoteDataSource: remote);
  });

  group('BillingDataRepository', () {
    test('should read the offers, buy, restore and finish in the store', () async {
      when(() => store.loadOffers()).thenAnswer((_) async => TestOffers.all);
      when(() => store.buy(TestOffers.plus1tbAnnual, accountId: 'account')).thenAnswer((_) async {});
      when(() => store.restore()).thenAnswer((_) async {});
      when(() => store.finish('token')).thenAnswer((_) async {});

      expect(await repository.loadOffers(), TestOffers.all);
      await repository.buy(TestOffers.plus1tbAnnual, accountId: 'account');
      await repository.restore();
      await repository.finish('token');

      verify(() => store.buy(TestOffers.plus1tbAnnual, accountId: 'account')).called(1);
      verify(() => store.restore()).called(1);
      verify(() => store.finish('token')).called(1);
    });

    test('should give the purchases of the store', () async {
      const update = StorePurchaseUpdate(status: StorePurchaseStatus.canceled, productId: 'plus_100');
      when(() => store.purchases).thenAnswer((_) => Stream.value(update));

      expect(await repository.purchases.single, update);
    });

    test('should register the purchase in the server', () async {
      final model = UserPlanModel.fromJson(const {'plan': 'PLUS_100'});
      when(() => remote.registerGooglePurchase('token')).thenAnswer((_) async => model);

      expect(await repository.register('token'), model);
    });
  });
}
