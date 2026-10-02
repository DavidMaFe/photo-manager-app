import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';


class RequestResetHeader extends StatelessWidget {

  const RequestResetHeader({super.key});

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

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n.forgotPasswordTitle,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87
            ),
          ),
        ),
        Text(
          l10n.forgotPasswordSubtitle,
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