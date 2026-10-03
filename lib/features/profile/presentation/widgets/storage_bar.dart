import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';

import '../../../../l10n/app_localizations.dart';


class StorageBar extends StatelessWidget {

  final UserProfile profile;

  const StorageBar({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {

    final usedGb = profile.storageUsedGb;
    final totalGb = profile.storageTotalGb;
    final percentage = profile.storageUsedPercentage;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.storage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.palette.ink
              ),
            ),
            Text(
              '${usedGb.toStringAsFixed(1)} / ${totalGb.toStringAsFixed(0)} GB',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.palette.ink2
              ),
            )
          ],
        ),

        const SizedBox(height: 12),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: context.palette.surface2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStorageColor(context, percentage)
            ),
          ),
        )
      ],
    );
  }

  Color _getStorageColor(BuildContext context, double percentage) {
    if (percentage < 0.5) {
      return context.palette.accent;
    } else if (percentage < 0.75) {
      return context.palette.review;
    } else if (percentage < 0.9) {
      return context.palette.review;
    } else {
      return context.palette.danger;
    }
  }
}