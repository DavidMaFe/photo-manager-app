import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';


class ValidateCodeHeader extends StatelessWidget {

  final String email;

  const ValidateCodeHeader({super.key, required this.email});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/photo_manager_logo_cut.png',
          width: 180,
          height: 180,
        ),

        const SizedBox(height: 16),

        Text(
          l10n.validateCodeTitle,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: context.palette.ink
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.validateCodeSubtitle(email),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: context.palette.ink2,
              fontWeight: FontWeight.w400
            ),
          ),
        )
      ],
    );
  }
}