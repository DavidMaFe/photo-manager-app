import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/get_sync_config_use_case.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Loads the backup configuration once for the profile rows.
class SyncConfigLoader extends StatefulWidget {
  final Widget Function(BuildContext context, SyncConfig? config, bool loading) builder;

  /// Defaults to the registered [GetSyncConfigUseCase].
  final Future<SyncConfig?> Function()? load;

  const SyncConfigLoader({super.key, required this.builder, this.load});

  @override
  State<SyncConfigLoader> createState() => SyncConfigLoaderState();
}

class SyncConfigLoaderState extends State<SyncConfigLoader> {
  SyncConfig? _config;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// Reads the configuration again (e.g. after editing it).
  Future<void> reload() async {
    try {
      final config = await (widget.load ?? () => sl<GetSyncConfigUseCase>()())();
      if (mounted) setState(() => _config = config);
    } catch (_) {
      // The rows fall back to the "off" summary.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _config, _loading);
}

/// Short texts describing the backup configuration.
class SyncConfigSummary {
  /// "Daily at 03:00 · Wi-Fi only".
  static String schedule(SyncConfig? config, AppLocalizations l10n) {
    if (config == null || !config.autoSyncEnabled) return l10n.autoBackupOff;

    final locale = l10n.localeName;
    final time = DateFormat.Hm(locale).format(DateTime(2000, 1, 1, config.syncHour, config.syncMinute));
    final when = config.isWeeklySync && config.syncDayOfWeek != null
        ? l10n.weeklyAt(_weekday(config.syncDayOfWeek!, locale), time)
        : l10n.dailyAt(time);
    final network = config.requiresWifiOnly ? l10n.condWifi : l10n.condAnyNetwork;
    return '$when · $network';
  }

  /// "Failures only", "All", "Finished only" or "Off".
  static String notifications(SyncConfig? config, AppLocalizations l10n) {
    if (config == null) return l10n.notifOff;
    if (config.notifyOnSuccess && config.notifyOnFailure) return l10n.notifAll;
    if (config.notifyOnFailure) return l10n.notifOnlyFailures;
    if (config.notifyOnSuccess) return l10n.notifOnlySuccess;
    return l10n.notifOff;
  }

  /// Full capitalized weekday for 1 (Monday) … 7 (Sunday).
  static String _weekday(int dayOfWeek, String locale) {
    // 2024-01-01 was a Monday.
    final name = DateFormat.EEEE(locale).format(DateTime(2024, 1, dayOfWeek));
    return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
  }
}
