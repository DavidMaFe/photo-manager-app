import 'package:photo_manager_app/features/auth/presentation/utils/auth_validators.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_password_field.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Optional password change: current, new and confirmation.
/// Fields are only required once the user starts changing the password.
class PasswordChangeSection extends StatelessWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool enabled;

  const PasswordChangeSection({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.leavePasswordEmptyHint,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.palette.ink2),
        ),
        const SizedBox(height: 16),
        AppPasswordField(
          label: l10n.currentPasswordLabel,
          controller: currentPasswordController,
          hintText: l10n.currentPasswordPlaceholder,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          showTooltip: l10n.showPassword,
          hideTooltip: l10n.hidePassword,
          validator: (value) {
            // Only required when the user is changing the password.
            if (newPasswordController.text.isNotEmpty || confirmPasswordController.text.isNotEmpty) {
              if (value == null || value.isEmpty) {
                return l10n.errorCurrentPasswordRequired;
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppPasswordField(
          label: l10n.newPasswordLabel,
          controller: newPasswordController,
          enabled: enabled,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          showTooltip: l10n.showPassword,
          hideTooltip: l10n.hidePassword,
          validator: (value) {
            if (currentPasswordController.text.isNotEmpty) {
              if (value == null || value.isEmpty) {
                return l10n.errorNewPasswordRequired;
              }
              return AuthValidators.newPassword(l10n, value);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppPasswordField(
          label: l10n.confirmNewPasswordLabel,
          controller: confirmPasswordController,
          enabled: enabled,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          showTooltip: l10n.showPassword,
          hideTooltip: l10n.hidePassword,
          validator: (value) {
            if (newPasswordController.text.isNotEmpty) {
              if (value == null || value.isEmpty) {
                return l10n.errorConfirmPasswordRequired;
              }
              if (value != newPasswordController.text) {
                return l10n.errorPasswordsDoNotMatch;
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
