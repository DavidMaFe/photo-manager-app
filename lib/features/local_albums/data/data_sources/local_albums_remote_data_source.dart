import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/local_albums/data/models/local_album_model.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album_registration.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

/// The albums of the gallery of a device on the server (ROADMAP-local-albums.md). The client adds the token.
abstract class LocalAlbumsRemoteDataSource {
  /// GET /api/device/{deviceUuid}/albums/
  Future<List<LocalAlbumModel>> getAlbums(String deviceUuid);

  /// PUT /api/device/{deviceUuid}/albums/
  Future<List<LocalAlbumModel>> register(String deviceUuid, List<LocalAlbumRegistration> albums);

  /// PUT /api/device/{deviceUuid}/albums/modes/
  Future<List<LocalAlbumModel>> setModes(String deviceUuid, Map<String, LocalAlbumMode> modes);
}

class LocalAlbumsRemoteDataSourceImpl implements LocalAlbumsRemoteDataSource {
  /// The server takes at most 1000 albums per request.
  static const int maxAlbumsPerRequest = 1000;
  static const Duration _timeout = Duration(minutes: 1);

  final http.Client client;
  final String baseUrl;

  LocalAlbumsRemoteDataSourceImpl({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  @override
  Future<List<LocalAlbumModel>> getAlbums(String deviceUuid) async {
    final response = await _send(() => client.get(_albums(deviceUuid)));
    return _parse(response);
  }

  @override
  Future<List<LocalAlbumModel>> register(String deviceUuid, List<LocalAlbumRegistration> albums) async {
    final result = <LocalAlbumModel>[];
    for (var start = 0; start == 0 || start < albums.length; start += maxAlbumsPerRequest) {
      final chunk = albums.sublist(start, (start + maxAlbumsPerRequest).clamp(0, albums.length));
      final response = await _send(() => client.put(
            _albums(deviceUuid),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: jsonEncode({'albums': chunk.map(LocalAlbumModel.registrationToJson).toList()}),
          ));
      result.addAll(_parse(response));
    }
    return result;
  }

  @override
  Future<List<LocalAlbumModel>> setModes(String deviceUuid, Map<String, LocalAlbumMode> modes) async {
    final response = await _send(() => client.put(
          Uri.parse('$baseUrl/api/device/${Uri.encodeComponent(deviceUuid)}/albums/modes/'),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'},
          body: jsonEncode({
            'modes': [
              for (final entry in modes.entries) {'localAlbumId': entry.key, 'mode': entry.value.code},
            ],
          }),
        ));
    return _parse(response);
  }

  Uri _albums(String deviceUuid) => Uri.parse('$baseUrl/api/device/${Uri.encodeComponent(deviceUuid)}/albums/');

  List<LocalAlbumModel> _parse(http.Response response) {
    _check(response, 200);
    final albums = (jsonDecode(response.body) as Map<String, dynamic>)['albums'] as List<dynamic>;
    return [for (final json in albums) LocalAlbumModel.fromJson(json as Map<String, dynamic>)];
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
