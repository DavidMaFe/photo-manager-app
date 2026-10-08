import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/encrypted_media/data/data_sources/encrypted_media_remote_data_source.dart';
import 'package:photo_manager_app/features/encrypted_media/data/data_sources/encrypted_object_cache.dart';
import 'package:photo_manager_app/features/encrypted_media/data/models/encrypted_file_ref_model.dart';
import 'package:photo_manager_app/features/encrypted_media/data/repositories/encrypted_media_data_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/data/repositories/file_key_data_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_range.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_failures.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';

import '../../../helpers/recording_file_key_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockRemote extends Mock implements EncryptedMediaRemoteDataSource {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() => registerFallbackValue(FakeUri()));

  final keyB64 = base64Encode(Uint8List(72));
  final metadataB64 = base64Encode(Uint8List(50));

  group('EncryptedFileRefModel', () {
    test('should parse the key, its version and the metadata', () {
      final ref = EncryptedFileRefModel.fromJson(
          {'id': 5, 'encryptedFileKey': keyB64, 'keyVersion': 2, 'encryptedMetadata': metadataB64})!;

      expect(ref.fileId, '5');
      expect(ref.keyVersion, 2);
      expect(ref.encryptedFileKey, hasLength(72));
      expect(ref.encryptedMetadata, hasLength(50));
    });

    test('should read the id from fileId in the keys endpoint', () {
      final ref = EncryptedFileRefModel.fromJson({'fileId': 9, 'encryptedFileKey': keyB64, 'keyVersion': 1},
          idField: 'fileId')!;

      expect(ref.fileId, '9');
      expect(ref.encryptedMetadata, isNull);
    });

    test('should give null for files without a key', () {
      expect(EncryptedFileRefModel.fromJson({'id': 1, 'encryptedFileKey': null, 'keyVersion': null}), isNull);
    });
  });

  group('EncryptedMediaRemoteDataSource', () {
    late MockHttpClient client;
    late EncryptedMediaRemoteDataSourceImpl remote;

    setUp(() {
      client = MockHttpClient();
      remote = EncryptedMediaRemoteDataSourceImpl(client: client, baseUrl: 'http://server');
    });

    test('should download the thumbnail and the original from their endpoints', () async {
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response.bytes([1, 2, 3], 200));

      expect(await remote.getObject('5', MediaVariant.thumbnail), [1, 2, 3]);
      await remote.getObject('5', MediaVariant.original);

      final urls = verify(() => client.get(captureAny(), headers: any(named: 'headers'))).captured;
      expect(urls.map((url) => url.toString()), ['http://server/api/file/5/thumbnail/', 'http://server/api/file/5/']);
    });

    test('should ask for a range and read the total size from Content-Range', () async {
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async =>
          http.Response.bytes([7, 8], 206, headers: {'content-range': 'bytes 10-11/5072'}));

      final range = await remote.getOriginalRange('5', 10, 11);

      expect(range.bytes, [7, 8]);
      expect(range.totalLength, 5072);
      final headers = verify(() => client.get(any(), headers: captureAny(named: 'headers'))).captured.single as Map;
      expect(headers[HttpHeaders.rangeHeader], 'bytes=10-11');
    });

    test('should throw ApiException with the error of the backend', () async {
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(
          jsonEncode({'code': 'FILE_NOT_FOUND', 'message': 'Not found', 'timestamp': 'now'}), 404));

      await expectLater(remote.getObject('5', MediaVariant.original),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 'FILE_NOT_FOUND')));
    });

    test('should POST the ids and parse the keys, leaving out the files without one', () async {
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(jsonEncode({
                'files': [
                  {'fileId': 1, 'encryptedFileKey': keyB64, 'keyVersion': 1, 'encryptedMetadata': metadataB64},
                  {'fileId': 2, 'encryptedFileKey': null, 'keyVersion': null, 'encryptedMetadata': null},
                ]
              }), 200));

      final refs = await remote.getFileKeys(['1', '2']);

      expect(refs.map((ref) => ref.fileId), ['1']);
      final captured = verify(() => client.post(captureAny(), headers: any(named: 'headers'),
          body: captureAny(named: 'body'))).captured;
      expect(captured.first.toString(), 'http://server/api/file/keys/');
      expect(jsonDecode(captured.last as String), {'fileIds': [1, 2]});
    });
  });

  group('EncryptedObjectCache', () {
    late Directory dir;

    setUp(() async => dir = await Directory.systemTemp.createTemp('object_cache'));

    tearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('should keep the objects as they are, by file and variant', () async {
      final cache = EncryptedObjectCache(baseDirectory: () async => dir);

      await cache.write('5', MediaVariant.thumbnail, Uint8List.fromList([1, 2]));

      expect(await cache.read('5', MediaVariant.thumbnail), [1, 2]);
      expect(await cache.read('5', MediaVariant.original), isNull);
      expect(File('${dir.path}/encrypted_media/thumbnail/5.pmef').existsSync(), isTrue);
    });

    test('should remove the least recently used objects over the limit', () async {
      final cache = EncryptedObjectCache(baseDirectory: () async => dir, maxBytes: 250);
      await cache.write('1', MediaVariant.original, Uint8List(100));
      await cache.write('2', MediaVariant.original, Uint8List(100));
      // Object 1 is used again, so object 2 is the oldest
      await File('${dir.path}/encrypted_media/original/2.pmef').setLastModified(DateTime(2020));
      await cache.read('1', MediaVariant.original);

      await cache.write('3', MediaVariant.original, Uint8List(100));

      expect(await cache.read('2', MediaVariant.original), isNull);
      expect(await cache.read('1', MediaVariant.original), isNotNull);
      expect(await cache.read('3', MediaVariant.original), isNotNull);
    });

    test('should remove everything on clear (logout)', () async {
      final cache = EncryptedObjectCache(baseDirectory: () async => dir);
      await cache.write('1', MediaVariant.original, Uint8List(10));

      await cache.clear();

      expect(Directory('${dir.path}/encrypted_media').existsSync(), isFalse);
      expect(await cache.read('1', MediaVariant.original), isNull);
    });
  });

  group('EncryptedMediaDataRepository', () {
    late Directory dir;
    late MockRemote remote;
    late EncryptedMediaDataRepository repository;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('media_repository');
      remote = MockRemote();
      repository = EncryptedMediaDataRepository(remoteDataSource: remote,
          cache: EncryptedObjectCache(baseDirectory: () async => dir));
    });

    tearDown(() => dir.delete(recursive: true));

    test('should download once and then read from the encrypted cache', () async {
      when(() => remote.getObject('5', MediaVariant.thumbnail)).thenAnswer((_) async => Uint8List.fromList([4]));

      expect(await repository.object('5', MediaVariant.thumbnail), [4]);
      expect(await repository.object('5', MediaVariant.thumbnail), [4]);

      verify(() => remote.getObject('5', MediaVariant.thumbnail)).called(1);
    });

    test('should share one download between simultaneous requests', () async {
      final completer = Completer<Uint8List>();
      when(() => remote.getObject('5', MediaVariant.original)).thenAnswer((_) => completer.future);

      final first = repository.object('5', MediaVariant.original);
      final second = repository.object('5', MediaVariant.original);
      await Future<void>.delayed(Duration.zero);
      completer.complete(Uint8List.fromList([1]));

      expect(await first, [1]);
      expect(await second, [1]);
      verify(() => remote.getObject('5', MediaVariant.original)).called(1);
    });

    test('should serve ranges of an original already in the cache without the network', () async {
      when(() => remote.getObject('5', MediaVariant.original))
          .thenAnswer((_) async => Uint8List.fromList(List.generate(100, (i) => i)));
      await repository.object('5', MediaVariant.original);

      final range = await repository.originalRange('5', 10, 12);

      expect(range.bytes, [10, 11, 12]);
      expect(range.totalLength, 100);
      verifyNever(() => remote.getOriginalRange(any(), any(), any()));
    });

    test('should ask the backend for ranges of originals not in the cache', () async {
      when(() => remote.getOriginalRange('5', 0, 31))
          .thenAnswer((_) async => EncryptedRange(bytes: Uint8List(32), totalLength: 999));

      expect((await repository.originalRange('5', 0, 31)).totalLength, 999);
    });
  });

  group('FileKeyDataRepository', () {
    late MockRemote remote;
    late FileKeyDataRepository repository;

    setUp(() {
      remote = MockRemote();
      repository = FileKeyDataRepository(remoteDataSource: remote);
    });

    test('should answer from memory the keys of the listed files', () async {
      final ref = RecordingFileKeyRepository.ref('1');
      repository.remember([ref]);

      expect(await repository.refFor('1'), ref);
      verifyNever(() => remote.getFileKeys(any()));
    });

    test('should ask the server once for all the ids of the same moment', () async {
      when(() => remote.getFileKeys(any())).thenAnswer((invocation) async => [
            for (final id in invocation.positionalArguments.first as List<String>) RecordingFileKeyRepository.ref(id)
          ]);

      final refs = await Future.wait([repository.refFor('1'), repository.refFor('2'), repository.refFor('3')]);

      expect(refs.map((ref) => ref.fileId), ['1', '2', '3']);
      final asked = verify(() => remote.getFileKeys(captureAny())).captured.single as List<String>;
      expect(asked, ['1', '2', '3']);
      // Now they are known
      await repository.refFor('2');
      verifyNoMoreInteractions(remote);
    });

    test('should split more than 200 ids in several requests', () async {
      when(() => remote.getFileKeys(any())).thenAnswer((invocation) async => [
            for (final id in invocation.positionalArguments.first as List<String>) RecordingFileKeyRepository.ref(id)
          ]);

      await Future.wait([for (var i = 0; i < 450; i++) repository.refFor('$i')]);

      final sizes = verify(() => remote.getFileKeys(captureAny())).captured.map((ids) => (ids as List).length);
      expect(sizes, [200, 200, 50]);
    });

    test('should fail with UnencryptedFileFailure for a file without a key', () async {
      when(() => remote.getFileKeys(any())).thenAnswer((_) async => <EncryptedFileRef>[]);

      await expectLater(repository.refFor('1'), throwsA(isA<UnencryptedFileFailure>()));
    });

    test('should pass the network error to every id of the batch', () async {
      when(() => remote.getFileKeys(any())).thenThrow(const SocketException('offline'));

      await expectLater(Future.wait([repository.refFor('1'), repository.refFor('2')]), throwsA(isA<SocketException>()));
    });

    test('should forget the keys on clear', () async {
      repository.remember([RecordingFileKeyRepository.ref('1')]);
      when(() => remote.getFileKeys(any())).thenAnswer((_) async => <EncryptedFileRef>[]);

      repository.clear();

      await expectLater(repository.refFor('1'), throwsA(isA<UnencryptedFileFailure>()));
    });
  });
}
