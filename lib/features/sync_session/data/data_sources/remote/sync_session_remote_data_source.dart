import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/sync_session/data/models/duplicate_files_result_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_file_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_result_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_session_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/upload_result_model.dart';

import '../../../../../config/data_constants.dart';


abstract class SyncSessionRemoteDataSource {
  Future<SyncSessionModel> startSyncSession(String deviceUuid);
  Future<DuplicateFilesResultModel> checkDuplicates(String sessionId, List<String> fileHashes);
  Future<UploadResultModel> uploadFile(String sessionId, SyncFileModel file);
  Future<SyncResultModel> completeSyncSession(String sessionId);
  Future<void> cancelSyncSession(String sessionId);
}


class SyncSessionRemoteDatasourceImpl implements SyncSessionRemoteDataSource {

  final http.Client client;
  final String baseUrl;

  SyncSessionRemoteDatasourceImpl({
    required this.client,
    this.baseUrl = DataConstants.backendBaseUrl,
  });
  
  @override
  Future<SyncSessionModel> startSyncSession(String deviceUuid) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/sync_session/start/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'deviceUuid': deviceUuid}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SyncSessionModel.fromJson(json);
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
  Future<DuplicateFilesResultModel> checkDuplicates(String sessionId, List<String> fileHashes) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/sync_session/check_duplicates/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'sessionId': sessionId, 'fileHashes': fileHashes}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return DuplicateFilesResultModel.fromJson(json);
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
  Future<UploadResultModel> uploadFile(String sessionId, SyncFileModel file) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/sync_session/upload/'));
      request.headers.addAll(HttpHeadersUtil.getJsonHeaders());

      request.fields['sessionId'] = sessionId;
      request.fields['metadata'] = jsonEncode(file.uploadMetadata);
      request.files.add(await http.MultipartFile.fromPath('file', file.devicePath, filename: file.fileName));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return UploadResultModel.fromJson(jsonResponse);
      } else {
        final errorResponse = ErrorResponseModel.fromJson(jsonDecode(response.body));
        throw ApiException(errorResponse);
      }
    } on SocketException {
      rethrow;
    } on HttpException {
      rethrow;
    } on FileSystemException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
  
  @override
  Future<SyncResultModel> completeSyncSession(String sessionId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/sync_session/complete/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'sessionId': sessionId}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SyncResultModel.fromJson(json);
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
  Future<void> cancelSyncSession(String sessionId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/sync_session/cancel/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'sessionId': sessionId}),
      );

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