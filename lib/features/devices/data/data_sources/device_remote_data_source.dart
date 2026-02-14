import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/devices/data/models/device_model.dart';

import '../../../../config/data_constants.dart';

abstract class DeviceRemoteDataSource {
  Future<List<DeviceModel>> getUserDevices();

  Future<void> renameDevice({
    required String deviceId,
    required String newName,
  });

  Future<void> toggleAutoSync({
    required String deviceId,
    required bool enabled,
  });

  Future<void> unlinkDevice({required String deviceId});
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  DeviceRemoteDataSourceImpl({
    required this.client,
    this.baseUrl = DataConstants.backendBaseUrl,
  });

  @override
  Future<List<DeviceModel>> getUserDevices() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/api/device/list/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> jsonList = jsonResponse['devices'];
        return jsonList.map((json) => DeviceModel.fromJson(json)).toList();
      } else {
        final errorResponse =
            ErrorResponseModel.fromJson(jsonDecode(response.body));
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
  Future<void> renameDevice({
    required String deviceId,
    required String newName,
  }) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/api/device/rename/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({
          'deviceId': deviceId,
          'newName': newName,
        }),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        final errorResponse =
            ErrorResponseModel.fromJson(jsonDecode(response.body));
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
  Future<void> toggleAutoSync({
    required String deviceId,
    required bool enabled,
  }) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/api/device/auto-sync/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
        body: jsonEncode({
          'deviceId': deviceId,
          'enabled': enabled,
        }),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        final errorResponse =
            ErrorResponseModel.fromJson(jsonDecode(response.body));
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
  Future<void> unlinkDevice({required String deviceId}) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/api/device/unlink/$deviceId/'),
        headers: HttpHeadersUtil.getJsonHeaders(),
      );

      if (response.statusCode == 200) {
        return;
      } else {
        final errorResponse =
            ErrorResponseModel.fromJson(jsonDecode(response.body));
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
