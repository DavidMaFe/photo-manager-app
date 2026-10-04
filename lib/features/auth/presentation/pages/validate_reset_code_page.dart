import 'package:photo_manager_app/config/theme/app_typography.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/otp_field.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/password_reset_layout.dart';

import '../../../../core/errors/service/error_notification_service.dart';
import '../../../../l10n/app_localizations.dart';


class ValidateResetCodePage extends StatefulWidget {

  /// Seconds before the code can be sent again.
  static const int resendCooldownSeconds = 60;
  static const int codeLength = 6;

  final String email;

  const ValidateResetCodePage({super.key, required this.email});

  @override
  State<ValidateResetCodePage> createState() => _ValidateResetCodePageState();
}

class _ValidateResetCodePageState extends State<ValidateResetCodePage> {

  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _secondsLeft = ValidateResetCodePage.resendCooldownSeconds;

  bool get _isCodeComplete => _codeController.text.length == ValidateResetCodePage.codeLength;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() => setState(() {});

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = ValidateResetCodePage.resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  void _handleValidateCode() {
    if (!_isCodeComplete) return;
    context.read<AuthBloc>().add(
      ResetCodeValidationRequested(
        email: widget.email,
        code: _codeController.text.trim()
      )
    );
  }

  void _handleResendCode() {
    context.read<AuthBloc>().add(
      PasswordResetCodeResendRequested(email: widget.email)
    );
    _startResendCountdown();
  }

  void _handleBack() {
    context.go(RoutePaths.requestPasswordReset);
  }

  static String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  /// "We've sent a 6-digit code to **email**".
  InlineSpan _descriptionSpan(AppLocalizations l10n) {
    final text = l10n.codeSentTo(widget.email);
    final index = text.indexOf(widget.email);
    if (index < 0) return TextSpan(text: text);
    return TextSpan(children: [
      TextSpan(text: text.substring(0, index)),
      TextSpan(
        text: widget.email,
        style: TextStyle(fontWeight: FontWeight.w700, color: context.palette.ink),
      ),
      TextSpan(text: text.substring(index + widget.email.length)),
    ]);
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ResetCodeValidated) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.go(RoutePaths.resetPassword, extra: {
                'email': state.email,
                'code': state.code,
              });
            }
          });
        }

        if (state is PasswordResetEmailSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.codeResent))
          );
        }

        if (state is AuthError) {
          ErrorNotificationService.showError(
            context,
            state.failure,
            onRetry: _handleValidateCode
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final canResend = _secondsLeft <= 0 && !isLoading;

        return PasswordResetLayout(
          step: 2,
          icon: Symbols.mark_email_unread_rounded,
          title: l10n.checkYourEmail,
          descriptionSpan: _descriptionSpan(l10n),
          primaryLabel: l10n.validateCodeButton,
          onPrimary: _isCodeComplete ? _handleValidateCode : null,
          isLoading: isLoading,
          onBack: _handleBack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OtpField(
                length: ValidateResetCodePage.codeLength,
                controller: _codeController,
                autofocus: true,
                hasError: state is AuthError,
                onCompleted: (_) => _handleValidateCode(),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.didNotReceiveCode,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: palette.ink2),
                  ),
                  TextButton(
                    onPressed: canResend ? _handleResendCode : null,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      disabledForegroundColor: palette.ink2,
                      textStyle: AppTypography.button(14).copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    child: Text(
                      canResend
                          ? l10n.resendCodeButton
                          : l10n.resendIn(_formatCountdown(_secondsLeft.clamp(0, 9999))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
