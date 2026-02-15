import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class TrashActionButtons extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const TrashActionButtons({
    super.key,
    required this.selectedCount,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Restore button (Filled)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: PhotoManagerColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: onRestore,
                heroTag: 'restore_button',
                backgroundColor: PhotoManagerColors.primary,
                elevation: 0,
                icon: const Icon(Icons.restore, size: 20, color: Colors.white),
                label: Text(
                  l10n.restore,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            // Delete button (Outlined)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: PhotoManagerColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: onDelete,
                heroTag: 'delete_button',
                backgroundColor: Colors.white,
                elevation: 0,
                icon: const Icon(Icons.delete_forever, size: 20, color: PhotoManagerColors.primary),
                label: Text(
                  l10n.delete,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: PhotoManagerColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
