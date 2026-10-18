import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/config/app_config.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/plans/domain/entities/user_plan.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_card.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_limit_banner.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_offer.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_texts.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// The plans: the current one with what the user uses of it, and every plan with what it includes and its price.
class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.background,
      appBar: SecondaryTopBar(title: l10n.plansTitle),
      body: SafeArea(
        top: false,
        child: BlocBuilder<PlanCubit, PlanState>(
          builder: (context, state) {
            final plan = state.plan;
            return RefreshIndicator(
              onRefresh: () => context.read<PlanCubit>().load(),
              child: ListView(
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
                      // Buying arrives with Google Play Billing (Phase 4), behind its switch
                      onChoose: AppConfig.billingEnabled && offer.tier.isPaid && plan?.tier != offer.tier
                          ? () {}
                          : null,
                    ),
                  if (!AppConfig.billingEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Text(l10n.planComingSoon,
                          textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: p.ink2)),
                    ),
                ],
              ),
            );
          },
        ),
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
        ],
      ),
    );
  }
}
