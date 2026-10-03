import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "N items to review" card shown above the gallery grid.
class PendingReviewCard extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onReview;

  const PendingReviewCard({super.key, required this.pendingCount, required this.onReview});

  @override
  Widget build(BuildContext context) {
    if (pendingCount <= 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return AppCard(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: p.reviewSoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(Symbols.fact_check_rounded, size: 22, color: p.reviewIcon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.toReviewTitle(pendingCount),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.toReviewBody,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppButton(
            label: l10n.review,
            variant: AppButtonVariant.inverse,
            size: AppButtonSize.small,
            onPressed: onReview,
          ),
        ],
      ),
    );
  }
}
