import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
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

    final baseUrl = DataConstants.backendBaseUrl;
    final thumbnailUrl = '$baseUrl/api/file/${file.id}/thumbnail/';

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedScale(
            scale: isSelected ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AuthenticatedImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),

          if (isSelectionMode) _buildSelectionOverlay(),
          if (isSelectionMode) _buildCheckbox(),
          if (file.isPending && !isSelectionMode) _buildPendingBadge(context),
          if (file.isVideo) _buildPlayIcon()
        ],
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: isSelected
            ? Border.all(color: PhotoManagerColors.primary, width: 3)
            : null,
        color: isSelected
            ? PhotoManagerColors.primary.withValues(alpha: 0.15)
            : Colors.transparent
      ),
    );
  }

  Widget _buildCheckbox() {
    return Positioned(
      top: 4,
      left: 4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4
            )
          ]
        ),
        child: Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? PhotoManagerColors.primary : Colors.grey.shade400,
          size: 24
        ),
      ),
    );
  }

  Widget _buildPendingBadge(BuildContext context) {
    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2)
            )
          ]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule,
              size: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayIcon() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2)
            )
          ]
        ),
        child: const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}