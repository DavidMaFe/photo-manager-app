import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';


/// Rounded thumbnail of a photo for the cover sheets and cards.
class CoverThumbnail extends StatelessWidget {
  final String fileId;
  final double size;
  final double radius;

  const CoverThumbnail({super.key, required this.fileId, required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: context.palette.surface2,
        child: SizedBox.square(
          dimension: size,
          child: AuthenticatedImage(
            imageUrl: '${DataConstants.backendBaseUrl}/api/file/$fileId/thumbnail/',
            fit: BoxFit.cover,
            placeholder: (_, __) => const SizedBox.shrink(),
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
