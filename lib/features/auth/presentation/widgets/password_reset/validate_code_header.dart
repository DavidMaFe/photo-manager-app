import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
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
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [PhotoManagerColors.primary, Color(0xFF6F58ED), Color(0xFF7556EE)]),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            color: Colors.white,
            size: 48
          ),
        ),

        SizedBox(height: 16),

        Text(
          l10n.validateCodeTitle,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.validateCodeSubtitle(email),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400
            ),
          ),
        )
      ],
    );
  }
}