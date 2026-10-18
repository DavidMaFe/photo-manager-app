import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_limits.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';

class MockPlanCubit extends MockCubit<PlanState> implements PlanCubit {}

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

/// The plan of the user, read from above by the pages (provided by main.dart in the app), as a mock.
class PlanTestProviders {
  final MockPlanCubit plan = MockPlanCubit();

  /// Without a plan: as before the first read (no limits applied in the screens).
  PlanTestProviders({PlanState state = const PlanState()}) {
    when(() => plan.state).thenReturn(state);
    when(() => plan.load()).thenAnswer((_) async => state.plan);
  }

  List<BlocProvider> get providers => [BlocProvider<PlanCubit>.value(value: plan)];
}

/// Shortcut for the pages that do not check the plan.
List<BlocProvider> planTestProviders() => PlanTestProviders().providers;
