import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_failures.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/load_media_use_case.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/encrypted_image_provider.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/widgets/encrypted_image.dart';

/// A photo at full size: the thumbnail first, which is small and usually cached, then the original once it is
/// downloaded and decrypted (decision D10).
class EncryptedPhotoViewer extends StatelessWidget {
  final String fileId;
  final LoadMediaUseCase? loadMedia;

  const EncryptedPhotoViewer({super.key, required this.fileId, this.loadMedia});

  @override
  Widget build(BuildContext context) {
    final load = loadMedia ?? sl<LoadMediaUseCase>();
    final thumbnail = EncryptedImage(fileId: fileId, fit: BoxFit.contain, loadMedia: load);
    return Image(
      key: ValueKey('encrypted-photo-$fileId'),
      image: EncryptedImageProvider(fileId: fileId, variant: MediaVariant.original, loadMedia: load),
      fit: BoxFit.contain,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          wasSynchronouslyLoaded || frame != null ? child : thumbnail,
      // The thumbnail stays when the original fails; a locked file shows the lock
      errorBuilder: (context, error, _) => error is LockedFileFailure
          ? EncryptedImage(fileId: fileId, fit: BoxFit.contain, loadMedia: load)
          : thumbnail,
    );
  }
}
