import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class DayOfWeekPickerWidget extends StatelessWidget {
  final int? selectedDay;

  const DayOfWeekPickerWidget({
    super.key,
    this.selectedDay,
  });

  String _getDayName(BuildContext context, int day) {
    final l10n = AppLocalizations.of(context)!;
    switch (day) {
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      case 7:
        return l10n.sunday;
      default:
        return '';
    }
  }

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
              l10n.syncDayOfWeekTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.syncDayOfWeekDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final day = index + 1; // 1-7 (Monday-Sunday)
                final isSelected = selectedDay == day;

                return FilterChip(
                  label: Text(_getDayName(context, day)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context
                          .read<SyncConfigBloc>()
                          .add(UpdateSyncDayOfWeek(day));
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
