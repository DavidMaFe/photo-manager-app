import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/trash/data/models/trash_page_model.dart';

abstract class TrashRemoteDataSource {
  Future<TrashPageModel> getTrashFiles({
    required int page,
    required int pageSize,
  });

  Future<void> restoreFiles(List<String> fileIds);

  Future<void> permanentlyDeleteFiles(List<String> fileIds);

  Future<void> emptyTrash();
}

class TrashRemoteDataSourceImpl implements TrashRemoteDataSource {
  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl;

  TrashRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
    this.baseUrl = DataConstants.backendBaseUrl,
  });

  @override
  Future<TrashPageModel> getTrashFiles({
    required int page,
    required int pageSize,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'isDeleted': 'true', // Only fetch deleted files
    };

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
        return TrashPageModel.fromJson(
          jsonData,
          currentPage: page,
          pageSize: pageSize,
        );
      } else {
        final errorResponse =
            ErrorResponseModel.fromJson(jsonDecode(response.body));
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
  Future<void> restoreFiles(List<String> fileIds) async {
    final url = Uri.parse('$baseUrl/api/file/restore/');

    try {
      final token = await authLocalDataSource.getToken();
      final response = await client.post(
        url,
        headers: HttpHeadersUtil.getAuthJsonHeaders(token),
        body: jsonEncode({'fileIds': fileIds}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        final errorResponse =
            ErrorResponseModel.fromJson(jsonDecode(response.body));
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
  Future<void> permanentlyDeleteFiles(List<String> fileIds) async {
    final url = Uri.parse('$baseUrl/api/file/delete-permanently/');

    try {
      final token = await authLocalDataSource.getToken();
      final response = await client.delete(
        url,
        headers: HttpHeadersUtil.getAuthJsonHeaders(token),
        body: jsonEncode({'fileIds': fileIds}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        final errorResponse =
            ErrorResponseModel.fromJson(jsonDecode(response.body));
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
  Future<void> emptyTrash() async {
    final url = Uri.parse('$baseUrl/api/file/empty-trash/');

    try {
      final token = await authLocalDataSource.getToken();
      final response = await client.delete(
        url,
        headers: HttpHeadersUtil.getAuthJsonHeaders(token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        final errorResponse =
            ErrorResponseModel.fromJson(jsonDecode(response.body));
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
