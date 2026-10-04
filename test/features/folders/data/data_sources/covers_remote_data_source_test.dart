import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/folders/data/data_sources/covers_remote_data_source.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_change.dart';

import '../../../../fixtures/json_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient client;
  late CoversRemoteDataSourceImpl dataSource;
  const baseUrl = 'http://localhost:8080';

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    client = MockHttpClient();
    dataSource = CoversRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
  });

  final coversBody = jsonEncode({
    'covers': [
      {'fileId': 7, 'position': 1, 'sourceFolderId': 2, 'sourceFolderName': 'Playa', 'sourceFolderPath': []},
      {'fileId': 5, 'position': 0, 'sourceFolderId': 3, 'sourceFolderName': 'Atardeceres', 'sourceFolderPath': ['Atardeceres']},
    ],
  });

  http.Response error(String code, int status) => http.Response(
        jsonEncode({'code': code, 'message': code, 'timestamp': '2026-10-04T12:00:00', 'path': '/api/'}),
        status,
      );

  group('getCoverTargets', () {
    test('should GET the targets of the file', () async {
      // Arrange
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(readJson('cover_targets.json'), 200));

      // Act
      final targets = await dataSource.getCoverTargets('42');

      // Assert
      verify(() => client.get(Uri.parse('$baseUrl/api/file/42/cover-targets/'), headers: any(named: 'headers'))).called(1);
      expect(targets, hasLength(3));
    });

    test('should return no targets for a photo without album', () async {
      // Arrange
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response('[]', 200));

      // Act & Assert
      expect(await dataSource.getCoverTargets('42'), isEmpty);
    });

    test('should throw ApiException FILE_NOT_FOUND', () async {
      // Arrange
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => error('FILE_NOT_FOUND', 400));

      // Act & Assert
      expect(
        () => dataSource.getCoverTargets('42'),
        throwsA(predicate((e) => e is ApiException && e.code == 'FILE_NOT_FOUND')),
      );
    });
  });

  group('applyCoverChanges', () {
    test('should PUT the file and its changes and parse the folders', () async {
      // Arrange
      when(() => client.put(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'folders': [
              {'folderId': 2, 'covers': []},
            ],
          }),
          200,
        ),
      );

      // Act
      final folders = await dataSource.applyCoverChanges('42', const [
        CoverChange.add('1'),
        CoverChange.replace('2', '9'),
      ]);

      // Assert
      final captured = verify(
        () => client.put(captureAny(), headers: any(named: 'headers'), body: captureAny(named: 'body')),
      ).captured;
      expect(captured[0], Uri.parse('$baseUrl/api/folder/cover/batch/'));
      expect(jsonDecode(captured[1] as String), {
        'fileId': '42',
        'changes': [
          {'folderId': '1', 'action': 'add'},
          {'folderId': '2', 'action': 'replace', 'replaceFileId': '9'},
        ],
      });
      expect(folders.single.folderId, '2');
    });

    test('should throw ApiException FOLDER_COVERS_LIMIT_EXCEEDED', () async {
      // Arrange
      when(() => client.put(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => error('FOLDER_COVERS_LIMIT_EXCEEDED', 400));

      // Act & Assert
      expect(
        () => dataSource.applyCoverChanges('42', const [CoverChange.add('1')]),
        throwsA(predicate((e) => e is ApiException && e.code == 'FOLDER_COVERS_LIMIT_EXCEEDED')),
      );
    });
  });

  group('getAlbumCovers', () {
    test('should GET the covers of the album sorted by position', () async {
      // Arrange
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(coversBody, 200));

      // Act
      final covers = await dataSource.getAlbumCovers('2');

      // Assert
      verify(() => client.get(Uri.parse('$baseUrl/api/folder/2/covers/'), headers: any(named: 'headers'))).called(1);
      expect(covers.map((c) => c.fileId), ['5', '7']);
    });
  });

  group('setAlbumCovers', () {
    test('should PUT the final order', () async {
      // Arrange
      when(() => client.put(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(coversBody, 200));

      // Act
      await dataSource.setAlbumCovers('2', ['5', '7']);

      // Assert
      final captured = verify(
        () => client.put(captureAny(), headers: any(named: 'headers'), body: captureAny(named: 'body')),
      ).captured;
      expect(captured[0], Uri.parse('$baseUrl/api/folder/2/covers/'));
      expect(jsonDecode(captured[1] as String), {'fileIds': ['5', '7']});
    });

    test('should rethrow SocketException', () async {
      // Arrange
      when(() => client.put(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenThrow(const SocketException('No internet'));

      // Act & Assert
      expect(() => dataSource.setAlbumCovers('2', []), throwsA(isA<SocketException>()));
    });
  });
}
