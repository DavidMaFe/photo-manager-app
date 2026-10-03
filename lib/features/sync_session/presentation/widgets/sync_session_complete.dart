import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';


class SyncSessionComplete extends StatelessWidget {

  const SyncSessionComplete({super.key});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 4, color: context.palette.accent),
          const SizedBox(height: 32),
          Text(l10n.syncSessionCompleting, style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: context.palette.ink
          )),
          const SizedBox(height: 8),
          Text(l10n.syncSessionSave, style: TextStyle(
            fontSize: 14,
            color: context.palette.ink2
          ))
        ],
      ),
    );
  }
}