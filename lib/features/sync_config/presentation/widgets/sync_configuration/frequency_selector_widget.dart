import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class FrequencySelectorWidget extends StatelessWidget {
  final SyncFrequency frequency;

  const FrequencySelectorWidget({
    super.key,
    required this.frequency,
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
              l10n.syncFrequencyTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            RadioListTile<SyncFrequency>(
              title: Text(l10n.syncFrequencyDaily),
              value: SyncFrequency.daily,
              groupValue: frequency,
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<SyncConfigBloc>()
                      .add(UpdateSyncFrequency(value));
                }
              },
            ),
            RadioListTile<SyncFrequency>(
              title: Text(l10n.syncFrequencyWeekly),
              value: SyncFrequency.weekly,
              groupValue: frequency,
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<SyncConfigBloc>()
                      .add(UpdateSyncFrequency(value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
