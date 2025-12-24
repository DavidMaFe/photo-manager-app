import 'package:flutter/material.dart';

import '../../../../config/theme/photo_manager_colors.dart';
import '../../../../l10n/app_localizations.dart';


class SyncSessionInit extends StatelessWidget {

  const SyncSessionInit({super.key});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 4, color: PhotoManagerColors.primary),
          const SizedBox(height: 32),
          Text(l10n.syncSessionInit, style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color(0xFF212121)
          )),
          const SizedBox(height: 8),
          Text(l10n.syncSessionConnecting, style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575)
          ))
        ],
      ),
    );
  }
}