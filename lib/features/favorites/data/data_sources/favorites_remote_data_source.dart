import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/favorites/data/models/favorite_result_model.dart';


abstract class FavoritesRemoteDataSource {
  Future<FavoriteResultModel> setFavorite(List<String> fileIds, bool favorite);
}


class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {

  final http.Client client;
  final String baseUrl;

  FavoritesRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<FavoriteResultModel> setFavorite(List<String> fileIds, bool favorite) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/file/favorite/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({'fileIds': fileIds, 'favorite': favorite}),
      );

      if (response.statusCode == 200) {
        return FavoriteResultModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
