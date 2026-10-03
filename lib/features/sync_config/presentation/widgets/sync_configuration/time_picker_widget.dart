import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "Time" row with a pill that opens the (themed) time picker.
class TimePickerWidget extends StatelessWidget {
  final TimeOfDay time;

  const TimePickerWidget({super.key, required this.time});

  static String format(TimeOfDay time, String locale) =>
      DateFormat.Hm(locale).format(DateTime(2000, 1, 1, time.hour, time.minute));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return Row(
      children: [
        Expanded(
          child: Text(l10n.time, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink)),
        ),
        AppButton.neutral(
          label: format(time, l10n.localeName),
          size: AppButtonSize.small,
          onPressed: () async {
            final selectedTime = await showTimePicker(context: context, initialTime: time);
            if (selectedTime != null && context.mounted) {
              context.read<SyncConfigBloc>().add(UpdateSyncTime(selectedTime));
            }
          },
        ),
      ],
    );
  }
}
