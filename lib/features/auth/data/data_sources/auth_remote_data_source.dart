import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/core/crypto/data/models/kdf_params_model.dart';
import 'package:photo_manager_app/core/crypto/data/models/key_version_model.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/errors/utils/error_logger.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';

import '../models/auth_response_model.dart';
import '../models/refresh_token_response_model.dart';


/// Public authentication endpoints. The password never travels: only the authKey derived from it on the device, as
/// Base64 (docs/e2ee-spec.md, section 12).
abstract class AuthRemoteDataSource {
  Future<KdfParams> getKdfParams(String email);
  Future<AuthResponseModel> login(String email, String authKey, String deviceUuid);
  Future<void> logout(String token);
  Future<AuthResponseModel> register({
    required String email,
    required String authKey,
    required String name,
    String? surname,
    required String deviceUuid,
    required KdfParams kdfParams,
    required NewKeyMaterial key,
  });
  Future<RefreshTokenResponseModel> refreshToken(String refreshToken, String deviceUuid);
  Future<void> requestPasswordReset(String email);
  Future<void> validateResetCode(String email, String code);
  Future<List<RecoveryWrap>> getRecoveryWraps(String email, String code);

  /// Returns whether the account is locked after the reset (no recovered key).
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newAuthKey,
    required KdfParams kdfParams,
    required List<RecoveredKey> recoveredKeys,
  });
}


class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  final http.Client client;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<KdfParams> getKdfParams(String email) async {
    final uri = Uri.parse('$baseUrl/api/auth/kdf-params/').replace(queryParameters: {'email': email});
    final json = await _send(() => client.get(uri, headers: HttpHeadersUtil.getJsonHeaders()));
    return KdfParamsModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> login(String email, String authKey, String deviceUuid) async {
    final json = await _post('/api/login/', {
      'email': email,
      'authKey': authKey,
      'deviceUuid': deviceUuid,
    });
    return AuthResponseModel.fromJson(json as Map<String, dynamic>);
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
        ErrorLogger.logWarning(
          'Logout error: ${errorResponse.code} - ${errorResponse.message}',
          context: 'AuthRemoteDataSource.logout',
        );
      }
    } catch (e) {
      // Log error but don't throw - local cache will be cleared anyway
      ErrorLogger.logWarning('Logout failed: $e', context: 'AuthRemoteDataSource.logout');
    }
  }

  @override
  Future<RefreshTokenResponseModel> refreshToken(String refreshToken, String deviceUuid) async {
    final json = await _post('/api/auth/refresh/', {
      'refreshToken': refreshToken,
      'deviceUuid': deviceUuid,
    });
    return RefreshTokenResponseModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String authKey,
    required String name,
    String? surname,
    required String deviceUuid,
    required KdfParams kdfParams,
    required NewKeyMaterial key,
  }) async {
    final json = await _post('/api/register/', {
      'email': email,
      'authKey': authKey,
      'name': name,
      if (surname != null) 'surname': surname,
      'deviceUuid': deviceUuid,
      'kdfSalt': KdfParamsModel.saltToJson(kdfParams),
      'kdfParams': KdfParamsModel.paramsToJson(kdfParams),
      'key': KeyRequestModel.newKey(key),
    });
    return AuthResponseModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _post('/api/password-reset/request/', {'email': email});
  }

  @override
  Future<void> validateResetCode(String email, String code) async {
    await _post('/api/password-reset/validate/', {'email': email, 'code': code});
  }

  @override
  Future<List<RecoveryWrap>> getRecoveryWraps(String email, String code) async {
    final json = await _post('/api/password-reset/recovery-keys/', {'email': email, 'code': code});
    return KeyRequestModel.recoveryWrapsFromJson(json as Map<String, dynamic>);
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newAuthKey,
    required KdfParams kdfParams,
    required List<RecoveredKey> recoveredKeys,
  }) async {
    final json = await _post('/api/password-reset/reset/', {
      'email': email,
      'code': code,
      'newAuthKey': newAuthKey,
      'kdfSalt': KdfParamsModel.saltToJson(kdfParams),
      'kdfParams': KdfParamsModel.paramsToJson(kdfParams),
      'recoveredKeys': recoveredKeys.map(KeyRequestModel.recovered).toList(),
    });
    return (json as Map<String, dynamic>)['accountLocked'] as bool;
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) {
    return _send(() => client.post(
          Uri.parse('$baseUrl$path'),
          headers: HttpHeadersUtil.getJsonHeaders(),
          body: jsonEncode(body),
        ));
  }

  /// Sends the request and returns the decoded JSON body (null if empty), or throws [ApiException] with the error of
  /// the backend.
  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isEmpty ? null : jsonDecode(response.body);
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
