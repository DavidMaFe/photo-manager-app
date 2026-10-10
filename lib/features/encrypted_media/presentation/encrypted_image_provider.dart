import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/load_media_use_case.dart';

/// Image of an encrypted file: downloads it (or reads it from the encrypted cache), decrypts it in memory and decodes
/// it. Flutter's image cache keeps the decoded image, also in memory only; it is emptied at logout.
@immutable
class EncryptedImageProvider extends ImageProvider<EncryptedImageProvider> {
  final String fileId;
  final MediaVariant variant;
  final LoadMediaUseCase loadMedia;

  const EncryptedImageProvider({required this.fileId, required this.variant, required this.loadMedia});

  @override
  Future<EncryptedImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<EncryptedImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(EncryptedImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _load(decode),
      scale: 1,
      debugLabel: 'encrypted:$fileId:${variant.name}',
    );
  }

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    final bytes = await loadMedia(fileId, variant);
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is EncryptedImageProvider && other.fileId == fileId && other.variant == variant;

  @override
  int get hashCode => Object.hash(fileId, variant);
}
