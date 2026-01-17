import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/remote/sync_device_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class FakeUri extends Fake implements Uri {}

void main() {
  late SyncDeviceRemoteDataSourceImpl dataSource;
  late MockHttpClient mockClient;
  late MockAuthLocalDataSource mockAuthDataSource;

  const baseUrl = DataConstants.backendBaseUrl;
  const token = 'test-token-123';

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    mockAuthDataSource = MockAuthLocalDataSource();
    dataSource = SyncDeviceRemoteDataSourceImpl(
      client: mockClient,
      authLocalDataSource: mockAuthDataSource,
      baseUrl: baseUrl,
    );

    when(() => mockAuthDataSource.getToken()).thenAnswer((_) async => token);
  });

  group('registerDevice', () {
    const uuid = 'device-uuid-123';
    const name = 'Samsung Galaxy S21';
    const model = 'SM-G991B';
    const osType = 'ANDROID';
    const osVersion = '13';
    const appVersion = '1.0.0';
    const pushToken = 'push-token-456';

    test('should return SyncDeviceModel on successful registration', () async {
      // Arrange
      final responseBody = jsonEncode({
        'id': 'device-123',
        'uuid': uuid,
        'name': name,
        'model': model,
        'osType': osType,
        'osVersion': osVersion,
        'appVersion': appVersion,
        'userId': 'user-789',
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.registerDevice(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
        pushToken: pushToken,
      );

      // Assert
      expect(result.uuid, uuid);
      expect(result.name, name);
      expect(result.osType, osType);
      verify(() => mockClient.post(
            Uri.parse('$baseUrl/api/device/register/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: any(named: 'body'),
          )).called(1);
    });

    test('should register device without push token', () async {
      // Arrange
      final responseBody = jsonEncode({
        'id': 'device-123',
        'uuid': uuid,
        'name': name,
        'model': model,
        'osType': osType,
        'osVersion': osVersion,
        'appVersion': appVersion,
        'userId': 'user-789',
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.registerDevice(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
        pushToken: null,
      );

      // Assert
      verify(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).called(1);
    });

    test('should throw HttpException on 409 conflict (device exists)', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'message': 'Device already registered'}),
            409,
          ));

      // Act & Assert
      expect(
        () => dataSource.registerDevice(
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
        ),
        throwsA(isA<HttpException>()),
      );
    });

    test('should throw HttpException on 400 bad request', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({'message': 'Invalid device data'}),
            400,
          ));

      // Act & Assert
      expect(
        () => dataSource.registerDevice(
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
        ),
        throwsA(isA<HttpException>()),
      );
    });

    test('should throw Exception on network error', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(const SocketException('Network error'));

      // Act & Assert
      expect(
        () => dataSource.registerDevice(
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should include authorization header', () async {
      // Arrange
      final responseBody = jsonEncode({
        'id': 'device-123',
        'uuid': uuid,
        'name': name,
        'model': model,
        'osType': osType,
        'osVersion': osVersion,
        'appVersion': appVersion,
        'userId': 'user-789',
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.registerDevice(
        uuid: uuid,
        name: name,
        model: model,
        osType: osType,
        osVersion: osVersion,
        appVersion: appVersion,
      );

      // Assert
      verify(() => mockClient.post(
            any(),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: any(named: 'body'),
          )).called(1);
    });
  });
}
