import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/app_config.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/billing_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_card.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_limit_banner.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_offer.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_texts.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// The plans: the current one with what the user uses of it, and every plan with what it includes and its price.
/// With buying on, the prices are the ones of the store and each paid plan has a button per way to pay it.
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  @override
  void initState() {
    super.initState();
    if (AppConfig.billingEnabled) context.read<BillingCubit>().loadOffers();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: SecondaryTopBar(title: l10n.plansTitle),
      body: SafeArea(
        top: false,
        child: BlocListener<BillingCubit, BillingState>(
          listenWhen: (previous, current) => current.notice != null && previous.notice != current.notice,
          listener: _showNotice,
          child: BlocBuilder<PlanCubit, PlanState>(
            builder: (context, state) => BlocBuilder<BillingCubit, BillingState>(
              builder: (context, billing) => _plans(context, state.plan, billing),
            ),
          ),
        ),
      ),
    );
  }

  Widget _plans(BuildContext context, UserPlan? plan, BillingState billing) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final note = !AppConfig.billingEnabled
        ? l10n.planComingSoon
        : billing.storeUnavailable
            ? l10n.planStoreUnavailable
            : null;
    return RefreshIndicator(
      onRefresh: () => Future.wait([
        context.read<PlanCubit>().load(),
        if (AppConfig.billingEnabled) context.read<BillingCubit>().loadOffers(),
      ]),
      child: ListView(
        // Pulled down to refresh even when the plans fit on the screen
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(l10n.plansSubtitle, style: TextStyle(fontSize: 14, color: p.ink2)),
          ),
          const PlanLimitBanner(),
          if (plan != null) _CurrentPlan(plan: plan),
          for (final offer in PlanOffer.catalog)
            PlanCard(
              offer: offer,
              isCurrent: plan?.tier == offer.tier,
              storePrices: AppConfig.billingEnabled ? _offersOf(offer.tier, billing) : const [],
              buyable: _buyable(offer.tier, plan, billing),
              buying: billing.buying,
              onBuy: (storeOffer) => context.read<BillingCubit>().buy(storeOffer),
            ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(note, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: p.ink2)),
            ),
          if (PlanOffer.catalog.any((offer) => _buyable(offer.tier, plan, billing).isNotEmpty)) const _PurchaseTerms(),
        ],
      ),
    );
  }

  static List<StoreOffer> _offersOf(PlanTier tier, BillingState billing) =>
      billing.offers.where((storeOffer) => storeOffer.tier == tier).toList();

  /// Without the account id of the server (buying is off there) nothing can be bought. What the user already pays is
  /// left out: the same plan and period, or the whole plan when the period is unknown.
  static List<StoreOffer> _buyable(PlanTier tier, UserPlan? plan, BillingState billing) {
    if (!AppConfig.billingEnabled || plan == null || plan.billingAccountId == null) return const [];
    final period = plan.subscription?.period;
    return _offersOf(tier, billing)
        .where((storeOffer) => plan.tier != tier || (period != null && period != storeOffer.period))
        .toList();
  }

  void _showNotice(BuildContext context, BillingState billing) {
    final l10n = AppLocalizations.of(context)!;
    final text = switch (billing.notice!) {
      BillingNotice.done => l10n.planPurchaseDone(PlanTexts.name(billing.noticeTier ?? PlanTier.free, l10n)),
      BillingNotice.pending => l10n.planPurchasePending,
      BillingNotice.error => l10n.planPurchaseError,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    context.read<BillingCubit>().noticeShown();
  }
}

/// What buying means, under the buy buttons: the plan starts at once (so the user asks to start it within the
/// withdrawal period), renews until cancelled in Google Play and is kept until the end of the paid period.
class _PurchaseTerms extends StatelessWidget {
  const _PurchaseTerms();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    return Padding(
      key: const ValueKey('plans-purchase-terms'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        children: [
          Text(l10n.planPurchaseTerms, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: p.ink2)),
          TextButton(
            onPressed: () => context.push(RoutePaths.legalDocumentOf(LegalDocumentType.terms.slug)),
            child: Text(l10n.planPurchaseTermsLink),
          ),
        ],
      ),
    );
  }
}

/// The plan of the user: its use of space and devices, and the state of the subscription.
class _CurrentPlan extends StatelessWidget {
  final UserPlan plan;

  const _CurrentPlan({required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final status = PlanTexts.subscriptionStatus(plan.subscription, l10n);
    final style = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink2);

    return AppCard(
      key: const ValueKey('plans-current'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.planYours, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
          const SizedBox(height: 2),
          Text(PlanTexts.summary(plan.tier, plan.limits, l10n),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.ink)),
          const SizedBox(height: 10),
          Text(l10n.planUsageStorage(
                  PlanTexts.used(plan.storedBytes, l10n), PlanTexts.size(plan.limits.storageBytes, l10n)),
              style: style),
          Text(l10n.planUsageDevices(plan.devices, plan.limits.maxDevices), style: style),
          if (status != null) ...[
            const SizedBox(height: 8),
            Text(status, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.accentInk)),
          ],
          if (AppConfig.billingEnabled && plan.subscription != null) ...[
            const SizedBox(height: 8),
            AppButton.text(
              key: const ValueKey('plans-manage'),
              label: l10n.planManage,
              onPressed: () => launchUrl(manageSubscriptionsUrl(plan.subscription!.tier),
                  mode: LaunchMode.externalApplication),
            ),
          ],
        ],
      ),
    );
  }
}

/// The subscriptions of the user in Google Play, on the one of [tier]: there the user cancels it or changes the
/// payment method.
Uri manageSubscriptionsUrl(PlanTier tier) => Uri.https('play.google.com', '/store/account/subscriptions', {
      'sku': StoreOffer.productIdOf(tier),
      'package': 'com.photomanagerpro.app',
    });
