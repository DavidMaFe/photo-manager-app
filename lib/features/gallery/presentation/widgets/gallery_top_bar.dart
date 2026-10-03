import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/icon_circle_button.dart';
import 'package:photo_manager_app/core/widgets/screen_header.dart';
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
          ? _SelectionHeader(
              key: const ValueKey('selection'),
              selectedCount: selectedCount,
              areAllFilesSelected: areAllFilesSelected,
              onCancel: onCancelSelection,
              onSelectAll: onSelectAll,
              onDeselectAll: onDeselectAll,
            )
          : ScreenHeader(key: const ValueKey('title'), title: l10n.navPhotos, actions: actions),
    );
  }
}

class _SelectionHeader extends StatelessWidget {
  final int selectedCount;
  final bool areAllFilesSelected;
  final VoidCallback? onCancel;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;

  const _SelectionHeader({
    super.key,
    required this.selectedCount,
    required this.areAllFilesSelected,
    this.onCancel,
    this.onSelectAll,
    this.onDeselectAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconCircleButton(
              icon: Symbols.close_rounded,
              tooltip: l10n.closeSelection,
              onPressed: onCancel,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.selectedCount(selectedCount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.palette.ink),
              ),
            ),
            AppButton.neutral(
              label: areAllFilesSelected ? l10n.selectNone : l10n.selectAllShort,
              size: AppButtonSize.small,
              onPressed: areAllFilesSelected ? onDeselectAll : onSelectAll,
            ),
          ],
        ),
      ),
    );
  }
}
