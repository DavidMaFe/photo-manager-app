import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:photo_manager_app/features/encrypted_media/domain/services/decrypted_range_reader.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/video_stream_server.dart';

/// HTTP server on 127.0.0.1 that the video player reads from (docs/e2ee-spec.md, section 11). Each video gets an
/// address with a random token; the server answers the Range requests of the player over the plaintext, decrypting
/// only the chunks they need. Nothing decrypted is written to disk.
class LocalVideoStreamServer implements VideoStreamServer {
  /// Biggest answer to an open range ("bytes=0-"): the player asks for the next part when it needs it.
  static const int maxResponseBytes = 4 * 1024 * 1024;

  final DecryptedRangeReader _reader;
  final Random _random;
  final Map<String, ({String fileId, String mimeType})> _videos = {};
  HttpServer? _server;

  LocalVideoStreamServer(this._reader, {Random? random}) : _random = random ?? Random.secure();

  @override
  Future<Uri> urlFor(String fileId, {String? mimeType}) async {
    final server = _server ??= await _start();
    final token = List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    _videos[token] = (fileId: fileId, mimeType: mimeType ?? 'video/mp4');
    return Uri.parse('http://${InternetAddress.loopbackIPv4.address}:${server.port}/v/$token');
  }

  @override
  Future<void> stop() async {
    _videos.clear();
    await _server?.close(force: true);
    _server = null;
  }

  Future<HttpServer> _start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen(_handle);
    return server;
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    try {
      final segments = request.uri.pathSegments;
      final video = segments.length == 2 && segments.first == 'v' ? _videos[segments.last] : null;
      if (video == null || (request.method != 'GET' && request.method != 'HEAD')) {
        response.statusCode = video == null ? HttpStatus.notFound : HttpStatus.methodNotAllowed;
        return;
      }

      final total = await _reader.plainLength(video.fileId);
      final range = parseRange(request.headers.value(HttpHeaders.rangeHeader), total);
      response.headers
        ..contentType = ContentType.parse(video.mimeType)
        ..set(HttpHeaders.acceptRangesHeader, 'bytes');

      if (range == null) {
        response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
        response.headers.set(HttpHeaders.contentRangeHeader, 'bytes */$total');
        return;
      }

      final (start, end) = range;
      response.statusCode = HttpStatus.partialContent;
      response.headers.set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$total');
      response.contentLength = end - start + 1;
      if (request.method == 'GET') {
        response.add(await _reader.read(video.fileId, start, end));
      }
    } catch (_) {
      // The player retries; nothing about the file is logged
      try {
        response.statusCode = HttpStatus.internalServerError;
      } on StateError {
        // Headers already sent
      }
    } finally {
      await response.close();
    }
  }

  /// Plaintext range to serve for the Range header [header] over [total] bytes, or null if it cannot be satisfied.
  /// Without a header or with an open range, at most [maxResponseBytes] are served.
  static (int, int)? parseRange(String? header, int total) {
    if (total == 0) {
      return null;
    }
    if (header == null) {
      return (0, min(total, maxResponseBytes) - 1);
    }
    final match = RegExp(r'^bytes=(\d*)-(\d*)$').firstMatch(header.trim());
    if (match == null || (match.group(1)!.isEmpty && match.group(2)!.isEmpty)) {
      return null;
    }
    final startText = match.group(1)!;
    final endText = match.group(2)!;
    if (startText.isEmpty) {
      // Suffix: the last N bytes
      final length = min(int.parse(endText), total);
      return length == 0 ? null : (total - length, total - 1);
    }
    final start = int.parse(startText);
    if (start >= total) {
      return null;
    }
    final end = endText.isEmpty ? min(total, start + maxResponseBytes) - 1 : min(int.parse(endText), total - 1);
    return end < start ? null : (start, end);
  }
}
