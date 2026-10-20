import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_typography.dart';
import 'package:photo_manager_app/core/widgets/otp_field.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/registration_email_cubit.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/password_reset_layout.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Step 2 of the registration: the 6-digit code emailed to the address. It can be sent again after a minute.
class RegisterCodeStep extends StatefulWidget {
  /// Seconds before the code can be sent again.
  static const int resendCooldownSeconds = 60;
  static const int codeLength = 6;

  const RegisterCodeStep({super.key});

  @override
  State<RegisterCodeStep> createState() => _RegisterCodeStepState();
}

class _RegisterCodeStepState extends State<RegisterCodeStep> {
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _secondsLeft = RegisterCodeStep.resendCooldownSeconds;

  bool get _isCodeComplete => _codeController.text.length == RegisterCodeStep.codeLength;

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
    setState(() => _secondsLeft = RegisterCodeStep.resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  void _handleVerify() {
    if (!_isCodeComplete) return;
    context.read<RegistrationEmailCubit>().verifyCode(_codeController.text);
  }

  void _handleResend() {
    context.read<RegistrationEmailCubit>().resendCode();
    _codeController.clear();
    _startResendCountdown();
  }

  static String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  /// "We've sent a 6-digit code to **email**".
  InlineSpan _descriptionSpan(AppLocalizations l10n, String email) {
    final text = l10n.codeSentTo(email);
    final index = text.indexOf(email);
    if (index < 0) return TextSpan(text: text);
    return TextSpan(children: [
      TextSpan(text: text.substring(0, index)),
      TextSpan(text: email, style: TextStyle(fontWeight: FontWeight.w700, color: context.palette.ink)),
      TextSpan(text: text.substring(index + email.length)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final cubit = context.read<RegistrationEmailCubit>();
    final state = context.watch<RegistrationEmailCubit>().state;
    final canResend = _secondsLeft <= 0 && !state.loading;

    return PasswordResetLayout(
      step: 2,
      icon: Symbols.mark_email_unread_rounded,
      title: l10n.checkYourEmail,
      descriptionSpan: _descriptionSpan(l10n, state.email),
      primaryLabel: l10n.validateCodeButton,
      onPrimary: _isCodeComplete ? _handleVerify : null,
      isLoading: state.loading,
      onBack: cubit.changeEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OtpField(
            length: RegisterCodeStep.codeLength,
            controller: _codeController,
            autofocus: true,
            hasError: state.failure != null,
            onCompleted: (_) => _handleVerify(),
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
                key: const ValueKey('register-resend-code'),
                onPressed: canResend ? _handleResend : null,
                style: TextButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  disabledForegroundColor: palette.ink2,
                  textStyle: AppTypography.button(14).copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                child: Text(
                  canResend ? l10n.resendCodeButton : l10n.resendIn(_formatCountdown(_secondsLeft.clamp(0, 9999))),
                ),
              ),
            ],
          ),
          Center(
            child: TextButton(
              key: const ValueKey('register-change-email'),
              onPressed: state.loading ? null : cubit.changeEmail,
              child: Text(l10n.registerChangeEmail),
            ),
          ),
        ],
      ),
    );
  }
}
