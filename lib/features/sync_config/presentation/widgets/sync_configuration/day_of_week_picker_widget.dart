import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Seven day boxes (Monday first) for weekly backups.
class DayOfWeekPickerWidget extends StatelessWidget {
  /// 1 (Monday) … 7 (Sunday).
  final int? selectedDay;

  const DayOfWeekPickerWidget({super.key, required this.selectedDay});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final locale = l10n.localeName;

    return Row(
      children: [
        for (var day = 1; day <= 7; day++) ...[
          if (day > 1) const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              button: true,
              selected: day == selectedDay,
              // 2024-01-01 was a Monday.
              label: DateFormat.EEEE(locale).format(DateTime(2024, 1, day)),
              excludeSemantics: true,
              child: Material(
                color: day == selectedDay ? p.accent : p.surface2,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.read<SyncConfigBloc>().add(UpdateSyncDayOfWeek(day)),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Center(
                      child: Text(
                        DateFormat.EEEEE(locale).format(DateTime(2024, 1, day)).toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: day == selectedDay ? p.onAccent : p.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
