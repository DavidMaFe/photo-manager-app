import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class FileSelectionBar extends StatelessWidget {
  
  final int selectedCount;
  final VoidCallback onClose;
  
  const FileSelectionBar({
    super.key, 
    required this.selectedCount, 
    required this.onClose
  });
  
  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: PhotoManagerColors.primary.withValues(alpha: 0.1),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              tooltip: 'Exit selection mode',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.selectedFilesWithLimit(selectedCount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}