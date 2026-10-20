import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/features/plans/presentation/bloc/plan_cubit.dart';
import 'package:photo_manager_app/features/plans/presentation/widgets/plan_texts.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Why this device does not back up because of the plan: the account is read only, or this device is paused. Nothing
/// when neither happens.
class PlanLimitBanner extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const PlanLimitBanner({super.key, this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12)});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PlanCubit, PlanState>(
      builder: (context, state) {
        final plan = state.plan;
        if (plan == null) return const SizedBox.shrink();
        final (String title, String body)? notice = plan.readOnly
            ? (
                l10n.planReadOnlyTitle,
                l10n.planReadOnlyBody(
                    PlanTexts.used(plan.storedBytes, l10n), PlanTexts.size(plan.limits.storageBytes, l10n)),
              )
            : state.isThisDevicePaused
                ? (l10n.planDevicePausedTitle, l10n.planDevicePausedBody(plan.limits.maxDevices))
                : null;
        if (notice == null) return const SizedBox.shrink();

        final p = context.palette;
        return AppCard(
          key: const ValueKey('plan-limit-banner'),
          margin: margin,
          color: p.reviewSoft,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Symbols.pause_circle_rounded, color: p.reviewIcon, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notice.$1, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: p.reviewInk)),
                    const SizedBox(height: 4),
                    Text(notice.$2, style: TextStyle(fontSize: 13, color: p.ink)),
                    const SizedBox(height: 6),
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 36)),
                      onPressed: () => context.goNamed(RouteNames.plans),
                      child: Text(l10n.planSeePlans),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
