import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import '../../../../../l10n/app_localizations.dart';


class ResetPasswordHeader extends StatelessWidget {

  const ResetPasswordHeader({super.key});

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
            Icons.lock_open,
            color: Colors.white,
            size: 48
          ),
        ),

        SizedBox(height: 16),

        Text(
          l10n.resetPasswordTitle,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87
          ),
        ),
        SizedBox(height: 8),
        Text(
          l10n.resetPasswordSubtitle,
          textAlign: TextAlign.center,
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