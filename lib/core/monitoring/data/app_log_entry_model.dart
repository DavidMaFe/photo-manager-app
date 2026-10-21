import 'package:photo_manager_app/core/monitoring/data/device_context.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';

/// [AppLogEntry] as it is kept in the queue and sent to the backend.
class AppLogEntryModel extends AppLogEntry {
  const AppLogEntryModel({
    required super.level,
    required super.event,
    required super.occurredAt,
    super.message,
    super.errorType,
    super.stackTrace,
    super.screen,
    super.requestId,
  });

  factory AppLogEntryModel.fromEntity(AppLogEntry entry) => AppLogEntryModel(
        level: entry.level,
        event: entry.event,
        occurredAt: entry.occurredAt,
        message: entry.message,
        errorType: entry.errorType,
        stackTrace: entry.stackTrace,
        screen: entry.screen,
        requestId: entry.requestId,
      );

  factory AppLogEntryModel.fromJson(Map<String, dynamic> json) => AppLogEntryModel(
        level: AppLogLevel.values.byName(json['level'] as String),
        event: json['event'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String),
        message: json['message'] as String?,
        errorType: json['errorType'] as String?,
        stackTrace: json['stackTrace'] as String?,
        screen: json['screen'] as String?,
        requestId: json['requestId'] as String?,
      );

  /// As it is kept in the queue.
  Map<String, dynamic> toJson() => {
        'level': level.name,
        'event': event,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
        if (message != null) 'message': message,
        if (errorType != null) 'errorType': errorType,
        if (stackTrace != null) 'stackTrace': stackTrace,
        if (screen != null) 'screen': screen,
        if (requestId != null) 'requestId': requestId,
      };

  /// As the backend takes it (ClientLogEntryDTO): with the device and the version.
  Map<String, dynamic> toRequestJson(DeviceContext device) => {
        ...toJson(),
        'level': level.name.toUpperCase(),
        'appVersion': device.appVersion,
        'build': device.build,
        'platform': device.platform,
        'osVersion': device.osVersion,
        'deviceModel': device.deviceModel,
      };
}
