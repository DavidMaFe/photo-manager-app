import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/folders/data/data_sources/folder_remote_data_source.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_content_model.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_model.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late FolderRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;
  late MockAuthLocalDataSource mockAuthLocalDataSource;

  const baseUrl = DataConstants.backendBaseUrl;
  const testToken = 'test-token-123';

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    dataSource = FolderRemoteDataSourceImpl(
      client: mockHttpClient,
      authLocalDataSource: mockAuthLocalDataSource,
      baseUrl: baseUrl,
    );

    when(() => mockAuthLocalDataSource.getToken())
        .thenAnswer((_) async => testToken);
  });

  group('FolderRemoteDataSource', () {
    final testDate = DateTime(2024, 1, 15, 10, 30);

    group('getFolders', () {
      test('should perform GET request with correct endpoint and headers', () async {
        // Arrange
        final responseBody = jsonEncode({
          'folders': [
            {
              'id': 'folder-1',
              'name': 'Vacation',
              'parentFolderId': null,
              'path': '/root/folder-1',
              'createdAt': testDate.toIso8601String(),
              'filesQuantity': 42,
              'subfolderCount': 3,
            },
          ],
        });

        when(() => mockHttpClient.get(
              Uri.parse('$baseUrl/api/folder/list/'),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.getFolders();

        // Assert
        final captured = verify(() => mockHttpClient.get(
              Uri.parse('$baseUrl/api/folder/list/'),
              headers: captureAny(named: 'headers'),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers['Authorization'], 'Bearer $testToken');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should return list of FolderModel when successful', () async {
        // Arrange
        final responseBody = jsonEncode({
          'folders': [
            {
              'id': 'folder-1',
              'name': 'Vacation',
              'parentFolderId': null,
              'path': '/root/folder-1',
              'createdAt': testDate.toIso8601String(),
              'filesQuantity': 42,
              'subfolderCount': 3,
            },
            {
              'id': 'folder-2',
              'name': 'Work',
              'parentFolderId': null,
              'path': '/root/folder-2',
              'createdAt': testDate.toIso8601String(),
              'filesQuantity': 15,
              'subfolderCount': 0,
            },
          ],
        });

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.getFolders();

        // Assert
        expect(result, isA<List<FolderModel>>());
        expect(result.length, 2);
        expect(result[0].name, 'Vacation');
        expect(result[1].name, 'Work');
      });

      test('should add parentId query parameter when provided', () async {
        // Arrange
        const parentId = 'parent-1';
        final responseBody = jsonEncode({'folders': []});

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.getFolders(parentFolderId: parentId);

        // Assert
        verify(() => mockHttpClient.get(
              Uri.parse('$baseUrl/api/folder/list/?parentId=$parentId'),
              headers: any(named: 'headers'),
            )).called(1);
      });

      test('should return empty list when no folders', () async {
        // Arrange
        final responseBody = jsonEncode({'folders': []});

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.getFolders();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw ApiException on 404 error', () async {
        // Arrange
        final responseBody = jsonEncode({
          'code': 'NOT_FOUND',
          'message': 'Not found',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/folder/list/',
        });

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 404));

        // Act & Assert
        expect(
          () => dataSource.getFolders(),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'NOT_FOUND' &&
                e.message == 'Not found'),
          ),
        );
      });

      test('should throw ApiException on 500 error', () async {
        // Arrange
        final responseBody = jsonEncode({
          'code': 'INTERNAL_SERVER_ERROR',
          'message': 'Server error',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/folder/list/',
        });

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 500));

        // Act & Assert
        expect(
          () => dataSource.getFolders(),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'INTERNAL_SERVER_ERROR' &&
                e.message == 'Server error'),
          ),
        );
      });

      test('should rethrow SocketException on network error', () async {
        // Arrange
        const exception = SocketException('Network error');
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => dataSource.getFolders(),
          throwsA(exception),
        );
      });
    });

    group('getFolderContent', () {
      test('should perform GET request with correct endpoint and headers', () async {
        // Arrange
        const folderId = 'folder-1';
        final responseBody = jsonEncode({
          'folderInfo': {
            'id': folderId,
            'name': 'Vacation',
            'parentFolderId': null,
            'path': '/root/folder-1',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 0,
            'subfolderCount': 0,
          },
          'subfolders': [],
          'files': {'files': [], 'hasNext': false},
        });

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.getFolderContent(folderId: folderId);

        // Assert
        final captured = verify(() => mockHttpClient.get(
              captureAny(),
              headers: captureAny(named: 'headers'),
            ));
        captured.called(1);

        final uri = captured.captured[0] as Uri;
        final headers = captured.captured[1] as Map<String, String>;

        expect(uri.path, '/api/folder/$folderId/');
        expect(headers['Content-Type'], 'application/json');
        expect(headers['Authorization'], 'Bearer $testToken');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should include page and pageSize query parameters', () async {
        // Arrange
        const folderId = 'folder-1';
        const page = 2;
        const pageSize = 25;
        final responseBody = jsonEncode({
          'folderInfo': {
            'id': folderId,
            'name': 'Vacation',
            'parentFolderId': null,
            'path': '/root/folder-1',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 0,
            'subfolderCount': 0,
          },
          'subfolders': [],
          'files': {'files': [], 'hasNext': false},
        });

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.getFolderContent(
          folderId: folderId,
          page: page,
          pageSize: pageSize,
        );

        // Assert
        final captured = verify(() => mockHttpClient.get(
              captureAny(),
              headers: any(named: 'headers'),
            )).captured;

        final uri = captured.first as Uri;
        expect(uri.queryParameters['page'], '2');
        expect(uri.queryParameters['pageSize'], '25');
      });

      test('should include fileType query parameter when provided', () async {
        // Arrange
        const folderId = 'folder-1';
        const fileType = 'IMAGE';
        final responseBody = jsonEncode({
          'folderInfo': {
            'id': folderId,
            'name': 'Vacation',
            'parentFolderId': null,
            'path': '/root/folder-1',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 0,
            'subfolderCount': 0,
          },
          'subfolders': [],
          'files': {'files': [], 'hasNext': false},
        });

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.getFolderContent(
          folderId: folderId,
          fileType: fileType,
        );

        // Assert
        final captured = verify(() => mockHttpClient.get(
              captureAny(),
              headers: any(named: 'headers'),
            )).captured;

        final uri = captured.first as Uri;
        expect(uri.queryParameters['type'], fileType);
      });

      test('should include status query parameter when provided', () async {
        // Arrange
        const folderId = 'folder-1';
        const status = 'UPLOADED';
        final responseBody = jsonEncode({
          'folderInfo': {
            'id': folderId,
            'name': 'Vacation',
            'parentFolderId': null,
            'path': '/root/folder-1',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 0,
            'subfolderCount': 0,
          },
          'subfolders': [],
          'files': {'files': [], 'hasNext': false},
        });

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.getFolderContent(
          folderId: folderId,
          status: status,
        );

        // Assert
        final captured = verify(() => mockHttpClient.get(
              captureAny(),
              headers: any(named: 'headers'),
            )).captured;

        final uri = captured.first as Uri;
        expect(uri.queryParameters['status'], status);
      });

      test('should return FolderContentModel when successful', () async {
        // Arrange
        const folderId = 'folder-1';
        final responseBody = jsonEncode({
          'folderInfo': {
            'id': folderId,
            'name': 'Vacation',
            'parentFolderId': null,
            'path': '/root/folder-1',
            'createdAt': testDate.toIso8601String(),
            'filesQuantity': 2,
            'subfolderCount': 1,
          },
          'subfolders': [
            {
              'id': 'subfolder-1',
              'name': 'Summer',
              'parentFolderId': folderId,
              'path': '/root/folder-1/subfolder-1',
              'createdAt': testDate.toIso8601String(),
              'filesQuantity': 5,
              'subfolderCount': 0,
            },
          ],
          'files': {
            'files': [
              {
                'id': 'file-1',
                'type': 'IMAGE',
                'status': 'PENDING',
                'capturedAt': testDate.toIso8601String(),
              },
            ],
            'hasNext': true,
          },
        });

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.getFolderContent(folderId: folderId);

        // Assert
        expect(result, isA<FolderContentModel>());
        expect(result.folder.id, folderId);
        expect(result.subfolders.length, 1);
        expect(result.files.length, 1);
        expect(result.hasMoreFiles, true);
      });

      test('should throw ApiException on error', () async {
        // Arrange
        const folderId = 'folder-1';
        final responseBody = jsonEncode({
          'code': 'FOLDER_NOT_FOUND',
          'message': 'Folder not found',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/folder/$folderId/',
        });

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 404));

        // Act & Assert
        expect(
          () => dataSource.getFolderContent(folderId: folderId),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'FOLDER_NOT_FOUND' &&
                e.message == 'Folder not found'),
          ),
        );
      });
    });

    group('createFolder', () {
      test('should perform POST request with correct endpoint and body', () async {
        // Arrange
        const folderName = 'Vacation';
        final responseBody = jsonEncode({
          'id': 'folder-1',
          'name': folderName,
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        });

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.createFolder(name: folderName);

        // Assert
        final captured = verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/folder/new/'),
              headers: captureAny(named: 'headers'),
              body: jsonEncode({'folderName': folderName}),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers['Authorization'], 'Bearer $testToken');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should include parentFolderId in request when provided', () async {
        // Arrange
        const folderName = 'Vacation';
        const parentFolderId = 'parent-1';
        final responseBody = jsonEncode({
          'id': 'folder-1',
          'name': folderName,
          'parentFolderId': parentFolderId,
          'path': '/root/parent-1/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        });

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.createFolder(
          name: folderName,
          parentFolderId: parentFolderId,
        );

        // Assert
        final captured = verify(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: captureAny(named: 'body'),
            )).captured;

        final body = jsonDecode(captured.first as String);
        expect(body['folderName'], folderName);
        expect(body['parentFolderId'], parentFolderId);
      });

      test('should return FolderModel when successful', () async {
        // Arrange
        const folderName = 'Vacation';
        final responseBody = jsonEncode({
          'id': 'folder-1',
          'name': folderName,
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 0,
          'subfolderCount': 0,
        });

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.createFolder(name: folderName);

        // Assert
        expect(result, isA<FolderModel>());
        expect(result.name, folderName);
      });

      test('should throw ApiException on 409 conflict error', () async {
        // Arrange
        const folderName = 'Vacation';
        final responseBody = jsonEncode({
          'code': 'FOLDER_ALREADY_EXISTS',
          'message': 'Folder already exists',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/folder/new/',
        });

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 409));

        // Act & Assert
        expect(
          () => dataSource.createFolder(name: folderName),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'FOLDER_ALREADY_EXISTS' &&
                e.message == 'Folder already exists'),
          ),
        );
      });
    });

    group('renameFolder', () {
      test('should perform PUT request with correct endpoint and body', () async {
        // Arrange
        const folderId = 'folder-1';
        const newName = 'New Vacation';
        final responseBody = jsonEncode({
          'id': folderId,
          'name': newName,
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 42,
          'subfolderCount': 3,
        });

        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.renameFolder(folderId: folderId, newName: newName);

        // Assert
        final captured = verify(() => mockHttpClient.put(
              Uri.parse('$baseUrl/api/folder/$folderId/'),
              headers: captureAny(named: 'headers'),
              body: jsonEncode({'newName': newName}),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers['Authorization'], 'Bearer $testToken');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should return FolderModel when successful', () async {
        // Arrange
        const folderId = 'folder-1';
        const newName = 'New Vacation';
        final responseBody = jsonEncode({
          'id': folderId,
          'name': newName,
          'parentFolderId': null,
          'path': '/root/folder-1',
          'createdAt': testDate.toIso8601String(),
          'filesQuantity': 42,
          'subfolderCount': 3,
        });

        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.renameFolder(
          folderId: folderId,
          newName: newName,
        );

        // Assert
        expect(result, isA<FolderModel>());
        expect(result.name, newName);
      });

      test('should throw ApiException on error', () async {
        // Arrange
        const folderId = 'folder-1';
        const newName = 'New Name';
        final responseBody = jsonEncode({
          'code': 'FOLDER_NOT_FOUND',
          'message': 'Folder not found',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/folder/$folderId/',
        });

        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 404));

        // Act & Assert
        expect(
          () => dataSource.renameFolder(folderId: folderId, newName: newName),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'FOLDER_NOT_FOUND' &&
                e.message == 'Folder not found'),
          ),
        );
      });
    });

    group('deleteFolder', () {
      test('should perform DELETE request with correct endpoint', () async {
        // Arrange
        const folderId = 'folder-1';

        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response('', 200));

        // Act
        await dataSource.deleteFolder(folderId: folderId);

        // Assert
        final captured = verify(() => mockHttpClient.delete(
              Uri.parse('$baseUrl/api/folder/$folderId/'),
              headers: captureAny(named: 'headers'),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers['Authorization'], 'Bearer $testToken');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should complete successfully on 200 status', () async {
        // Arrange
        const folderId = 'folder-1';

        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response('', 200));

        // Act & Assert
        expect(
          dataSource.deleteFolder(folderId: folderId),
          completes,
        );
      });

      test('should throw ApiException on 404 error', () async {
        // Arrange
        const folderId = 'folder-1';
        final responseBody = jsonEncode({
          'code': 'FOLDER_NOT_FOUND',
          'message': 'Folder not found',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/folder/$folderId/',
        });

        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(responseBody, 404));

        // Act & Assert
        expect(
          () => dataSource.deleteFolder(folderId: folderId),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'FOLDER_NOT_FOUND' &&
                e.message == 'Folder not found'),
          ),
        );
      });

      test('should throw ApiException on 400 error (folder not empty)', () async {
        // Arrange
        const folderId = 'folder-1';
        final responseBody = jsonEncode({
          'code': 'FOLDER_NOT_EMPTY',
          'message': 'Folder is not empty',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/folder/$folderId/',
        });

        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(responseBody, 400));

        // Act & Assert
        expect(
          () => dataSource.deleteFolder(folderId: folderId),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'FOLDER_NOT_EMPTY' &&
                e.message == 'Folder is not empty'),
          ),
        );
      });
    });
  });
}
