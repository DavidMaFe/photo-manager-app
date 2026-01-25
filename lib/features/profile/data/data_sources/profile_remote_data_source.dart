import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/profile/data/models/user_profile_model.dart';


abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateUserProfile({
    String? name,
    String? surname,
    String? profileImage,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}


class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {

  final http.Client client;
  final AuthLocalDataSource authLocalDataSource;
  final String baseUrl;

  ProfileRemoteDataSourceImpl({
    required this.client,
    required this.authLocalDataSource,
    this.baseUrl = 'http://10.0.2.2:8080'
  });

  @override
  Future<UserProfileModel> getUserProfile() async {

    final token = await authLocalDataSource.getToken();
    final response = await client.get(
      Uri.parse('$baseUrl/api/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserProfileModel.fromJson(jsonData);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid or expired token');
    } else {
      throw Exception('Error when trying to get the user profile');
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile({
    String? name,
    String? surname,
    String? profileImage,
  }) async {
    final token = await authLocalDataSource.getToken();

    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (surname != null) body['surname'] = surname;
    if (profileImage != null) body['profileImage'] = profileImage;

    final response = await client.put(
      Uri.parse('$baseUrl/api/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserProfileModel.fromJson(jsonData);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid or expired token');
    } else if (response.statusCode == 400) {
      throw Exception('Invalid profile data');
    } else {
      throw Exception('Error when trying to update the user profile');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await authLocalDataSource.getToken();

    final response = await client.post(
      Uri.parse('$baseUrl/api/password-change/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Invalid or expired token');
    } else if (response.statusCode == 400) {
      throw Exception('Invalid current password');
    } else {
      throw Exception('Error when trying to change password');
    }
  }
}
