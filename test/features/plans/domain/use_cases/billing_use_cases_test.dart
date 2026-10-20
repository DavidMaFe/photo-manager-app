import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_purchase_update.dart';
import 'package:photo_manager_app/features/plans/domain/repositories/billing_repository.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/buy_plan_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/load_plan_offers_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/register_store_purchase_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/restore_purchases_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/watch_store_purchases_use_case.dart';

import '../../../../helpers/plan_test_providers.dart';

class MockBillingRepository extends Mock implements BillingRepository {}

void main() {
  late MockBillingRepository repository;

  setUpAll(() => registerFallbackValue(TestOffers.plus100Monthly));

  setUp(() {
    repository = MockBillingRepository();
    when(() => repository.buy(any(), accountId: any(named: 'accountId'))).thenAnswer((_) async {});
    when(() => repository.finish(any())).thenAnswer((_) async {});
    when(() => repository.restore()).thenAnswer((_) async {});
  });

  group('LoadPlanOffersUseCase', () {
    test('should read the plans of the store', () async {
      when(() => repository.loadOffers()).thenAnswer((_) async => TestOffers.all);

      expect(await LoadPlanOffersUseCase(repository)(), TestOffers.all);
    });
  });

  group('BuyPlanUseCase', () {
    test('should buy with the account id of the server', () async {
      await BuyPlanUseCase(repository)(TestOffers.plus250Annual, accountId: 'account');

      verify(() => repository.buy(TestOffers.plus250Annual, accountId: 'account')).called(1);
    });

    test('should not buy without an account id (buying is off in the server)', () async {
      expect(() => BuyPlanUseCase(repository)(TestOffers.plus250Annual, accountId: null), throwsStateError);
      expect(() => BuyPlanUseCase(repository)(TestOffers.plus250Annual, accountId: ''), throwsStateError);
      verifyNever(() => repository.buy(any(), accountId: any(named: 'accountId')));
    });
  });

  group('RegisterStorePurchaseUseCase', () {
    test('should register the purchase in the server and then finish it in the store', () async {
      when(() => repository.register('token')).thenAnswer((_) async => TestPlans.plus100);

      final plan = await RegisterStorePurchaseUseCase(repository)('token');

      expect(plan, TestPlans.plus100);
      verifyInOrder([() => repository.register('token'), () => repository.finish('token')]);
    });

    test('should not finish the purchase when the server fails, so it comes back with the next restore', () async {
      when(() => repository.register('token')).thenThrow(Exception('offline'));

      await expectLater(RegisterStorePurchaseUseCase(repository)('token'), throwsException);
      verifyNever(() => repository.finish(any()));
    });
  });

  group('RestorePurchasesUseCase', () {
    test('should restore the purchases of the store', () async {
      await RestorePurchasesUseCase(repository)();

      verify(() => repository.restore()).called(1);
    });
  });

  group('WatchStorePurchasesUseCase', () {
    test('should give what the store says about the purchases', () async {
      const update = StorePurchaseUpdate(status: StorePurchaseStatus.pending, productId: 'plus_100');
      when(() => repository.purchases).thenAnswer((_) => Stream.value(update));

      expect(await WatchStorePurchasesUseCase(repository)().single, update);
    });
  });
}
