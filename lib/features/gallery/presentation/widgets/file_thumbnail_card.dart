import 'package:photo_manager_app/features/encrypted_media/presentation/widgets/encrypted_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/widgets/media_thumbnail.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class FileThumbnailCard extends StatelessWidget {

  final GalleryFile file;
  final bool isSelectionMode;
  final bool isSelected;

  /// Shows the favorite heart (off in the trash or while the feature is hidden).
  final bool showFavorite;

  /// First tile of a date group (2×2).
  final bool large;

  /// Fades and shrinks the thumbnail out (it is about to leave the grid).
  final bool leaving;

  /// Shows the «Cover» badge (the file is a cover of the album being viewed).
  final bool isCover;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FileThumbnailCard({
    super.key,
    required this.file,
    required this.isSelectionMode,
    required this.isSelected,
    this.showFavorite = false,
    this.large = false,
    this.leaving = false,
    this.isCover = false,
    this.onTap,
    this.onLongPress
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFavorite = showFavorite && file.isFavorite;

    final thumbnail = MediaThumbnail(
      image: EncryptedImage(
        fileId: file.id,
        // MediaThumbnail paints the surface2 placeholder behind the image.
        transparentWhileLoading: true,
      ),
      isPending: file.isPending,
      isVideo: file.isVideo,
      videoDuration: file.durationSeconds == null
          ? null
          : Duration(seconds: file.durationSeconds!),
      selectable: isSelectionMode,
      selected: isSelected,
      isFavorite: isFavorite,
      large: large,
      coverLabel: isCover ? l10n.coverBadge : null,
      semanticLabel: [
        file.isVideo ? l10n.filePropertyTypeVideo : l10n.filePropertyTypeImage,
        if (isFavorite) l10n.favorite,
        if (isCover) l10n.cover,
      ].join(', '),
      onTap: onTap,
      onLongPress: onLongPress,
    );

    return AnimatedOpacity(
      duration: GalleryBloc.unfavoritedExitDuration,
      curve: Curves.easeOut,
      opacity: leaving ? 0 : 1,
      child: AnimatedScale(
        duration: GalleryBloc.unfavoritedExitDuration,
        curve: Curves.easeOut,
        scale: leaving ? 0.85 : 1,
        child: IgnorePointer(ignoring: leaving, child: thumbnail),
      ),
    );
  }
}
