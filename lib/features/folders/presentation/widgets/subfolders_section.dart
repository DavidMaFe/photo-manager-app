import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/create_album_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/folder.dart';


/// Horizontal row of sub-album cards ending with a dashed "Sub-album" card.
class SubfoldersSection extends StatelessWidget {

  static const double cardWidth = 112;
  static const double coverHeight = 84;

  final List<Folder> subfolders;
  final ValueChanged<Folder>? onFolderTap;
  final VoidCallback? onCreate;

  const SubfoldersSection({
    super.key,
    required this.subfolders,
    this.onFolderTap,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return SizedBox(
      height: coverHeight + 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subfolders.length + (onCreate != null ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == subfolders.length) {
            return SizedBox(
              width: cardWidth,
              height: coverHeight,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: coverHeight,
                  child: CreateAlbumCard(label: l10n.subalbum, onTap: onCreate!, radius: 16, iconSize: 24),
                ),
              ),
            );
          }

          final folder = subfolders[index];
          return SizedBox(
            width: cardWidth,
            child: Semantics(
              button: true,
              label: '${folder.name}, ${l10n.itemsCount(folder.fileCount)}',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => onFolderTap?.call(folder),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: coverHeight,
                      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Icon(Symbols.photo_album_rounded, size: 28, color: p.ink3)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      folder.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink),
                    ),
                    Text(
                      l10n.itemsCount(folder.fileCount),
                      maxLines: 1,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: p.ink2),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
