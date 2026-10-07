import 'package:photo_manager_app/config/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/legal/presentation/widgets/legal_acceptance_checkbox.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class RegisterActions extends StatelessWidget {

  final VoidCallback onRegister;
  final VoidCallback onGoToLogin;
  final ValueChanged<bool> onLegalTermsChanged;
  final bool isLoading;

  const RegisterActions({
    super.key,
    required this.onRegister,
    required this.onGoToLogin,
    required this.onLegalTermsChanged,
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LegalAcceptanceCheckbox(enabled: !isLoading, onChanged: onLegalTermsChanged),

        const SizedBox(height: 12),

        AppButton.primary(
          label: l10n.registerButton,
          onPressed: onRegister,
          loading: isLoading,
        ),

        const SizedBox(height: 8),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.alreadyHaveAccount,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: palette.ink2),
            ),
            TextButton(
              onPressed: isLoading ? null : onGoToLogin,
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                textStyle: AppTypography.button(14),
              ),
              child: Text(l10n.signIn),
            ),
          ],
        ),
      ],
    );
  }
}
