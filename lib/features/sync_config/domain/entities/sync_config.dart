import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/battery_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/network_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';

class SyncConfig extends Equatable {
  final bool autoSyncEnabled;
  final SyncFrequency syncFrequency;
  final int syncHour; // 0-23
  final int syncMinute; // 0-59
  final int? syncDayOfWeek; // 1-7 (Monday-Sunday), null for daily
  final NetworkPreference networkPreference;
  final BatteryPreference batteryPreference;
  final bool notifyOnSuccess;
  final bool notifyOnFailure;

  const SyncConfig({
    required this.autoSyncEnabled,
    required this.syncFrequency,
    required this.syncHour,
    required this.syncMinute,
    this.syncDayOfWeek,
    required this.networkPreference,
    required this.batteryPreference,
    required this.notifyOnSuccess,
    required this.notifyOnFailure,
  });

  /// Default configuration: auto-sync disabled
  factory SyncConfig.disabled() {
    return const SyncConfig(
      autoSyncEnabled: false,
      syncFrequency: SyncFrequency.daily,
      syncHour: 2, // 2:00 AM
      syncMinute: 0,
      syncDayOfWeek: null,
      networkPreference: NetworkPreference.wifiOnly,
      batteryPreference: BatteryPreference.chargingOrAbove15Percent,
      notifyOnSuccess: false,
      notifyOnFailure: true,
    );
  }

  /// Default configuration: auto-sync enabled with sensible defaults
  factory SyncConfig.defaultEnabled() {
    return const SyncConfig(
      autoSyncEnabled: true,
      syncFrequency: SyncFrequency.daily,
      syncHour: 2, // 2:00 AM
      syncMinute: 0,
      syncDayOfWeek: null,
      networkPreference: NetworkPreference.wifiOnly,
      batteryPreference: BatteryPreference.chargingOrAbove15Percent,
      notifyOnSuccess: false,
      notifyOnFailure: true,
    );
  }

  TimeOfDay get syncTime => TimeOfDay(hour: syncHour, minute: syncMinute);

  bool get isDailySync => syncFrequency.isDaily;
  bool get isWeeklySync => syncFrequency.isWeekly;
  bool get requiresWifiOnly => networkPreference.isWifiOnly;
  bool get requiresBatteryCondition => batteryPreference.isChargingOrAbove15Percent;

  SyncConfig copyWith({
    bool? autoSyncEnabled,
    SyncFrequency? syncFrequency,
    int? syncHour,
    int? syncMinute,
    int? syncDayOfWeek,
    bool clearDayOfWeek = false,
    NetworkPreference? networkPreference,
    BatteryPreference? batteryPreference,
    bool? notifyOnSuccess,
    bool? notifyOnFailure,
  }) {
    return SyncConfig(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncFrequency: syncFrequency ?? this.syncFrequency,
      syncHour: syncHour ?? this.syncHour,
      syncMinute: syncMinute ?? this.syncMinute,
      syncDayOfWeek: clearDayOfWeek ? null : (syncDayOfWeek ?? this.syncDayOfWeek),
      networkPreference: networkPreference ?? this.networkPreference,
      batteryPreference: batteryPreference ?? this.batteryPreference,
      notifyOnSuccess: notifyOnSuccess ?? this.notifyOnSuccess,
      notifyOnFailure: notifyOnFailure ?? this.notifyOnFailure,
    );
  }

  @override
  List<Object?> get props => [
        autoSyncEnabled,
        syncFrequency,
        syncHour,
        syncMinute,
        syncDayOfWeek,
        networkPreference,
        batteryPreference,
        notifyOnSuccess,
        notifyOnFailure,
      ];
}
