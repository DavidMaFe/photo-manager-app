import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/app_password_field.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// The password and a code (of the authenticator app, or a backup code) typed in [PasswordAndCodeDialog].
class PasswordAndCode {
  final String password;
  final String code;

  const PasswordAndCode({required this.password, required this.code});
}

/// Asks for the password and a code before turning the authenticator app off or renewing the backup codes. Returns
/// null if cancelled or a field is empty.
class PasswordAndCodeDialog {
  const PasswordAndCodeDialog._();

  static Future<PasswordAndCode?> show(BuildContext context, {required String title, bool destructive = false}) async {
    final l10n = AppLocalizations.of(context)!;
    var password = '';
    var code = '';
    final confirmed = await AppDialog.show(
      context: context,
      title: title,
      message: l10n.twoFactorPromptBody,
      content: _Fields(onPasswordChanged: (value) => password = value, onCodeChanged: (value) => code = value),
      primaryLabel: l10n.continueLabel,
      secondaryLabel: l10n.cancel,
      destructive: destructive,
    );
    if (confirmed != true || password.isEmpty || code.trim().isEmpty) {
      return null;
    }
    return PasswordAndCode(password: password, code: code.trim());
  }
}

/// Owns the controllers, so they are disposed with the dialog route.
class _Fields extends StatefulWidget {
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onCodeChanged;

  const _Fields({required this.onPasswordChanged, required this.onCodeChanged});

  @override
  State<_Fields> createState() => _FieldsState();
}

class _FieldsState extends State<_Fields> {
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => widget.onPasswordChanged(_passwordController.text));
    _codeController.addListener(() => widget.onCodeChanged(_codeController.text));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppPasswordField(
          key: const ValueKey('two-factor-password-field'),
          controller: _passwordController,
          label: l10n.passwordLabel,
          showTooltip: l10n.showPassword,
          hideTooltip: l10n.hidePassword,
        ),
        const SizedBox(height: 12),
        AppTextField(
          key: const ValueKey('two-factor-code-field'),
          controller: _codeController,
          label: l10n.twoFactorCodeLabel,
          hintText: '123456',
          autofillHints: const [AutofillHints.oneTimeCode],
        ),
      ],
    );
  }
}
