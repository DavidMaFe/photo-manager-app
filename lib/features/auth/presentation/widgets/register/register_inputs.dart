import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_password_field.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/features/auth/presentation/utils/auth_validators.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class RegisterInputs extends StatelessWidget {

  final TextEditingController nameInputController;
  final TextEditingController surnameInputController;
  final TextEditingController emailInputController;
  final TextEditingController passwordInputController;
  final TextEditingController confirmPasswordInputController;
  final bool enabled;

  const RegisterInputs({
    super.key,
    required this.nameInputController,
    required this.surnameInputController,
    required this.emailInputController,
    required this.passwordInputController,
    required this.confirmPasswordInputController,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: l10n.nameLabel,
                  controller: nameInputController,
                  hintText: l10n.namePlaceholder,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  enabled: enabled,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.errorNameRequired;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: l10n.surnameShortLabel,
                  labelNote: l10n.optionalLabel,
                  controller: surnameInputController,
                  hintText: l10n.surnamePlaceholder,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.familyName],
                  enabled: enabled,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

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
            controller: passwordInputController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            enabled: enabled,
            showTooltip: l10n.showPassword,
            hideTooltip: l10n.hidePassword,
            validator: (value) => AuthValidators.password(l10n, value),
          ),

          const SizedBox(height: 16),

          AppPasswordField(
            label: l10n.confirmPasswordLabel,
            controller: confirmPasswordInputController,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            enabled: enabled,
            showTooltip: l10n.showPassword,
            hideTooltip: l10n.hidePassword,
            validator: (value) =>
                AuthValidators.confirmation(l10n, value, passwordInputController.text),
          ),
        ],
      ),
    );
  }
}
