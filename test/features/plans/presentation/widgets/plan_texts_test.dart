import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_subscription.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_texts.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../../../helpers/plan_test_providers.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));
  final en = lookupAppLocalizations(const Locale('en'));

  PlanSubscription subscription(SubscriptionStatus status, {bool autoRenewing = true}) => PlanSubscription(
      tier: PlanTier.plus100, status: status, periodEnd: DateTime(2026, 11, 18), autoRenewing: autoRenewing);

  // In the app the localizations of Flutter load the date formats
  setUpAll(() => initializeDateFormatting());

  group('PlanTexts', () {
    test('should name the plans', () {
      expect(PlanTexts.name(PlanTier.free, es), 'Gratis');
      expect(PlanTexts.name(PlanTier.plus1tb, en), '1 TB');
    });

    test('should show the limits of the plans as whole units', () {
      expect(PlanTexts.size(5 * testGib, es), '5 GB');
      expect(PlanTexts.size(100 * testMib, es), '100 MB');
      expect(PlanTexts.size(1024 * testGib, es), '1 TB');
      expect(PlanTexts.size(10 * testGib, en), '10 GB');
    });

    test('should summarize the plan for the profile', () {
      expect(PlanTexts.summary(PlanTier.free, TestPlans.freeLimits, es), 'Gratis · 5 GB');
    });

    test('should say what the subscription does next', () {
      expect(PlanTexts.subscriptionStatus(null, es), isNull);
      expect(PlanTexts.subscriptionStatus(subscription(SubscriptionStatus.active), en), startsWith('Renews on'));
      expect(PlanTexts.subscriptionStatus(subscription(SubscriptionStatus.canceled, autoRenewing: false), en),
          startsWith('Ends on'));
      expect(PlanTexts.subscriptionStatus(subscription(SubscriptionStatus.onHold), en), contains('payment'));
      expect(PlanTexts.subscriptionStatus(subscription(SubscriptionStatus.expired), es), startsWith('Tu suscripción terminó'));
      expect(PlanTexts.subscriptionStatus(subscription(SubscriptionStatus.pending), es), startsWith('Pago pendiente'));
    });
  });
}
