import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/network/authenticated_http_client.dart';
import 'package:photo_manager_app/core/services/timezone_service.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthLocalDataSource authLocalDataSource;
  late List<http.BaseRequest> sent;

  AuthenticatedHttpClient buildClient() {
    return AuthenticatedHttpClient(
      client: MockClient((request) async {
        sent.add(request);
        return http.Response('{}', 200);
      }),
      authLocalDataSource: authLocalDataSource,
      onTokenRefresh: () async {},
      eventBus: AppEventBus(),
    );
  }

  setUp(() async {
    sent = [];
    authLocalDataSource = MockAuthLocalDataSource();
    when(() => authLocalDataSource.getToken()).thenAnswer((_) async => 'token');
    await TimezoneService.init(resolver: () async => 'Europe/Paris');
  });

  tearDown(TimezoneService.reset);

  group('AuthenticatedHttpClient', () {
    group('X-Timezone', () {
      test('should add the device time zone to a request without it', () async {
        // Act
        await buildClient().get(Uri.parse('http://localhost/api/file/list/'));

        // Assert
        expect(sent.single.headers['X-Timezone'], 'Europe/Paris');
        expect(sent.single.headers['Authorization'], 'Bearer token');
      });

      test('should keep the time zone set by the caller', () async {
        // Act
        await buildClient().get(
          Uri.parse('http://localhost/api/file/list/'),
          headers: {'X-Timezone': 'Asia/Tokyo'},
        );

        // Assert
        expect(sent.single.headers['X-Timezone'], 'Asia/Tokyo');
      });

      test('should add the device time zone to multipart uploads', () async {
        // Arrange
        final request = http.MultipartRequest('POST', Uri.parse('http://localhost/api/sync_session/upload/'))
          ..fields['name'] = 'photo.jpg';

        // Act
        await buildClient().send(request);

        // Assert
        expect(sent.single.headers['X-Timezone'], 'Europe/Paris');
        expect(sent.single.headers['Authorization'], 'Bearer token');
      });
    });
  });
}
