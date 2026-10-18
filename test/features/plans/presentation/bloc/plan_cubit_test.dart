import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/get_user_plan_use_case.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';

import '../../../../helpers/plan_test_providers.dart';

class MockGetUserPlanUseCase extends Mock implements GetUserPlanUseCase {}

void main() {
  late MockGetUserPlanUseCase getUserPlan;

  PlanCubit build() => PlanCubit(getUserPlan: getUserPlan, deviceUuid: () async => 'phone');

  setUp(() => getUserPlan = MockGetUserPlanUseCase());

  group('PlanCubit', () {
    blocTest<PlanCubit, PlanState>(
      'should load the plan with the UUID of this device',
      setUp: () => when(() => getUserPlan()).thenAnswer((_) async => TestPlans.plus100),
      build: build,
      act: (cubit) => cubit.load(),
      expect: () => [
        const PlanState(loading: true),
        const PlanState(plan: TestPlans.plus100, deviceUuid: 'phone'),
      ],
    );

    blocTest<PlanCubit, PlanState>(
      'should keep the last plan when a new read fails',
      setUp: () => when(() => getUserPlan()).thenThrow(Exception('offline')),
      build: build,
      seed: () => const PlanState(plan: TestPlans.free, deviceUuid: 'phone'),
      act: (cubit) => cubit.load(),
      expect: () => [
        const PlanState(plan: TestPlans.free, loading: true, deviceUuid: 'phone'),
        isA<PlanState>()
            .having((state) => state.plan, 'plan', TestPlans.free)
            .having((state) => state.failure, 'failure', isA<Failure>()),
      ],
    );

    blocTest<PlanCubit, PlanState>(
      'should forget the plan when the session ends',
      build: build,
      seed: () => const PlanState(plan: TestPlans.free, deviceUuid: 'phone'),
      act: (cubit) => cubit.clear(),
      expect: () => [const PlanState()],
    );

    test('should know whether this device is paused', () {
      const paused = UserPlan(
        tier: PlanTier.free,
        limits: TestPlans.freeLimits,
        storedBytes: 0,
        devices: 3,
        pausedDevices: ['phone'],
        readOnly: false,
        subscription: null,
      );

      expect(const PlanState(plan: paused, deviceUuid: 'phone').isThisDevicePaused, isTrue);
      expect(const PlanState(plan: paused, deviceUuid: 'tablet').isThisDevicePaused, isFalse);
      expect(const PlanState(plan: paused).isThisDevicePaused, isFalse);
    });
  });
}
