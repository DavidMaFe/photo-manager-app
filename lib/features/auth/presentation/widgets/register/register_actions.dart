import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
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
              backgroundColor: PhotoManagerColors.primary,
              disabledBackgroundColor: Colors.grey[300],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)
              ),
              elevation: 0
            ),
            child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                color: Colors.grey[600],
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
                  color: isLoading ? Colors.grey : PhotoManagerColors.primary,
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
            color: Colors.grey[500]
          ),
        )
      ],
    );
  }
}