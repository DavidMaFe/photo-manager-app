import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class NotificationPreferencesWidget extends StatelessWidget {
  final bool notifyOnSuccess;
  final bool notifyOnFailure;

  const NotificationPreferencesWidget({
    super.key,
    required this.notifyOnSuccess,
    required this.notifyOnFailure,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(l10n.notifyOnSuccess),
              subtitle: Text(l10n.notifyOnSuccessDescription),
              value: notifyOnSuccess,
              onChanged: (value) {
                context.read<SyncConfigBloc>().add(ToggleNotifyOnSuccess(value));
              },
            ),
            const Divider(),
            SwitchListTile(
              title: Text(l10n.notifyOnFailure),
              subtitle: Text(l10n.notifyOnFailureDescription),
              value: notifyOnFailure,
              onChanged: (value) {
                context.read<SyncConfigBloc>().add(ToggleNotifyOnFailure(value));
              },
            ),
          ],
        ),
      ),
    );
  }
}
