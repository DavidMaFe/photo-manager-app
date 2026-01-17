import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_event.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_complete.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_error_view.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/sync_session_fetch_files.dart';
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
            backgroundColor: Color(0xFFF5F5F5),
            appBar: AppBar(
              title: Text(l10n.syncSessionTitle),
              backgroundColor: PhotoManagerColors.primary,
              foregroundColor: Colors.white,
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

      final shouldCancel = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.syncSessionCancelWarning),
            content: Text(
              state is SyncSessionUploading
                ? l10n.syncSessionCancelDescription
                : l10n.syncSessionCancelShortDescription
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text('No')
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: Color(0xFFF44336)),
                child: Text(l10n.syncSessionCancelConfirm),
              )
            ],
          )
      );

      if(shouldCancel == true && context.mounted) {
        context.read<SyncSessionBloc>().add(const SyncSessionCancelled());
      }

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
      return SyncSessionErrorView(
        message: state.failure.code!,
        onRetry: () {
          context.read<SyncSessionBloc>().add(const SyncSessionRetried());
        },
      );
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildCancelledView(BuildContext context, SyncSessionCancelling state) {
    return CircularProgressIndicator();
  }
}