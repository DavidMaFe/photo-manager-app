abstract class DeviceEvent {}

class LoadDevices extends DeviceEvent {}

class RefreshDevices extends DeviceEvent {}

class RenameDevice extends DeviceEvent {
  final String deviceId;
  final String newName;

  RenameDevice({
    required this.deviceId,
    required this.newName,
  });
}

class ToggleAutoSync extends DeviceEvent {
  final String deviceId;
  final bool enabled;

  ToggleAutoSync({
    required this.deviceId,
    required this.enabled,
  });
}

class UnlinkDevice extends DeviceEvent {
  final String deviceId;

  /// The device the app runs on: unlinking it closes the session here.
  final bool isCurrentDevice;

  UnlinkDevice({required this.deviceId, this.isCurrentDevice = false});
}
