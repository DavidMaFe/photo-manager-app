import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_request_model.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_response_model.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_folder_model.dart';


abstract class FileManagementRemoteDataSource {
  Future<ManageFileResponseModel> manageFiles(ManageFileRequestModel request);
  Future<List<ManageFolderModel>> getFolders();
  Future<ManageFolderModel> createFolder(String name);
}


class FileManagementRemoteDataSourceImpl implements FileManagementRemoteDataSource {

  final http.Client client;
  final String baseUrl;

  FileManagementRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<ManageFileResponseModel> manageFiles(ManageFileRequestModel request) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/file/manage/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return ManageFileResponseModel.fromJson(body);
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
  Future<List<ManageFolderModel>> getFolders() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/folder/list/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> foldersJson = body['folders'] ?? [];

        return foldersJson
            .map((json) => ManageFolderModel.fromJson(json as Map<String, dynamic>))
            .toList();
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
  Future<ManageFolderModel> createFolder(String name) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/folder/new/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'folderName': name}),
      );

      if (response.statusCode == 200) {
        return ManageFolderModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
