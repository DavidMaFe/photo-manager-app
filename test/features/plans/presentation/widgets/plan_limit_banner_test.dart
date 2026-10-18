import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_limit_banner.dart';

import '../../../../helpers/plan_test_providers.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  UserPlan plan({bool readOnly = false, List<String> paused = const []}) => UserPlan(
        tier: PlanTier.free,
        limits: TestPlans.freeLimits,
        storedBytes: 6 * testGib,
        devices: 3,
        pausedDevices: paused,
        readOnly: readOnly,
        subscription: null,
      );

  Future<void> pump(WidgetTester tester, PlanState state) => tester.pumpWidget(makeTestableWidgetWithBlocs(
        providers: PlanTestProviders(state: state).providers,
        child: const Scaffold(body: PlanLimitBanner()),
      ));

  group('PlanLimitBanner', () {
    testWidgets('should explain a read only account', (tester) async {
      await pump(tester, PlanState(plan: plan(readOnly: true), deviceUuid: 'phone'));

      expect(find.text('Your account is read only'), findsOneWidget);
      expect(find.textContaining('your plan allows 5 GB'), findsOneWidget);
      expect(find.text('See plans'), findsOneWidget);
    });

    testWidgets('should explain that this device is paused', (tester) async {
      await pump(tester, PlanState(plan: plan(paused: ['phone']), deviceUuid: 'phone'));

      expect(find.text('This device is paused'), findsOneWidget);
      expect(find.textContaining('Your plan allows 2 devices'), findsOneWidget);
    });

    testWidgets('should show nothing when another device is paused', (tester) async {
      await pump(tester, PlanState(plan: plan(paused: ['tablet']), deviceUuid: 'phone'));

      expect(find.byKey(const ValueKey('plan-limit-banner')), findsNothing);
    });

    testWidgets('should show nothing before the plan is read', (tester) async {
      await pump(tester, const PlanState());

      expect(find.byKey(const ValueKey('plan-limit-banner')), findsNothing);
    });
  });
}
