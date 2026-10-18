import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_purchase_update.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/buy_plan_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/load_plan_offers_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/register_store_purchase_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/restore_purchases_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/watch_store_purchases_use_case.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/billing_cubit.dart';

import '../../../../helpers/plan_test_providers.dart';

class MockWatchStorePurchasesUseCase extends Mock implements WatchStorePurchasesUseCase {}

class MockLoadPlanOffersUseCase extends Mock implements LoadPlanOffersUseCase {}

class MockBuyPlanUseCase extends Mock implements BuyPlanUseCase {}

class MockRegisterStorePurchaseUseCase extends Mock implements RegisterStorePurchaseUseCase {}

class MockRestorePurchasesUseCase extends Mock implements RestorePurchasesUseCase {}

void main() {
  late MockWatchStorePurchasesUseCase watchPurchases;
  late MockLoadPlanOffersUseCase loadOffers;
  late MockBuyPlanUseCase buy;
  late MockRegisterStorePurchaseUseCase register;
  late MockRestorePurchasesUseCase restore;
  late StreamController<StorePurchaseUpdate> store;
  late List<UserPlan> plansShown;
  String? accountId;

  const purchased = StorePurchaseUpdate(status: StorePurchaseStatus.purchased, productId: 'plus_100', purchaseToken: 't');
  const restored = StorePurchaseUpdate(status: StorePurchaseStatus.restored, productId: 'plus_100', purchaseToken: 't');

  BillingCubit build() => BillingCubit(
        watchPurchases: watchPurchases,
        loadOffers: loadOffers,
        buy: buy,
        register: register,
        restore: restore,
        accountId: () => accountId,
        onPlan: plansShown.add,
      );

  /// The store says [update] once the session started.
  Future<void> storeSays(BillingCubit cubit, StorePurchaseUpdate update) async {
    await cubit.start();
    store.add(update);
    await Future<void>.delayed(Duration.zero);
  }

  setUpAll(() => registerFallbackValue(TestOffers.plus100Monthly));

  setUp(() {
    watchPurchases = MockWatchStorePurchasesUseCase();
    loadOffers = MockLoadPlanOffersUseCase();
    buy = MockBuyPlanUseCase();
    register = MockRegisterStorePurchaseUseCase();
    restore = MockRestorePurchasesUseCase();
    store = StreamController<StorePurchaseUpdate>.broadcast();
    plansShown = [];
    accountId = 'account';
    when(() => watchPurchases()).thenAnswer((_) => store.stream);
    when(() => restore()).thenAnswer((_) async {});
    when(() => buy(any(), accountId: any(named: 'accountId'))).thenAnswer((_) async {});
    when(() => register(any())).thenAnswer((_) async => TestPlans.plus100);
  });

  tearDown(() => store.close());

  group('BillingCubit', () {
    // ==================== OFFERS ====================

    blocTest<BillingCubit, BillingState>(
      'should load the plans of the store',
      setUp: () => when(() => loadOffers()).thenAnswer((_) async => TestOffers.all),
      build: build,
      act: (cubit) => cubit.loadOffers(),
      expect: () => [
        const BillingState(loadingOffers: true),
        const BillingState(offers: TestOffers.all),
      ],
    );

    blocTest<BillingCubit, BillingState>(
      'should not read the store again once it has the plans',
      build: build,
      seed: () => const BillingState(offers: TestOffers.all),
      act: (cubit) => cubit.loadOffers(),
      expect: () => const <BillingState>[],
      verify: (_) => verifyNever(() => loadOffers()),
    );

    blocTest<BillingCubit, BillingState>(
      'should say the store is not available when it gives no plans',
      setUp: () => when(() => loadOffers()).thenAnswer((_) async => const []),
      build: build,
      act: (cubit) => cubit.loadOffers(),
      expect: () => [const BillingState(loadingOffers: true), const BillingState(storeUnavailable: true)],
    );

    blocTest<BillingCubit, BillingState>(
      'should say the store is not available when it fails',
      setUp: () => when(() => loadOffers()).thenThrow(Exception('no store')),
      build: build,
      act: (cubit) => cubit.loadOffers(),
      expect: () => [const BillingState(loadingOffers: true), const BillingState(storeUnavailable: true)],
    );

    // ==================== BUYING ====================

    blocTest<BillingCubit, BillingState>(
      'should start the purchase with the account id of the plan',
      build: build,
      act: (cubit) => cubit.buy(TestOffers.plus250Monthly),
      expect: () => [const BillingState(buying: TestOffers.plus250Monthly)],
      verify: (_) => verify(() => buy(TestOffers.plus250Monthly, accountId: 'account')).called(1),
    );

    blocTest<BillingCubit, BillingState>(
      'should not start a second purchase while one is in progress',
      build: build,
      seed: () => const BillingState(buying: TestOffers.plus100Monthly),
      act: (cubit) => cubit.buy(TestOffers.plus250Monthly),
      expect: () => const <BillingState>[],
      verify: (_) => verifyNever(() => buy(any(), accountId: any(named: 'accountId'))),
    );

    blocTest<BillingCubit, BillingState>(
      'should tell the user when the purchase does not start',
      setUp: () => when(() => buy(any(), accountId: any(named: 'accountId'))).thenThrow(StateError('no account')),
      build: build,
      act: (cubit) => cubit.buy(TestOffers.plus250Monthly),
      expect: () => [
        const BillingState(buying: TestOffers.plus250Monthly),
        const BillingState(notice: BillingNotice.error),
      ],
    );

    // ==================== WHAT THE STORE SAYS ====================

    blocTest<BillingCubit, BillingState>(
      'should register a paid purchase, show its plan and tell the user',
      build: build,
      seed: () => const BillingState(buying: TestOffers.plus100Monthly),
      act: (cubit) => storeSays(cubit, purchased),
      expect: () => [const BillingState(notice: BillingNotice.done, noticeTier: PlanTier.plus100)],
      verify: (_) {
        verify(() => register('t')).called(1);
        expect(plansShown, [TestPlans.plus100]);
      },
    );

    blocTest<BillingCubit, BillingState>(
      'should tell the user when the server does not accept the purchase',
      setUp: () => when(() => register(any())).thenThrow(Exception('PURCHASE_OF_ANOTHER_ACCOUNT')),
      build: build,
      seed: () => const BillingState(buying: TestOffers.plus100Monthly),
      act: (cubit) => storeSays(cubit, purchased),
      expect: () => [const BillingState(notice: BillingNotice.error)],
      verify: (_) => expect(plansShown, isEmpty),
    );

    blocTest<BillingCubit, BillingState>(
      'should register a restored purchase without telling the user',
      build: build,
      act: (cubit) => storeSays(cubit, restored),
      expect: () => const <BillingState>[],
      verify: (_) => expect(plansShown, [TestPlans.plus100]),
    );

    blocTest<BillingCubit, BillingState>(
      'should ignore quietly a restored purchase the server rejects (another account of the app)',
      setUp: () => when(() => register(any())).thenThrow(Exception('PURCHASE_OF_ANOTHER_ACCOUNT')),
      build: build,
      act: (cubit) => storeSays(cubit, restored),
      expect: () => const <BillingState>[],
    );

    blocTest<BillingCubit, BillingState>(
      'should tell the user when the payment is pending',
      build: build,
      seed: () => const BillingState(buying: TestOffers.plus100Monthly),
      act: (cubit) => storeSays(
          cubit, const StorePurchaseUpdate(status: StorePurchaseStatus.pending, productId: 'plus_100')),
      expect: () => [const BillingState(notice: BillingNotice.pending)],
      verify: (_) => verifyNever(() => register(any())),
    );

    blocTest<BillingCubit, BillingState>(
      'should only stop waiting when the user cancels in the store',
      build: build,
      seed: () => const BillingState(buying: TestOffers.plus100Monthly),
      act: (cubit) => storeSays(
          cubit, const StorePurchaseUpdate(status: StorePurchaseStatus.canceled, productId: 'plus_100')),
      expect: () => [const BillingState()],
    );

    blocTest<BillingCubit, BillingState>(
      'should tell the user when the store fails',
      build: build,
      seed: () => const BillingState(buying: TestOffers.plus100Monthly),
      act: (cubit) =>
          storeSays(cubit, const StorePurchaseUpdate(status: StorePurchaseStatus.error, productId: 'plus_100')),
      expect: () => [const BillingState(notice: BillingNotice.error)],
    );

    // ==================== SESSION ====================

    blocTest<BillingCubit, BillingState>(
      'should restore the purchases when the session starts, listening to the store only once',
      build: build,
      act: (cubit) async {
        await cubit.start();
        await cubit.start();
      },
      verify: (_) {
        verify(() => restore()).called(2);
        verify(() => watchPurchases()).called(1);
      },
    );

    blocTest<BillingCubit, BillingState>(
      'should go on when restoring fails',
      setUp: () => when(() => restore()).thenThrow(Exception('no store')),
      build: build,
      act: (cubit) => cubit.start(),
      expect: () => const <BillingState>[],
    );

    blocTest<BillingCubit, BillingState>(
      'should leave the purchases that arrive without a session for the next one',
      build: build,
      act: (cubit) async {
        await cubit.start();
        cubit.clear();
        store.add(purchased);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [const BillingState()],
      verify: (_) => verifyNever(() => register(any())),
    );

    blocTest<BillingCubit, BillingState>(
      'should forget the plans of the store and the notices when the session ends',
      build: build,
      seed: () => const BillingState(offers: TestOffers.all, notice: BillingNotice.done),
      act: (cubit) => cubit.clear(),
      expect: () => [const BillingState()],
    );

    blocTest<BillingCubit, BillingState>(
      'should forget the notice once shown',
      build: build,
      seed: () => const BillingState(offers: TestOffers.all, notice: BillingNotice.error),
      act: (cubit) => cubit.noticeShown(),
      expect: () => [const BillingState(offers: TestOffers.all)],
    );
  });
}
