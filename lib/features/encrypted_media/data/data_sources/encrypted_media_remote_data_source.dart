import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/encrypted_media/data/models/encrypted_file_ref_model.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_range.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';

/// Downloads the encrypted objects of the files and their keys. The client adds the token.
abstract class EncryptedMediaRemoteDataSource {
  Future<Uint8List> getObject(String fileId, MediaVariant variant);

  /// Bytes [start]..[end] of the original (Range request, answered with 206).
  Future<EncryptedRange> getOriginalRange(String fileId, int start, int end);

  /// POST /api/file/keys/ with at most 200 ids. Files without a key are left out.
  Future<List<EncryptedFileRef>> getFileKeys(List<String> fileIds);
}

class EncryptedMediaRemoteDataSourceImpl implements EncryptedMediaRemoteDataSource {
  static const int maxIdsPerRequest = 200;
  static const Duration _timeout = Duration(minutes: 2);

  final http.Client client;
  final String baseUrl;

  EncryptedMediaRemoteDataSourceImpl({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  @override
  Future<Uint8List> getObject(String fileId, MediaVariant variant) async {
    final suffix = variant == MediaVariant.thumbnail ? 'thumbnail/' : '';
    final response = await _send(() => client.get(Uri.parse('$baseUrl/api/file/$fileId/$suffix')));
    _check(response, 200);
    return response.bodyBytes;
  }

  @override
  Future<EncryptedRange> getOriginalRange(String fileId, int start, int end) async {
    final response = await _send(() => client.get(Uri.parse('$baseUrl/api/file/$fileId/'),
        headers: {HttpHeaders.rangeHeader: 'bytes=$start-$end'}));
    _check(response, 206);
    final total = RegExp(r'/(\d+)$').firstMatch(response.headers[HttpHeaders.contentRangeHeader] ?? '');
    if (total == null) {
      throw const FormatException('Missing Content-Range in a partial response');
    }
    return EncryptedRange(bytes: response.bodyBytes, totalLength: int.parse(total.group(1)!));
  }

  @override
  Future<List<EncryptedFileRef>> getFileKeys(List<String> fileIds) async {
    final response = await _send(() => client.post(
          Uri.parse('$baseUrl/api/file/keys/'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: jsonEncode({'fileIds': fileIds.map(int.parse).toList()}),
        ));
    _check(response, 200);
    final files = (jsonDecode(response.body) as Map<String, dynamic>)['files'] as List<dynamic>;
    return [
      for (final json in files)
        if (EncryptedFileRefModel.fromJson(json as Map<String, dynamic>, idField: 'fileId') case final ref?) ref,
    ];
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
