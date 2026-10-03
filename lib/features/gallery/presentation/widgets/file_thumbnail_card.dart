import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/core/widgets/media_thumbnail.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';


class FileThumbnailCard extends StatelessWidget {

  final GalleryFile file;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const FileThumbnailCard({
    super.key,
    required this.file,
    required this.isSelectionMode,
    required this.isSelected,
    this.onTap,
    this.onLongPress
  });

  @override
  Widget build(BuildContext context) {

    const baseUrl = DataConstants.backendBaseUrl;
    final thumbnailUrl = '$baseUrl/api/file/${file.id}/thumbnail/';

    return MediaThumbnail(
      image: AuthenticatedImage(
        imageUrl: thumbnailUrl,
        fit: BoxFit.cover,
      ),
      isPending: file.isPending,
      isVideo: file.isVideo,
      videoDuration: file.durationSeconds == null
          ? null
          : Duration(seconds: file.durationSeconds!),
      selectable: isSelectionMode,
      selected: isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
