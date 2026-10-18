import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_limits.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/billing_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';

class MockPlanCubit extends MockCubit<PlanState> implements PlanCubit {}

class MockBillingCubit extends MockCubit<BillingState> implements BillingCubit {}

const int testMib = 1024 * 1024;
const int testGib = 1024 * testMib;

/// Plans of the tests.
class TestPlans {
  static const freeLimits =
      PlanLimits(storageBytes: 5 * testGib, maxDevices: 2, maxVideoBytes: 100 * testMib, dailyBackup: false);

  static const free = UserPlan(
    tier: PlanTier.free,
    limits: freeLimits,
    storedBytes: 0,
    devices: 1,
    pausedDevices: [],
    readOnly: false,
    subscription: null,
  );

  static const plus100 = UserPlan(
    tier: PlanTier.plus100,
    limits: PlanLimits(storageBytes: 100 * testGib, maxDevices: 3, maxVideoBytes: 2 * testGib, dailyBackup: true),
    storedBytes: 0,
    devices: 1,
    pausedDevices: [],
    readOnly: false,
    subscription: null,
  );
}

/// Plans of the store of the tests, with their prices.
class TestOffers {
  static const plus100Monthly = StoreOffer(tier: PlanTier.plus100, period: BillingPeriod.monthly, price: '1,99 €');
  static const plus100Annual = StoreOffer(tier: PlanTier.plus100, period: BillingPeriod.annual, price: '19,99 €');
  static const plus250Monthly = StoreOffer(tier: PlanTier.plus250, period: BillingPeriod.monthly, price: '3,99 €');
  static const plus250Annual = StoreOffer(tier: PlanTier.plus250, period: BillingPeriod.annual, price: '39,99 €');
  static const plus1tbMonthly = StoreOffer(tier: PlanTier.plus1tb, period: BillingPeriod.monthly, price: '9,99 €');
  static const plus1tbAnnual = StoreOffer(tier: PlanTier.plus1tb, period: BillingPeriod.annual, price: '99,99 €');

  static const all = [plus100Monthly, plus100Annual, plus250Monthly, plus250Annual, plus1tbMonthly, plus1tbAnnual];
}

/// The plan of the user and the purchases, read from above by the pages (provided by main.dart in the app), as mocks.
class PlanTestProviders {
  final MockPlanCubit plan = MockPlanCubit();
  final MockBillingCubit billing = MockBillingCubit();

  /// Without a plan: as before the first read (no limits applied in the screens).
  PlanTestProviders({PlanState state = const PlanState(), BillingState billingState = const BillingState()}) {
    when(() => plan.state).thenReturn(state);
    when(() => plan.load()).thenAnswer((_) async => state.plan);
    when(() => billing.state).thenReturn(billingState);
    when(() => billing.loadOffers()).thenAnswer((_) async {});
    registerFallbackValue(TestOffers.plus100Monthly);
    when(() => billing.buy(any())).thenAnswer((_) async {});
  }

  List<BlocProvider> get providers => [
        BlocProvider<PlanCubit>.value(value: plan),
        BlocProvider<BillingCubit>.value(value: billing),
      ];
}

/// Shortcut for the pages that do not check the plan.
List<BlocProvider> planTestProviders() => PlanTestProviders().providers;
