import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/data_constants.dart';
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
        verify(() => mockHttpClient.get(
              Uri.parse('$baseUrl/api/folder/list/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $testToken',
              },
            )).called(1);
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

      test('should throw HttpException on 404 error', () async {
        // Arrange
        final responseBody = jsonEncode({'message': 'Not found'});

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 404));

        // Act & Assert
        expect(
          () => dataSource.getFolders(),
          throwsA(isA<HttpException>()),
        );
      });

      test('should throw HttpException on 500 error', () async {
        // Arrange
        final responseBody = jsonEncode({'message': 'Server error'});

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 500));

        // Act & Assert
        expect(
          () => dataSource.getFolders(),
          throwsA(isA<HttpException>()),
        );
      });

      test('should throw Exception on network error', () async {
        // Arrange
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenThrow(const SocketException('Network error'));

        // Act & Assert
        expect(
          () => dataSource.getFolders(),
          throwsException,
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
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $testToken',
              },
            )).captured;

        final uri = captured.first as Uri;
        expect(uri.path, '/api/folder/$folderId/');
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

      test('should throw HttpException on error', () async {
        // Arrange
        const folderId = 'folder-1';
        final responseBody = jsonEncode({'message': 'Folder not found'});

        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(responseBody, 404));

        // Act & Assert
        expect(
          () => dataSource.getFolderContent(folderId: folderId),
          throwsA(isA<HttpException>()),
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
        verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/folder/new/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $testToken',
              },
              body: jsonEncode({'folderName': folderName}),
            )).called(1);
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

      test('should throw HttpException on 409 conflict error', () async {
        // Arrange
        const folderName = 'Vacation';
        final responseBody = jsonEncode({'message': 'Folder already exists'});

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 409));

        // Act & Assert
        expect(
          () => dataSource.createFolder(name: folderName),
          throwsA(isA<HttpException>()),
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
        verify(() => mockHttpClient.put(
              Uri.parse('$baseUrl/api/folder/$folderId/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $testToken',
              },
              body: jsonEncode({'newName': newName}),
            )).called(1);
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

      test('should throw HttpException on error', () async {
        // Arrange
        const folderId = 'folder-1';
        const newName = 'New Name';
        final responseBody = jsonEncode({'message': 'Folder not found'});

        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(responseBody, 404));

        // Act & Assert
        expect(
          () => dataSource.renameFolder(folderId: folderId, newName: newName),
          throwsA(isA<HttpException>()),
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
        verify(() => mockHttpClient.delete(
              Uri.parse('$baseUrl/api/folder/$folderId/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $testToken',
              },
            )).called(1);
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

      test('should throw HttpException on 404 error', () async {
        // Arrange
        const folderId = 'folder-1';
        final responseBody = jsonEncode({'message': 'Folder not found'});

        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(responseBody, 404));

        // Act & Assert
        expect(
          () => dataSource.deleteFolder(folderId: folderId),
          throwsA(isA<HttpException>()),
        );
      });

      test('should throw HttpException on 400 error (folder not empty)', () async {
        // Arrange
        const folderId = 'folder-1';
        final responseBody = jsonEncode({'message': 'Folder is not empty'});

        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(responseBody, 400));

        // Act & Assert
        expect(
          () => dataSource.deleteFolder(folderId: folderId),
          throwsA(isA<HttpException>()),
        );
      });
    });
  });
}
