import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_typography.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/core/widgets/otp_field.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/password_reset_layout.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Second factor of a login from a device that is not trusted: the 6-digit code emailed to the account, which can be
/// sent again after a minute, or, with the authenticator app on, a code of the app or a backup code. Going back (or
/// the system back) cancels the login.
class LoginSecondFactorStep extends StatefulWidget {
  /// Seconds before the code can be sent again (the server allows one a minute).
  static const int resendCooldownSeconds = 60;
  static const int codeLength = 6;

  final AuthSecondFactorRequired state;

  const LoginSecondFactorStep({super.key, required this.state});

  @override
  State<LoginSecondFactorStep> createState() => _LoginSecondFactorStepState();
}

class _LoginSecondFactorStepState extends State<LoginSecondFactorStep> {
  final _codeController = TextEditingController();
  final _backupCodeController = TextEditingController();
  Timer? _resendTimer;
  int _secondsLeft = LoginSecondFactorStep.resendCooldownSeconds;

  /// Only with the authenticator app: a backup code instead of a code of the app.
  bool _useBackupCode = false;

  bool get _usesApp => widget.state.challenge.usesAuthenticatorApp;

  bool get _isCodeComplete => _useBackupCode
      ? _backupCodeController.text.trim().isNotEmpty
      : _codeController.text.length == LoginSecondFactorStep.codeLength;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    _backupCodeController.addListener(_onCodeChanged);
    if (!_usesApp) _startResendCountdown();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _backupCodeController.removeListener(_onCodeChanged);
    _backupCodeController.dispose();
    super.dispose();
  }

  void _onCodeChanged() => setState(() {});

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = LoginSecondFactorStep.resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  void _handleVerify() {
    if (!_isCodeComplete || widget.state.working) return;
    final code = _useBackupCode ? _backupCodeController.text.trim() : _codeController.text;
    context.read<AuthBloc>().add(LoginSecondFactorSubmitted(code));
  }

  void _toggleBackupCode() {
    setState(() => _useBackupCode = !_useBackupCode);
    _codeController.clear();
    _backupCodeController.clear();
  }

  void _handleResend() {
    context.read<AuthBloc>().add(LoginSecondFactorResendRequested());
    _codeController.clear();
    _startResendCountdown();
  }

  void _handleBack() => context.read<AuthBloc>().add(LoginSecondFactorCancelled());

  static String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  /// "... We've sent a 6-digit code to **d***@outlook.es**".
  InlineSpan _descriptionSpan(AppLocalizations l10n, String emailHint) {
    final text = l10n.loginSecondFactorBody(emailHint);
    final index = text.indexOf(emailHint);
    if (index < 0) return TextSpan(text: text);
    return TextSpan(children: [
      TextSpan(text: text.substring(0, index)),
      TextSpan(text: emailHint, style: TextStyle(fontWeight: FontWeight.w700, color: context.palette.ink)),
      TextSpan(text: text.substring(index + emailHint.length)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final state = widget.state;
    final canResend = _secondsLeft <= 0 && !state.working;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: PasswordResetLayout(
        icon: Symbols.verified_user_rounded,
        title: _usesApp ? l10n.loginTotpTitle : l10n.loginSecondFactorTitle,
        description: _usesApp ? (_useBackupCode ? l10n.loginBackupCodeBody : l10n.loginTotpBody) : null,
        descriptionSpan: _usesApp ? null : _descriptionSpan(l10n, state.challenge.emailHint),
        primaryLabel: l10n.validateCodeButton,
        onPrimary: _isCodeComplete && !state.working ? _handleVerify : null,
        isLoading: state.working,
        onBack: _handleBack,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_useBackupCode)
              AppTextField(
                key: const ValueKey('login-backup-code-field'),
                controller: _backupCodeController,
                label: l10n.loginBackupCodeLabel,
                hintText: 'abcde-fghij',
                autofocus: true,
                errorText: state.failure == null ? null : '',
              )
            else
              OtpField(
                length: LoginSecondFactorStep.codeLength,
                controller: _codeController,
                autofocus: true,
                hasError: state.failure != null,
                onCompleted: (_) => _handleVerify(),
              ),
            const SizedBox(height: 16),
            if (_usesApp)
              Center(
                child: TextButton(
                  key: const ValueKey('login-second-factor-backup-code'),
                  onPressed: state.working ? null : _toggleBackupCode,
                  child: Text(_useBackupCode ? l10n.loginUseAppCode : l10n.loginUseBackupCode),
                ),
              )
            else
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.didNotReceiveCode,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: palette.ink2),
                  ),
                  TextButton(
                    key: const ValueKey('login-second-factor-resend'),
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
                key: const ValueKey('login-second-factor-back'),
                onPressed: state.working ? null : _handleBack,
                child: Text(l10n.loginSecondFactorBack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
