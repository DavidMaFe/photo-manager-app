import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

import '../../../../l10n/app_localizations.dart';


class FileThumbnailCard extends StatelessWidget {

  final GalleryFile file;
  final VoidCallback? onTap;

  const FileThumbnailCard({super.key, required this.file, this.onTap});

  @override
  Widget build(BuildContext context) {

    final baseUrl = DataConstants.backendBaseUrl;
    final thumbnailUrl = '$baseUrl/api/file/${file.id}/thumbnail/';

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AuthenticatedImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
            ),
          ),

          if(file.isPending) _buildPendingBadge(context),
          if(file.isVideo) _buildPlayIcon()
        ],
      ),
    );
  }

  Widget _buildPendingBadge(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

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
            const SizedBox(width: 2),
            Text(l10n.pending, style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold
            ))
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