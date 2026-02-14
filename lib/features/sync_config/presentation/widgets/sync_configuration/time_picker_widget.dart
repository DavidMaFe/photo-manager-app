import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class TimePickerWidget extends StatelessWidget {
  final TimeOfDay time;

  const TimePickerWidget({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(
          l10n.syncTimeTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(l10n.syncTimeDescription),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time.format(context),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.access_time),
          ],
        ),
        onTap: () async {
          final selectedTime = await showTimePicker(
            context: context,
            initialTime: time,
          );

          if (selectedTime != null) {
            if (context.mounted) {
              context.read<SyncConfigBloc>().add(UpdateSyncTime(selectedTime));
            }
          }
        },
      ),
    );
  }
}
