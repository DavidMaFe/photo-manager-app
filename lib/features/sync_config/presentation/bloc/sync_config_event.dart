import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/battery_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/network_preference.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/sync_frequency.dart';

abstract class SyncConfigEvent {}

/// Load the current sync configuration
class LoadSyncConfig extends SyncConfigEvent {}

/// Save the complete sync configuration
class SaveSyncConfig extends SyncConfigEvent {}

/// Toggle auto-sync on/off
class ToggleAutoSync extends SyncConfigEvent {
  final bool enabled;

  ToggleAutoSync(this.enabled);
}

/// Update sync frequency (daily/weekly)
class UpdateSyncFrequency extends SyncConfigEvent {
  final SyncFrequency frequency;

  UpdateSyncFrequency(this.frequency);
}

/// Update sync time (hour and minute)
class UpdateSyncTime extends SyncConfigEvent {
  final TimeOfDay time;

  UpdateSyncTime(this.time);
}

/// Update day of week for weekly sync (1-7, Monday-Sunday)
class UpdateSyncDayOfWeek extends SyncConfigEvent {
  final int dayOfWeek;

  UpdateSyncDayOfWeek(this.dayOfWeek);
}

/// Update network preference (WiFi-only or any network)
class UpdateNetworkPreference extends SyncConfigEvent {
  final NetworkPreference preference;

  UpdateNetworkPreference(this.preference);
}

/// Update battery preference (any or charging/15%+)
class UpdateBatteryPreference extends SyncConfigEvent {
  final BatteryPreference preference;

  UpdateBatteryPreference(this.preference);
}

/// Toggle notify on success
class ToggleNotifyOnSuccess extends SyncConfigEvent {
  final bool enabled;

  ToggleNotifyOnSuccess(this.enabled);
}

/// Toggle notify on failure
class ToggleNotifyOnFailure extends SyncConfigEvent {
  final bool enabled;

  ToggleNotifyOnFailure(this.enabled);
}
