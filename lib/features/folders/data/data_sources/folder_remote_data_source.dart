import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_content_model.dart';

import '../models/folder_model.dart';


abstract class FolderRemoteDataSource {
  Future<List<FolderModel>> getFolders({String? parentFolderId});
  Future<FolderContentModel> getFolderContent({
    required String folderId,
    int page = 0,
    int pageSize = 50,
    String? fileType,
    String? status
  });
  Future<FolderModel> createFolder({required String name, String? parentFolderId});
  Future<FolderModel> renameFolder({required String folderId, required String newName});
  Future<void> deleteFolder({required String folderId});
}


class FolderRemoteDataSourceImpl implements FolderRemoteDataSource {

  final http.Client client;
  final String baseUrl;
  final AuthLocalDataSource authLocalDataSource;

  FolderRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authLocalDataSource.getToken();
    return HttpHeadersUtil.getAuthJsonHeaders(token);
  }

  @override
  Future<List<FolderModel>> getFolders({String? parentFolderId}) async {
    try {
      final headers = await _getHeaders();

      final finalUrl = '$baseUrl/api/folder/list/';
      final uri = parentFolderId != null
          ? Uri.parse('$finalUrl?parentId=$parentFolderId')
          : Uri.parse(finalUrl);

      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.body)["folders"] as List<dynamic>;
        return jsonList.map((json) => FolderModel.fromJson(json as Map<String, dynamic>)).toList();
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
  Future<FolderContentModel> getFolderContent({
    required String folderId,
    int page = 0,
    int pageSize = 0,
    String? fileType,
    String? status,
  }) async {
    try {
      final headers = await _getHeaders();

      final finalUrl = '$baseUrl/api/folder/$folderId/';
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (fileType != null) {
        queryParams['type'] = fileType;
      }

      if (status != null) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(finalUrl).replace(queryParameters: queryParams);
      final response = await client.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return FolderContentModel.fromJson(jsonData, currentPage: page);
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
  Future<FolderModel> createFolder({required String name, String? parentFolderId}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse("$baseUrl/api/folder/new/");

      final body = jsonEncode({
        'folderName': name,
        if (parentFolderId != null) 'parentFolderId': parentFolderId,
      });

      final response = await client.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return FolderModel.fromJson(jsonData);
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
  Future<FolderModel> renameFolder({required String folderId, required String newName}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/folder/$folderId/');
      final body = jsonEncode({'newName': newName});

      final response = await client.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return FolderModel.fromJson(jsonData);
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
  Future<void> deleteFolder({required String folderId}) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/api/folder/$folderId/');

      final response = await client.delete(url, headers: headers);

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