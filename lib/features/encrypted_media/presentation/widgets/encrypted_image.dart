import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_failures.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/load_media_use_case.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/encrypted_image_provider.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// A thumbnail or original of a file, decrypted on this device. Files of a locked key version show a lock.
class EncryptedImage extends StatelessWidget {
  final String fileId;
  final MediaVariant variant;
  final BoxFit fit;

  /// Nothing while loading, for tiles that paint their own background.
  final bool transparentWhileLoading;

  /// Nothing when it cannot be loaded (album mosaics). Locked files always show the lock.
  final bool hideErrors;
  final LoadMediaUseCase? loadMedia;

  const EncryptedImage({
    super.key,
    required this.fileId,
    this.variant = MediaVariant.thumbnail,
    this.fit = BoxFit.cover,
    this.transparentWhileLoading = false,
    this.hideErrors = false,
    this.loadMedia,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Image(
      key: ValueKey('encrypted-image-$fileId-${variant.name}'),
      image: EncryptedImageProvider(fileId: fileId, variant: variant, loadMedia: loadMedia ?? sl<LoadMediaUseCase>()),
      fit: fit,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        if (transparentWhileLoading) {
          return const SizedBox.shrink(key: ValueKey('encrypted-image-loading'));
        }
        return Container(
          key: const ValueKey('encrypted-image-loading'),
          color: palette.media,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: palette.onMedia)),
        );
      },
      errorBuilder: (context, error, _) => hideErrors && error is! LockedFileFailure
          ? const SizedBox.shrink(key: ValueKey('encrypted-image-error'))
          : _ErrorPlaceholder(locked: error is LockedFileFailure),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final bool locked;

  const _ErrorPlaceholder({required this.locked});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      key: ValueKey(locked ? 'encrypted-image-locked' : 'encrypted-image-error'),
      color: palette.line,
      child: Center(
        child: Tooltip(
          message: locked ? l10n.mediaLocked : l10n.mediaLoadError,
          child: Icon(locked ? Symbols.lock_rounded : Symbols.broken_image_rounded, color: palette.ink2, size: 28),
        ),
      ),
    );
  }
}
