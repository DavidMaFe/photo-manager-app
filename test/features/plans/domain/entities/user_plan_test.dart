import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_subscription.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
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

  group('PlanSubscription', () {
    PlanSubscription subscription(SubscriptionStatus status, {bool autoRenewing = true}) => PlanSubscription(
        tier: PlanTier.plus100, status: status, periodEnd: null, autoRenewing: autoRenewing);

    test('should renew while the store will charge it again', () {
      expect(subscription(SubscriptionStatus.active).renews, isTrue);
      expect(subscription(SubscriptionStatus.inGracePeriod).renews, isTrue);
      expect(subscription(SubscriptionStatus.onHold).renews, isTrue);
      expect(subscription(SubscriptionStatus.paused).renews, isTrue);
    });

    test('should not renew when cancelled, ended or not paid yet', () {
      expect(subscription(SubscriptionStatus.active, autoRenewing: false).renews, isFalse);
      expect(subscription(SubscriptionStatus.expired).renews, isFalse);
      expect(subscription(SubscriptionStatus.revoked).renews, isFalse);
      expect(subscription(SubscriptionStatus.pending).renews, isFalse);
    });
  });

  group('BillingPeriod', () {
    test('should read the base plans of the store', () {
      expect(BillingPeriod.fromBasePlan('monthly'), BillingPeriod.monthly);
      expect(BillingPeriod.fromBasePlan('annual'), BillingPeriod.annual);
      expect(BillingPeriod.fromBasePlan('weekly'), isNull);
      expect(BillingPeriod.fromBasePlan(null), isNull);
    });
  });

  group('StoreOffer', () {
    test('should map the plans to the products of the store and back', () {
      expect(StoreOffer.productIdOf(PlanTier.plus100), 'plus_100');
      expect(StoreOffer.productIdOf(PlanTier.plus250), 'plus_250');
      expect(StoreOffer.productIdOf(PlanTier.plus1tb), 'plus_1tb');
      expect(StoreOffer.tierOf('plus_1tb'), PlanTier.plus1tb);
      expect(StoreOffer.tierOf(''), isNull);
      expect(StoreOffer.tierOf('other'), isNull);
    });
  });
}
