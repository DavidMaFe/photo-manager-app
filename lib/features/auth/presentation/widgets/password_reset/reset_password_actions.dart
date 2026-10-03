import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';


class ResetPasswordActions extends StatelessWidget {

  final VoidCallback onResetPassword;
  final bool isLoading;

  const ResetPasswordActions({
    super.key,
    required this.onResetPassword,
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
              onPressed: isLoading ? null : onResetPassword,
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
                  l10n.resetPasswordButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ),
            ),
          )
        ],
    );
  }
}