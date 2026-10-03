
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/utils/date_formatter.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/enums/synchronization_status.dart';

class SynchronizationListItem extends StatelessWidget {

  final Synchronization session;
  final VoidCallback? onTap;

  const SynchronizationListItem({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.palette.surface2)
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusIcon(context),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.syncFiles(session.uploadedFiles),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.palette.ink,
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatRelativeTime(session.startedAt, context),
                        style: TextStyle(
                          fontSize: 13,
                          color: context.palette.ink2
                        ),
                      )
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.palette.line,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (session.status) {
      case SynchronizationStatus.completed:
        backgroundColor = context.palette.safeSoft;
        iconColor = context.palette.safe;
        icon = Icons.check;
        break;
      case SynchronizationStatus.inProgress:
        backgroundColor = context.palette.reviewSoft;
        iconColor = context.palette.review;
        icon = Icons.sync;
        break;
      case SynchronizationStatus.failed:
        backgroundColor = context.palette.dangerSoft;
        iconColor = context.palette.danger;
        icon = Icons.close;
        break;
      case SynchronizationStatus.cancelled:
        backgroundColor = context.palette.surface2;
        iconColor = context.palette.ink2;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 22,
      ),
    );
  }
}