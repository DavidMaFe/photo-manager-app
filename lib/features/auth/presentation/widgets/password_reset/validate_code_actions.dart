import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';


class ValidateCodeActions extends StatelessWidget {

  final VoidCallback onValidateCode;
  final VoidCallback onResendCode;
  final VoidCallback onBack;
  final bool isLoading;

  const ValidateCodeActions({
    super.key,
    required this.onValidateCode,
    required this.onResendCode,
    required this.onBack,
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onValidateCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.palette.accent,
                disabledBackgroundColor: context.palette.line,
                foregroundColor: context.palette.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                elevation: 0
              ),
              child: isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(context.palette.onAccent),
                  )
                )
                : Text(
                  l10n.validateCodeButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ),
            ),
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: isLoading ? null : onResendCode,
            child: Text(
              l10n.resendCodeButton,
              style: TextStyle(
                color: isLoading ? context.palette.ink2 : context.palette.accentInk,
                fontSize: 15,
                fontWeight: FontWeight.w500
              ),
            )
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: isLoading ? null : onBack,
            child: Text(
              l10n.backToLogin,
              style: TextStyle(
                color: isLoading ? context.palette.ink2 : context.palette.ink2,
                fontSize: 15,
                fontWeight: FontWeight.w400
              ),
            )
          )
        ],
    );
  }
}