import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_bloc.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_state.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/share_cubit.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Messages of the downloads and of sharing anywhere in the app: «Downloading 3 items», «Already on this phone»,
/// failures, and the dialog «Preparing 3 of 10…» while the originals to share are decrypted.
class DownloadFeedbackListener extends StatefulWidget {
  final Widget child;

  const DownloadFeedbackListener({super.key, required this.child});

  @override
  State<DownloadFeedbackListener> createState() => _DownloadFeedbackListenerState();
}

class _DownloadFeedbackListenerState extends State<DownloadFeedbackListener> {
  final ValueNotifier<SharePreparing?> _preparing = ValueNotifier(null);
  bool _dialogOpen = false;

  @override
  void dispose() {
    _preparing.dispose();
    super.dispose();
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<DownloadProgressBloc, DownloadProgressState>(
          listenWhen: (previous, current) => previous.outcomeSerial != current.outcomeSerial,
          listener: (context, state) {
            final outcome = state.outcome!;
            _snack(context,
                outcome.started == 0 ? l10n.downloadAllOnDevice(outcome.requested) : l10n.downloadStarted(outcome.started));
          },
        ),
        BlocListener<DownloadProgressBloc, DownloadProgressState>(
          listenWhen: (previous, current) => current.failure != null && previous.failure != current.failure,
          listener: (context, state) => _snack(context, FailureMessageHelper.getMessage(context, state.failure!)),
        ),
        BlocListener<ShareCubit, ShareState>(
          listener: (context, state) {
            if (state is SharePreparing) {
              _preparing.value = state;
              if (!_dialogOpen) _openPreparingDialog(context);
            } else {
              _closePreparingDialog(context);
              if (state is ShareError) _snack(context, FailureMessageHelper.getMessage(context, state.failure));
            }
          },
        ),
      ],
      child: widget.child,
    );
  }

  void _openPreparingDialog(BuildContext context) {
    _dialogOpen = true;
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: ValueListenableBuilder<SharePreparing?>(
            valueListenable: _preparing,
            builder: (context, preparing, _) => Row(
              children: [
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(AppLocalizations.of(context)!
                      .sharePreparing(preparing?.prepared ?? 0, preparing?.total ?? 0)),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() => _dialogOpen = false);
  }

  void _closePreparingDialog(BuildContext context) {
    if (_dialogOpen) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
