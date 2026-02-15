
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6))
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.syncFiles(session.uploadedFiles),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatRelativeTime(session.startedAt, context),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280)
                        ),
                      )
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFD1D5DB),
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    switch (session.status) {
      case SynchronizationStatus.completed:
        backgroundColor = const Color(0xFFDCFCE7);
        iconColor = const Color(0xFF16A34A);
        icon = Icons.check;
        break;
      case SynchronizationStatus.inProgress:
        backgroundColor = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFF59E0B);
        icon = Icons.sync;
        break;
      case SynchronizationStatus.failed:
        backgroundColor = const Color(0xFFFEE2E2);
        iconColor = const Color(0xFFEF4444);
        icon = Icons.close;
        break;
      case SynchronizationStatus.cancelled:
        backgroundColor = const Color(0xFFF3F4F6);
        iconColor = const Color(0xFF6B7280);
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