import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';


class SyncSessionErrorView extends StatelessWidget {

  final String message;
  final VoidCallback onRetry;

  const SyncSessionErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 100,
            color: context.palette.danger,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.palette.dangerSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.palette.danger,
                width: 1
              )
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: context.palette.dangerInk
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.palette.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
              ),
              child: Text(l10n.tryAgain, style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.palette.onAccent
              )),
            )
          ),
          const SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: context.palette.accent, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)
                    )
                ),
                child: Text(l10n.goBack, style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.palette.accentInk
                )),
              )
          )
        ],
      )
    );
  }
}