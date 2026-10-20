import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/plans/data/data_sources/billing_remote_data_source.dart';
import 'package:photo_manager_app/features/plans/domain/entities/plan_tier.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient client;
  late BillingRemoteDataSourceImpl dataSource;
  const baseUrl = 'http://10.0.2.2:8080';

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    client = MockHttpClient();
    dataSource = BillingRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
  });

  void answer(int status, Map<String, dynamic> body) =>
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(jsonEncode(body), status));

  group('BillingRemoteDataSource', () {
    test('should POST the purchase token and read the new plan', () async {
      answer(200, {
        'plan': 'PLUS_250',
        'limits': {'storageBytes': 1, 'maxDevices': 5, 'maxVideoBytes': 2, 'dailyBackup': true},
        'usage': {'storedBytes': 0, 'devices': 1, 'pausedDevices': []},
        'readOnly': false,
        'billingAccountId': 'account',
      });

      final plan = await dataSource.registerGooglePurchase('purchase-token');

      final captured =
          verify(() => client.post(captureAny(), headers: any(named: 'headers'), body: captureAny(named: 'body')))
              .captured;
      expect((captured[0] as Uri).toString(), '$baseUrl/api/subscriptions/google/');
      expect(jsonDecode(captured[1] as String), {'purchaseToken': 'purchase-token'});
      expect(plan.tier, PlanTier.plus250);
      expect(plan.billingAccountId, 'account');
    });

    test('should throw an ApiException with the error of the server', () async {
      answer(409, {
        'code': 'PURCHASE_OF_ANOTHER_ACCOUNT',
        'message': 'This purchase belongs to another account',
        'timestamp': '',
        'path': '',
      });

      await expectLater(
        dataSource.registerGooglePurchase('purchase-token'),
        throwsA(isA<ApiException>().having((e) => e.errorResponse.code, 'code', 'PURCHASE_OF_ANOTHER_ACCOUNT')),
      );
    });
  });
}
