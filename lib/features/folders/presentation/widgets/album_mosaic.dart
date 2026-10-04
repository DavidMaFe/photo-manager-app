import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/constants/app_constants.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';


/// Cover of an album, adapted to how many photos it has:
/// - 3: big photo on the left (2 rows) and two small ones stacked (2fr / 1fr);
/// - 2: two equal columns;
/// - 1: the whole photo;
/// - 0: the album icon on surface2.
///
/// Used by album and sub-album cards and by the album's cover card.
class AlbumMosaic extends StatelessWidget {

  static const double gap = 2;

  /// Files of the mosaic in order (the first one is the big one). Extra ones are ignored.
  final List<String> fileIds;
  final double radius;
  final double iconSize;

  /// Builds each photo; the authenticated thumbnail by default.
  final Widget Function(BuildContext context, String fileId)? imageBuilder;

  const AlbumMosaic({
    super.key,
    required this.fileIds,
    required this.radius,
    this.iconSize = 36,
    this.imageBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ids = fileIds.take(kMaxAlbumCovers).toList();

    Widget tile(String fileId) => ColoredBox(
          color: p.surface2,
          child: SizedBox.expand(child: (imageBuilder ?? _thumbnail)(context, fileId)),
        );

    final Widget content = switch (ids.length) {
      0 => ColoredBox(
          color: p.surface2,
          child: Center(child: Icon(Symbols.photo_album_rounded, size: iconSize, color: p.ink3)),
        ),
      1 => tile(ids[0]),
      2 => Row(
          children: [
            Expanded(child: tile(ids[0])),
            const SizedBox(width: gap),
            Expanded(child: tile(ids[1])),
          ],
        ),
      _ => Row(
          children: [
            Expanded(flex: 2, child: tile(ids[0])),
            const SizedBox(width: gap),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: tile(ids[1])),
                  const SizedBox(height: gap),
                  Expanded(child: tile(ids[2])),
                ],
              ),
            ),
          ],
        ),
    };

    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: content);
  }

  static Widget _thumbnail(BuildContext context, String fileId) {
    return AuthenticatedImage(
      imageUrl: '${DataConstants.backendBaseUrl}/api/file/$fileId/thumbnail/',
      fit: BoxFit.cover,
      // The tile paints the surface2 placeholder behind the image.
      placeholder: (_, __) => const SizedBox.shrink(),
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
