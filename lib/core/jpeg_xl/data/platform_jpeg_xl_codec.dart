
import 'package:flutter/services.dart';
import 'package:jpeg_xl_codec/jpeg_xl_codec.dart';
import 'package:photo_manager_app/core/jpeg_xl/domain/jpeg_xl_codec.dart';

/// [JpegXlCodec] of the local plugin `jpeg_xl_codec` (jxl-coder 2.6.1 on Android). On platforms without it every
/// call throws MissingPluginException: the files are uploaded as they are and their JPEG XL cannot be rebuilt.
class PlatformJpegXlCodec implements JpegXlCodec {
  final JpegXlCodecChannel channel;

  const PlatformJpegXlCodec({this.channel = const JpegXlCodecChannel()});

  @override
  Future<Uint8List?> jpegToJxl(Uint8List jpeg) async {
    try {
      return await channel.jpegToJxl(jpeg);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<Uint8List> jxlToJpeg(Uint8List jxl) async {
    try {
      return await channel.jxlToJpeg(jxl);
    } on MissingPluginException {
      throw const JpegXlUnavailableFailure();
    } on PlatformException {
      throw const JpegXlUnavailableFailure();
    }
  }
}
