import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/battery_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/network_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';

class SyncConfigModel extends SyncConfig {
  const SyncConfigModel({
    required super.autoSyncEnabled,
    required super.syncFrequency,
    required super.syncHour,
    required super.syncMinute,
    super.syncDayOfWeek,
    required super.networkPreference,
    required super.batteryPreference,
    required super.notifyOnSuccess,
    required super.notifyOnFailure,
  });

  factory SyncConfigModel.fromJson(Map<String, dynamic> json) {
    return SyncConfigModel(
      autoSyncEnabled: json['autoSyncEnabled'] as bool,
      syncFrequency: SyncFrequency.fromJson(json['syncFrequency'] as String),
      syncHour: json['syncHour'] as int,
      syncMinute: json['syncMinute'] as int,
      syncDayOfWeek: json['syncDayOfWeek'] as int?,
      networkPreference: NetworkPreference.fromJson(json['networkPreference'] as String),
      batteryPreference: BatteryPreference.fromJson(json['batteryPreference'] as String),
      notifyOnSuccess: json['notifyOnSuccess'] as bool,
      notifyOnFailure: json['notifyOnFailure'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoSyncEnabled': autoSyncEnabled,
      'syncFrequency': syncFrequency.toJson(),
      'syncHour': syncHour,
      'syncMinute': syncMinute,
      'syncDayOfWeek': syncDayOfWeek,
      'networkPreference': networkPreference.toJson(),
      'batteryPreference': batteryPreference.toJson(),
      'notifyOnSuccess': notifyOnSuccess,
      'notifyOnFailure': notifyOnFailure,
    };
  }

  factory SyncConfigModel.fromEntity(SyncConfig config) {
    return SyncConfigModel(
      autoSyncEnabled: config.autoSyncEnabled,
      syncFrequency: config.syncFrequency,
      syncHour: config.syncHour,
      syncMinute: config.syncMinute,
      syncDayOfWeek: config.syncDayOfWeek,
      networkPreference: config.networkPreference,
      batteryPreference: config.batteryPreference,
      notifyOnSuccess: config.notifyOnSuccess,
      notifyOnFailure: config.notifyOnFailure,
    );
  }
}
