import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';


class RequestResetInputs extends StatelessWidget {

  final TextEditingController emailInputController;
  final bool enabled;

  const RequestResetInputs({
    super.key,
    required this.emailInputController,
    this.enabled = true
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.emailLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: context.palette.ink
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: emailInputController,
          keyboardType: TextInputType.emailAddress,
          enabled: enabled,

          validator: (value) {
            if(value == null || value.trim().isEmpty) {
              return l10n.errorEmailRequired;
            }

            if(!value.contains('@') || !value.contains('.')) {
              return l10n.errorInvalidEmail;
            }

            return null;
          },

          decoration: InputDecoration(
            hintText: l10n.emailPlaceholder,
            hintStyle: TextStyle(color: context.palette.ink3),
            filled: true,
            fillColor: context.palette.background,

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.danger, width: 2)
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.danger, width: 2)
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.line)
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.line)
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.palette.accent, width: 2)
            ),

            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          ),
        )
      ],
    );
  }
}