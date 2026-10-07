import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/crypto/data/models/kdf_params_model.dart';
import 'package:photo_manager_app/core/crypto/data/models/key_version_model.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';

/// Key and password endpoints of the logged-in user (docs/e2ee-spec.md, section 12). The client adds the token.
abstract class AccountSecurityRemoteDataSource {
  Future<KdfParams> getKdfParams(String email);

  Future<AccountKeys> getAccountKeys();

  Future<void> changePassword({
    required String currentAuthKey,
    required String newAuthKey,
    required KdfParams kdfParams,
    required List<RewrappedKey> keys,
  });

  Future<void> resetPasswordFromDevice({
    required String newAuthKey,
    required KdfParams kdfParams,
    required List<DeviceRewrappedKey> keys,
  });

  Future<int> createKeyVersion(NewKeyMaterial key);

  Future<void> unlockKeyVersion({
    required int version,
    String? recoveryAuthKey,
    String? masterKeyAuth,
    required String encryptedMasterKey,
  });
}

class AccountSecurityRemoteDataSourceImpl implements AccountSecurityRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AccountSecurityRemoteDataSourceImpl({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  @override
  Future<KdfParams> getKdfParams(String email) async {
    final uri = Uri.parse('$baseUrl/api/auth/kdf-params/').replace(queryParameters: {'email': email});
    final json = await _send(() => client.get(uri, headers: HttpHeadersUtil.getJsonHeaders()));
    return KdfParamsModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<AccountKeys> getAccountKeys() async {
    final json = await _send(() => client.get(Uri.parse('$baseUrl/api/auth/keys/'),
        headers: HttpHeadersUtil.getJsonHeaders()));
    return AccountKeysModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> changePassword({
    required String currentAuthKey,
    required String newAuthKey,
    required KdfParams kdfParams,
    required List<RewrappedKey> keys,
  }) async {
    await _post('/api/password-change/', {
      'currentAuthKey': currentAuthKey,
      'newAuthKey': newAuthKey,
      'kdfSalt': KdfParamsModel.saltToJson(kdfParams),
      'kdfParams': KdfParamsModel.paramsToJson(kdfParams),
      'keys': keys.map(KeyRequestModel.rewrapped).toList(),
    });
  }

  @override
  Future<void> resetPasswordFromDevice({
    required String newAuthKey,
    required KdfParams kdfParams,
    required List<DeviceRewrappedKey> keys,
  }) async {
    await _post('/api/auth/password-reset/device/', {
      'newAuthKey': newAuthKey,
      'kdfSalt': KdfParamsModel.saltToJson(kdfParams),
      'kdfParams': KdfParamsModel.paramsToJson(kdfParams),
      'keys': keys.map(KeyRequestModel.deviceRewrapped).toList(),
    });
  }

  @override
  Future<int> createKeyVersion(NewKeyMaterial key) async {
    final json = await _post('/api/auth/keys/', KeyRequestModel.newKey(key));
    return (json as Map<String, dynamic>)['version'] as int;
  }

  @override
  Future<void> unlockKeyVersion({
    required int version,
    String? recoveryAuthKey,
    String? masterKeyAuth,
    required String encryptedMasterKey,
  }) async {
    await _post('/api/auth/keys/$version/unlock/', {
      if (recoveryAuthKey != null) 'recoveryAuthKey': recoveryAuthKey,
      if (masterKeyAuth != null) 'masterKeyAuth': masterKeyAuth,
      'encryptedMasterKey': encryptedMasterKey,
    });
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body) {
    return _send(() => client.post(Uri.parse('$baseUrl$path'),
        headers: HttpHeadersUtil.getJsonHeaders(), body: jsonEncode(body)));
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isEmpty ? null : jsonDecode(response.body);
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
