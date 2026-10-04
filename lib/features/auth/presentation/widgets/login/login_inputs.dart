import 'package:photo_manager_app/config/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_password_field.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/features/auth/presentation/utils/auth_validators.dart';

import '../../../../../l10n/app_localizations.dart';


class LoginInputs extends StatelessWidget {

  final TextEditingController emailInputController;
  final TextEditingController passwordInputController;
  final VoidCallback onForgotPassword;
  final VoidCallback? onSubmitted;
  final bool enabled;

  const LoginInputs({
    super.key,
    required this.emailInputController,
    required this.passwordInputController,
    required this.onForgotPassword,
    this.onSubmitted,
    this.enabled = true
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: l10n.emailLabel,
            controller: emailInputController,
            hintText: l10n.emailPlaceholder,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            enabled: enabled,
            validator: (value) => AuthValidators.email(l10n, value),
          ),

          const SizedBox(height: 16),

          AppPasswordField(
            label: l10n.passwordLabel,
            labelTrailing: TextButton(
              onPressed: enabled ? onForgotPassword : null,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 32),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: AppTypography.button(13),
              ),
              child: Text(l10n.forgotPassword),
            ),
            controller: passwordInputController,
            textInputAction: TextInputAction.done,
            enabled: enabled,
            showTooltip: l10n.showPassword,
            hideTooltip: l10n.hidePassword,
            onFieldSubmitted: (_) => onSubmitted?.call(),
            validator: (value) => AuthValidators.password(l10n, value),
          ),
        ],
      ),
    );
  }
}
