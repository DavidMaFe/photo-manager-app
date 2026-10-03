import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_event.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_complete.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_fetch_files.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/dialogs/cancel_sync_confirmation_dialog.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_init.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_uploading_files.dart';

import '../../../../l10n/app_localizations.dart';
import '../widgets/sync_session_success_view.dart';


class SyncSessionProcessPage extends StatelessWidget {
  
  const SyncSessionProcessPage({super.key});
  
  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SyncSessionBloc, SyncSessionState>(
      builder: (context, state) {
        final canPopDirectly = _canPopDirectly(state);

        return PopScope(
          canPop: canPopDirectly,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            if (didPop) return;
            await _handleBackPressed(context, state, l10n);
          },
          child: Scaffold(
            backgroundColor: context.palette.surface2,
            appBar: AppBar(
              title: Text(l10n.syncSessionTitle),
              backgroundColor: context.palette.accent,
              foregroundColor: context.palette.onAccent,
              elevation: 0,
              automaticallyImplyLeading: canPopDirectly,
            ),
            body: _buildViewForState(context, state),
          ),
        );
      }
    );
  }

  bool _canPopDirectly(SyncSessionState state) {
    return state is SyncSessionSuccess || state is SyncSessionCancelling ||
        state is SyncSessionError || state is SyncSessionInitial;
  }

  Future<void> _handleBackPressed(BuildContext context, SyncSessionState state, AppLocalizations l10n) async {

    if(state is SyncSessionStarting || state is SyncSessionFetchingFiles || state is SyncSessionUploading || state is SyncSessionCompleting) {

      CancelSyncConfirmationDialog.show(
        context: context,
        onConfirm: () {
          if (context.mounted) {
            context.read<SyncSessionBloc>().add(const SyncSessionCancelled());
          }
        },
      );

    }
  }

  Widget _buildViewForState(BuildContext context, SyncSessionState state) {

    if (state is SyncSessionStarting) {
      return const SyncSessionInit();
    }

    if (state is SyncSessionFetchingFiles) {
      return const SyncSessionFetchFiles();
    }

    if (state is SyncSessionUploading) {
      return SyncSessionUploadingFiles(
          uploadCount: state.uploadCount,
          totalCount: state.totalCount
      );
    }

    if (state is SyncSessionCompleting) {
      return const SyncSessionComplete();
    }

    if (state is SyncSessionSuccess) {
      return SyncSessionSuccessView(result: state.result);
    }

    if (state is SyncSessionCancelling) {
      return _buildCancelledView(context, state);
    }

    if (state is SyncSessionError) {
      return ErrorDisplay(
        failure: state.failure,
        onRetry: () {
          context.read<SyncSessionBloc>().add(SyncSessionRetried(context));
        },
      );
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildCancelledView(BuildContext context, SyncSessionCancelling state) {
    return const CircularProgressIndicator();
  }
}