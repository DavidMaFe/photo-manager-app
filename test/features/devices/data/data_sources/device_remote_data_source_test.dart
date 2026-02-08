import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/devices/data/data_sources/device_remote_data_source.dart';
import 'package:photo_manager_app/features/devices/data/models/device_model.dart';
import '../../../../fixtures/test_data.dart';
import '../../../../helpers/mock_factories.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late DeviceRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  const baseUrl = 'http://localhost:8080';

  setUpAll(() async {
    // Initialize Flutter bindings for PlatformDispatcher
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeUri());
    // Set up mock SharedPreferences with a test token
    await setupMockSharedPreferences({
      'auth_token': 'test_token_123',
    });
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = DeviceRemoteDataSourceImpl(
      client: mockHttpClient,
      baseUrl: baseUrl,
    );
  });

  group('DeviceRemoteDataSource', () {
    group('getUserDevices', () {
      test('should perform GET request with correct endpoint', () async {
        // Arrange
        final responseBody =
            jsonEncode(TestDeviceJsonData.deviceListResponse);

        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        await dataSource.getUserDevices();

        // Assert
        verify(() => mockHttpClient.get(
              Uri.parse('$baseUrl/api/device/list/'),
              headers: any(named: 'headers'),
            )).called(1);
      });

      test('should return list of DeviceModel on success', () async {
        // Arrange
        final responseBody =
            jsonEncode(TestDeviceJsonData.deviceListResponse);

        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.getUserDevices();

        // Assert
        expect(result, isA<List<DeviceModel>>());
        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[0].name, 'Samsung Galaxy S21');
        expect(result[1].id, '2');
        expect(result[1].name, 'iPhone 13 Pro');
      });

      test('should return empty list when no devices exist', () async {
        // Arrange
        final responseBody =
            jsonEncode(TestDeviceJsonData.emptyDeviceListResponse);

        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.getUserDevices();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw ApiException on 401 Unauthorized', () async {
        // Arrange
        final errorResponse = HttpErrorResponses.unauthorized();

        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => dataSource.getUserDevices(),
          throwsA(isA<ApiException>()),
        );
      });

      test('should throw ApiException on 500 Internal Server Error',
          () async {
        // Arrange
        final errorResponse = HttpErrorResponses.internalServerError();

        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => dataSource.getUserDevices(),
          throwsA(isA<ApiException>()),
        );
      });

      test('should throw SocketException on network error', () async {
        // Arrange
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenThrow(const SocketException('No internet connection'));

        // Act & Assert
        expect(
          () => dataSource.getUserDevices(),
          throwsA(isA<SocketException>()),
        );
      });

      test('should throw HttpException on HTTP error', () async {
        // Arrange
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenThrow(const HttpException('HTTP error'));

        // Act & Assert
        expect(
          () => dataSource.getUserDevices(),
          throwsA(isA<HttpException>()),
        );
      });
    });

    group('renameDevice', () {
      const testDeviceId = '1';
      const testNewName = 'My New Device Name';

      test('should perform PUT request with correct endpoint and body',
          () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('', 200));

        // Act
        await dataSource.renameDevice(
          deviceId: testDeviceId,
          newName: testNewName,
        );

        // Assert
        verify(() => mockHttpClient.put(
              Uri.parse('$baseUrl/api/device/rename/'),
              headers: any(named: 'headers'),
              body: jsonEncode({
                'deviceId': testDeviceId,
                'newName': testNewName,
              }),
            )).called(1);
      });

      test('should complete successfully on 200 OK', () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('', 200));

        // Act & Assert
        await expectLater(
          dataSource.renameDevice(
            deviceId: testDeviceId,
            newName: testNewName,
          ),
          completes,
        );
      });

      test('should throw ApiException on 404 Not Found', () async {
        // Arrange
        final errorResponse = HttpErrorResponses.notFound('Device not found');

        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => dataSource.renameDevice(
            deviceId: testDeviceId,
            newName: testNewName,
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('should throw SocketException on network error', () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(const SocketException('No internet connection'));

        // Act & Assert
        expect(
          () => dataSource.renameDevice(
            deviceId: testDeviceId,
            newName: testNewName,
          ),
          throwsA(isA<SocketException>()),
        );
      });
    });

    group('toggleAutoSync', () {
      const testDeviceId = '1';

      test('should perform PUT request with correct endpoint when enabling',
          () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('', 200));

        // Act
        await dataSource.toggleAutoSync(
          deviceId: testDeviceId,
          enabled: true,
        );

        // Assert
        verify(() => mockHttpClient.put(
              Uri.parse('$baseUrl/api/device/auto-sync/'),
              headers: any(named: 'headers'),
              body: jsonEncode({
                'deviceId': testDeviceId,
                'enabled': true,
              }),
            )).called(1);
      });

      test('should perform PUT request with correct endpoint when disabling',
          () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('', 200));

        // Act
        await dataSource.toggleAutoSync(
          deviceId: testDeviceId,
          enabled: false,
        );

        // Assert
        verify(() => mockHttpClient.put(
              Uri.parse('$baseUrl/api/device/auto-sync/'),
              headers: any(named: 'headers'),
              body: jsonEncode({
                'deviceId': testDeviceId,
                'enabled': false,
              }),
            )).called(1);
      });

      test('should complete successfully on 200 OK', () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response('', 200));

        // Act & Assert
        await expectLater(
          dataSource.toggleAutoSync(
            deviceId: testDeviceId,
            enabled: true,
          ),
          completes,
        );
      });

      test('should throw ApiException on error', () async {
        // Arrange
        final errorResponse = HttpErrorResponses.internalServerError();

        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => dataSource.toggleAutoSync(
            deviceId: testDeviceId,
            enabled: true,
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('unlinkDevice', () {
      const testDeviceId = '1';

      test('should perform DELETE request with correct endpoint', () async {
        // Arrange
        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response('', 200));

        // Act
        await dataSource.unlinkDevice(deviceId: testDeviceId);

        // Assert
        verify(() => mockHttpClient.delete(
              Uri.parse('$baseUrl/api/device/unlink/$testDeviceId/'),
              headers: any(named: 'headers'),
            )).called(1);
      });

      test('should complete successfully on 200 OK', () async {
        // Arrange
        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => http.Response('', 200));

        // Act & Assert
        await expectLater(
          dataSource.unlinkDevice(deviceId: testDeviceId),
          completes,
        );
      });

      test('should throw ApiException on 404 Not Found', () async {
        // Arrange
        final errorResponse = HttpErrorResponses.notFound('Device not found');

        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((_) async => errorResponse);

        // Act & Assert
        expect(
          () => dataSource.unlinkDevice(deviceId: testDeviceId),
          throwsA(isA<ApiException>()),
        );
      });

      test('should throw SocketException on network error', () async {
        // Arrange
        when(() => mockHttpClient.delete(
              any(),
              headers: any(named: 'headers'),
            )).thenThrow(const SocketException('No internet connection'));

        // Act & Assert
        expect(
          () => dataSource.unlinkDevice(deviceId: testDeviceId),
          throwsA(isA<SocketException>()),
        );
      });
    });
  });
}
