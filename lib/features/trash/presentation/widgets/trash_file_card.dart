import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_radius.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/core/widgets/media_thumbnail.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class TrashFileCard extends StatelessWidget {
  /// Files deleted within this many days get the danger countdown pill.
  static const int soonThresholdDays = 3;

  final TrashFile file;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TrashFileCard({
    super.key,
    required this.file,
    required this.isSelectionMode,
    required this.isSelected,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    const baseUrl = DataConstants.backendBaseUrl;
    final thumbnailUrl = '$baseUrl/api/file/${file.id}/thumbnail/';

    return MediaThumbnail(
      image: AuthenticatedImage(
        imageUrl: thumbnailUrl,
        fit: BoxFit.cover,
        // MediaThumbnail paints the surface2 placeholder behind the image.
        placeholder: (_, __) => const SizedBox.shrink(),
      ),
      isVideo: file.isVideo,
      selectable: isSelectionMode,
      selected: isSelected,
      bottomLeftBadge: isSelectionMode ? null : _buildDeletionCountdownBadge(context),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _buildDeletionCountdownBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isDeletedSoon(file) ? palette.danger : palette.scrim,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        l10n.daysLeft(file.daysUntilPermanentDeletion),
        style: TextStyle(
          color: palette.onMedia,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static bool isDeletedSoon(TrashFile file) => file.daysUntilPermanentDeletion <= soonThresholdDays;
}
