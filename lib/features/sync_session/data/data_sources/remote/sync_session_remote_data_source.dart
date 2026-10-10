import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/sync_session/data/models/duplicate_files_result_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/encrypted_upload_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_result_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_session_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/upload_result_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';

import '../../../../../config/data_constants.dart';


abstract class SyncSessionRemoteDataSource {
  Future<SyncSessionModel> startSyncSession(String deviceUuid);
  Future<DuplicateFilesResultModel> checkDuplicates(String sessionId, List<String> fileHashes);
  /// Multipart with the encrypted file, the encrypted thumbnail (if any) and the metadata.
  Future<UploadResultModel> uploadFile(String sessionId, EncryptedUpload upload);
  Future<SyncResultModel> completeSyncSession(String sessionId);
  Future<void> cancelSyncSession(String sessionId);
}


class SyncSessionRemoteDatasourceImpl implements SyncSessionRemoteDataSource {

  final http.Client client;
  final String baseUrl;

  // Timeout for regular API calls (start, check-duplicates, complete, cancel).
  static const Duration _apiTimeout = Duration(seconds: 30);

  // Longer timeout for file uploads — large photos/videos may take a while.
  // WorkManager gives background tasks up to 10 minutes total, so 3 minutes
  // per file is a reasonable ceiling that still leaves time for multiple files.
  static const Duration _uploadTimeout = Duration(minutes: 3);

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
      ).timeout(_apiTimeout);

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
      ).timeout(_apiTimeout);

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
  Future<UploadResultModel> uploadFile(String sessionId, EncryptedUpload upload) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/sync_session/upload/'));
      request.headers.addAll(HttpHeadersUtil.getMultipartHeaders());

      request.fields['sessionId'] = sessionId;
      request.fields['metadata'] = jsonEncode(EncryptedUploadModel.metadataToJson(upload));
      // The part names say nothing about the file: the original name is in the encrypted metadata
      request.files.add(await http.MultipartFile.fromPath('file', upload.encryptedFile.path, filename: 'file'));
      final thumbnail = upload.encryptedThumbnail;
      if (thumbnail != null) {
        request.files.add(http.MultipartFile.fromBytes('thumbnail', thumbnail, filename: 'thumbnail'));
      }

      final streamedResponse = await client.send(request).timeout(_uploadTimeout);
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
      ).timeout(_apiTimeout);

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
      ).timeout(_apiTimeout);

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