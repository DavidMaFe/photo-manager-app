import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/plans/data/data_sources/plan_remote_data_source.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient client;
  late PlanRemoteDataSourceImpl dataSource;
  const baseUrl = 'http://10.0.2.2:8080';

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    client = MockHttpClient();
    dataSource = PlanRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
  });

  group('PlanRemoteDataSource', () {
    test('should GET the plan of the user', () async {
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(
          jsonEncode({
            'plan': 'PLUS_100',
            'limits': {'storageBytes': 1, 'maxDevices': 3, 'maxVideoBytes': 2, 'dailyBackup': true},
            'usage': {'storedBytes': 0, 'devices': 1, 'pausedDevices': []},
            'readOnly': false,
          }),
          200));

      final plan = await dataSource.getUserPlan();

      final uri = verify(() => client.get(captureAny(), headers: any(named: 'headers'))).captured.single as Uri;
      expect(uri.toString(), '$baseUrl/api/profile/plan/');
      expect(plan.tier, PlanTier.plus100);
    });

    test('should throw an ApiException with the error of the server', () async {
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(
          jsonEncode({'code': 'USER_NOT_FOUND', 'message': 'User not found', 'timestamp': '', 'path': ''}), 404));

      await expectLater(dataSource.getUserPlan(), throwsA(isA<ApiException>()));
    });
  });
}
