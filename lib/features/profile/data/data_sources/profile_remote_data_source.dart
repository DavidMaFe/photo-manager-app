import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/profile/data/models/user_profile_model.dart';


abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
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
}
