import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/server_files_remote_data_source.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  late List<http.Request> requests;

  ServerFilesRemoteDataSourceImpl dataSource(int status, Object body) => ServerFilesRemoteDataSourceImpl(
        baseUrl: baseUrl,
        client: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});
        }),
      );

  setUp(() => requests = []);

  group('getFiles', () {
    test('should ask for every file and parse them', () async {
      final files = await dataSource(200, {
        'files': [
          {'id': 7, 'type': 'VIDEO', 'sizeBytes': 1234, 'folderId': null},
          {'id': 8, 'type': 'IMAGE', 'sizeBytes': 99, 'folderId': 3},
        ],
      }).getFiles();

      expect(requests.single.url.toString(), '$baseUrl/api/file/ids/');
      expect(files.first.id, '7');
      expect(files.first.type, FileType.video);
      expect(files.first.sizeBytes, 1234);
      expect(files.first.folderId, isNull);
      expect(files.last.folderId, '3');
    });

    test('should ask only for an album and its subalbums', () async {
      await dataSource(200, {'files': []}).getFiles(folderId: '3', includeSubfolders: true);

      expect(requests.single.url.queryParameters, {'folder': '3', 'includeSubfolders': 'true'});
    });

    test('should throw ApiException with the error of the server', () async {
      final call = dataSource(400, {'code': 'FOLDER_NOT_FOUND', 'message': 'x', 'timestamp': 't'}).getFiles(
          folderId: '9');

      await expectLater(call, throwsA(isA<ApiException>()));
    });
  });

  group('getFilesByIds', () {
    test('should send the ids as numbers and parse the files with their keys', () async {
      final files = await dataSource(200, {
        'files': [
          {
            'id': 7,
            'type': 'IMAGE',
            'status': 'MANAGED',
            'capturedAt': '2024-08-03T10:42:00',
            'sizeBytes': 10,
            'encryptedFileKey': 'a2V5',
            'keyVersion': 1,
            'encryptedMetadata': 'bWV0YQ==',
          },
        ],
      }).getFilesByIds(['7', '8']);

      expect(requests.single.url.path, '/api/file/list/by-ids/');
      expect(jsonDecode(requests.single.body), {'fileIds': [7, 8]});
      expect(files.single.id, '7');
      expect(files.single.capturedAt, DateTime(2024, 8, 3, 10, 42));
      expect(files.single.encryptedRef?.keyVersion, 1);
    });
  });

  group('markOnDevice', () {
    test('should send the device and the ids', () async {
      await dataSource(200, {'updated': [7]}).markOnDevice('phone-uuid', ['7']);

      expect(requests.single.url.path, '/api/file/on-device/');
      expect(jsonDecode(requests.single.body), {'deviceUuid': 'phone-uuid', 'fileIds': [7]});
    });

    test('should throw ApiException when the device is not of the user', () async {
      final call = dataSource(400, {'code': 'DEVICE_NOT_FOUND', 'message': 'x', 'timestamp': 't'})
          .markOnDevice('x', ['7']);

      await expectLater(call, throwsA(isA<ApiException>()));
    });
  });
}
