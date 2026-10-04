import 'package:photo_manager_app/config/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';

import '../../../../../l10n/app_localizations.dart';


class LoginActions extends StatelessWidget {

  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final bool isLoading;

  const LoginActions({
    super.key,
    required this.onLogin,
    required this.onRegister,
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        AppButton.primary(
          label: l10n.loginButton,
          onPressed: onLogin,
          loading: isLoading,
        ),

        const SizedBox(height: 16),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.noAccountYet,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: context.palette.ink2),
            ),
            TextButton(
              onPressed: isLoading ? null : onRegister,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                textStyle: AppTypography.button(14),
              ),
              child: Text(l10n.createAccountLink),
            ),
          ],
        ),
      ],
    );
  }
}
