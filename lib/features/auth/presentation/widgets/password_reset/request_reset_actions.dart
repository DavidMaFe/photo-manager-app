import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import '../../../../../l10n/app_localizations.dart';


class RequestResetActions extends StatelessWidget {

  final VoidCallback onSendCode;
  final VoidCallback onBackToLogin;
  final bool isLoading;

  const RequestResetActions({
    super.key,
    required this.onSendCode,
    required this.onBackToLogin,
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSendCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: PhotoManagerColors.primary,
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)
                ),
                elevation: 0
              ),
              child: isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                )
                : Text(
                  l10n.sendCodeButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ),
            ),
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: isLoading ? null : onBackToLogin,
            child: Text(
              l10n.backToLogin,
              style: TextStyle(
                color: isLoading ? Colors.grey : PhotoManagerColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w500
              ),
            )
          )
        ],
      ),
    );
  }
}