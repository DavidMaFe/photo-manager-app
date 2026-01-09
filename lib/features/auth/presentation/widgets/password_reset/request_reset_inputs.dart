import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
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
            color: Colors.black87
          ),
        ),

        SizedBox(height: 8),

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
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2)
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2)
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!)
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!)
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PhotoManagerColors.primary, width: 2)
            ),

            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          ),
        )
      ],
    );
  }
}