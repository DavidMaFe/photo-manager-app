import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import '../../../../../l10n/app_localizations.dart';


class ValidateCodeInputs extends StatelessWidget {

  final TextEditingController codeInputController;
  final bool enabled;

  const ValidateCodeInputs({
    super.key,
    required this.codeInputController,
    this.enabled = true
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.codeLabel,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87
          ),
        ),

        SizedBox(height: 8),

        TextFormField(
          controller: codeInputController,
          keyboardType: TextInputType.number,
          enabled: enabled,
          textAlign: TextAlign.center,
          maxLength: 6,

          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6)
          ],

          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 8
          ),

          validator: (value) {
            if(value == null || value.trim().isEmpty) {
              return l10n.errorCodeRequired;
            }

            if(value.trim().length != 6) {
              return l10n.errorCodeInvalid;
            }

            return null;
          },

          decoration: InputDecoration(
            hintText: l10n.codePlaceholder,
            hintStyle: TextStyle(color: Colors.grey[400], letterSpacing: 8),
            filled: true,
            fillColor: Colors.grey[50],
            counterText: '',

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

            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20)
          ),
        )
      ],
    );
  }
}