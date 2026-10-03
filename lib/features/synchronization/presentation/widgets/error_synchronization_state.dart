
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class ErrorSynchronizationState extends StatelessWidget {

  final String message;
  final VoidCallback onRetry;

  const ErrorSynchronizationState({
    super.key,
    required this.message,
    required this.onRetry
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.palette.dangerSoft,
                shape: BoxShape.circle
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: context.palette.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.syncErrorLoad,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.palette.ink
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: context.palette.ink2
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.palette.accent,
                foregroundColor: context.palette.onAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
              ),
            )
          ],
        ),
      ),
    );
  }
}