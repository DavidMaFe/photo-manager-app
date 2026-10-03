import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/utils/date_formatter.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/enums/synchronization_status.dart';

/// Activity row for a backup session (inside the activity card).
class SynchronizationListItem extends StatelessWidget {

  final Synchronization session;
  final VoidCallback? onTap;

  const SynchronizationListItem({super.key, required this.session, this.onTap});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final (background, iconColor, icon, title) = _visualsFor(l10n, p);

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w700, color: p.ink, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatDayAndTime(session.startedAt, context),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }

  (Color, Color, IconData, String) _visualsFor(AppLocalizations l10n, AppPalette p) {
    switch (session.status) {
      case SynchronizationStatus.completed:
        return (p.safeSoft, p.safe, Symbols.check_rounded, l10n.itemsSaved(session.uploadedFiles));
      case SynchronizationStatus.inProgress:
        return (p.accentSoft, p.accent, Symbols.sync_rounded, l10n.backupRunning);
      case SynchronizationStatus.failed:
        return (p.dangerSoft, p.danger, Symbols.error_rounded, l10n.incompleteWithFailures(session.failedFiles));
      case SynchronizationStatus.cancelled:
        return (p.surface2, p.ink2, Symbols.cancel_rounded, l10n.backupCancelled);
    }
  }
}
