import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';

class AccountDeletionSummaryModel extends AccountDeletionSummary {
  const AccountDeletionSummaryModel({
    required super.files,
    required super.storedBytes,
    required super.albums,
    required super.devices,
  });

  factory AccountDeletionSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountDeletionSummaryModel(
      files: (json['files'] as num?)?.toInt() ?? 0,
      storedBytes: (json['storedBytes'] as num?)?.toInt() ?? 0,
      albums: (json['albums'] as num?)?.toInt() ?? 0,
      devices: (json['devices'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'files': files, 'storedBytes': storedBytes, 'albums': albums, 'devices': devices};
}
