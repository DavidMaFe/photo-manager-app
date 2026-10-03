import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class RegisterHeader extends StatelessWidget {

  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {

    final l10n =  AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/photo_manager_logo_cut.png',
          width: 140,
          height: 140,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.createAccount,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: context.palette.ink
          ),
        ),
        Text(
          l10n.registerTitle,
          style: TextStyle(
            fontSize: 16,
            color: context.palette.ink2,
            fontWeight: FontWeight.w400
          ),
        )
      ],
    );
  }
}