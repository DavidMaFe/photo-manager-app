import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class RegisterActions extends StatelessWidget {

  final VoidCallback onRegister;
  final VoidCallback onGoToLogin;
  final bool isLoading;

  const RegisterActions({
    super.key,
    required this.onRegister,
    required this.onGoToLogin,
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
            onPressed: isLoading ? null : onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.palette.accent,
              disabledBackgroundColor: context.palette.line,
              foregroundColor: context.palette.onAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              elevation: 0
            ),
            child: isLoading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(context.palette.onAccent),
            )) : Text(l10n.registerButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.alreadyHaveAccount,
              style: TextStyle(
                color: context.palette.ink2,
                fontSize: 15
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : onGoToLogin,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              child: Text(
                l10n.signIn,
                style: TextStyle(
                  color: isLoading ? context.palette.ink2 : context.palette.accentInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.registerTermsDisclaimer,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: context.palette.ink2
          ),
        )
      ],
    );
  }
}