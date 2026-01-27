import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_page_model.dart';

import '../../../auth/data/data_sources/auth_local_data_source.dart';


abstract class GalleryRemoteDataSource {
  Future<GalleryPageModel> getFiles({
    required int page,
    required int pageSize,
    String? type,
    String? status
  });
}


class GalleryRemoteDataSourceImpl implements GalleryRemoteDataSource {

  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl;

  GalleryRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<GalleryPageModel> getFiles({
    required int page,
    required int pageSize,
    String? type,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'isDeleted': 'false',
    };

    if (type != null) {
      queryParams['type'] = type;
    }

    if (status != null) {
      queryParams['status'] = status;
    }

    final url = Uri.parse('$baseUrl/api/file/list/').replace(
      queryParameters: queryParams,
    );

    try {
      final token = await authLocalDataSource.getToken();
      final response = await client.get(
        url,
        headers: HttpHeadersUtil.getAuthJsonHeaders(token),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return GalleryPageModel.fromJson(jsonData, currentPage: page, pageSize: pageSize);
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