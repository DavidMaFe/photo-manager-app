import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/core/widgets/selection_header.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Trash top bar ("Empty" action) or the selection header.
class TrashHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isSelectionMode;
  final int selectedCount;
  final bool areAllFilesSelected;
  final bool canEmpty;
  final VoidCallback onCancelSelection;
  final VoidCallback onEmptyTrash;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClearSelection;

  const TrashHeader({
    super.key,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onCancelSelection,
    required this.onEmptyTrash,
    this.areAllFilesSelected = false,
    this.canEmpty = true,
    this.onSelectAll,
    this.onClearSelection,
  });

  @override
  Size get preferredSize => Size.fromHeight(isSelectionMode ? 72 : SecondaryTopBar.height);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isSelectionMode) {
      return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          bottom: false,
          child: SelectionHeader(
            title: l10n.selectedCount(selectedCount),
            closeTooltip: l10n.closeSelection,
            onClose: onCancelSelection,
            toggleLabel: areAllFilesSelected ? l10n.selectNone : l10n.selectAllShort,
            onToggle: areAllFilesSelected ? onClearSelection : onSelectAll,
          ),
        ),
      );
    }

    return SecondaryTopBar(
      title: l10n.trash,
      actions: [
        if (canEmpty)
          AppButton.danger(
            label: l10n.emptyTrashShort,
            size: AppButtonSize.small,
            onPressed: onEmptyTrash,
          ),
      ],
    );
  }
}
