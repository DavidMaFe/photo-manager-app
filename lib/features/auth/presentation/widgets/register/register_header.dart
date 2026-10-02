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
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87
          ),
        ),
        Text(
          l10n.registerTitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400
          ),
        )
      ],
    );
  }
}