import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/features/auth/presentation/utils/auth_validators.dart';

import '../../../../../l10n/app_localizations.dart';


class RequestResetInputs extends StatelessWidget {

  final TextEditingController emailInputController;
  final VoidCallback? onSubmitted;
  final bool enabled;

  const RequestResetInputs({
    super.key,
    required this.emailInputController,
    this.onSubmitted,
    this.enabled = true
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return AppTextField(
      label: l10n.emailLabel,
      controller: emailInputController,
      hintText: l10n.emailPlaceholder,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.send,
      autofillHints: const [AutofillHints.email],
      enabled: enabled,
      onFieldSubmitted: (_) => onSubmitted?.call(),
      validator: (value) => AuthValidators.email(l10n, value),
    );
  }
}
