import 'package:photo_manager_app/features/encrypted_media/presentation/widgets/encrypted_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';


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
          child: EncryptedImage(fileId: fileId, transparentWhileLoading: true, hideErrors: true),
        ),
      ),
    );
  }
}
