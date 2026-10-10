import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/encrypted_media/data/services/local_video_stream_server.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/decrypted_range_reader.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/services/file_key_unwrapper.dart';

import '../../../helpers/e2ee_test_kit.dart';
import '../helpers/encrypted_media_fixtures.dart';

void main() {
  group('LocalVideoStreamServer.parseRange', () {
    const max = LocalVideoStreamServer.maxResponseBytes;

    test('should serve the asked bytes, clipped to the end of the file', () {
      expect(LocalVideoStreamServer.parseRange('bytes=0-99', 1000), (0, 99));
      expect(LocalVideoStreamServer.parseRange('bytes=900-5000', 1000), (900, 999));
    });

    test('should serve at most 4 MiB for an open range or no range', () {
      expect(LocalVideoStreamServer.parseRange('bytes=10-', 1000), (10, 999));
      expect(LocalVideoStreamServer.parseRange('bytes=0-', 10 * max), (0, max - 1));
      expect(LocalVideoStreamServer.parseRange(null, 10 * max), (0, max - 1));
    });

    test('should serve the last bytes of a suffix range', () {
      expect(LocalVideoStreamServer.parseRange('bytes=-100', 1000), (900, 999));
      expect(LocalVideoStreamServer.parseRange('bytes=-5000', 1000), (0, 999));
    });

    test('should not satisfy ranges outside the file or malformed', () {
      expect(LocalVideoStreamServer.parseRange('bytes=1000-', 1000), isNull);
      expect(LocalVideoStreamServer.parseRange('bytes=50-10', 1000), isNull);
      expect(LocalVideoStreamServer.parseRange('bytes=-', 1000), isNull);
      expect(LocalVideoStreamServer.parseRange('items=0-1', 1000), isNull);
      expect(LocalVideoStreamServer.parseRange('bytes=0-1', 0), isNull);
    });
  });

  group('LocalVideoStreamServer', () {
    late EncryptedTestFile video;
    late LocalVideoStreamServer server;
    late HttpClient http;

    setUp(() async {
      final kit = await E2eeTestKit.create();
      final engine = await smallChunkEngine();
      final account = await kit.material('the password', E2eeTestKit.cheapParams());
      await kit.keyring.storeNewKey(1, account);
      video = await EncryptedTestFile.create(engine, account.masterKey);
      final media = FakeEncryptedMediaRepository({video.fileId: video});
      final reader = DecryptedRangeReader(media, FileKeyUnwrapper(engine, kit.store, keysOf([video])), engine);
      server = LocalVideoStreamServer(reader);
      http = HttpClient();
    });

    tearDown(() async {
      http.close(force: true);
      await server.stop();
    });

    Future<(HttpClientResponse, List<int>)> get(Uri url, {String? range, String method = 'GET'}) async {
      final request = await http.openUrl(method, url);
      if (range != null) request.headers.set(HttpHeaders.rangeHeader, range);
      final response = await request.close();
      final body = await response.fold<List<int>>([], (all, chunk) => all..addAll(chunk));
      return (response, body);
    }

    test('should give a local address with a token', () async {
      final url = await server.urlFor(video.fileId, mimeType: 'video/quicktime');

      expect(url.host, '127.0.0.1');
      expect(url.path, matches(RegExp(r'^/v/[0-9a-f]{32}$')));
    });

    test('should answer a range of the player with the decrypted bytes', () async {
      final url = await server.urlFor(video.fileId, mimeType: 'video/quicktime');

      final (response, body) = await get(url, range: 'bytes=1000-3100');

      expect(response.statusCode, HttpStatus.partialContent);
      expect(response.headers.value(HttpHeaders.contentRangeHeader), 'bytes 1000-3100/5000');
      expect(response.headers.value(HttpHeaders.acceptRangesHeader), 'bytes');
      expect(response.headers.contentType?.mimeType, 'video/quicktime');
      expect(body, video.plain.sublist(1000, 3101));
    });

    test('should answer HEAD with the size and no body', () async {
      final url = await server.urlFor(video.fileId);

      final (response, body) = await get(url, method: 'HEAD');

      expect(response.statusCode, HttpStatus.partialContent);
      expect(response.headers.value(HttpHeaders.contentRangeHeader), 'bytes 0-4999/5000');
      expect(response.headers.contentType?.mimeType, 'video/mp4');
      expect(body, isEmpty);
    });

    test('should answer 416 with the size for a range outside the video', () async {
      final url = await server.urlFor(video.fileId);

      final (response, _) = await get(url, range: 'bytes=6000-');

      expect(response.statusCode, HttpStatus.requestedRangeNotSatisfiable);
      expect(response.headers.value(HttpHeaders.contentRangeHeader), 'bytes */5000');
    });

    test('should answer 404 to an unknown token', () async {
      final url = await server.urlFor(video.fileId);

      final (response, _) = await get(url.replace(path: '/v/0000'));

      expect(response.statusCode, HttpStatus.notFound);
    });

    test('should stop serving after stop (logout)', () async {
      final url = await server.urlFor(video.fileId);

      await server.stop();

      await expectLater(get(url), throwsA(isA<SocketException>()));
    });
  });
}
