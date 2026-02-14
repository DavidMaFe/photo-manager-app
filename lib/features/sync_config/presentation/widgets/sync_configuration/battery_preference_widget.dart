import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/battery_preference.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class BatteryPreferenceWidget extends StatelessWidget {
  final BatteryPreference preference;

  const BatteryPreferenceWidget({
    super.key,
    required this.preference,
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
              l10n.batteryPreferenceTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            RadioListTile<BatteryPreference>(
              title: Text(l10n.batteryPreferenceAny),
              subtitle: Text(l10n.batteryPreferenceAnyDescription),
              value: BatteryPreference.any,
              groupValue: preference,
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<SyncConfigBloc>()
                      .add(UpdateBatteryPreference(value));
                }
              },
            ),
            RadioListTile<BatteryPreference>(
              title: Text(l10n.batteryPreferenceCharging),
              subtitle: Text(l10n.batteryPreferenceChargingDescription),
              value: BatteryPreference.chargingOrAbove15Percent,
              groupValue: preference,
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<SyncConfigBloc>()
                      .add(UpdateBatteryPreference(value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
