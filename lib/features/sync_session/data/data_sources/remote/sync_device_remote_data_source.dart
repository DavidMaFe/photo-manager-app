import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_device_model.dart';

import '../../../../../core/errors/base/failure_codes.dart';


abstract class SyncDeviceRemoteDataSource {
  Future<SyncDeviceModel> registerDevice({
    required String uuid,
    required String name,
    required String model,
    required String osType,
    required String osVersion,
    required String appVersion,
    String? pushToken
  });
}


class SyncDeviceRemoteDataSourceImpl implements SyncDeviceRemoteDataSource {

  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl;

  SyncDeviceRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
    this.baseUrl = DataConstants.backendBaseUrl,
  });

  Future<Map<String, String>> _headers() async {
    String? token = await authLocalDataSource.getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token!}'
    };
  }

  @override
  Future<SyncDeviceModel> registerDevice({
    required String uuid,
    required String name,
    required String model,
    required String osType,
    required String osVersion,
    required String appVersion,
    String? pushToken
  }) async {

    try {

      final requestBody = {
        'uuid': uuid,
        'name': name,
        'model': model,
        'osType': osType,
        'osVersion': osVersion,
        'appVersion': appVersion,
        if (pushToken != null && pushToken.isNotEmpty) 'pushToken': pushToken
      };

      Map<String, String> headers = await _headers();
      
      final response = await client.post(
        Uri.parse('$baseUrl/api/device/register/'),
        headers: headers,
        body: jsonEncode(requestBody)
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final deviceId = SyncDeviceModel.parseDeviceIdFromJson(json);
        final userId = _getUserIdFromToken();

        return SyncDeviceModel.fromRegistrationResponse(
          id: deviceId,
          uuid: uuid,
          name: name,
          model: model,
          osType: osType,
          osVersion: osVersion,
          appVersion: appVersion,
          userId: userId
        );
      } else {
        throw Exception(jsonDecode(response.body)["code"]);
      }
      
    } catch (e) {
      throw Exception(FailureCodes.unknownErrorCode);
    }
  }

  String _getUserIdFromToken() {
    return ''; // TODO: Implementar
  }
}