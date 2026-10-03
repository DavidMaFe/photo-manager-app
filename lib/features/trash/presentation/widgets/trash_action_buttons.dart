import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
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
                    color: context.palette.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: onRestore,
                heroTag: 'restore_button',
                backgroundColor: context.palette.accent,
                elevation: 0,
                icon: Icon(Icons.restore, size: 20, color: context.palette.onAccent),
                label: Text(
                  l10n.restore,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.palette.onAccent,
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
                    color: context.palette.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: onDelete,
                heroTag: 'delete_button',
                backgroundColor: context.palette.surface,
                elevation: 0,
                icon: Icon(Icons.delete_forever, size: 20, color: context.palette.accent),
                label: Text(
                  l10n.delete,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.palette.accentInk,
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
