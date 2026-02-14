import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class AutoSyncToggleWidget extends StatelessWidget {
  final bool isEnabled;

  const AutoSyncToggleWidget({
    super.key,
    required this.isEnabled,
  });

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
        onChanged: (value) {
          context.read<SyncConfigBloc>().add(ToggleAutoSync(value));
        },
      ),
    );
  }
}
