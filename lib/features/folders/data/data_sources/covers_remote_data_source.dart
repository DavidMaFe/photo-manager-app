import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';

import '../../domain/entities/album_cover.dart';
import '../../domain/entities/cover_change.dart';
import '../models/album_cover_model.dart';
import '../models/cover_change_model.dart';
import '../models/cover_target_model.dart';
import '../models/folder_covers_model.dart';


abstract class CoversRemoteDataSource {
  Future<List<CoverTargetModel>> getCoverTargets(String fileId);
  Future<List<FolderCoversModel>> applyCoverChanges(String fileId, List<CoverChange> changes);
  Future<List<AlbumCover>> getAlbumCovers(String folderId);
  Future<List<AlbumCover>> setAlbumCovers(String folderId, List<String> orderedFileIds);
}


class CoversRemoteDataSourceImpl implements CoversRemoteDataSource {

  final http.Client client;
  final String baseUrl;

  CoversRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<List<CoverTargetModel>> getCoverTargets(String fileId) {
    return _send(
      () => client.get(Uri.parse('$baseUrl/api/file/$fileId/cover-targets/'), headers: HttpHeadersUtil.getJsonHeaders()),
      (body) => (body as List<dynamic>)
          .map((json) => CoverTargetModel.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<List<FolderCoversModel>> applyCoverChanges(String fileId, List<CoverChange> changes) {
    return _send(
      () => client.put(
        Uri.parse('$baseUrl/api/folder/cover/batch/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'fileId': fileId, 'changes': changes.map(CoverChangeModel.toJson).toList()}),
      ),
      (body) => ((body as Map<String, dynamic>)['folders'] as List<dynamic>? ?? const [])
          .map((json) => FolderCoversModel.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<List<AlbumCover>> getAlbumCovers(String folderId) {
    return _send(
      () => client.get(Uri.parse('$baseUrl/api/folder/$folderId/covers/'), headers: HttpHeadersUtil.getJsonHeaders()),
      (body) => AlbumCoverModel.listFromJson((body as Map<String, dynamic>)['covers']),
    );
  }

  @override
  Future<List<AlbumCover>> setAlbumCovers(String folderId, List<String> orderedFileIds) {
    return _send(
      () => client.put(
        Uri.parse('$baseUrl/api/folder/$folderId/covers/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'fileIds': orderedFileIds}),
      ),
      (body) => AlbumCoverModel.listFromJson((body as Map<String, dynamic>)['covers']),
    );
  }

  /// Sends the request and parses a 200 body, or throws [ApiException].
  Future<T> _send<T>(Future<http.Response> Function() request, T Function(Object? body) parse) async {
    try {
      final response = await request();

      if (response.statusCode == 200) {
        return parse(jsonDecode(response.body));
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
