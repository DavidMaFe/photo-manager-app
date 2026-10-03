import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/widgets/segmented_control.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "Every day" / "Once a week".
class FrequencySelectorWidget extends StatelessWidget {
  final SyncFrequency frequency;

  const FrequencySelectorWidget({super.key, required this.frequency});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SegmentedControl<SyncFrequency>(
      segments: [
        SegmentItem(value: SyncFrequency.daily, label: l10n.everyDay),
        SegmentItem(value: SyncFrequency.weekly, label: l10n.oncePerWeek),
      ],
      selected: frequency,
      onChanged: (value) => context.read<SyncConfigBloc>().add(UpdateSyncFrequency(value)),
    );
  }
}
