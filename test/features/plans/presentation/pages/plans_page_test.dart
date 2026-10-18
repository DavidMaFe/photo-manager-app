import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/app_config.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_subscription.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/pages/plans_page.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_card.dart';

import '../../../../helpers/plan_test_providers.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  tearDown(() => AppConfig.billingEnabled = false);

  Future<void> pump(WidgetTester tester, PlanState state) async {
    setUpCustomScreenSize(tester, 390, 3000);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: PlanTestProviders(state: state).providers,
      child: const PlansPage(),
    ));
  }

  group('PlansPage', () {
    testWidgets('should show the four plans and mark the one of the user', (tester) async {
      await pump(tester, const PlanState(plan: TestPlans.free));

      expect(find.byType(PlanCard), findsNWidgets(4));
      final current = tester.widgetList<PlanCard>(find.byType(PlanCard)).where((card) => card.isCurrent);
      expect(current.single.offer.tier, PlanTier.free);
    });

    testWidgets('should show what the user uses of the plan', (tester) async {
      await pump(tester, const PlanState(plan: TestPlans.free));

      expect(find.byKey(const ValueKey('plans-current')), findsOneWidget);
      expect(find.text('Free · 5 GB'), findsOneWidget);
      expect(find.text('Space: 0 B of 5 GB'), findsOneWidget);
      expect(find.text('Devices: 1 of 2'), findsOneWidget);
    });

    testWidgets('should say when the subscription renews', (tester) async {
      await pump(tester, PlanState(plan: UserPlan(
        tier: PlanTier.plus100,
        limits: TestPlans.plus100.limits,
        storedBytes: 0,
        devices: 1,
        pausedDevices: const [],
        readOnly: false,
        subscription: PlanSubscription(tier: PlanTier.plus100, status: SubscriptionStatus.active,
            periodEnd: DateTime(2026, 11, 18), autoRenewing: true),
      )));

      expect(find.textContaining('Renews on'), findsOneWidget);
    });

    testWidgets('should not offer to buy while buying is off', (tester) async {
      await pump(tester, const PlanState(plan: TestPlans.free));

      expect(find.byType(AppButton), findsNothing);
      expect(find.text('Paid plans are coming soon.'), findsOneWidget);
    });

    testWidgets('should offer the other paid plans when buying is on', (tester) async {
      AppConfig.billingEnabled = true;
      await pump(tester, const PlanState(plan: TestPlans.plus100));

      // 250 GB and 1 TB: not the free plan nor the current one
      expect(find.byType(AppButton), findsNWidgets(2));
      expect(find.text('Paid plans are coming soon.'), findsNothing);
    });
  });
}
