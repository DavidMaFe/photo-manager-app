import 'package:photo_manager_app/features/two_factor/domain/entities/two_factor_status.dart';

class TwoFactorStatusModel extends TwoFactorStatus {
  const TwoFactorStatusModel({required super.totpEnabled, required super.backupCodesLeft});

  factory TwoFactorStatusModel.fromJson(Map<String, dynamic> json) => TwoFactorStatusModel(
        totpEnabled: json['totpEnabled'] as bool,
        backupCodesLeft: (json['backupCodesLeft'] as num).toInt(),
      );
}
