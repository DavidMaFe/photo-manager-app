import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_logo.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/auth_title.dart';

import '../../../../../l10n/app_localizations.dart';


class LoginHeader extends StatelessWidget {

  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(markHeight: 72, direction: Axis.vertical, wordmarkSize: 22),
        const SizedBox(height: 44),
        AuthTitle(title: l10n.loginGreeting, subtitle: l10n.loginSubtitle),
      ],
    );
  }
}
