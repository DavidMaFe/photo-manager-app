import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class TrashEmptyState extends StatelessWidget {
  const TrashEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 80,
            color: context.palette.ink3,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.trashIsEmpty,
            style: TextStyle(
              fontSize: 20,
              color: context.palette.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              l10n.trashEmptyDescription,
              style: TextStyle(
                fontSize: 14,
                color: context.palette.ink2,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
