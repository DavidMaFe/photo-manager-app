import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class GalleryHeader extends StatelessWidget implements PreferredSizeWidget {

  final bool isSelectionMode;
  final int selectedCount;
  final bool areAllFilesSelected;
  final VoidCallback? onCancelSelection;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;

  const GalleryHeader({
    super.key,
    this.isSelectionMode = false,
    this.selectedCount = 0,
    this.areAllFilesSelected = false,
    this.onCancelSelection,
    this.onSelectAll,
    this.onDeselectAll
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isSelectionMode) {
      return _buildSelectionAppBar(context, l10n);
    }

    return _buildNormalAppBar(context, l10n);
  }

  AppBar _buildNormalAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      title: Text(l10n.gallery),
      centerTitle: false,
      elevation: 0,
      backgroundColor: context.palette.surface,
    );
  }

  AppBar _buildSelectionAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: onCancelSelection,
        tooltip: l10n.cancel,
      ),
      title: Text(
        l10n.selectedFilesWithLimit(selectedCount),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: context.palette.accent.withValues(alpha: 0.1),
      actions: [
        if (areAllFilesSelected && onDeselectAll != null)
          TextButton.icon(
            onPressed: onDeselectAll,
            icon: const Icon(Icons.deselect, size: 20),
            label: Text(l10n.deselectAll),
            style: TextButton.styleFrom(
              foregroundColor: context.palette.accent
            ),
          )
        else if (!areAllFilesSelected && onSelectAll != null)
          TextButton.icon(
            onPressed: onSelectAll,
            icon: const Icon(Icons.select_all, size: 20),
            label: Text(l10n.selectAll),
            style: TextButton.styleFrom(
              foregroundColor: context.palette.accent
            ),
          ),
        const SizedBox(width: 8)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}