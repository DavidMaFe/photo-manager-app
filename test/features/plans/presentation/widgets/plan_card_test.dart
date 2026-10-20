import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_card.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_offer.dart';

import '../../../../helpers/plan_test_providers.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    PlanOffer offer, {
    bool isCurrent = false,
    List<StoreOffer> storePrices = const [],
    List<StoreOffer> buyable = const [],
    StoreOffer? buying,
    ValueChanged<StoreOffer>? onBuy,
  }) async {
    setUpCustomScreenSize(tester, 390, 900);
    await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: SingleChildScrollView(
            child: PlanCard(
      offer: offer,
      isCurrent: isCurrent,
      storePrices: storePrices,
      buyable: buyable,
      buying: buying,
      onBuy: onBuy,
    )))));
  }

  group('PlanCard', () {
    testWidgets('should show the price and what a paid plan includes', (tester) async {
      await pump(tester, PlanOffer.catalog[1]);

      expect(find.text('100 GB'), findsOneWidget);
      expect(find.text('€1.99/month'), findsOneWidget);
      expect(find.text('or €19.99/year: 2 months free'), findsOneWidget);
      expect(find.text('100 GB of space'), findsOneWidget);
      expect(find.text('3 devices'), findsOneWidget);
      expect(find.text('Videos up to 2 GB'), findsOneWidget);
      expect(find.text('Daily automatic backup'), findsOneWidget);
    });

    testWidgets('should show the free plan without price and with weekly backups', (tester) async {
      await pump(tester, PlanOffer.catalog.first);

      expect(find.text('Free'), findsOneWidget);
      expect(find.textContaining('/month'), findsNothing);
      expect(find.text('Videos up to 100 MB'), findsOneWidget);
      expect(find.text('Weekly automatic backup'), findsOneWidget);
    });

    testWidgets('should mark the plan of the user', (tester) async {
      await pump(tester, PlanOffer.catalog.first, isCurrent: true);

      expect(find.text('Your plan'), findsOneWidget);
    });

    testWidgets('should show the prices of the store when there are', (tester) async {
      await pump(tester, PlanOffer.catalog[1], storePrices: const [TestOffers.plus100Monthly, TestOffers.plus100Annual]);

      expect(find.text('1,99 €/month'), findsOneWidget);
      expect(find.text('or 19,99 €/year: 2 months free'), findsOneWidget);
      expect(find.text('€1.99/month'), findsNothing);
    });

    testWidgets('should show no buttons when nothing can be bought', (tester) async {
      await pump(tester, PlanOffer.catalog[2], storePrices: const [TestOffers.plus250Monthly]);

      expect(find.byType(AppButton), findsNothing);
    });

    testWidgets('should buy the offer of the button tapped', (tester) async {
      StoreOffer? bought;
      await pump(tester, PlanOffer.catalog[2],
          buyable: const [TestOffers.plus250Monthly, TestOffers.plus250Annual], onBuy: (offer) => bought = offer);

      expect(find.text('3,99 € per month'), findsOneWidget);
      await tester.tap(find.text('39,99 € per year'));

      expect(bought, TestOffers.plus250Annual);
    });

    testWidgets('should disable every button while a purchase is in progress', (tester) async {
      StoreOffer? bought;
      await pump(tester, PlanOffer.catalog[2],
          buyable: const [TestOffers.plus250Monthly, TestOffers.plus250Annual],
          buying: TestOffers.plus1tbMonthly,
          onBuy: (offer) => bought = offer);

      await tester.tap(find.text('39,99 € per year'));

      expect(bought, isNull);
      expect(tester.widgetList<AppButton>(find.byType(AppButton)).every((button) => button.onPressed == null), isTrue);
    });
  });
}
