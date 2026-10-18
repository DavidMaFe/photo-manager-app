import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/plans/data/models/user_plan_model.dart';

/// Plan endpoints. The client adds the token.
abstract class PlanRemoteDataSource {
  Future<UserPlanModel> getUserPlan();
}

class PlanRemoteDataSourceImpl implements PlanRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  PlanRemoteDataSourceImpl({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  @override
  Future<UserPlanModel> getUserPlan() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/api/profile/plan/'),
          headers: HttpHeadersUtil.getJsonHeaders());
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
