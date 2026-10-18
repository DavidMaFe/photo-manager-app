import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_card.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_offer.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pump(WidgetTester tester, PlanOffer offer, {bool isCurrent = false, VoidCallback? onChoose}) async {
    setUpCustomScreenSize(tester, 390, 900);
    await tester.pumpWidget(makeTestableWidget(
        Scaffold(body: SingleChildScrollView(child: PlanCard(offer: offer, isCurrent: isCurrent, onChoose: onChoose)))));
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

    testWidgets('should show the button only when buying is possible', (tester) async {
      var chosen = false;
      await pump(tester, PlanOffer.catalog[2]);
      expect(find.byType(AppButton), findsNothing);

      await pump(tester, PlanOffer.catalog[2], onChoose: () => chosen = true);
      await tester.tap(find.byType(AppButton));

      expect(chosen, isTrue);
    });
  });
}
