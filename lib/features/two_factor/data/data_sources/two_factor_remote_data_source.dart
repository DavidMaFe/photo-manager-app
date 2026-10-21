import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/two_factor/data/models/totp_set_up_model.dart';
import 'package:photo_manager_app/features/two_factor/data/models/two_factor_status_model.dart';

/// Endpoints of the authenticator app (/api/auth/2fa/). The client adds the token.
abstract class TwoFactorRemoteDataSource {
  Future<TwoFactorStatusModel> getStatus();
  Future<TotpSetUpModel> setUpTotp();
  Future<List<String>> enableTotp(String code);

  /// [authKey] in Base64.
  Future<void> disableTotp(String authKey, String code);

  /// [authKey] in Base64.
  Future<List<String>> regenerateBackupCodes(String authKey, String code);
}

class TwoFactorRemoteDataSourceImpl implements TwoFactorRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  TwoFactorRemoteDataSourceImpl({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  @override
  Future<TwoFactorStatusModel> getStatus() async {
    final json = await _send(() => client.get(Uri.parse('$baseUrl/api/auth/2fa/'),
        headers: HttpHeadersUtil.getJsonHeaders()));
    return TwoFactorStatusModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<TotpSetUpModel> setUpTotp() async {
    final json = await _post('/api/auth/2fa/totp/setup/', null);
    return TotpSetUpModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<String>> enableTotp(String code) async {
    return _backupCodes(await _post('/api/auth/2fa/totp/enable/', {'code': code}));
  }

  @override
  Future<void> disableTotp(String authKey, String code) async {
    await _post('/api/auth/2fa/totp/disable/', {'authKey': authKey, 'code': code});
  }

  @override
  Future<List<String>> regenerateBackupCodes(String authKey, String code) async {
    return _backupCodes(await _post('/api/auth/2fa/backup-codes/', {'authKey': authKey, 'code': code}));
  }

  static List<String> _backupCodes(dynamic json) =>
      ((json as Map<String, dynamic>)['backupCodes'] as List<dynamic>).cast<String>();

  Future<dynamic> _post(String path, Map<String, dynamic>? body) {
    return _send(() => client.post(Uri.parse('$baseUrl$path'),
        headers: HttpHeadersUtil.getJsonHeaders(), body: body == null ? null : jsonEncode(body)));
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
