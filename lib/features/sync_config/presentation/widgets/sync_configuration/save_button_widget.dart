import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "Save changes" anchored at the bottom; enabled only with pending changes.
class SaveButtonWidget extends StatelessWidget {
  final bool isSaving;
  final bool hasChanges;

  const SaveButtonWidget({super.key, required this.isSaving, this.hasChanges = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.background,
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: AppButton.primary(
            label: l10n.saveChanges,
            loading: isSaving,
            onPressed: hasChanges ? () => context.read<SyncConfigBloc>().add(SaveSyncConfig()) : null,
          ),
        ),
      ),
    );
  }
}
