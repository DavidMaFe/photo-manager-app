import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../../../config/theme/photo_manager_colors.dart';

class TrashHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onCancelSelection;
  final VoidCallback onEmptyTrash;

  const TrashHeader({
    super.key,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onCancelSelection,
    required this.onEmptyTrash,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onCancelSelection,
          tooltip: l10n.cancel,
        ),
        title: Text(
          l10n.filesSelected(selectedCount),
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () {
              // TODO: Implement select all
            },
            tooltip: l10n.selectAll,
          ),
        ],
        backgroundColor: PhotoManagerColors.primary.withValues(alpha: 0.1),
      );
    }

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(l10n.trash),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined),
          onPressed: onEmptyTrash,
          tooltip: l10n.emptyTrash,
        ),
      ],
      backgroundColor: Colors.white,
    );
  }
}
