import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';

import '../../../../helpers/plan_test_providers.dart';

void main() {
  group('PlanTier', () {
    test('should read the names of the API, free for unknown ones', () {
      expect(PlanTier.fromApi('PLUS_1TB'), PlanTier.plus1tb);
      expect(PlanTier.fromApi(null), PlanTier.free);
      expect(PlanTier.fromApi('OTHER'), PlanTier.free);
    });

    test('should be paid except the free plan', () {
      expect(PlanTier.free.isPaid, isFalse);
      expect(PlanTier.plus250.isPaid, isTrue);
    });
  });

  group('UserPlan', () {
    test('should allow videos up to the limit of the plan', () {
      expect(TestPlans.free.allowsVideo(100 * testMib), isTrue);
      expect(TestPlans.free.allowsVideo(100 * testMib + 1), isFalse);
      expect(TestPlans.plus100.allowsVideo(100 * testMib + 1), isTrue);
    });

    test('should tell whether a device is paused', () {
      const plan = UserPlan(
        tier: PlanTier.free,
        limits: TestPlans.freeLimits,
        storedBytes: 0,
        devices: 3,
        pausedDevices: ['tablet'],
        readOnly: false,
        subscription: null,
      );

      expect(plan.isPaused('tablet'), isTrue);
      expect(plan.isPaused('phone'), isFalse);
    });
  });
}
