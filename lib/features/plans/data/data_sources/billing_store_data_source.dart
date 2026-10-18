import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_purchase_update.dart';

/// The store of the device (Google Play).
abstract class BillingStoreDataSource {
  Future<List<StoreOffer>> loadOffers();

  Future<void> buy(StoreOffer offer, {required String accountId});

  Stream<StorePurchaseUpdate> get purchases;

  Future<void> restore();

  Future<void> finish(String purchaseToken);
}

class GooglePlayBillingStoreDataSource implements BillingStoreDataSource {
  final InAppPurchase _store;

  /// What the store needs to buy each offer read by [loadOffers].
  final Map<StoreOffer, GooglePlayProductDetails> _details = {};

  /// Paid purchases waiting for [finish], by token.
  final Map<String, PurchaseDetails> _toFinish = {};

  /// The subscription this store account has, replaced when the user changes of plan.
  GooglePlayPurchaseDetails? _owned;

  GooglePlayBillingStoreDataSource(this._store);

  @override
  late final Stream<StorePurchaseUpdate> purchases =
      _store.purchaseStream.asyncExpand((list) => Stream.fromFutures(list.map(_update))).asBroadcastStream();

  @override
  Future<List<StoreOffer>> loadOffers() async {
    if (!await _store.isAvailable()) return const [];
    final ids = {for (final tier in PlanTier.values.where((tier) => tier.isPaid)) StoreOffer.productIdOf(tier)};
    final response = await _store.queryProductDetails(ids);
    _details.clear();
    for (final details in response.productDetails.whereType<GooglePlayProductDetails>()) {
      final offer = _offerOf(details);
      if (offer != null) _details[offer] = details;
    }
    final offers = _details.keys.toList()
      ..sort((a, b) => a.tier.index != b.tier.index ? a.tier.index - b.tier.index : a.period.index - b.period.index);
    return offers;
  }

  /// One per base plan: the offers of the store (discounts, trials) are left out.
  static StoreOffer? _offerOf(GooglePlayProductDetails details) {
    final index = details.subscriptionIndex;
    final tier = StoreOffer.tierOf(details.id);
    if (index == null || tier == null) return null;
    final offerDetails = details.productDetails.subscriptionOfferDetails![index];
    final period = BillingPeriod.fromBasePlan(offerDetails.basePlanId);
    if (offerDetails.offerId != null || period == null) return null;
    return StoreOffer(tier: tier, period: period, price: details.price);
  }

  @override
  Future<void> buy(StoreOffer offer, {required String accountId}) async {
    final details = _details[offer];
    if (details == null) throw StateError('Unknown offer of the store: $offer');
    final owned = _owned;
    final started = await _store.buyNonConsumable(
      purchaseParam: GooglePlayPurchaseParam(
        productDetails: details,
        applicationUserName: accountId,
        offerToken: details.offerToken,
        // Changing of plan replaces the current one: the time left is credited to the new one
        changeSubscriptionParam: owned == null
            ? null
            : ChangeSubscriptionParam(oldPurchaseDetails: owned, replacementMode: ReplacementMode.withTimeProration),
      ),
    );
    if (!started) throw StateError('The store did not start the purchase');
  }

  @override
  Future<void> restore() => _store.restorePurchases();

  @override
  Future<void> finish(String purchaseToken) async {
    final purchase = _toFinish.remove(purchaseToken);
    if (purchase != null && purchase.pendingCompletePurchase) await _store.completePurchase(purchase);
  }

  Future<StorePurchaseUpdate> _update(PurchaseDetails purchase) async {
    final token = purchase.verificationData.serverVerificationData;
    final status = switch (purchase.status) {
      PurchaseStatus.pending => StorePurchaseStatus.pending,
      PurchaseStatus.purchased => StorePurchaseStatus.purchased,
      PurchaseStatus.restored => StorePurchaseStatus.restored,
      PurchaseStatus.canceled => StorePurchaseStatus.canceled,
      PurchaseStatus.error => StorePurchaseStatus.error,
    };
    if (status == StorePurchaseStatus.purchased || status == StorePurchaseStatus.restored) {
      _toFinish[token] = purchase;
      if (purchase is GooglePlayPurchaseDetails) _owned = purchase;
    } else if (purchase.pendingCompletePurchase && status != StorePurchaseStatus.pending) {
      // A purchase that failed or was cancelled is closed in the store right away
      await _store.completePurchase(purchase);
    }
    return StorePurchaseUpdate(status: status, productId: purchase.productID, purchaseToken: token.isEmpty ? null : token);
  }
}
