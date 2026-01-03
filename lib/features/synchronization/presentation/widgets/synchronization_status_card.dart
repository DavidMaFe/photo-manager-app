import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/synchronization.dart';


class SynchronizationStatusCard extends StatelessWidget {
  
  final Synchronization? latestSync;
  final VoidCallback onSyncNowPressed;
  
  const SynchronizationStatusCard({
    super.key, 
    required this.latestSync, 
    required this.onSyncNowPressed
  });
  
  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.syncCurrentState, style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500
              )),
              _buildStatusBadge(l10n)
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusIcon(),
          const SizedBox(height: 24),
          if (latestSync != null) ...[
            Text(l10n.syncLast, style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14
            )),
            const SizedBox(height: 6),
            Text(
              DateFormatter.formatRelativeTime(latestSync!.startedAt, context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700
              ),
            )
          ] else ...[
            Text(
              l10n.syncEmpty,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700
              ),
            )
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSyncNowPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: PhotoManagerColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                elevation: 2
              ),
              child: Text(
                l10n.syncNow,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AppLocalizations l10n) {

    final text = latestSync?.isCompleted == true ? l10n.synchronized : l10n.syncPending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;

    if (latestSync == null) {
      icon = Icons.sync;
    } else if (latestSync!.isCompleted) {
      icon = Icons.check;
    } else if (latestSync!.isInProgress) {
      icon = Icons.sync;
    } else if (latestSync!.hasFailed) {
      icon = Icons.close;
    } else {
      icon = Icons.sync;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}