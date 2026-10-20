import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/plans/data/data_sources/billing_store_data_source.dart';
import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_purchase_update.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

class FakePurchaseParam extends Fake implements PurchaseParam {}

class FakePurchaseDetails extends Fake implements PurchaseDetails {}

/// A product of the store with one entry per base plan or offer: (base plan, offer id, price).
List<GooglePlayProductDetails> product(String id, List<(String, String?, String)> offers) =>
    GooglePlayProductDetails.fromProductDetails(ProductDetailsWrapper(
      description: '',
      name: id,
      productId: id,
      productType: ProductType.subs,
      title: id,
      subscriptionOfferDetails: [
        for (final (basePlan, offerId, price) in offers)
          SubscriptionOfferDetailsWrapper(
            basePlanId: basePlan,
            offerId: offerId,
            offerTags: const [],
            offerIdToken: 'offer-$id-$basePlan-$offerId',
            pricingPhases: [
              PricingPhaseWrapper(
                billingCycleCount: 0,
                billingPeriod: basePlan == 'monthly' ? 'P1M' : 'P1Y',
                formattedPrice: price,
                priceAmountMicros: 1990000,
                priceCurrencyCode: 'EUR',
                recurrenceMode: RecurrenceMode.infiniteRecurring,
              ),
            ],
          ),
      ],
    ));

GooglePlayPurchaseDetails purchase(String productId, String token, PurchaseStatus status, {bool acknowledged = false}) =>
    GooglePlayPurchaseDetails(
      productID: productId,
      verificationData:
          PurchaseVerificationData(localVerificationData: '', serverVerificationData: token, source: 'google_play'),
      transactionDate: '0',
      billingClientPurchase: PurchaseWrapper(
        orderId: 'order',
        packageName: 'com.photomanagerpro.app',
        purchaseTime: 0,
        purchaseToken: token,
        signature: '',
        products: [productId],
        isAutoRenewing: true,
        originalJson: '{}',
        isAcknowledged: acknowledged,
        purchaseState: PurchaseStateWrapper.purchased,
      ),
      status: status,
    );

void main() {
  late MockInAppPurchase store;
  late StreamController<List<PurchaseDetails>> storePurchases;
  late GooglePlayBillingStoreDataSource dataSource;

  const plus100Monthly = StoreOffer(tier: PlanTier.plus100, period: BillingPeriod.monthly, price: '1,99 €');
  const plus250Monthly = StoreOffer(tier: PlanTier.plus250, period: BillingPeriod.monthly, price: '3,99 €');

  setUpAll(() {
    registerFallbackValue(FakePurchaseParam());
    registerFallbackValue(FakePurchaseDetails());
  });

  setUp(() {
    store = MockInAppPurchase();
    storePurchases = StreamController<List<PurchaseDetails>>();
    when(() => store.purchaseStream).thenAnswer((_) => storePurchases.stream);
    when(() => store.isAvailable()).thenAnswer((_) async => true);
    when(() => store.queryProductDetails(any())).thenAnswer((_) async => ProductDetailsResponse(
          productDetails: [
            ...product('plus_250', [('monthly', null, '3,99 €'), ('annual', null, '39,99 €')]),
            ...product('plus_100', [('monthly', null, '1,99 €'), ('annual', null, '19,99 €'), ('annual', 'promo', '9,99 €')]),
          ],
          notFoundIDs: const ['plus_1tb'],
        ));
    when(() => store.buyNonConsumable(purchaseParam: any(named: 'purchaseParam'))).thenAnswer((_) async => true);
    when(() => store.completePurchase(any())).thenAnswer((_) async {});
    when(() => store.restorePurchases()).thenAnswer((_) async {});
    dataSource = GooglePlayBillingStoreDataSource(store);
  });

  tearDown(() {
    storePurchases.close();
  });

  group('GooglePlayBillingStoreDataSource', () {
    group('loadOffers', () {
      test('should ask the store for the three paid plans', () async {
        await dataSource.loadOffers();

        final ids = verify(() => store.queryProductDetails(captureAny())).captured.single as Set<String>;
        expect(ids, {'plus_100', 'plus_250', 'plus_1tb'});
      });

      test('should give one offer per base plan, ordered by plan and period, without the promotions', () async {
        final offers = await dataSource.loadOffers();

        expect(offers, const [
          StoreOffer(tier: PlanTier.plus100, period: BillingPeriod.monthly, price: '1,99 €'),
          StoreOffer(tier: PlanTier.plus100, period: BillingPeriod.annual, price: '19,99 €'),
          StoreOffer(tier: PlanTier.plus250, period: BillingPeriod.monthly, price: '3,99 €'),
          StoreOffer(tier: PlanTier.plus250, period: BillingPeriod.annual, price: '39,99 €'),
        ]);
      });

      test('should leave out unknown products and base plans', () async {
        when(() => store.queryProductDetails(any())).thenAnswer((_) async => ProductDetailsResponse(
              productDetails: [
                ...product('plus_100', [('weekly', null, '0,99 €')]),
                ...product('other', [('monthly', null, '5 €')]),
              ],
              notFoundIDs: const [],
            ));

        expect(await dataSource.loadOffers(), isEmpty);
      });

      test('should give nothing when the store is not available', () async {
        when(() => store.isAvailable()).thenAnswer((_) async => false);

        expect(await dataSource.loadOffers(), isEmpty);
        verifyNever(() => store.queryProductDetails(any()));
      });
    });

    group('buy', () {
      test('should buy the base plan with the account id and its offer token', () async {
        await dataSource.loadOffers();

        await dataSource.buy(plus100Monthly, accountId: 'account');

        final param = verify(() => store.buyNonConsumable(purchaseParam: captureAny(named: 'purchaseParam')))
            .captured
            .single as GooglePlayPurchaseParam;
        expect(param.productDetails.id, 'plus_100');
        expect(param.applicationUserName, 'account');
        expect(param.offerToken, 'offer-plus_100-monthly-null');
        expect(param.changeSubscriptionParam, isNull);
      });

      test('should replace the subscription the store account has when the plan changes', () async {
        await dataSource.loadOffers();
        final updates = dataSource.purchases.first;
        storePurchases.add([purchase('plus_100', 'old-token', PurchaseStatus.restored, acknowledged: true)]);
        await updates;

        await dataSource.buy(plus250Monthly, accountId: 'account');

        final param = verify(() => store.buyNonConsumable(purchaseParam: captureAny(named: 'purchaseParam')))
            .captured
            .single as GooglePlayPurchaseParam;
        expect(param.changeSubscriptionParam!.oldPurchaseDetails.productID, 'plus_100');
        expect(param.changeSubscriptionParam!.replacementMode, ReplacementMode.withTimeProration);
      });

      test('should fail for an offer the store did not give', () async {
        await expectLater(dataSource.buy(plus100Monthly, accountId: 'account'), throwsStateError);
      });

      test('should fail when the store does not start the purchase', () async {
        await dataSource.loadOffers();
        when(() => store.buyNonConsumable(purchaseParam: any(named: 'purchaseParam'))).thenAnswer((_) async => false);

        await expectLater(dataSource.buy(plus100Monthly, accountId: 'account'), throwsStateError);
      });
    });

    group('purchases', () {
      test('should map what the store says, with the token of each purchase', () async {
        final updates = dataSource.purchases.take(5).toList();
        storePurchases.add([
          purchase('plus_100', 't1', PurchaseStatus.pending),
          purchase('plus_100', 't2', PurchaseStatus.purchased),
          purchase('plus_100', 't3', PurchaseStatus.restored),
          purchase('plus_100', 't4', PurchaseStatus.canceled),
          purchase('plus_100', '', PurchaseStatus.error),
        ]);

        expect(await updates, const [
          StorePurchaseUpdate(status: StorePurchaseStatus.pending, productId: 'plus_100', purchaseToken: 't1'),
          StorePurchaseUpdate(status: StorePurchaseStatus.purchased, productId: 'plus_100', purchaseToken: 't2'),
          StorePurchaseUpdate(status: StorePurchaseStatus.restored, productId: 'plus_100', purchaseToken: 't3'),
          StorePurchaseUpdate(status: StorePurchaseStatus.canceled, productId: 'plus_100', purchaseToken: 't4'),
          StorePurchaseUpdate(status: StorePurchaseStatus.error, productId: 'plus_100'),
        ]);
      });

      test('should close right away the purchases that failed or were cancelled', () async {
        final cancelled = purchase('plus_100', 't4', PurchaseStatus.canceled);
        final pending = purchase('plus_100', 't1', PurchaseStatus.pending);
        final updates = dataSource.purchases.take(2).toList();
        storePurchases.add([cancelled, pending]);
        await updates;

        verify(() => store.completePurchase(cancelled)).called(1);
        verifyNever(() => store.completePurchase(pending));
      });
    });

    group('finish', () {
      test('should complete a paid purchase only once', () async {
        final paid = purchase('plus_100', 't2', PurchaseStatus.purchased);
        final updates = dataSource.purchases.first;
        storePurchases.add([paid]);
        await updates;

        await dataSource.finish('t2');
        await dataSource.finish('t2');

        verify(() => store.completePurchase(paid)).called(1);
      });

      test('should not complete a purchase already acknowledged', () async {
        final updates = dataSource.purchases.first;
        storePurchases.add([purchase('plus_100', 't3', PurchaseStatus.restored, acknowledged: true)]);
        await updates;

        await dataSource.finish('t3');

        verifyNever(() => store.completePurchase(any()));
      });

      test('should do nothing for an unknown token', () async {
        await dataSource.finish('unknown');

        verifyNever(() => store.completePurchase(any()));
      });
    });

    test('should restore the purchases with the store', () async {
      await dataSource.restore();

      verify(() => store.restorePurchases()).called(1);
    });
  });
}
