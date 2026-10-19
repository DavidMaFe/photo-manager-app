import 'dart:async';
import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_purchase_update.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/buy_plan_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/load_plan_offers_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/register_store_purchase_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/restore_purchases_use_case.dart';
import 'package:photo_manager_app/features/plans/domain/use_cases/watch_store_purchases_use_case.dart';

/// What the plans page tells the user once.
enum BillingNotice { done, pending, error }

class BillingState extends Equatable {
  /// The plans of the store with their prices.
  final List<StoreOffer> offers;
  final bool loadingOffers;

  /// The store did not answer: the page shows the plans without the buy buttons.
  final bool storeUnavailable;

  /// The offer being bought: the buttons wait until the store answers.
  final StoreOffer? buying;
  final BillingNotice? notice;

  /// The plan of a [BillingNotice.done].
  final PlanTier? noticeTier;

  const BillingState({
    this.offers = const [],
    this.loadingOffers = false,
    this.storeUnavailable = false,
    this.buying,
    this.notice,
    this.noticeTier,
  });

  BillingState copyWith({
    List<StoreOffer>? offers,
    bool? loadingOffers,
    bool? storeUnavailable,
    StoreOffer? Function()? buying,
    BillingNotice? Function()? notice,
    PlanTier? noticeTier,
  }) =>
      BillingState(
        offers: offers ?? this.offers,
        loadingOffers: loadingOffers ?? this.loadingOffers,
        storeUnavailable: storeUnavailable ?? this.storeUnavailable,
        buying: buying != null ? buying() : this.buying,
        notice: notice != null ? notice() : this.notice,
        noticeTier: noticeTier ?? this.noticeTier,
      );

  @override
  List<Object?> get props => [offers, loadingOffers, storeUnavailable, buying, notice, noticeTier];
}

/// Buying plans with Google Play, behind `AppConfig.billingEnabled`. One for the whole app: it listens to the store
/// from the session start, because a purchase can finish while the user is in another page (or with the app closed,
/// and then it arrives with the restore of the next session).
///
/// A purchase only changes the plan once the server verifies it with the store; then the store is told it was
/// delivered. Purchases that arrive without a session are left for the next one.
class BillingCubit extends Cubit<BillingState> {
  final WatchStorePurchasesUseCase _watchPurchases;
  final LoadPlanOffersUseCase _loadOffers;
  final BuyPlanUseCase _buy;
  final RegisterStorePurchaseUseCase _register;
  final RestorePurchasesUseCase _restore;
  final String? Function() _accountId;
  final void Function(UserPlan plan) _onPlan;

  StreamSubscription<StorePurchaseUpdate>? _purchases;
  bool _withSession = false;

  BillingCubit({
    required WatchStorePurchasesUseCase watchPurchases,
    required LoadPlanOffersUseCase loadOffers,
    required BuyPlanUseCase buy,
    required RegisterStorePurchaseUseCase register,
    required RestorePurchasesUseCase restore,
    required String? Function() accountId,
    required void Function(UserPlan plan) onPlan,
  })  : _watchPurchases = watchPurchases,
        _loadOffers = loadOffers,
        _buy = buy,
        _register = register,
        _restore = restore,
        _accountId = accountId,
        _onPlan = onPlan,
        super(const BillingState());

  /// The session started: listens to the store and registers again what this store account bought.
  Future<void> start() async {
    _withSession = true;
    _purchases ??= _watchPurchases().listen(_onPurchase);
    try {
      await _restore();
    } catch (e) {
      developer.log('Restoring the purchases failed: $e', name: 'Billing');
    }
  }

  /// Read again each time the plans page opens: the prices and the plans of the store can change during a session.
  /// The plans already read are shown meanwhile, and kept if the store fails.
  Future<void> loadOffers() async {
    if (state.loadingOffers) return;
    emit(state.copyWith(loadingOffers: true, storeUnavailable: false));
    try {
      final offers = await _loadOffers();
      emit(state.copyWith(offers: offers, loadingOffers: false, storeUnavailable: offers.isEmpty));
    } catch (e) {
      developer.log('Reading the plans of the store failed: $e', name: 'Billing');
      emit(state.copyWith(loadingOffers: false, storeUnavailable: state.offers.isEmpty));
    }
  }

  Future<void> buy(StoreOffer offer) async {
    if (state.buying != null) return;
    emit(state.copyWith(buying: () => offer, notice: () => null));
    try {
      await _buy(offer, accountId: _accountId());
    } catch (e) {
      developer.log('The purchase did not start: $e', name: 'Billing');
      emit(state.copyWith(buying: () => null, notice: () => BillingNotice.error));
    }
  }

  /// The page showed the notice.
  void noticeShown() => emit(state.copyWith(notice: () => null));

  /// The session ended: the purchases that arrive now are left for the next session.
  void clear() {
    _withSession = false;
    emit(const BillingState());
  }

  Future<void> _onPurchase(StorePurchaseUpdate update) async {
    if (!_withSession) return;
    switch (update.status) {
      case StorePurchaseStatus.pending:
        emit(state.copyWith(buying: () => null, notice: () => BillingNotice.pending));
      case StorePurchaseStatus.canceled:
        emit(state.copyWith(buying: () => null));
      case StorePurchaseStatus.error:
        emit(state.copyWith(buying: () => null, notice: () => BillingNotice.error));
      case StorePurchaseStatus.purchased:
        await _registerPurchase(update, quietly: false);
      case StorePurchaseStatus.restored:
        await _registerPurchase(update, quietly: true);
    }
  }

  /// A restored purchase may be of another account of the app (the same Google account): the server rejects it and
  /// the user is not told.
  Future<void> _registerPurchase(StorePurchaseUpdate update, {required bool quietly}) async {
    final token = update.purchaseToken;
    if (token == null) return;
    try {
      final plan = await _register(token);
      _onPlan(plan);
      if (!quietly) {
        emit(state.copyWith(buying: () => null, notice: () => BillingNotice.done, noticeTier: plan.tier));
      }
    } catch (e) {
      developer.log('Registering the purchase in the server failed: $e', name: 'Billing');
      if (!quietly) emit(state.copyWith(buying: () => null, notice: () => BillingNotice.error));
    }
  }

  @override
  Future<void> close() {
    _purchases?.cancel();
    return super.close();
  }
}
