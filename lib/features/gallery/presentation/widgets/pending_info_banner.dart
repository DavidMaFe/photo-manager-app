import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';


class PendingInfoBanner extends StatelessWidget {

  final int pendingCount;

  const PendingInfoBanner({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    if (pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.palette.reviewSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.palette.review,
          width: 1
        )
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: context.palette.reviewInk,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pendingCount == 1 ? l10n.pendingFilesInfoSingle : l10n.pendingFilesInfo(pendingCount),
              style: TextStyle(
                color: context.palette.reviewInk,
                fontSize: 14,
                fontWeight: FontWeight.w500
              ),
            ),
          )
        ],
      ),
    );
  }
}