import 'dart:typed_data';

import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_codec.dart';
import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_format.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/original_content.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/decrypted_range_reader.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/use_cases/get_file_metadata_use_case.dart';

/// The decrypted original of a file with its real name and MIME type, for saving or sharing it.
///
/// It reads the original by ranges ([DecryptedRangeReader]), without the cache of the viewer. A video comes in chunks
/// of [chunkLength] bytes. An image comes whole (at most 20 MB): if it is stored in JPEG XL it is rebuilt into its exact
/// JPEG, which every app opens.
class OriginalContentReader {
  static const int chunkLength = 8 * 1024 * 1024;

  final DecryptedRangeReader _rangeReader;
  final GetFileMetadataUseCase _getFileMetadata;
  final JpegXlCodec _jpegXlCodec;

  OriginalContentReader(this._rangeReader, this._getFileMetadata, this._jpegXlCodec);

  Future<OriginalContent> read(String fileId, {required bool isVideo}) async {
    final metadata = await _getFileMetadata(fileId);
    final length = await _rangeReader.plainLength(fileId);
    var mimeType = metadata.mimeType ?? (isVideo ? 'video/mp4' : 'image/jpeg');
    var fileName = metadata.name ?? 'PhotoManager_$fileId${_extensionFor(mimeType)}';

    if (isVideo) {
      return OriginalContent(fileName: fileName, mimeType: mimeType, length: length, bytes: _chunks(fileId, length));
    }

    var bytes = length == 0 ? Uint8List(0) : await _rangeReader.read(fileId, 0, length - 1);
    if (JpegXlFormat.isJpegXl(bytes)) {
      bytes = await _jpegXlCodec.jxlToJpeg(bytes);
      mimeType = 'image/jpeg';
    }
    return OriginalContent(fileName: fileName, mimeType: mimeType, length: bytes.length, bytes: Stream.value(bytes));
  }

  Stream<Uint8List> _chunks(String fileId, int length) async* {
    for (var start = 0; start < length; start += chunkLength) {
      final end = (start + chunkLength < length ? start + chunkLength : length) - 1;
      yield await _rangeReader.read(fileId, start, end);
    }
  }

  static String _extensionFor(String mimeType) => switch (mimeType) {
        'image/png' => '.png',
        'image/heic' || 'image/heif' => '.heic',
        'image/webp' => '.webp',
        'image/gif' => '.gif',
        'video/quicktime' => '.mov',
        _ when mimeType.startsWith('video/') => '.mp4',
        _ => '.jpg',
      };
}
