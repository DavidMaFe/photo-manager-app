import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';

class TotpSetUpModel extends TotpSetUp {
  const TotpSetUpModel({required super.secret, required super.otpauthUri});

  factory TotpSetUpModel.fromJson(Map<String, dynamic> json) => TotpSetUpModel(
        secret: json['secret'] as String,
        otpauthUri: json['otpauthUri'] as String,
      );
}
