import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/storage_budget.dart';

import '../../../../helpers/plan_test_providers.dart';

void main() {
  final quota = TestPlans.freeLimits.storageBytes;

  group('StorageBudget', () {
    test('should start with the free space of the plan', () {
      final budget = StorageBudget(TestPlans.freeWithStored(quota - 1000));

      expect(budget.remainingBytes, 1000);
      expect(budget.fits(1000), isTrue);
      expect(budget.fits(1001), isFalse);
    });

    test('should spend what is stored', () {
      final budget = StorageBudget(TestPlans.freeWithStored(quota - 1000))..spend(600);

      expect(budget.remainingBytes, 400);
      expect(budget.fits(500), isFalse);
    });

    test('should never go below zero', () {
      final budget = StorageBudget(TestPlans.freeWithStored(quota - 100))..spend(500);

      expect(budget.remainingBytes, 0);
    });

    test('should have no space when more is stored than the plan allows (a paid plan ended)', () {
      final budget = StorageBudget(TestPlans.freeWithStored(quota + 5000));

      expect(budget.remainingBytes, 0);
      expect(budget.fits(1), isFalse);
    });

    test('should take the space as the server sees it again', () {
      final budget = StorageBudget(TestPlans.freeWithStored(quota - 1000))..spend(900);

      budget.refresh(TestPlans.freeWithStored(quota - 5000));

      expect(budget.remainingBytes, 5000);
    });

    test('should not limit anything without a plan', () {
      final budget = StorageBudget(null);

      expect(budget.remainingBytes, isNull);
      expect(budget.fits(1 << 40), isTrue);
      budget.spend(100);
      expect(budget.remainingBytes, isNull);
      expect(StorageBudget.unlimited().fits(1 << 40), isTrue);
    });
  });
}
