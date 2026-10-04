import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/widgets/app_switch.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "When it finishes" and "If something fails" alert switches.
class NotificationPreferencesWidget extends StatelessWidget {
  final bool notifyOnSuccess;
  final bool notifyOnFailure;

  const NotificationPreferencesWidget({
    super.key,
    required this.notifyOnSuccess,
    required this.notifyOnFailure,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<SyncConfigBloc>();

    return ListRowGroup(
      children: [
        ListRow(
          title: l10n.alertSuccess,
          subtitle: l10n.alertSuccessBody,
          trailing: AppSwitch(
            value: notifyOnSuccess,
            semanticLabel: l10n.alertSuccess,
            onChanged: (value) => bloc.add(ToggleNotifyOnSuccess(value)),
          ),
        ),
        ListRow(
          title: l10n.alertFailure,
          subtitle: l10n.alertFailureBody,
          trailing: AppSwitch(
            value: notifyOnFailure,
            semanticLabel: l10n.alertFailure,
            onChanged: (value) => bloc.add(ToggleNotifyOnFailure(value)),
          ),
        ),
      ],
    );
  }
}
