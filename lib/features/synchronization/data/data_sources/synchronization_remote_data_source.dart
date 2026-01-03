import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/features/synchronization/data/models/synchronization_model.dart';

import '../../../../core/errors/base/failure_codes.dart';
import '../../../auth/data/data_sources/auth_local_data_source.dart';


class SynchronizationsListResponse {

  final List<SynchronizationModel> syncSessions;
  final bool hasNext;

  const SynchronizationsListResponse({
    required this.syncSessions,
    required this.hasNext
  });
}


abstract class SynchronizationRemoteDataSource {
  Future<SynchronizationsListResponse> getSynchronizations({
    required String deviceUuid,
    required int page,
    required int pageSize
  });
}


class SynchronizationRemoteDataSourceImpl implements SynchronizationRemoteDataSource {

  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl;

  SynchronizationRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
    this.baseUrl = DataConstants.backendBaseUrl
  });

  @override
  Future<SynchronizationsListResponse> getSynchronizations({
    required String deviceUuid,
    required int page,
    required int pageSize
  }) async{

    try {

      final uri = Uri.parse('$baseUrl/api/sync_session/list/').replace(queryParameters: {
        'deviceUuid': deviceUuid, 'page': page.toString(), 'pageSize': pageSize.toString()
      });

      String? token = await authLocalDataSource.getToken();
      final response = await client.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          }
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final sessionsJson = jsonData['syncSessions'] as List<dynamic>;
        final sessions = sessionsJson.map((json) => SynchronizationModel.fromJson(json as Map<String, dynamic>)).toList();
        final hasNext = jsonData['hasNext'] as bool;

        return SynchronizationsListResponse(syncSessions: sessions, hasNext: hasNext);
      } else {
        throw HttpException(jsonDecode(response.body)["message"]);
      }

    } catch(e) {
      if (e is HttpException) rethrow;
      throw Exception(FailureCodes.unknownErrorCode);
    }

  }
}