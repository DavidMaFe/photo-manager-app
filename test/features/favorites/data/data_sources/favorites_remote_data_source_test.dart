import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/favorites/data/data_sources/favorites_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient client;
  late FavoritesRemoteDataSourceImpl dataSource;
  const baseUrl = 'http://localhost:8080';

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    client = MockHttpClient();
    dataSource = FavoritesRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
  });

  group('FavoritesRemoteDataSource', () {
    test('should POST the IDs and the value to set', () async {
      // Arrange
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(jsonEncode({'updated': [1, 2], 'failed': []}), 200),
      );

      // Act
      final result = await dataSource.setFavorite(['1', '2'], true);

      // Assert
      final captured = verify(
        () => client.post(captureAny(), headers: captureAny(named: 'headers'), body: captureAny(named: 'body')),
      ).captured;
      expect(captured[0], Uri.parse('$baseUrl/api/file/favorite/'));
      expect((captured[1] as Map<String, String>)['Content-Type'], 'application/json');
      expect(jsonDecode(captured[2] as String), {'fileIds': ['1', '2'], 'favorite': true});
      expect(result.updatedIds, ['1', '2']);
    });

    test('should throw ApiException on non-200 status code', () async {
      // Arrange
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'code': 'VALIDATION_ERROR',
            'message': 'File IDs are required',
            'timestamp': '2026-10-04T12:00:00',
            'path': '/api/file/favorite/',
          }),
          400,
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.setFavorite([], true),
        throwsA(predicate((e) => e is ApiException && e.code == 'VALIDATION_ERROR')),
      );
    });

    test('should rethrow SocketException', () async {
      // Arrange
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenThrow(const SocketException('No internet'));

      // Act & Assert
      expect(() => dataSource.setFavorite(['1'], false), throwsA(isA<SocketException>()));
    });
  });
}
