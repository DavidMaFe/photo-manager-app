import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/widgets/permission/background_task_permission_helper.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class AutoSyncToggleWidget extends StatelessWidget {
  final bool isEnabled;

  const AutoSyncToggleWidget({
    super.key,
    required this.isEnabled,
  });

  /// When the user enables auto-sync on Android, request battery optimization
  /// exemption so that WorkManager tasks are not killed by the OS.
  /// The sync is enabled regardless of whether the exemption is granted —
  /// we still schedule the task, but without the exemption it may not run
  /// reliably on some devices.
  Future<void> _onToggleChanged(BuildContext context, bool value) async {
    if (value && Platform.isAndroid) {
      final isExempt =
          await BackgroundTaskPermissionHelper.isBackgroundTaskEnabled();

      if (!isExempt && context.mounted) {
        // Request battery optimization exemption via the system dialog.
        // This is required for WorkManager tasks to run reliably on physical
        // Android devices. Without it, the OS kills background tasks.
        await BackgroundTaskPermissionHelper.requestBatteryOptimizationExemption();
      }
    }

    if (context.mounted) {
      context.read<SyncConfigBloc>().add(ToggleAutoSync(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: Text(
          l10n.enableAutoSync,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          isEnabled ? l10n.autoSyncEnabled : l10n.autoSyncDisabled,
        ),
        value: isEnabled,
        onChanged: (value) => _onToggleChanged(context, value),
      ),
    );
  }
}
