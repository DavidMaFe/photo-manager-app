import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/account_deletion/data/models/account_deletion_summary_model.dart';

/// Account deletion endpoints. The client adds the token.
abstract class AccountDeletionRemoteDataSource {
  Future<AccountDeletionSummaryModel> getSummary();

  /// [authKey] in Base64.
  Future<void> deleteAccount(String authKey);
}

class AccountDeletionRemoteDataSourceImpl implements AccountDeletionRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  AccountDeletionRemoteDataSourceImpl({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  @override
  Future<AccountDeletionSummaryModel> getSummary() async {
    final json = await _send(() => client.get(Uri.parse('$baseUrl/api/profile/deletion-summary/'),
        headers: HttpHeadersUtil.getJsonHeaders()));
    return AccountDeletionSummaryModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAccount(String authKey) async {
    await _send(() => client.post(Uri.parse('$baseUrl/api/profile/delete/'),
        headers: HttpHeadersUtil.getJsonHeaders(), body: jsonEncode({'authKey': authKey})));
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
