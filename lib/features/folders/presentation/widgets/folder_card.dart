import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/app_config.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_radius.dart';
import 'package:photo_manager_app/core/utils/date_formatter.dart';
import 'package:photo_manager_app/core/widgets/app_context_menu.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/folder.dart';
import 'album_mosaic.dart';


enum _AlbumMenuAction { rename, delete }

/// Album card: square cover, name, "items · sub-albums" and the months it covers.
/// A long press opens the rename/delete menu.
class FolderCard extends StatelessWidget {

  final Folder folder;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    this.onRename,
    this.onDelete
  });

  /// "148 · 3 sub-albums", or just the item count without sub-albums.
  static String metaFor(Folder folder, AppLocalizations l10n) {
    return folder.subfolderCount > 0
        ? l10n.albumMeta(folder.fileCount, folder.subfolderCount)
        : l10n.itemsCount(folder.fileCount);
  }

  /// "Aug 2024" / "Jan – Aug 2024", or `null` while the album has no dated files.
  static String? dateRangeFor(Folder folder, AppLocalizations l10n) {
    return DateFormatter.formatMonthRange(folder.oldestCapturedAt, folder.newestCapturedAt, l10n.localeName);
  }

  /// Photos of the album's mosaic: the chosen covers, else the recent photos.
  /// None while the favorites and covers feature is off (the album icon).
  static List<String> coverFileIdsFor(Folder folder) {
    return AppConfig.favoritesAndCoversEnabled ? folder.mosaicFileIds : const [];
  }

  bool get _hasMenu => onRename != null || onDelete != null;

  Future<void> _showMenu(BuildContext context, Offset position) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showAppContextMenu<_AlbumMenuAction>(
      context,
      position: position,
      items: [
        if (onRename != null)
          AppMenuItem(value: _AlbumMenuAction.rename, label: l10n.rename, icon: Symbols.edit_rounded),
        if (onDelete != null)
          AppMenuItem(
            value: _AlbumMenuAction.delete,
            label: l10n.delete,
            icon: Symbols.delete_rounded,
            destructive: true,
          ),
      ],
    );
    switch (action) {
      case _AlbumMenuAction.rename:
        onRename?.call();
      case _AlbumMenuAction.delete:
        onDelete?.call();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final dateRange = dateRangeFor(folder, l10n);

    return Semantics(
      button: true,
      label: [folder.name, metaFor(folder, l10n), if (dateRange != null) dateRange].join(', '),
      excludeSemantics: true,
      onLongPressHint: _hasMenu ? l10n.moreOptions : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPressStart: _hasMenu ? (details) => _showMenu(context, details.globalPosition) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: AlbumMosaic(fileIds: coverFileIdsFor(folder), radius: AppRadius.card),
            ),
            const SizedBox(height: 8),
            Text(
              folder.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink),
            ),
            const SizedBox(height: 2),
            Text(
              metaFor(folder, l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
            ),
            if (dateRange != null)
              Text(
                dateRange,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink3),
              ),
          ],
        ),
      ),
    );
  }
}
