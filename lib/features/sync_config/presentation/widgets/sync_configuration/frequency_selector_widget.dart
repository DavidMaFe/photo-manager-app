import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/segmented_control.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "Every day" / "Once a week". Without [dailyAllowed] (free plan) choosing "Every day" explains that the plan backs
/// up weekly and offers the plans, without changing the frequency.
class FrequencySelectorWidget extends StatelessWidget {
  final SyncFrequency frequency;
  final bool dailyAllowed;

  const FrequencySelectorWidget({super.key, required this.frequency, this.dailyAllowed = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SegmentedControl<SyncFrequency>(
      segments: [
        SegmentItem(value: SyncFrequency.daily, label: l10n.everyDay),
        SegmentItem(value: SyncFrequency.weekly, label: l10n.oncePerWeek),
      ],
      selected: frequency,
      onChanged: (value) {
        if (value.isDaily && !dailyAllowed) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(l10n.planWeeklyOnly),
              action: SnackBarAction(label: l10n.planSeePlans, onPressed: () => context.goNamed(RouteNames.plans)),
            ));
          return;
        }
        context.read<SyncConfigBloc>().add(UpdateSyncFrequency(value));
      },
    );
  }
}
