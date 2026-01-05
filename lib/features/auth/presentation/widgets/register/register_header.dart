import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class RegisterHeader extends StatelessWidget {

  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {

    final l10n =  AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                PhotoManagerColors.primary,
                const Color(0xFF6F58ED),
                const Color(0xFF7556EE)
              ]
            ),
            borderRadius: BorderRadius.circular(20)
          ),
          child: const Icon(
            Icons.person_add_outlined,
            color: Colors.white,
            size: 48,
          ),
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