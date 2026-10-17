import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/downloads/data/models/remote_media_file_model.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_file_model.dart';

/// Endpoints of the downloads (ROADMAP-downloads-and-account-deletion.md, Phase 1). The client adds the token.
abstract class ServerFilesRemoteDataSource {
  /// GET /api/file/ids/
  Future<List<RemoteMediaFileModel>> getFiles({String? folderId, bool includeSubfolders = false});

  /// POST /api/file/list/by-ids/ with at most [maxIdsPerRequest] ids.
  Future<List<GalleryFileModel>> getFilesByIds(List<String> fileIds);

  /// POST /api/file/on-device/ with at most [maxIdsPerRequest] ids.
  Future<void> markOnDevice(String deviceUuid, List<String> fileIds);
}

class ServerFilesRemoteDataSourceImpl implements ServerFilesRemoteDataSource {
  static const int maxIdsPerRequest = 200;
  static const Duration _timeout = Duration(minutes: 1);

  final http.Client client;
  final String baseUrl;

  ServerFilesRemoteDataSourceImpl({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  @override
  Future<List<RemoteMediaFileModel>> getFiles({String? folderId, bool includeSubfolders = false}) async {
    final uri = Uri.parse('$baseUrl/api/file/ids/');
    final query = {
      if (folderId != null) 'folder': folderId,
      if (folderId != null && includeSubfolders) 'includeSubfolders': 'true',
    };
    final response = await _send(() => client.get(query.isEmpty ? uri : uri.replace(queryParameters: query)));
    _check(response, 200);
    final files = (jsonDecode(response.body) as Map<String, dynamic>)['files'] as List<dynamic>;
    return [for (final json in files) RemoteMediaFileModel.fromJson(json as Map<String, dynamic>)];
  }

  @override
  Future<List<GalleryFileModel>> getFilesByIds(List<String> fileIds) async {
    final response = await _send(() => client.post(
          Uri.parse('$baseUrl/api/file/list/by-ids/'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: jsonEncode({'fileIds': fileIds.map(int.parse).toList()}),
        ));
    _check(response, 200);
    final files = (jsonDecode(response.body) as Map<String, dynamic>)['files'] as List<dynamic>;
    return [for (final json in files) GalleryFileModel.fromJson(json as Map<String, dynamic>)];
  }

  @override
  Future<void> markOnDevice(String deviceUuid, List<String> fileIds) async {
    final response = await _send(() => client.post(
          Uri.parse('$baseUrl/api/file/on-device/'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: jsonEncode({'deviceUuid': deviceUuid, 'fileIds': fileIds.map(int.parse).toList()}),
        ));
    _check(response, 200);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on SocketException {
      rethrow;
    } on HttpException {
      rethrow;
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  void _check(http.Response response, int expected) {
    if (response.statusCode == expected) {
      return;
    }
    try {
      throw ApiException(ErrorResponseModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>));
    } on FormatException {
      throw Exception('Unexpected status ${response.statusCode}');
    }
  }
}
