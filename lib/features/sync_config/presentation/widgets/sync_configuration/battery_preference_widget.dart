import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/segmented_control.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/battery_preference.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "Battery": always / charging or above 15 %.
class BatteryPreferenceWidget extends StatelessWidget {
  final BatteryPreference preference;

  const BatteryPreferenceWidget({super.key, required this.preference});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.battery, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.palette.ink)),
        const SizedBox(height: 8),
        SegmentedControl<BatteryPreference>(
          segments: [
            SegmentItem(value: BatteryPreference.any, label: l10n.always),
            SegmentItem(value: BatteryPreference.chargingOrAbove15Percent, label: l10n.condBattery),
          ],
          selected: preference,
          onChanged: (value) => context.read<SyncConfigBloc>().add(UpdateBatteryPreference(value)),
        ),
      ],
    );
  }
}
