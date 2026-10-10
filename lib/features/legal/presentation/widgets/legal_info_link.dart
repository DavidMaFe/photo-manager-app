import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/app_typography.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Link to the information pages and legal texts, on the screens without a session.
class LegalInfoLink extends StatelessWidget {
  const LegalInfoLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        key: const ValueKey('legal-info-link'),
        onPressed: () => context.push(RoutePaths.legal),
        style: TextButton.styleFrom(minimumSize: const Size(44, 44), textStyle: AppTypography.button(13)),
        child: Text(AppLocalizations.of(context)!.legalInfoLink, textAlign: TextAlign.center),
      ),
    );
  }
}
