import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/utils/date_formatter.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/icon_circle_button.dart';
import 'package:photo_manager_app/core/widgets/progress_ring.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/synchronization.dart';


/// Phase of a backup running on this phone.
enum LiveBackupPhase { preparing, scanning, uploading, finishing, cancelling }

/// Progress of the backup running on this phone (from SyncSessionBloc).
class LiveBackup {
  final LiveBackupPhase phase;
  final int uploaded;
  final int total;

  /// Estimated time left; `null` until there is enough data.
  final Duration? remaining;

  /// Bytes still to upload; 0 when unknown.
  final int remainingBytes;

  const LiveBackup({
    required this.phase,
    this.uploaded = 0,
    this.total = 0,
    this.remaining,
    this.remainingBytes = 0,
  });

  double get progress => total == 0 ? 0 : (uploaded / total).clamp(0.0, 1.0);
}


/// Backup status card: progress ring, status, "Back up now" and the backup
/// conditions. While [live] is set it shows the running backup instead.
class SynchronizationStatusCard extends StatelessWidget {

  final Synchronization? latestSync;
  final VoidCallback onSyncNowPressed;

  /// Backup schedule and conditions; the pills are hidden while unknown.
  final SyncConfig? config;
  final VoidCallback? onSettingsPressed;

  /// Backup running on this phone.
  final LiveBackup? live;
  final VoidCallback? onCancelPressed;

  const SynchronizationStatusCard({
    super.key,
    required this.latestSync,
    required this.onSyncNowPressed,
    this.config,
    this.onSettingsPressed,
    this.live,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final status = live != null ? _liveStatusFor(live!, l10n, p) : _statusFor(context, l10n, p);

    return AppCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        children: [
          ProgressRing(
            value: status.progress,
            color: status.color,
            child: status.percentLabel != null
                ? Text(
                    status.percentLabel!,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: p.ink),
                  )
                : Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: status.softColor, shape: BoxShape.circle),
                    child: Icon(status.icon, size: 32, color: status.color, fill: 1),
                  ),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(status.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 6),
          Text(
            status.meta,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
          ),
          const SizedBox(height: 20),
          if (live == null)
            AppButton.primary(
              label: l10n.backupNow,
              icon: Symbols.sync_rounded,
              onPressed: onSyncNowPressed,
            )
          else
            // Pausing is not supported yet (section 9): only cancel.
            AppButton.neutral(
              label: l10n.cancel,
              icon: Symbols.close_rounded,
              onPressed: live!.phase == LiveBackupPhase.cancelling ? null : onCancelPressed,
            ),
          if (config != null) ...[
            const SizedBox(height: 16),
            BackupConditionsRow(config: config!, onSettingsPressed: onSettingsPressed),
          ],
        ],
      ),
    );
  }

  _CardStatus _liveStatusFor(LiveBackup live, AppLocalizations l10n, AppPalette p) {
    final percent = NumberFormat.percentPattern(l10n.localeName).format(live.progress);

    switch (live.phase) {
      case LiveBackupPhase.uploading:
        final remaining = live.remaining;
        final time = remaining == null
            ? null
            : remaining.inMinutes < 1
                ? l10n.remainingLessThanMinute
                : l10n.remainingMinutes(remaining.inMinutes);
        final bytes = live.remainingBytes > 0
            ? l10n.bytesToUpload(FileSizeFormatter.format(live.remainingBytes, locale: l10n.localeName))
            : null;
        return _CardStatus(
          title: l10n.copyingNofM(live.uploaded, live.total),
          // «Quedan unos 3 min · 210 MB por subir», or as much of it as is known.
          meta: time == null && bytes == null
              ? l10n.backupRunning
              : [if (time != null) time, if (bytes != null) bytes].join(' · '),
          icon: Symbols.sync_rounded,
          color: p.accent,
          softColor: p.accentSoft,
          progress: live.progress,
          percentLabel: percent,
        );
      case LiveBackupPhase.preparing:
      case LiveBackupPhase.scanning:
        return _CardStatus(
          title: l10n.preparingBackup,
          meta: live.phase == LiveBackupPhase.scanning ? l10n.lookingForPhotos : l10n.backupRunning,
          icon: Symbols.sync_rounded,
          color: p.accent,
          softColor: p.accentSoft,
          progress: 0,
        );
      case LiveBackupPhase.finishing:
        return _CardStatus(
          title: l10n.finishingBackup,
          meta: l10n.copyingNofM(live.uploaded, live.total),
          icon: Symbols.cloud_sync_rounded,
          color: p.accent,
          softColor: p.accentSoft,
          progress: 1,
        );
      case LiveBackupPhase.cancelling:
        return _CardStatus(
          title: l10n.cancellingBackup,
          meta: l10n.copyingNofM(live.uploaded, live.total),
          icon: Symbols.cancel_rounded,
          color: p.ink2,
          softColor: p.surface2,
          progress: live.progress,
        );
    }
  }

  _CardStatus _statusFor(BuildContext context, AppLocalizations l10n, AppPalette p) {
    final sync = latestSync;

    if (sync == null) {
      return _CardStatus(
        title: l10n.noBackupsYet,
        meta: l10n.noBackupsBody,
        icon: Symbols.cloud_upload_rounded,
        color: p.accent,
        softColor: p.accentSoft,
        progress: 0,
      );
    }

    final relative = DateFormatter.formatRelativeTime(sync.endedAt, context);
    // Lower-cased only when it goes in the middle of a sentence.
    final when = _lowerFirst(relative);

    switch (sync.status) {
      case SynchronizationStatus.completed:
        return _CardStatus(
          title: l10n.allSafe,
          meta: l10n.lastBackupMeta(when, sync.uploadedFiles),
          icon: Symbols.cloud_done_rounded,
          color: p.safe,
          softColor: p.safeSoft,
          progress: 1,
        );
      case SynchronizationStatus.inProgress:
        final progress = sync.totalFiles == 0 ? 0.0 : sync.uploadedFiles / sync.totalFiles;
        return _CardStatus(
          title: l10n.copyingNofM(sync.uploadedFiles, sync.totalFiles),
          meta: l10n.backupRunning,
          icon: Symbols.sync_rounded,
          color: p.accent,
          softColor: p.accentSoft,
          progress: progress,
          percentLabel: NumberFormat.percentPattern(l10n.localeName).format(progress),
        );
      case SynchronizationStatus.failed:
        return _CardStatus(
          title: l10n.backupIncomplete,
          meta: l10n.backupIncompleteMeta(relative, sync.failedFiles),
          icon: Symbols.error_rounded,
          color: p.danger,
          softColor: p.dangerSoft,
          progress: 1,
        );
      case SynchronizationStatus.cancelled:
        return _CardStatus(
          title: l10n.backupCancelledTitle,
          meta: relative,
          icon: Symbols.cancel_rounded,
          color: p.ink2,
          softColor: p.surface2,
          progress: 0,
        );
    }
  }

  /// "Hace 2 horas" → "hace 2 horas" inside a sentence.
  static String _lowerFirst(String text) =>
      text.isEmpty ? text : text[0].toLowerCase() + text.substring(1);
}

class _CardStatus {
  final String title;
  final String meta;
  final IconData icon;
  final Color color;
  final Color softColor;
  final double progress;
  final String? percentLabel;

  const _CardStatus({
    required this.title,
    required this.meta,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.progress,
    this.percentLabel,
  });
}

/// Pills with the backup schedule and conditions plus a settings button.
class BackupConditionsRow extends StatelessWidget {
  final SyncConfig config;
  final VoidCallback? onSettingsPressed;

  const BackupConditionsRow({super.key, required this.config, this.onSettingsPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;
    final time = DateFormat.Hm(locale).format(DateTime(2000, 1, 1, config.syncHour, config.syncMinute));

    final pills = <(IconData, String)>[
      if (!config.autoSyncEnabled)
        (Symbols.sync_disabled_rounded, l10n.autoBackupOff)
      else ...[
        (
          Symbols.schedule_rounded,
          config.isWeeklySync && config.syncDayOfWeek != null
              ? l10n.condWeekly(_weekday(config.syncDayOfWeek!, locale), time)
              : l10n.condDaily(time),
        ),
        (
          Symbols.wifi_rounded,
          config.requiresWifiOnly ? l10n.condWifi : l10n.condAnyNetwork,
        ),
        if (config.requiresBatteryCondition) (Symbols.battery_charging_full_rounded, l10n.condBattery),
      ],
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (icon, label) in pills) _ConditionPill(icon: icon, label: label),
        if (onSettingsPressed != null)
          IconCircleButton(
            icon: Symbols.tune_rounded,
            size: 30,
            iconSize: 16,
            tooltip: l10n.backupSettings,
            onPressed: onSettingsPressed,
          ),
      ],
    );
  }

  /// Short capitalized weekday ("Sáb", "Sat") for 1 (Monday) … 7 (Sunday).
  static String _weekday(int dayOfWeek, String locale) {
    // 2024-01-01 was a Monday.
    final name = DateFormat.E(locale).format(DateTime(2024, 1, dayOfWeek));
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }
}

class _ConditionPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ConditionPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      constraints: const BoxConstraints(minHeight: 30),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: p.ink2),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink)),
        ],
      ),
    );
  }
}
