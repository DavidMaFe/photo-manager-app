import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_failures.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/load_media_use_case.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/encrypted_image_provider.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/widgets/encrypted_image.dart';

/// A photo at full size: the thumbnail first, which is small and usually cached, then the 2048 px version when the
/// file has one ([hasPreview]) or the original (decision D10, ROADMAP-media-compression.md).
///
/// With [showOriginal] (the user zoomed in) the original is loaded too and replaces the 2048 px version, which stays
/// on screen until the original is decrypted or if it fails.
class EncryptedPhotoViewer extends StatelessWidget {
  final String fileId;
  final bool hasPreview;
  final bool showOriginal;
  final LoadMediaUseCase? loadMedia;

  const EncryptedPhotoViewer({
    super.key,
    required this.fileId,
    this.hasPreview = false,
    this.showOriginal = false,
    this.loadMedia,
  });

  @override
  Widget build(BuildContext context) {
    final load = loadMedia ?? sl<LoadMediaUseCase>();
    final thumbnail = EncryptedImage(fileId: fileId, fit: BoxFit.contain, loadMedia: load);
    final first = _image(load, hasPreview ? MediaVariant.preview : MediaVariant.original, fallback: thumbnail);
    if (!hasPreview || !showOriginal) {
      return KeyedSubtree(key: ValueKey('encrypted-photo-$fileId'), child: first);
    }
    return KeyedSubtree(
      key: ValueKey('encrypted-photo-$fileId'),
      child: _image(load, MediaVariant.original, fallback: first),
    );
  }

  /// [variant] of the photo, with [fallback] on screen while it loads and if it fails; a locked file shows the lock.
  Widget _image(LoadMediaUseCase load, MediaVariant variant, {required Widget fallback}) {
    return Image(
      key: ValueKey('encrypted-photo-$fileId-${variant.name}'),
      image: EncryptedImageProvider(fileId: fileId, variant: variant, loadMedia: load),
      fit: BoxFit.contain,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          wasSynchronouslyLoaded || frame != null ? child : fallback,
      errorBuilder: (context, error, _) => error is LockedFileFailure
          ? EncryptedImage(fileId: fileId, fit: BoxFit.contain, loadMedia: load)
          : fallback,
    );
  }
}
