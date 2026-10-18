import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/app_config.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_subscription.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/billing_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/pages/plans_page.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_card.dart';

import '../../../../helpers/plan_test_providers.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  tearDown(() => AppConfig.billingEnabled = false);

  Future<PlanTestProviders> pump(WidgetTester tester, PlanState state,
      {BillingState billing = const BillingState()}) async {
    setUpCustomScreenSize(tester, 390, 3000);
    final providers = PlanTestProviders(state: state, billingState: billing);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(providers: providers.providers, child: const PlansPage()));
    return providers;
  }

  /// The plan of a user who can buy (buying is on in the server).
  UserPlan buyer(UserPlan plan, {PlanSubscription? subscription}) => UserPlan(
        tier: plan.tier,
        limits: plan.limits,
        storedBytes: plan.storedBytes,
        devices: plan.devices,
        pausedDevices: plan.pausedDevices,
        readOnly: plan.readOnly,
        subscription: subscription,
        billingAccountId: 'a' * 64,
      );

  const withOffers = BillingState(offers: TestOffers.all);

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

    // ==================== BUYING (Google Play) ====================

    testWidgets('should read the plans of the store when buying is on', (tester) async {
      AppConfig.billingEnabled = true;
      final providers = await pump(tester, PlanState(plan: buyer(TestPlans.free)));

      verify(() => providers.billing.loadOffers()).called(1);
    });

    testWidgets('should not read the store while buying is off', (tester) async {
      final providers = await pump(tester, PlanState(plan: buyer(TestPlans.free)), billing: withOffers);

      verifyNever(() => providers.billing.loadOffers());
      expect(find.byType(AppButton), findsNothing);
      expect(find.text('€1.99/month'), findsOneWidget);
    });

    testWidgets('should offer monthly and annual of every paid plan to a free user', (tester) async {
      AppConfig.billingEnabled = true;
      await pump(tester, PlanState(plan: buyer(TestPlans.free)), billing: withOffers);

      expect(find.byType(AppButton), findsNWidgets(6));
      expect(find.text('1,99 €/month'), findsOneWidget);
      expect(find.text('Paid plans are coming soon.'), findsNothing);
    });

    testWidgets('should offer the other period of the current plan and the other plans', (tester) async {
      AppConfig.billingEnabled = true;
      await pump(
          tester,
          PlanState(
              plan: buyer(TestPlans.plus100,
                  subscription: const PlanSubscription(
                      tier: PlanTier.plus100,
                      status: SubscriptionStatus.active,
                      period: BillingPeriod.monthly,
                      periodEnd: null,
                      autoRenewing: true))),
          billing: withOffers);

      expect(find.byKey(const ValueKey('plan-buy-plus_100-monthly')), findsNothing);
      expect(find.byKey(const ValueKey('plan-buy-plus_100-annual')), findsOneWidget);
      expect(find.byKey(const ValueKey('plan-buy-plus_250-monthly')), findsOneWidget);
      expect(find.byKey(const ValueKey('plan-buy-plus_1tb-annual')), findsOneWidget);
    });

    testWidgets('should not offer to buy while the server has buying off', (tester) async {
      AppConfig.billingEnabled = true;
      await pump(tester, const PlanState(plan: TestPlans.free), billing: withOffers);

      expect(find.byKey(const ValueKey('plan-buy-plus_100-monthly')), findsNothing);
    });

    testWidgets('should buy the plan of the button tapped', (tester) async {
      AppConfig.billingEnabled = true;
      final providers = await pump(tester, PlanState(plan: buyer(TestPlans.free)), billing: withOffers);

      await tester.tap(find.byKey(const ValueKey('plan-buy-plus_250-annual')));

      verify(() => providers.billing.buy(TestOffers.plus250Annual)).called(1);
    });

    testWidgets('should say when the store is not available', (tester) async {
      AppConfig.billingEnabled = true;
      await pump(tester, PlanState(plan: buyer(TestPlans.free)),
          billing: const BillingState(storeUnavailable: true));

      expect(find.text('Could not connect to Google Play. Try again later.'), findsOneWidget);
      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('should tell the user the purchase is done', (tester) async {
      AppConfig.billingEnabled = true;
      setUpCustomScreenSize(tester, 390, 3000);
      final providers = PlanTestProviders(state: PlanState(plan: buyer(TestPlans.plus100)), billingState: withOffers);
      whenListen(
        providers.billing,
        Stream.value(const BillingState(
            offers: TestOffers.all, notice: BillingNotice.done, noticeTier: PlanTier.plus100)),
        initialState: withOffers,
      );
      await tester.pumpWidget(makeTestableWidgetWithBlocs(providers: providers.providers, child: const PlansPage()));
      await tester.pump();

      expect(find.text('Done! You now have the 100 GB plan'), findsOneWidget);
      verify(() => providers.billing.noticeShown()).called(1);
    });

    testWidgets('should tell the user when the payment is pending', (tester) async {
      AppConfig.billingEnabled = true;
      setUpCustomScreenSize(tester, 390, 3000);
      final providers = PlanTestProviders(state: PlanState(plan: buyer(TestPlans.free)), billingState: withOffers);
      whenListen(providers.billing,
          Stream.value(const BillingState(offers: TestOffers.all, notice: BillingNotice.pending)),
          initialState: withOffers);
      await tester.pumpWidget(makeTestableWidgetWithBlocs(providers: providers.providers, child: const PlansPage()));
      await tester.pump();

      expect(find.text('Your payment is pending. The plan will apply as soon as it is confirmed.'), findsOneWidget);
    });

    testWidgets('should link to Google Play to manage the subscription', (tester) async {
      AppConfig.billingEnabled = true;
      await pump(
          tester,
          PlanState(
              plan: buyer(TestPlans.plus100,
                  subscription: const PlanSubscription(
                      tier: PlanTier.plus100, status: SubscriptionStatus.active, periodEnd: null, autoRenewing: true))),
          billing: withOffers);

      expect(find.byKey(const ValueKey('plans-manage')), findsOneWidget);
      expect(manageSubscriptionsUrl(PlanTier.plus100).toString(),
          'https://play.google.com/store/account/subscriptions?sku=plus_100&package=com.photomanagerpro.app');
    });

    testWidgets('should explain what buying means under the buy buttons', (tester) async {
      AppConfig.billingEnabled = true;
      await pump(tester, PlanState(plan: buyer(TestPlans.free)), billing: withOffers);

      expect(find.byKey(const ValueKey('plans-purchase-terms')), findsOneWidget);
      expect(find.textContaining('the plan starts at once'), findsOneWidget);
      expect(find.text('Terms of use'), findsOneWidget);
    });

    testWidgets('should not explain buying when nothing can be bought', (tester) async {
      AppConfig.billingEnabled = true;
      await pump(tester, const PlanState(plan: TestPlans.free), billing: withOffers);

      expect(find.byKey(const ValueKey('plans-purchase-terms')), findsNothing);
    });

    testWidgets('should not link to Google Play without a subscription', (tester) async {
      AppConfig.billingEnabled = true;
      await pump(tester, PlanState(plan: buyer(TestPlans.free)), billing: withOffers);

      expect(find.byKey(const ValueKey('plans-manage')), findsNothing);
    });
  });
}
