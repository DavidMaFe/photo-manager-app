import 'package:photo_manager_app/config/theme/app_palette.dart';
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
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: context.palette.ink
            ),
          ),
        ),
        Text(
          l10n.forgotPasswordSubtitle,
          textAlign: TextAlign.center,
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