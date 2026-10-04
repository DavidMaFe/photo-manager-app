import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/screen_header.dart';
import 'package:photo_manager_app/core/widgets/selection_header.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Gallery header: tab title with actions, or the selection header.
class GalleryTopBar extends StatelessWidget {

  final bool isSelectionMode;
  final int selectedCount;
  final bool areAllFilesSelected;
  final List<Widget> actions;
  final VoidCallback? onCancelSelection;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;

  const GalleryTopBar({
    super.key,
    this.isSelectionMode = false,
    this.selectedCount = 0,
    this.areAllFilesSelected = false,
    this.actions = const [],
    this.onCancelSelection,
    this.onSelectAll,
    this.onDeselectAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isSelectionMode
          ? SelectionHeader(
              key: const ValueKey('selection'),
              title: l10n.selectedCount(selectedCount),
              closeTooltip: l10n.closeSelection,
              onClose: onCancelSelection,
              toggleLabel: areAllFilesSelected ? l10n.selectNone : l10n.selectAllShort,
              onToggle: areAllFilesSelected ? onDeselectAll : onSelectAll,
            )
          : ScreenHeader(key: const ValueKey('title'), title: l10n.navPhotos, actions: actions),
    );
  }
}
