import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/features/plans/domain/entities/billing_period.dart';
import 'package:photo_manager_app/features/plans/domain/entities/store_offer.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_offer.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_texts.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// One plan of the plans page: name, price, what it includes and, when buying is on, a button per way to pay it.
class PlanCard extends StatelessWidget {
  final PlanOffer offer;
  final bool isCurrent;

  /// The prices of the store for this plan; empty shows the prices of the launch.
  final List<StoreOffer> storePrices;

  /// What can be bought of this plan (not the free plan, nor what the user already has); empty hides the buttons.
  final List<StoreOffer> buyable;

  /// The offer being bought: every button waits.
  final StoreOffer? buying;
  final ValueChanged<StoreOffer>? onBuy;

  const PlanCard({
    super.key,
    required this.offer,
    required this.isCurrent,
    this.storePrices = const [],
    this.buyable = const [],
    this.buying,
    this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final limits = offer.limits;
    final currency = NumberFormat.simpleCurrency(locale: l10n.localeName, name: 'EUR');
    final monthlyPrice = _storePrice(BillingPeriod.monthly) ??
        (offer.monthlyPrice == null ? null : currency.format(offer.monthlyPrice));
    final annualPrice =
        _storePrice(BillingPeriod.annual) ?? (offer.annualPrice == null ? null : currency.format(offer.annualPrice));

    return AppCard(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      color: isCurrent ? p.accentSoft : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(PlanTexts.name(offer.tier, l10n),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.ink)),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(999)),
                  child: Text(l10n.planYours,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: p.onAccent)),
                ),
            ],
          ),
          if (monthlyPrice != null) ...[
            const SizedBox(height: 4),
            Text(l10n.planPriceMonthly(monthlyPrice),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: p.accentInk)),
            if (annualPrice != null)
              Text(l10n.planPriceAnnual(annualPrice),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
          ],
          const SizedBox(height: 12),
          _Feature(icon: Symbols.cloud_rounded, text: l10n.planStorage(PlanTexts.size(limits.storageBytes, l10n))),
          _Feature(icon: Symbols.devices_rounded, text: l10n.planDevices(limits.maxDevices)),
          _Feature(icon: Symbols.movie_rounded, text: l10n.planVideos(PlanTexts.size(limits.maxVideoBytes, l10n))),
          _Feature(
            icon: Symbols.event_repeat_rounded,
            text: limits.dailyBackup ? l10n.planBackupDaily : l10n.planBackupWeekly,
          ),
          for (final (index, storeOffer) in buyable.indexed) ...[
            SizedBox(height: index == 0 ? 14 : 8),
            _buyButton(storeOffer, l10n),
          ],
        ],
      ),
    );
  }

  String? _storePrice(BillingPeriod period) =>
      storePrices.where((storeOffer) => storeOffer.period == period).firstOrNull?.price;

  /// Monthly as the main button, annual as the second one.
  Widget _buyButton(StoreOffer storeOffer, AppLocalizations l10n) {
    final key = ValueKey('plan-buy-${storeOffer.productId}-${storeOffer.period.basePlanId}');
    final label = storeOffer.period == BillingPeriod.monthly
        ? l10n.planBuyMonthly(storeOffer.price)
        : l10n.planBuyAnnual(storeOffer.price);
    final onPressed = buying == null && onBuy != null ? () => onBuy!(storeOffer) : null;
    final loading = buying == storeOffer;
    return storeOffer.period == BillingPeriod.monthly
        ? AppButton.primary(key: key, label: label, onPressed: onPressed, loading: loading, expand: true)
        : AppButton.secondary(key: key, label: label, onPressed: onPressed, loading: loading, expand: true);
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Feature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: p.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink))),
        ],
      ),
    );
  }
}
