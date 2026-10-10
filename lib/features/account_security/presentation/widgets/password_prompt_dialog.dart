import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/app_password_field.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/recovery_words_input.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// What the user typed in [PasswordPromptDialog]. [words] is empty unless the dialog asked for them.
class PasswordPromptResult {
  final String password;
  final List<String> words;

  const PasswordPromptResult({required this.password, this.words = const []});
}

/// Asks for the current password (needed to wrap the unlocked keys) and, optionally, the 24 words.
/// Returns null if cancelled or the password is empty.
class PasswordPromptDialog {
  const PasswordPromptDialog._();

  static Future<PasswordPromptResult?> show(BuildContext context,
      {bool askRecoveryWords = false, String? title, String? message, String? cancelLabel}) async {
    final l10n = AppLocalizations.of(context)!;
    var password = '';
    var wordsText = '';
    final confirmed = await AppDialog.show(
      context: context,
      title: title ?? l10n.lockedPasswordPrompt,
      message: message,
      content: _PasswordPromptFields(
        askRecoveryWords: askRecoveryWords,
        onPasswordChanged: (value) => password = value,
        onWordsChanged: (value) => wordsText = value,
      ),
      primaryLabel: l10n.continueLabel,
      secondaryLabel: cancelLabel ?? l10n.cancel,
    );
    if (confirmed != true || password.isEmpty) {
      return null;
    }
    return PasswordPromptResult(password: password, words: RecoveryWordsInput.parse(wordsText));
  }
}

/// Owns the controllers, so they are disposed with the dialog route and not while its closing animation still
/// paints the fields.
class _PasswordPromptFields extends StatefulWidget {
  final bool askRecoveryWords;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onWordsChanged;

  const _PasswordPromptFields({
    required this.askRecoveryWords,
    required this.onPasswordChanged,
    required this.onWordsChanged,
  });

  @override
  State<_PasswordPromptFields> createState() => _PasswordPromptFieldsState();
}

class _PasswordPromptFieldsState extends State<_PasswordPromptFields> {
  final _passwordController = TextEditingController();
  final _wordsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => widget.onPasswordChanged(_passwordController.text));
    _wordsController.addListener(() => widget.onWordsChanged(_wordsController.text));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _wordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.askRecoveryWords) ...[
          RecoveryWordsInput(controller: _wordsController),
          const SizedBox(height: 12),
        ],
        AppPasswordField(
          key: const ValueKey('password-prompt-field'),
          controller: _passwordController,
          label: l10n.passwordLabel,
          showTooltip: l10n.showPassword,
          hideTooltip: l10n.hidePassword,
        ),
      ],
    );
  }
}
