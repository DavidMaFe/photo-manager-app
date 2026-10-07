import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/recovery_words_input.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/password_reset_layout.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/reset_password_inputs.dart';
import '../../../../core/errors/service/error_notification_service.dart';
import '../../../../l10n/app_localizations.dart';


class ResetPasswordPage extends StatefulWidget {

  final String email;
  final String code;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.code
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}


class _ResetPasswordPageState extends State<ResetPasswordPage> {

  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _recoveryWordsController = TextEditingController();

  /// Answer to "Do you have your 24 recovery words?"; null until the user answers.
  bool? _hasRecoveryWords;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _recoveryWordsController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (_hasRecoveryWords == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.resetHaveWordsQuestion)));
      return;
    }
    if (!formValid) {
      return;
    }

    if (_hasRecoveryWords == false) {
      // Without the words the photos become locked: the user must accept it knowingly
      final l10n = AppLocalizations.of(context)!;
      final confirmed = await AppDialog.show(
        context: context,
        tone: AppDialogTone.review,
        icon: Symbols.lock_rounded,
        title: l10n.resetWithoutWordsTitle,
        message: l10n.resetWithoutWordsMessage,
        primaryLabel: l10n.resetWithoutWordsConfirm,
        secondaryLabel: l10n.cancel,
      );
      if (confirmed != true || !mounted) return;
    }

    if (!mounted) return;
    context.read<AuthBloc>().add(
      NewPasswordSubmitted(
        email: widget.email,
        code: widget.code,
        newPassword: _newPasswordController.text,
        recoveryWords: _hasRecoveryWords == true ? RecoveryWordsInput.parse(_recoveryWordsController.text) : null,
      )
    );
  }

  Widget _recoveryWordsQuestion(AppLocalizations l10n, bool enabled) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.resetHaveWordsQuestion,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: palette.ink)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _choice(l10n.resetHaveWordsYes, true, enabled, const ValueKey('reset-has-words-yes')),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _choice(l10n.resetHaveWordsNo, false, enabled, const ValueKey('reset-has-words-no')),
            ),
          ],
        ),
        if (_hasRecoveryWords == true) ...[
          const SizedBox(height: 12),
          RecoveryWordsInput(controller: _recoveryWordsController, enabled: enabled),
        ],
        if (_hasRecoveryWords == false) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: palette.reviewSoft, borderRadius: BorderRadius.circular(12)),
            child: Text(l10n.resetWithoutWordsMessage, style: TextStyle(color: palette.reviewInk)),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _choice(String label, bool value, bool enabled, Key key) {
    final selected = _hasRecoveryWords == value;
    return selected
        ? AppButton.primary(key: key, label: label, onPressed: enabled ? () {} : null)
        : AppButton.secondary(
            key: key,
            label: label,
            onPressed: enabled ? () => setState(() => _hasRecoveryWords = value) : null,
          );
  }

  void _handleBack() {
    context.go(RoutePaths.validateResetCode, extra: widget.email);
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetSuccessful) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.accountLocked ? l10n.resetAccountLockedNotice : l10n.passwordResetSuccess))
          );

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              context.go(RoutePaths.login);
            }
          });
        }

        if (state is AuthError) {
          ErrorNotificationService.showError(
            context,
            state.failure,
            onRetry: _handleResetPassword
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return PasswordResetLayout(
          step: 3,
          icon: Symbols.password_rounded,
          title: l10n.newPasswordHeadline,
          description: l10n.newPasswordBody,
          primaryLabel: l10n.resetPasswordButton,
          onPrimary: _handleResetPassword,
          isLoading: isLoading,
          onBack: _handleBack,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _recoveryWordsQuestion(l10n, !isLoading),
                ResetPasswordInputs(
                  newPasswordController: _newPasswordController,
                  confirmPasswordController: _confirmPasswordController,
                  enabled: !isLoading
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
