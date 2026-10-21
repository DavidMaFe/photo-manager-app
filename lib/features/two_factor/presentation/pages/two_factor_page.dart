import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/two_factor/domain/services/two_factor_exporter.dart';
import 'package:photo_manager_app/features/two_factor/presentation/bloc/two_factor_cubit.dart';
import 'package:photo_manager_app/features/two_factor/presentation/widgets/backup_codes_view.dart';
import 'package:photo_manager_app/features/two_factor/presentation/widgets/totp_set_up_view.dart';
import 'package:photo_manager_app/features/two_factor/presentation/widgets/two_factor_status_view.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Profile, Security, Authenticator app: turn it on (set-up and backup codes), new backup codes and turn it off.
class TwoFactorPage extends StatelessWidget {
  /// Replaces the platform one in tests.
  final TwoFactorExporter? exporter;

  const TwoFactorPage({super.key, this.exporter});

  /// Back from the set-up cancels it; from the backup codes, they count as saved; otherwise the page closes.
  void _handleBack(BuildContext context) {
    final cubit = context.read<TwoFactorCubit>();
    switch (cubit.state.view) {
      case TwoFactorView.setUp:
        cubit.cancelSetUp();
      case TwoFactorView.backupCodes:
        cubit.backupCodesSaved();
      default:
        context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final exporter = this.exporter ?? sl<TwoFactorExporter>();

    return BlocConsumer<TwoFactorCubit, TwoFactorState>(
      listenWhen: (previous, current) => current.failure != null || current.notice != null,
      listener: (context, state) {
        final failure = state.failure;
        if (failure != null && state.view != TwoFactorView.error) {
          ErrorNotificationService.showError(context, failure, config: ErrorDisplayConfig.snackBar);
        } else if (state.notice == TwoFactorNotice.disabled) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.twoFactorDisabledMessage)));
        }
        if (state.view != TwoFactorView.error) {
          context.read<TwoFactorCubit>().feedbackShown();
        }
      },
      builder: (context, state) {
        final title = switch (state.view) {
          TwoFactorView.setUp => l10n.twoFactorSetUpTitle,
          _ => l10n.twoFactorTitle,
        };
        return PopScope(
          canPop: state.view != TwoFactorView.setUp && state.view != TwoFactorView.backupCodes,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleBack(context);
          },
          child: Scaffold(
            backgroundColor: p.background,
            appBar: SecondaryTopBar(title: title, onBack: () => _handleBack(context)),
            body: SafeArea(
              top: false,
              child: switch (state.view) {
                TwoFactorView.loading => const Center(child: CircularProgressIndicator()),
                TwoFactorView.error => Padding(
                    padding: const EdgeInsets.all(16),
                    child: ErrorDisplay(
                      failure: state.failure!,
                      onRetry: () => context.read<TwoFactorCubit>().load(),
                    ),
                  ),
                TwoFactorView.status => TwoFactorStatusView(status: state.status!, working: state.working),
                TwoFactorView.setUp => TotpSetUpView(
                    setUp: state.setUp!,
                    working: state.working,
                    hasError: state.failure != null,
                    exporter: exporter,
                  ),
                TwoFactorView.backupCodes => BackupCodesView(codes: state.backupCodes, exporter: exporter),
              },
            ),
          ),
        );
      },
    );
  }
}
