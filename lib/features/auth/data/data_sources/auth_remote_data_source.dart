import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';

import '../models/auth_response_model.dart';


abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<void> logout(String token);
  Future<void> register(String email, String password, String name, String? surname);
  Future<void> requestPasswordReset(String email);
  Future<void> validateResetCode(String email, String code);
  Future<void> resetPassword(String email, String code, String newPassword);
}


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login/');

    try {
      final response = await client.post(
        url,
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AuthResponseModel.fromJson(jsonData);
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
  Future<void> logout(String token) async {
    final url = Uri.parse('$baseUrl/api/logout/');

    try {
      final response = await client.post(
        url,
        headers: HttpHeadersUtil.getAuthJsonHeaders(token),
      );

      if (response.statusCode != 200) {
        // Log error but don't throw - local cache will be cleared anyway
        final errorResponse = ErrorResponseModel.fromJson(jsonDecode(response.body));
        print('Logout error: ${errorResponse.code} - ${errorResponse.message}');
      }
    } catch (e) {
      // Log error but don't throw - local cache will be cleared anyway
      print('Logout failed: $e');
    }
  }
  
  @override
  Future<void> register(String email, String password, String name, String? surname) async {
    final url = Uri.parse('$baseUrl/api/register/');

    try {
      final Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'name': name,
      };

      if (surname != null) {
        body['surname'] = surname;
      }

      final response = await client.post(
        url,
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return;
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
  Future<void> requestPasswordReset(String email) async {
    final url = Uri.parse('$baseUrl/api/password-reset/request/');

    try {
      final response = await client.post(
        url,
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return;
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
  Future<void> validateResetCode(String email, String code) async {
    final url = Uri.parse('$baseUrl/api/password-reset/validate/');

    try {
      final response = await client.post(
        url,
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        return;
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
  Future<void> resetPassword(String email, String code, String newPassword) async {
    final url = Uri.parse('$baseUrl/api/password-reset/reset/');

    try {
      final response = await client.post(
        url,
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'email': email, 'code': code, 'newPassword': newPassword}),
      );

      if (response.statusCode == 200) {
        return;
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