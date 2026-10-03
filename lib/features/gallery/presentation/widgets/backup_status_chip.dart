import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/status_chip.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Backup status pill of the gallery header, fed by [SyncSessionBloc].
class BackupStatusChip extends StatelessWidget {
  final VoidCallback? onTap;

  const BackupStatusChip({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SyncSessionBloc, SyncSessionState>(
      builder: (context, state) {
        final (label, icon, variant) = switch (state) {
          SyncSessionUploading() => (
              l10n.backupInProgress(state.progressPercentage),
              Symbols.sync_rounded,
              StatusChipVariant.accent,
            ),
          SyncSessionStarting() || SyncSessionFetchingFiles() || SyncSessionCompleting() => (
              l10n.backupInProgress(0),
              Symbols.sync_rounded,
              StatusChipVariant.accent,
            ),
          SyncSessionError() => (
              l10n.backupFailed,
              Symbols.error_rounded,
              StatusChipVariant.danger,
            ),
          _ => (
              l10n.backupUpToDate,
              Symbols.cloud_done_rounded,
              StatusChipVariant.safe,
            ),
        };

        return StatusChip(label: label, icon: icon, variant: variant, onTap: onTap);
      },
    );
  }
}
