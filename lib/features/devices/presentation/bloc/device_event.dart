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

  UnlinkDevice({required this.deviceId});
}
