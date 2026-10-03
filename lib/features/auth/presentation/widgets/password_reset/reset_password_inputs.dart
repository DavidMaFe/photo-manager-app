import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_password_field.dart';
import 'package:photo_manager_app/features/auth/presentation/utils/auth_validators.dart';

import '../../../../../l10n/app_localizations.dart';


class ResetPasswordInputs extends StatelessWidget {

  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool enabled;

  const ResetPasswordInputs({
    super.key,
    required this.newPasswordController,
    required this.confirmPasswordController,
    this.enabled = true
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPasswordField(
            label: l10n.newPasswordLabel,
            controller: newPasswordController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            enabled: enabled,
            showTooltip: l10n.showPassword,
            hideTooltip: l10n.hidePassword,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.errorNewPasswordRequired;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          AppPasswordField(
            label: l10n.confirmNewPasswordLabel,
            controller: confirmPasswordController,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            enabled: enabled,
            showTooltip: l10n.showPassword,
            hideTooltip: l10n.hidePassword,
            validator: (value) =>
                AuthValidators.confirmation(l10n, value, newPasswordController.text),
          ),
        ],
      ),
    );
  }
}
