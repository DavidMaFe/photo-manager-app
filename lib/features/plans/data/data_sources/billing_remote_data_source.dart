import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/plans/data/models/user_plan_model.dart';

/// Purchases endpoints. The client adds the token.
abstract class BillingRemoteDataSource {
  /// `POST /api/subscriptions/google/`: the server verifies the purchase with Google Play and answers the plan.
  Future<UserPlanModel> registerGooglePurchase(String purchaseToken);
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  BillingRemoteDataSourceImpl({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  @override
  Future<UserPlanModel> registerGooglePurchase(String purchaseToken) async {
    try {
      final response = await client.post(Uri.parse('$baseUrl/api/subscriptions/google/'),
          headers: HttpHeadersUtil.getJsonHeaders(), body: jsonEncode({'purchaseToken': purchaseToken}));
      if (response.statusCode == 200) {
        return UserPlanModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw ApiException(ErrorResponseModel.fromJson(jsonDecode(response.body)));
    } on SocketException {
      rethrow;
    } on HttpException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
