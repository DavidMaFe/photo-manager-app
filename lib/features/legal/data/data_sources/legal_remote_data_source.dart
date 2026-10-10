import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';

/// POST /api/profile/terms/ (the client adds the token).
abstract class LegalRemoteDataSource {
  Future<void> acceptLegalTerms({required String termsVersion, required String privacyVersion});
}

class LegalRemoteDataSourceImpl implements LegalRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  LegalRemoteDataSourceImpl({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  @override
  Future<void> acceptLegalTerms({required String termsVersion, required String privacyVersion}) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/profile/terms/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'termsVersion': termsVersion, 'privacyVersion': privacyVersion}),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(ErrorResponseModel.fromJson(jsonDecode(response.body)));
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
