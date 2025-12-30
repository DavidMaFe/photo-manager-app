import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class GalleryHeader extends StatelessWidget implements PreferredSizeWidget {

  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback? onCancelSelection;
  final VoidCallback? onSelectAll;

  const GalleryHeader({
    super.key,
    this.isSelectionMode = false,
    this.selectedCount = 0,
    this.onCancelSelection,
    this.onSelectAll
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
        selectedCount == 1 ? l10n.selectedFilesSingle : l10n.selectedFiles(selectedCount),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: PhotoManagerColors.primary.withValues(alpha: 0.1),
      actions: [
        if (onSelectAll != null)
          TextButton.icon(
            onPressed: onSelectAll,
            icon: const Icon(Icons.select_all, size: 20),
            label: Text(l10n.selectAll),
            style: TextButton.styleFrom(
              foregroundColor: PhotoManagerColors.primary
            ),
          ),
          const SizedBox(width: 8)
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}