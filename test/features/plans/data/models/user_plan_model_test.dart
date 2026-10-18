import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/plans/data/models/user_plan_model.dart';
import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_subscription.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';

void main() {
  group('UserPlanModel', () {
    test('should read the free plan of a new account without subscription', () {
      final plan = UserPlanModel.fromJson(const {
        'plan': 'FREE',
        'limits': {'storageBytes': 5368709120, 'maxDevices': 2, 'maxVideoBytes': 104857600, 'dailyBackup': false},
        'usage': {'storedBytes': 1024, 'devices': 1, 'pausedDevices': []},
        'readOnly': false,
        'subscription': null,
      });

      expect(plan.tier, PlanTier.free);
      expect(plan.limits.storageBytes, 5368709120);
      expect(plan.limits.maxDevices, 2);
      expect(plan.limits.maxVideoBytes, 104857600);
      expect(plan.limits.dailyBackup, isFalse);
      expect(plan.storedBytes, 1024);
      expect(plan.devices, 1);
      expect(plan.pausedDevices, isEmpty);
      expect(plan.readOnly, isFalse);
      expect(plan.subscription, isNull);
    });

    test('should read a paid plan with its subscription and paused devices', () {
      final plan = UserPlanModel.fromJson(const {
        'plan': 'PLUS_250',
        'limits': {'storageBytes': 268435456000, 'maxDevices': 5, 'maxVideoBytes': 2147483648, 'dailyBackup': true},
        'usage': {'storedBytes': 10, 'devices': 6, 'pausedDevices': ['tablet']},
        'readOnly': false,
        'subscription': {
          'store': 'GOOGLE_PLAY',
          'productId': 'plus_250:monthly',
          'plan': 'PLUS_250',
          'status': 'CANCELED',
          'periodEnd': '2026-11-18T10:00:00',
          'autoRenewing': false,
        },
      });

      expect(plan.tier, PlanTier.plus250);
      expect(plan.pausedDevices, ['tablet']);
      expect(plan.subscription!.status, SubscriptionStatus.canceled);
      expect(plan.subscription!.tier, PlanTier.plus250);
      expect(plan.subscription!.periodEnd, DateTime(2026, 11, 18, 10));
      expect(plan.subscription!.autoRenewing, isFalse);
      expect(plan.subscription!.period, BillingPeriod.monthly);
      expect(plan.billingAccountId, isNull);
    });

    test('should read the billing account id and a pending annual subscription', () {
      final plan = UserPlanModel.fromJson(const {
        'plan': 'FREE',
        'subscription': {'productId': 'plus_1tb:annual', 'plan': 'PLUS_1TB', 'status': 'PENDING', 'autoRenewing': true},
        'billingAccountId': 'account',
      });

      expect(plan.subscription!.status, SubscriptionStatus.pending);
      expect(plan.subscription!.period, BillingPeriod.annual);
      expect(plan.billingAccountId, 'account');
    });

    test('should leave the period unknown for an unknown base plan', () {
      final plan = UserPlanModel.fromJson(const {
        'plan': 'PLUS_100',
        'subscription': {'productId': 'plus_100', 'plan': 'PLUS_100', 'status': 'ACTIVE'},
      });

      expect(plan.subscription!.period, isNull);
    });

    test('should fall back to the free plan and an expired state for unknown names', () {
      final plan = UserPlanModel.fromJson(const {
        'plan': 'PLUS_5TB',
        'subscription': {'plan': 'PLUS_5TB', 'status': 'SOMETHING'},
      });

      expect(plan.tier, PlanTier.free);
      expect(plan.subscription!.status, SubscriptionStatus.expired);
      expect(plan.subscription!.periodEnd, isNull);
    });
  });
}
