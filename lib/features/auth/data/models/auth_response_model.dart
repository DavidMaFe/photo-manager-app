
import 'package:photo_manager_app/core/crypto/data/models/key_version_model.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';

/// Login and register response. [keys] are the user's master key versions, wrapped (docs/e2ee-spec.md, section 12).
/// [legalAcceptanceRequired]: the user has not accepted the terms of use and the privacy policy in force.
class AuthResponseModel {

  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final UserModel user;
  final AccountKeys? keys;
  final bool legalAcceptanceRequired;

  AuthResponseModel({
    required this.token,
    this.refreshToken,
    this.expiresAt,
    required this.user,
    this.keys,
    this.legalAcceptanceRequired = false,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {

    final token = json['token'] as String;
    final refreshToken = json['refreshToken'] as String?;
    final expiresAt = json['expiresAt'] == null
        ? null
        : DateTime.parse(json['expiresAt'] as String);

    final user = UserModel(
        id: json['id'].toString(),
        email: json['email'] as String,
        name: json['name'] as String,
        surname: json['surname'] == null ? null : json['surname'] as String
    );

    return AuthResponseModel(
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      user: user,
      keys: json['keys'] == null ? null : AccountKeysModel.fromJson(json['keys'] as Map<String, dynamic>),
      legalAcceptanceRequired: json['legalAcceptanceRequired'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'token': token,
      'user': user.toJson(),
    };

    if (refreshToken != null) {
      json['refreshToken'] = refreshToken!;
    }

    if (expiresAt != null) {
      json['expiresAt'] = expiresAt!.toIso8601String();
    }

    return json;
  }
}