import 'package:photo_manager_app/features/sync_session/domain/entities/sync_session.dart';


class SyncSessionModel extends SyncSession {

  SyncSessionModel({
    required super.id,
    super.lastCompletedAt,
  });

  factory SyncSessionModel.fromJson(Map<String, dynamic> json) {
    return SyncSessionModel(
      id: json['sessionId'].toString(),
      lastCompletedAt: json['lastSyncCompletedAt'] != null
        ? DateTime.parse(json['lastSyncCompletedAt'] as String)
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': id,
      'lastSyncCompletedAt': lastCompletedAt?.toIso8601String(),
    };
  }

  factory SyncSessionModel.fromEntity(SyncSession session) {
    return SyncSessionModel(
      id: session.id,
      lastCompletedAt: session.lastCompletedAt,
    );
  }
}