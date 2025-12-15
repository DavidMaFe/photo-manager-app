import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';

import '../../../../../l10n/app_localizations.dart';


class LoginActions extends StatelessWidget {

  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onRegister;
  final bool isLoading;

  const LoginActions({
    super.key,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onRegister,
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
              onPressed: isLoading ? null : onLogin,
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
                  l10n.loginButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ),
            ),
          ),

          const SizedBox(height: 16),

          TextButton(
              onPressed: isLoading ? null : onForgotPassword,
              child: Text(
                l10n.forgotPassword,
                style: TextStyle(
                  color: isLoading ? Colors.grey : PhotoManagerColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500
                ),
              )
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.notHaveAccount,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15
                ),
              ),
              TextButton(onPressed: isLoading ? null : onRegister,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  child: Text(
                    l10n.signUp,
                    style: TextStyle(
                      color:  isLoading ? Colors.grey : PhotoManagerColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                    ),
                  )
              )
            ],
          )
        ],
      ),
    );
  }
}