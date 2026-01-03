
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class EmptySynchronizationState extends StatelessWidget {

  const EmptySynchronizationState({super.key});

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
                color: const Color(0xFFF3F4F6),
                shape: BoxShape.circle
              ),
              child: const Icon(
                Icons.sync_disabled,
                size: 60,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.notSyncYet,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111)
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.syncStart,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF111111).withValues(alpha: 0.6)
              ),
            )
          ],
        ),
      ),
    );
  }
}