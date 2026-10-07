import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/profile/data/models/user_profile_model.dart';

import '../../../../config/data_constants.dart';


abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateUserProfile({
    String? name,
    String? surname,
    String? profileImage,
  });
}


class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {

  final http.Client client;
  final String baseUrl;

  ProfileRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/profile/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return UserProfileModel.fromJson(jsonData);
      } else {
        final errorResponse = ErrorResponseModel.fromJson(jsonDecode(response.body));
        throw ApiException(errorResponse);
      }
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

  @override
  Future<UserProfileModel> updateUserProfile({
    String? name,
    String? surname,
    String? profileImage,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (surname != null) body['surname'] = surname;
      if (profileImage != null) body['profileImage'] = profileImage;

      final response = await client.put(
        Uri.parse('$baseUrl/api/profile/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return UserProfileModel.fromJson(jsonData);
      } else {
        final errorResponse = ErrorResponseModel.fromJson(jsonDecode(response.body));
        throw ApiException(errorResponse);
      }
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
