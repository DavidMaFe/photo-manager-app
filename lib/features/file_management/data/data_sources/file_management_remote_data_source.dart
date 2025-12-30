import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_request_model.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_response_model.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_folder_model.dart';

import '../../../../core/errors/base/failure_codes.dart';


abstract class FileManagementRemoteDataSource {
  Future<ManageFileResponseModel> manageFiles(ManageFileRequestModel request);
  Future<List<ManageFolderModel>> getFolders();
}


class FileManagementRemoteDataSourceImpl implements FileManagementRemoteDataSource {

  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl;

  FileManagementRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<ManageFileResponseModel> manageFiles(ManageFileRequestModel request) async {

    try {

      final response = await client.post(
        Uri.parse('$baseUrl/api/file/manage/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await authLocalDataSource.getToken()}'
        },
        body: jsonEncode(request.toJson())
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return ManageFileResponseModel.fromJson(body);
      } else {
        throw HttpException(jsonDecode(response.body)["message"]);
      }

    } catch (e) {
      if (e is HttpException) rethrow;
      throw Exception(FailureCodes.unknownErrorCode);
    }

  }

  @override
  Future<List<ManageFolderModel>> getFolders() async {
    try {

      final response = await client.get(
        Uri.parse('$baseUrl/api/folder/list/'),
        headers: {
          'Authorization': 'Bearer ${await authLocalDataSource.getToken()}'
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> foldersJson = body['folders'] ?? [];

        return foldersJson
            .map((json) => ManageFolderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(jsonDecode(response.body)["message"]);
      }
    } catch(e) {
      if (e is HttpException) rethrow;
      throw Exception(FailureCodes.unknownErrorCode);
    }
  }
}